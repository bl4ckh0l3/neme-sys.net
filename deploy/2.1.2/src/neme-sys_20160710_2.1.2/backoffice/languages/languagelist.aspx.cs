using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _LanguageList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected string cssClass;	
	protected IList<Language> languages;
	protected IList<string> languagesKey;
	protected IList<AvailableLanguage> availableLangs;
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
		cssClass="IL";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
	
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		IUserRepository urep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();
		bool carryOn = true;

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["languageItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["languageItems"];
		}else{
			if (Session["languageItems"] != null) {
				itemsXpage = (int)Session["languageItems"];
			}else{
				Session["languageItems"] = 20;
				itemsXpage = (int)Session["languageItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["languagePage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["languagePage"];
		}else{
			if (Session["languagePage"] != null) {
				numPage = (int)Session["languagePage"];
			}else{
				Session["languagePage"]= 1;
				numPage = (int)Session["languagePage"];
			}
		}

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		long totalcount=0L;
		try
		{
			languages = langrep.find(numPage, itemsXpage, out totalcount);
			availableLangs = langrep.getAvailableLanguageList();
			if(languages != null)
			{
				languagesKey = new List<string>();
				foreach (Language k in languages)
				{
					languagesKey.Add(k.label);
				}
				
				bolFoundLista = true;			
				
				//ArrayList.Adapter((IList)languages).Sort();					
				//Response.Write("type:"+availableLangs.GetType());
				//IList avlanglist = new ArrayList();
				//foreach (AvailableLanguage q in availableLangs)
				//{
					//Response.Write("<br>q.ToString BEFORE: "+q.ToString());
					//q.description = lang.getTranslated("backend.lingue.lista.table.lang_label."+q.description);
					//avlanglist.Add(q);
					//Response.Write("<br>q.ToString AFTER: "+q.ToString());
				//}
				
				//try{
				//ArrayList.Adapter((IList)availableLangs).Sort();					
				 //ArrayList.Adapter((IList)availableLangs).Sort(delegate(AvailableLanguage x, AvailableLanguage y){
					//return x.description.CompareTo(y.description);});
				
				//}catch(Exception exc){Response.Write("An error occured: " + exc.Message+"<br><br><br>"+exc.StackTrace);}					
			}	    	
		}
		catch (Exception ex)
		{
			languages = new List<Language>();
			availableLangs = new List<AvailableLanguage>();
			bolFoundLista = false;
		}

		//********** ESEGUO OPERARIONI CRUD SULLA LINGUA
		// CASO INSERT NEW LANG
		string operation = Request["operation"];
		if("insert"==operation)
		{
			carryOn = true;
			try{						
				string label = Request["label"];
				string description = Request["description"];
				bool set_to_users = Convert.ToBoolean(Convert.ToInt32(Request["set_to_users"]));		
				bool lang_active = Convert.ToBoolean(Convert.ToInt32(Request["lang_active"]));
				bool subdomain_active = Convert.ToBoolean(Convert.ToInt32(Request["subdomain_active"]));
				string url_subdomain = Request["url_subdomain"];
				
				Language mylang = new Language();
				mylang.id=-1;
				mylang.label = label;
				mylang.description = description;
				mylang.langActive = lang_active;
				mylang.subdomainActive = subdomain_active;
				mylang.urlSubdomain = url_subdomain;	
	
				// GESTISCO IL CASO DI INSERIMENTO ANCHE PER GLI UTENTI
				IList<User> usersToUpdate = new List<User>(); 
				if(set_to_users)
				{						
					IList<User> users = urep.find(false,false,true,false,false,false);
					if(users!= null)
					{
						foreach(User usr in users)
						{
							UserLanguage ul = new UserLanguage(); 
							ul.idLanguage = mylang.id;
							ul.idParentUser = usr.id;
							usr.languages.Add(ul);
							usersToUpdate.Add(usr);				
						}
					}
				}		
				
				langrep.saveCompleteLanguage(mylang, usersToUpdate);
				
				log.usr= login.userLogged.username;
				log.msg = "save language: "+mylang.ToString();
				log.type = "info";
				log.date = DateTime.Now;
				lrep.write(log);				
			}catch(Exception ex){
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));	
				carryOn = false;
			}			
			
			if(carryOn){
				Response.Redirect(Request.Url.AbsolutePath+"?cssClass="+Request["cssClass"]+"&items="+itemsXpage+"&page="+numPage);
			}else{
				Response.Redirect(url.ToString());
			}	
		}
		else if("delete"==operation)
		{
			carryOn = true;
			try{
				Language dellang = langrep.getById(Convert.ToInt32(Request["id"]));
				langrep.delete(dellang);
				
				log.usr= login.userLogged.username;
				log.msg = "delete language: "+dellang.ToString();
				log.type = "info";
				log.date = DateTime.Now;
				lrep.write(log);
			}catch(Exception ex){
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));	
				carryOn = false;
			}			
			
			if(carryOn){
				Response.Redirect(Request.Url.AbsolutePath+"?cssClass="+Request["cssClass"]+"&items="+itemsXpage+"&page="+numPage);
			}else{
				Response.Redirect(url.ToString());
			}	
		}

	
		_totalPages = (int)totalcount/itemsXpage;
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(totalcount % itemsXpage != 0 &&  (_totalPages * itemsXpage) < totalcount) {
			_totalPages = _totalPages +1;	
		}	
			
		this.pg1.totalPages = this.totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPage;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "items="+itemsXpage+"&cssClass="+cssClass;	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPage;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = "items="+itemsXpage+"&cssClass="+cssClass;		
	}
}