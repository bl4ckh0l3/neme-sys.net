using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections.Generic;

public partial class _MultiLanguageList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected int itemsXpage, numPage;
	protected string cssClass, search_key;	
	protected bool bolFoundLista = false;	
	public IDictionary<string, MultiLanguage> multilanguages;
	protected IList<Language> languages;
	protected IList<string> distKeys;
	private int _totalPages;	
	public int totalPages {
		get { return _totalPages; }
	}
	
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
	    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
	}

	protected void Page_Load(Object sender, EventArgs e)
	{
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;	
		cssClass="IML";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
	
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		IMultiLanguageRepository mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["multilanguageItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["multilanguageItems"];
			//Session["multilanguageItems"] = 1;
		}else{
			if (Session["multilanguageItems"] != null) {
				itemsXpage = (int)Session["multilanguageItems"];
			}else{
				Session["multilanguageItems"] = 20;
				itemsXpage = (int)Session["multilanguageItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["multilanguagePage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["multilanguagePage"];
		}else{
			if (Session["multilanguagePage"] != null) {
				numPage = (int)Session["multilanguagePage"];
			}else{
				Session["multilanguagePage"]= 1;
				numPage = (int)Session["multilanguagePage"];
			}
		}	

		if(!String.IsNullOrEmpty(Request["resetMenu"]) && Request["resetMenu"] == "1") 
		{
			Session["multilanguagePage"] = 1;
			numPage = (int)Session["multilanguagePage"];
			Session["search_key"] = "";
			search_key = (string)Session["search_key"];
		}

		if (!String.IsNullOrEmpty(Request["search_key"])) {
			//'** sostituisco: ������'
			//'** con: &egrave;&eacute;&agrave;&ograve;&ugrave;&igrave;&#39;
			string tmp_key = Request["search_key"].Trim();
			/*tmp_key = tmp_key.Replace("�", "&egrave;");
			tmp_key = tmp_key.Replace("�", "&eacute;");
			tmp_key = tmp_key.Replace("�", "&agrave;");
			tmp_key = tmp_key.Replace("�", "&ograve;");
			tmp_key = tmp_key.Replace("�", "&ugrave;");
			tmp_key = tmp_key.Replace("�", "&igrave;");
			tmp_key = tmp_key.Replace("'", "&#39;");*/
								
			Session["search_key"] = tmp_key;
			search_key = (string)Session["search_key"];
		}else{
			if (Session["search_key"] != "") {
				search_key = (string)Session["search_key"];
			}else{
				Session["search_key"] = "";
				search_key = (string)Session["search_key"];
			}
		}

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI
		bool isMultipleValueParam = Convert.ToBoolean(Convert.ToInt32(Request["is_multiple_selection"]));
		string multipleValuesListParam = Request["multiple_values"];
		string operationParam = Request["operation"];	
		int idParam = 0;
		if(!String.IsNullOrEmpty(Request["id"])){		
			idParam = Convert.ToInt32(Request["id"]);
		}
		string keywordParam = Request["keyword"];		
		//string pageRedirect = Application("baseroot")&"/backoffice/multilanguages/multilanguagelist.aspx?search_key="&search_key&"&items="&itemsXpage&"&page="&numPage
	
		long totalcount=0L;
		try
		{
			languages = langrep.getLanguageList();
			if(languages != null)
			{
				if(isMultipleValueParam)
				{
					if(operationParam=="delete")
					{
						IList<MultiLanguage> delOld = new List<MultiLanguage>();
	
						string[] p = multipleValuesListParam.Split('|');
						if(p!=null){
							foreach (string item in p){
								int Tmpid = Convert.ToInt32(item);
								MultiLanguage newInstance = new MultiLanguage();
								newInstance.id = Tmpid;
								delOld.Add(newInstance);			
							}
							
							mlangrep.delete(delOld);
						} 
	
					}
					else if(operationParam=="modify")
					{
						IList<MultiLanguage> updOld = new List<MultiLanguage>();
	
						string[] p = multipleValuesListParam.Split(new string[]{"###"}, StringSplitOptions.RemoveEmptyEntries);
						if(p!=null){
							foreach (string k in p){
								string[] values = k.Split(new string[]{"||"}, StringSplitOptions.RemoveEmptyEntries);
								if(values!=null){											
									foreach (Language l in languages)
									{
										string tmpkey = "";
										string tmpval = "";
										int Tmpid = 0;
										
										foreach (string j in values)
										{
											string testkey = j.Substring(0,j.IndexOf("="));
											//Response.Write("<b>testkey:</b>"+testkey+" - tmpval:"+j.Substring(j.IndexOf("=")+1)+"<br>");

											if("keyword"==testkey){
												tmpkey = j.Substring(j.IndexOf("=")+1);									
											}
											if("id_"+l.label==testkey){
												Tmpid = Convert.ToInt32(j.Substring(j.IndexOf("=")+1));
											}
											if("value_"+l.label==testkey){
												tmpval = j.Substring(j.IndexOf("=")+1);
											}
										}
										
										MultiLanguage newInstance = new MultiLanguage();
										newInstance.keyword = tmpkey;	
										newInstance.langCode = l.label;	
										newInstance.value = tmpval;
										newInstance.id = Tmpid;
										updOld.Add(newInstance);
										//Response.Write("<br>single modify operation:"+newInstance.ToString());										
									}								
								}		
							}
							
							mlangrep.update(updOld);
						} 
	
					}						
				}else
				{								
					if(operationParam=="insert")
					{
						IList<MultiLanguage> insNew = new List<MultiLanguage>();
						foreach (Language k in languages)
						{
							string srtTmpParam =  Request["value_"+k.label];
							MultiLanguage newInstance = new MultiLanguage();
							newInstance.keyword = keywordParam;	
							newInstance.langCode = k.label;	
							newInstance.value = srtTmpParam;
							insNew.Add(newInstance);
						}	
						mlangrep.insert(insNew);
					}		
					else if(operationParam=="delete")
					{
						IList<MultiLanguage> delOld = new List<MultiLanguage>();
						foreach (Language k in languages)
						{
							string srtTmpParam =  Request["value_"+k.label];
							int Tmpid = Convert.ToInt32(Request["klid_"+k.label]);
							MultiLanguage newInstance = new MultiLanguage();
							newInstance.keyword = keywordParam;	
							newInstance.langCode = k.label;	
							newInstance.value = srtTmpParam;
							newInstance.id = Tmpid;
							delOld.Add(newInstance);
						}	
						mlangrep.delete(delOld);
					}
					else if(operationParam=="update")
					{
						IList<MultiLanguage> updOld = new List<MultiLanguage>();
						foreach (Language k in languages)
						{
							string srtTmpParam =  Request["value_"+k.label];
							int Tmpid = Convert.ToInt32(Request["klid_"+k.label]);
							MultiLanguage newInstance = new MultiLanguage();
							newInstance.keyword = keywordParam;	
							newInstance.langCode = k.label;	
							newInstance.value = srtTmpParam;
							newInstance.id = Tmpid;
							updOld.Add(newInstance);
							//Response.Write("<br>single update operation:"+newInstance.ToString());
						}	
						mlangrep.update(updOld);						
					}			
				}

				multilanguages = mlangrep.find(search_key, numPage, itemsXpage, languages.Count, out distKeys, out totalcount);
				bolFoundLista = true;
			}	    	
		}
		catch (Exception ex)
		{
			multilanguages = new Dictionary<string, MultiLanguage>();
			distKeys = new List<string>();
			bolFoundLista = false;
		}
	
		_totalPages = (int)totalcount/itemsXpage;
		//Response.Write("totalcount:"+totalcount+" - logs.Count:"+logs.Count+" - items:"+itemsXpage+" - _totalPages before:"+_totalPages+"<br>");	
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(totalcount % itemsXpage != 0 &&  (_totalPages * itemsXpage) < totalcount) {
			_totalPages = _totalPages +1;	
		}		
		//Response.Write(" - _totalPages after:"+_totalPages+"<br>");	
		//Response.Write("numPage:"+numPage+" - paramType:"+paramType+" - paramDateFrom:"+paramDateFrom+" - paramDateTo:"+paramDateTo+"<br>");	
			
		this.pg1.totalPages = this.totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPage;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "items="+itemsXpage+"&cssClass="+cssClass+"&search_key="+(string)Session["search_key"];	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPage;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = "items="+itemsXpage+"&cssClass="+cssClass+"&search_key="+(string)Session["search_key"];	
	}
}