using System;
using System.Globalization;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using com.nemesys.model;
using com.nemesys.database.repository;
using com.nemesys.services;
using System.Collections;
using System.Collections.Generic;

public partial class _List : Page 
{
	protected ASP.MultiLanguageControl lang;
	protected ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected IContentRepository contentrep;
	protected ICountryRepository countryrep;
	protected bool bolFoundLista;
	protected bool bolHasDetailLink;
	protected IList<FContent> contents;
	protected IList<Geolocalization> points;
	protected int numPage, itemsXpage, orderBy, modelPageNum;
	protected int fromContent, toContent;
	protected IList<int> matchCategories = null;
	protected string status;
	protected string hierarchy;
	protected string categoryid;
	protected string detailURL = "#";
	protected string currentURL = "#";
	protected string tmpurl;
	protected bool bolHasFieldsFilter;
	protected bool bolHasSessionActive;
	protected bool bolHasFilterSearchActive;
	protected bool bolHasGeoSearchActive;
	protected string strParamPagFilter;
	protected IDictionary<string,string> objListPairKeyValue;

	protected Decimal prcsxVal;
	protected Decimal prcdxVal;
	protected Decimal supsxVal;
	protected Decimal supdxVal;
	protected Decimal locsxVal;
	protected Decimal locdxVal;
	protected string regprovsel;
	
	private int _totalCPages;	
	public int totalCPages {
		get { return _totalCPages; }
	}
	
	private string _pageTitle;	
	public string pageTitle {
		get { return _pageTitle; }
	}
	
	private string _metaDescription;	
	public string metaDescription {
		get { return _metaDescription; }
	}
	
	private string _metaKeyword;	
	public string metaKeyword {
		get { return _metaKeyword; }
	}
			
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
	}
		
	protected void Page_Load(object sender, EventArgs e) 
	{	
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;
		login.acceptedRoles = "";
		bool logged = login.checkedUser();
		contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
		countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");		
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		IGeolocalizationRepository georep = RepositoryFactory.getInstance<IGeolocalizationRepository>("IGeolocalizationRepository");
		confservice = new ConfigurationService();

		//se il sito � offline rimando a pagina default
		if ("1".Equals(confservice.get("go_offline").value)) 
		{
			UriBuilder defRedirect = new UriBuilder(Request.Url);
			defRedirect.Port = -1;	
			defRedirect.Path = "";			
			defRedirect.Query = "";
			Response.Redirect(defRedirect.ToString());
		}

		UriBuilder ubtmpurl = new UriBuilder(Request.Url);
		ubtmpurl.Port = -1;			
		ubtmpurl.Query = "";
		tmpurl = ubtmpurl.ToString();		
		tmpurl = tmpurl.Substring(0,tmpurl.LastIndexOf("/"));
				
		StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
		string basePath = Request.Path.ToLower();
		string newLangCode = "";

		bolFoundLista = false;
		bolHasDetailLink = false;
		bolHasFieldsFilter = false;
		bolHasSessionActive = false;
		bolHasFilterSearchActive = false;
		bolHasGeoSearchActive = false;
		strParamPagFilter="";
		objListPairKeyValue = new Dictionary<string,string>();
		
		Category category = null;
		Template template = null;	
		IList<int> matchLanguages = null;
		numPage = 1;
		status = "1";
		itemsXpage = 20;
		orderBy = 1;
		modelPageNum = 1;
		points = new List<Geolocalization>();
		
		if (!String.IsNullOrEmpty(Request["page"])) {
			numPage = Convert.ToInt32(Request["page"]);
		}
		if (!String.IsNullOrEmpty(Request["content_preview"])) {
			status = null;
		}

		
		if(Session["geolocalsearchpoly"] != null && Session["geolocalsearchpoly"].GetType().ToString().IndexOf("System.Collections.Generic.Dictionary")>=0){
			bolHasSessionActive = true;
		}
								
		//Response.Write("Request[fields_filter]:"+Request["fields_filter"]+"<br>");		
		
		try{		
			//****************** verifico se � stata fatta una ricerca dei field per contenuto e in tal caso recupero solo le news filtrate
			if(Request["fields_filter"]=="1"){
				if (!bolHasSessionActive){
					IDictionary<string,object> objGeolocalSearch = new Dictionary<string,object>();
					Session["geolocalsearchpoly"] = objGeolocalSearch;  
				}

				bolHasFilterSearchActive = true;
				((IDictionary<string,object>)Session["geolocalsearchpoly"])["fields_filter_active"] = "1";

				if (Request.Form.Count>0){      
					foreach(string y in Request.Form){
						if (y.StartsWith("field_")) {
							if(Request.Form[y].Trim()!="") {
								string tmpKey = y.Substring(y.IndexOf("field_")+6);//Mid(y,Instr(1, y, "__", 1)+2)
								string tmpValue = Request.Form[y];
								
								//Response.Write("tmpKey:"+tmpKey+" - tmpValue:"+tmpValue+"<br>");
								
								objListPairKeyValue.Add(tmpKey,tmpValue);
								strParamPagFilter+=y+"="+Request.Form[y]+"&";
							}
						}
					} 

					strParamPagFilter+="fields_filter=1";

					if(objListPairKeyValue.Count > 0){
						((IDictionary<string,object>)Session["geolocalsearchpoly"])["objListPairKeyValue"] =  objListPairKeyValue;      
						((IDictionary<string,object>)Session["geolocalsearchpoly"])["strParamPagFilter"] =  strParamPagFilter;
						bolHasFieldsFilter = true;
						//response.write("Session objListPairKeyValue.count:"& Session("geolocalsearchpoly").item("objListPairKeyValue").Count &"<br>")
					}
					//Response.Write("strParamPagFilter:"+strParamPagFilter+" - objListPairKeyValue.Count > 0: "+ (objListPairKeyValue.Count > 0)+"<br>");
				} 
			}else{
				//************ verifico se c'� una ricerca in sessione e riattivo i filtri
				if(bolHasSessionActive){
					object tobjListPairKeyValue = null;
					((IDictionary<string,object>)Session["geolocalsearchpoly"]).TryGetValue("objListPairKeyValue", out tobjListPairKeyValue);
					if (tobjListPairKeyValue != null && tobjListPairKeyValue.GetType().ToString().IndexOf("System.Collections.Generic.Dictionary")>=0) {
						objListPairKeyValue = (IDictionary<string,string>)tobjListPairKeyValue;
						object tstrParamPagFilter = null;
						((IDictionary<string,object>)Session["geolocalsearchpoly"]).TryGetValue("strParamPagFilter", out tstrParamPagFilter);
						if(tstrParamPagFilter != null){
							strParamPagFilter = (string)tstrParamPagFilter;
						}
						//Response.Write("bolHasSessionActive: strParamPagFilter:"+strParamPagFilter+"<br>");
						foreach(string u in objListPairKeyValue.Keys){
							//response.write("tmpKey Session:"&u&" - tmpValue Session:"&objListPairKeyValue(u)&"<br>")
							if(String.IsNullOrEmpty(objListPairKeyValue[u])){
								objListPairKeyValue.Remove(u); 
							}
						}
						bolHasFieldsFilter = true;
					}

					object tmp_fields_filter_active = "";		
					((IDictionary<string,object>)Session["geolocalsearchpoly"]).TryGetValue("fields_filter_active", out tmp_fields_filter_active);

					//Response.Write("tmp_fields_filter_active:"&tmp_fields_filter_active&"<br>");

					if(tmp_fields_filter_active != null && (string)tmp_fields_filter_active == "1"){
						bolHasFilterSearchActive = true;
					}
					//Response.Write("bolHasFilterSearchActive:"& bolHasFilterSearchActive &"<br>");
				}
			}
		}catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			bolHasFieldsFilter = false;
		}

		//**** verifico se � stata lanciata una ricerca e imposto nell'oggetto in sessione il parametro della ricerca attiva
		if(Request["search_active"]=="1"){
			if(Session["geolocalsearchpoly"] == null || Session["geolocalsearchpoly"].GetType().ToString().IndexOf("System.Collections.Generic.Dictionary")<0){
				IDictionary<string,object> objGeolocalSearch = new Dictionary<string,object>();
				Session["geolocalsearchpoly"] = objGeolocalSearch;		
			}
			((IDictionary<string,object>)Session["geolocalsearchpoly"])["search_active"] = "1";
			bolHasGeoSearchActive = true;
		}

		//Response.Write("Request[search_active]:"+Request["search_active"]+"<br>");					
		//Response.Write("bolHasSessionActive:"+bolHasSessionActive+"<br>");

		if (bolHasSessionActive){	
			object tmp_search_active = "";		
			((IDictionary<string,object>)Session["geolocalsearchpoly"]).TryGetValue("search_active", out tmp_search_active);
			//Response.Write("tmp_search_active:"+tmp_search_active+"<br>");
			
			if(tmp_search_active != null && (string)tmp_search_active == "1"){
				bolHasGeoSearchActive = true;
			}else{
				((IDictionary<string,object>)Session["geolocalsearchpoly"]).Remove("type");
				((IDictionary<string,object>)Session["geolocalsearchpoly"]).Remove("current_overlay");
				((IDictionary<string,object>)Session["geolocalsearchpoly"]).Remove("last_selection");
				((IDictionary<string,object>)Session["geolocalsearchpoly"]).Remove("vertices");
				((IDictionary<string,object>)Session["geolocalsearchpoly"]).Remove("center");
				((IDictionary<string,object>)Session["geolocalsearchpoly"]).Remove("radius"); 
			}
		}

		
		try
		{
			// tento di risolvere la categoria e il template in base ai parametri della request
			if(!String.IsNullOrEmpty(Request["categoryid"]))
			{
				category = catrep.getByIdCached(Convert.ToInt32(Request["categoryid"]), true);
				hierarchy = category.hierarchy;				
			}
			if(CategoryService.isCategoryNull(category))
			{	
				if(!String.IsNullOrEmpty(Request["hierarchy"]))
				{
					hierarchy = Request["hierarchy"];
					category = catrep.getByHierarchyCached(hierarchy, true);	
				}			
			}

			//Response.Write("category:"+category.ToString()+"<br>");			
			if(!CategoryService.isCategoryNull(category)){				
				setMetaCategory(category);
				if(category.idTemplate>0){
					template = templrep.getByIdCached(templateId,true);
				}
			}	

			if(template == null)
			{
				template = TemplateService.resolveTemplateByVirtualPath(basePath, lang.currentLangCode, out newLangCode);
			
				if(CategoryService.isCategoryNull(category))
				{
					category = catrep.getByTemplateCached(template.id, true);
					if(!CategoryService.isCategoryNull(category))
					{
						if(String.IsNullOrEmpty(Request["lang_code"]) && !String.IsNullOrEmpty(newLangCode)){
							HttpContext.Current.Items["lang-code"] = newLangCode;
							lang.set();
						}	
						hierarchy = category.hierarchy;					
						setMetaCategory(category); 					
					}
				}
			}
			
			if(template != null){
				itemsXpage = template.elemXpage;
				orderBy = template.orderBy;
				bool langHasSubDomainActive = false;
				string langUrlSubdomain = "";
				Language language = langrep.getByLabel(lang.currentLangCode, true);
				if(!LanguageService.isLanguageNull(language))
				{	
					langHasSubDomainActive = language.subdomainActive;
					langUrlSubdomain = language.urlSubdomain;
				}	
				
				currentURL = MenuService.resolvePageHrefUrl(builder.ToString(), modelPageNum, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);								
				detailURL = MenuService.resolvePageHrefUrl(builder.ToString(), modelPageNum+1, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
				//Response.Write("2 detailURL:"+detailURL+"<br>");	
				if(currentURL==null){
					currentURL = "#";
				}
				if(detailURL==null){
					detailURL = "#";
				}
				bolHasDetailLink = true;				
			}
			
			if(!CategoryService.isCategoryNull(category))
			{
				categoryid = category.id.ToString();
			}
		}catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			bolHasDetailLink = false;
		}
	
		if (!String.IsNullOrEmpty(lang.currentLangCode)) {
			matchLanguages = new List<int>();
			matchLanguages.Add(langrep.getByLabel(lang.currentLangCode, true).id);
		}
	
		if(!String.IsNullOrEmpty(Request["order_by"]))
		{
			orderBy = Convert.ToInt32(Request["order_by"]);	
		}
						
		try
		{			
			contents = contentrep.find(null,null,status,0,null,null,orderBy,matchCategories,matchLanguages,true,true,true,true,true);
			
			//Response.Write("contents != null:"+ contents!=null +"<br>");
			//Response.Write("bolHasFieldsFilter:"+ bolHasFieldsFilter +"<br>");		
			//Response.Write("contents:"+ contents.Count+"<br>");	
			
			if(contents != null && contents.Count>0){					
				bool keepContent = true;
				IDictionary<int,FContent> keeped = new Dictionary<int,FContent>();
				
				foreach(FContent c in contents){
					keeped.Add(c.id, c);
				}
				
				foreach(FContent c in contents){
					keepContent=true;
					
					if(c.fields != null && c.fields.Count>0){
						if(bolHasFieldsFilter){
							IDictionary<string,ContentField> fieldsDict = new Dictionary<string,ContentField>();							
							foreach(ContentField cf in c.fields){
								if(cf.enabled){
									fieldsDict[cf.description] = cf;
								}
							}
							
							foreach(string key in objListPairKeyValue.Keys){
								if(!fieldsDict.ContainsKey(key)){
									keepContent=false;
									keeped.Remove(c.id);
									break;
								}

								if(key=="prezzo"){
									bool hasLeft = false;
									bool hasRight=false;
									Decimal tmpcfVals = 0;
									prcsxVal = 0;
									prcdxVal = 0;
									string[] tmpprcVals = new string[2] {"",""};
									string fval = fieldsDict["prezzo"].value;	
									//Response.Write("fval:"+ fval+"<br>");	
									if(!String.IsNullOrEmpty(fval)){
										tmpcfVals = Convert.ToDecimal(fval);
										//Response.Write("tmpcfVals:"+ tmpcfVals+"<br>");
									}
									string kvval = objListPairKeyValue["prezzo"];
									//Response.Write("kvval:"+ kvval+"<br>");
									if(!String.IsNullOrEmpty(kvval)){
										tmpprcVals = kvval.Split('x');              
									}
									if(String.IsNullOrEmpty(tmpprcVals[0].Trim()) || String.IsNullOrEmpty(tmpprcVals[1].Trim())){
										string prcCheck = kvval.Trim();

										if(prcCheck.EndsWith("x")){
											prcsxVal = Convert.ToDecimal(tmpprcVals[0].Trim());
											hasLeft = true;
										}else if(prcCheck.StartsWith("x")){
											prcCheck = prcCheck.Replace("x", "");
											tmpprcVals[1] = prcCheck;
											prcdxVal = Convert.ToDecimal(tmpprcVals[1].Trim());
											hasRight=true;                      
										}
									}else{
										prcsxVal = Convert.ToDecimal(tmpprcVals[0].Trim());
										prcdxVal = Convert.ToDecimal(tmpprcVals[1].Trim());
										hasLeft = true;
										hasRight=true;                   
									}

									//Response.Write("<br>hasLeft:"+ hasLeft +" -hasRight:"+ hasRight + " -prcsxVal:"+prcsxVal+" -prcdxVal:"+prcdxVal+"<br>");

									if(hasLeft){
										//Response.Write("<br>tmpcfVals:"& tmpcfVals &" -typename:"& typename(tmpcfVals)&"<br>");    
										if(tmpcfVals < prcsxVal){
											keepContent=false;
											keeped.Remove(c.id);
											break;
										} 
									} 

									if(hasRight){
										//Response.Write("<br>tmpcfVals:"& tmpcfVals &" -typename:"& typename(tmpcfVals)&"<br>");  
										if(tmpcfVals > prcdxVal){
											keepContent=false;
											keeped.Remove(c.id);
											break;
										}    
									}
								}else if(key=="superficie"){								    
									bool hasLeft = false;
									bool hasRight=false;
									Decimal tmpcfVals = 0;
									supsxVal = 0;
									supdxVal = 0;
									string[] tmpsupVals = new string[2] {"",""};
									string fval = fieldsDict["superficie"].value;
									if(!String.IsNullOrEmpty(fval)){
										tmpcfVals = Convert.ToDecimal(fval);
									}
									string kvval = objListPairKeyValue["superficie"];
									if(!String.IsNullOrEmpty(kvval)){
										tmpsupVals = kvval.Split('x');              
									}
									if(String.IsNullOrEmpty(tmpsupVals[0].Trim()) || String.IsNullOrEmpty(tmpsupVals[1].Trim())){
										string supCheck = kvval.Trim();

										if(supCheck.EndsWith("x")){
											supsxVal = Convert.ToDecimal(tmpsupVals[0].Trim());
											hasLeft = true;
										}else if(supCheck.StartsWith("x")){
											supCheck = supCheck.Replace("x", "");
											tmpsupVals[1] = supCheck;
											supdxVal = Convert.ToDecimal(tmpsupVals[1].Trim());
											hasRight=true;                      
										}
									}else{
										supsxVal = Convert.ToDecimal(tmpsupVals[0].Trim());
										supdxVal = Convert.ToDecimal(tmpsupVals[1].Trim());
										hasLeft = true;
										hasRight=true;                   
									}

									//Response.Write("<br>hasLeft:"& hasLeft &" -hasRight:"& hasRight & " -prcsxVal:"&prcsxVal&" -prcdxVal:"&prcdxVal&"<br>");

									if(hasLeft){
										//Response.Write("<br>tmpcfVals:"& tmpcfVals &" -typename:"& typename(tmpcfVals)&"<br>");    
										if(tmpcfVals < supsxVal){
											keepContent=false;
											keeped.Remove(c.id);
											break;
										} 
									} 

									if(hasRight){
										//Response.Write("<br>tmpcfVals:"& tmpcfVals &" -typename:"& typename(tmpcfVals)&"<br>");  
										if(tmpcfVals > supdxVal){
											keepContent=false;
											keeped.Remove(c.id);
											break;
										}    
									}
								}else if(key=="locali"){							    
									bool hasLeft = false;
									bool hasRight=false;
									Decimal tmpcfVals = 0;
									locsxVal = 0;
									locdxVal = 0;
									string[] tmplocVals = new string[2] {"",""};
									string fval = fieldsDict["locali"].value;
									if(!String.IsNullOrEmpty(fval)){
										tmpcfVals = Convert.ToDecimal(fval);
									}
									string kvval = objListPairKeyValue["locali"];
									if(!String.IsNullOrEmpty(kvval)){
										tmplocVals = kvval.Split('x');              
									}
									if(String.IsNullOrEmpty(tmplocVals[0].Trim()) || String.IsNullOrEmpty(tmplocVals[1].Trim())){
										string locCheck = kvval.Trim();

										if(locCheck.EndsWith("x")){
											locsxVal = Convert.ToDecimal(tmplocVals[0].Trim());
											hasLeft = true;
										}else if(locCheck.StartsWith("x")){
											locCheck = locCheck.Replace("x", "");
											tmplocVals[1] = locCheck;
											locdxVal = Convert.ToDecimal(tmplocVals[1].Trim());
											hasRight=true;                      
										}
									}else{
										locsxVal = Convert.ToDecimal(tmplocVals[0].Trim());
										locdxVal = Convert.ToDecimal(tmplocVals[1].Trim());
										hasLeft = true;
										hasRight=true;                   
									}

									//Response.Write("<br>hasLeft:"& hasLeft &" -hasRight:"& hasRight & " -prcsxVal:"&prcsxVal&" -prcdxVal:"&prcdxVal&"<br>");

									if(hasLeft){
										//Response.Write("<br>tmpcfVals:"& tmpcfVals &" -typename:"& typename(tmpcfVals)&"<br>");    
										if(tmpcfVals < locsxVal){
											keepContent=false;
											keeped.Remove(c.id);
											break;
										} 
									} 

									if(hasRight){
										//Response.Write("<br>tmpcfVals:"& tmpcfVals &" -typename:"& typename(tmpcfVals)&"<br>");  
										if(tmpcfVals > locdxVal){
											keepContent=false;
											keeped.Remove(c.id);
											break;
										}    
									}
								}else if(key=="regione_provincia"){
									string regprovval = fieldsDict["regione_provincia"].value;
									regprovsel = objListPairKeyValue["regione_provincia"];
									regprovsel = regprovsel.Substring(0,regprovsel.IndexOf("_"));
									
									if (regprovval.IndexOf(regprovsel) < 0) {
										keepContent=false;
										keeped.Remove(c.id);
										break;
									}	
								}else{
									int ftype = fieldsDict[key].type;
									
									if(ftype==3 || ftype==4 || ftype==5){
										bool selected = false;
										string fval = fieldsDict[key].value;
										if (!String.IsNullOrEmpty(fval)){
											string[] spitValues = fval.Split(',');
											foreach(string x in spitValues){                    
												if (!String.IsNullOrEmpty(objListPairKeyValue[key])){
													string[] spitMatchValues = objListPairKeyValue[key].Split(',');
													foreach(string w in spitMatchValues){
														if(x.Trim()==w.Trim()){
															selected=true;
															break;
														}
													}
												}		
											} 
										}

										if (!selected){
											keepContent=false;
											keeped.Remove(c.id);
											break;
										}									
									}else{
										string fval = fieldsDict[key].value;
										string kvval = objListPairKeyValue[key];
										if(fval != kvval){
											keepContent=false;
											keeped.Remove(c.id);
											break;
										}
									}
								}								
								
							}								
						}
					}
					//Response.Write("keeped.Count:"+ keeped.Count+"<br>");	

					if(keepContent){
						//Response.Write("c.title:"+ c.title +" - bolHasGeoSearchActive:"+bolHasGeoSearchActive+"<br>");
						
						//*************** verifico se esiste la geolocalizzazione per questo elemento
						IList<Geolocalization> tmpPoints = georep.findByElement(c.id, 1);
						//Response.Write("tmpPoints != null:"+ (tmpPoints != null)+"<br>");	
						if(tmpPoints != null && tmpPoints.Count>0){
							//Response.Write("tmpPoints.Count:"+ tmpPoints.Count+"<br>");	
							/*
							se esiste un poligono/cerchio impostato dall utente come base di ricerca verifico se il punto � incluso nel poligono/cerchio
							l oggetto in sessione � un Dictionary con n chiavi, a seconda del tipo di poligono alcune chiavi saranno null e altre valorizzate:
							type: 1=poligono, 2=cerchio
							vertices: dictionary contenente i singoli vertici del poligono
							center: il punto di centro del cerchio
							radius: il raggio in metri del cerchio
							*/
							bool bolAddAllPoints = true;
							
							//Response.Write("bolHasGeoSearchActive:"+ bolHasGeoSearchActive+"<br>");	
							
							if (bolHasGeoSearchActive) {								
								bolAddAllPoints = false;
								
								//Response.Write("type:"+((IDictionary<string,object>)Session["geolocalsearchpoly"])["type"]);
								//Response.Write(" - is 1:"+((string)((IDictionary<string,object>)Session["geolocalsearchpoly"])["type"]=="1")+"<br>");
								
								if((string)((IDictionary<string,object>)Session["geolocalsearchpoly"])["type"]=="1"){
									//Response.Write("vertices:"+(string)((IDictionary<string,object>)Session["geolocalsearchpoly"])["vertices"]);
									
									IList<Geolocalization> objListVertices = GeolocalizationService.convertVertices((string)((IDictionary<string,object>)Session["geolocalsearchpoly"])["vertices"]);
									
									//Response.Write("objListVertices != null:"+ (objListVertices!=null)+"<br>");
									
									foreach(Geolocalization xLocal in tmpPoints){   
										//Response.Write("xLocal:"+ xLocal.ToString()+"<br>");       
										if(GeolocalizationService.isPointInPolygon(xLocal, objListVertices)){
											points.Add(xLocal);
											//Response.Write("isPointInPolygon content id: "+c.id+" - xLocal id element:"+ xLocal.idElement+" - ");  
											//Response.Write("points.Count:"+ points.Count+"<br>");
										}else{
											//Response.Write("**NOT** isPointInPolygon xLocal:"+ xLocal.ToString()+"<br>");  
											keepContent=false;
											keeped.Remove(c.id);
											break;               
										}
									}
								}else if((string)((IDictionary<string,object>)Session["geolocalsearchpoly"])["type"]=="2"){
									Geolocalization objCenter = GeolocalizationService.convertCenter((string)((IDictionary<string,object>)Session["geolocalsearchpoly"])["center"]); 
									//Response.Write("objCenter:"+ objCenter.ToString()+"<br>");         
									foreach(Geolocalization xLocal in tmpPoints){
										string stringradius = (string)((IDictionary<string,object>)Session["geolocalsearchpoly"])["radius"];
										double dblradius = 0;
										if(!String.IsNullOrEmpty(stringradius)){
											dblradius = double.Parse(stringradius, CultureInfo.InvariantCulture);
										}
											
										if(dblradius>0 && GeolocalizationService.isPointInCircleOnEarthSurface(xLocal, objCenter, dblradius)){
											//Response.Write("isPointInCircleOnEarthSurface content id: "+c.id+" - xLocal id element:"+ xLocal.idElement+" - ");  
											points.Add(xLocal);
										}else{
											//Response.Write("**NOT** isPointInCircleOnEarthSurface xLocal:"+ xLocal.ToString()+"<br>");  
											keepContent=false;
											keeped.Remove(c.id);
											break;              
										}
									} 
								} 							
							}
							
							if(bolAddAllPoints){
								foreach(Geolocalization g in tmpPoints){
									points.Add(g);
								}
							}
						}else{
							if (bolHasGeoSearchActive){
								keepContent=false;
								keeped.Remove(c.id);
								break;								
							}
						}
					}
					
					if(keepContent){
						if (!String.IsNullOrEmpty(lang.getTranslated(c.metaDescription))) {
							_metaDescription+= " " + lang.getTranslated(c.metaDescription);
						}else{
							if (!String.IsNullOrEmpty(c.metaDescription)) {
								_metaDescription+= " " + c.metaDescription;
							}
						}
						
						if (!String.IsNullOrEmpty(lang.getTranslated(c.metaKeyword))) {
							_metaKeyword+= " " + lang.getTranslated(c.metaKeyword);
						}else{
							if (!String.IsNullOrEmpty(c.metaKeyword)) {
								_metaKeyword+= " " + c.metaKeyword;
							}
						}
					}
				}
				//Response.Write("keeped.Count:"+ keeped.Count+"<br>");	
				//Response.Write("bolHasFilterSearchActive:"+ bolHasFilterSearchActive+"<br>");	
				//Response.Write("points.Count:"+ points.Count+"<br>");
				
				if(keeped.Count>0 && bolHasFilterSearchActive){
					//Response.Write("keeped.Count:"+ keeped.Count+"<br>");				
					bolFoundLista = true;
					contents = new List<FContent>(keeped.Values);
				}else{		
					bolFoundLista = false;
					contents = new List<FContent>();
					points = new List<Geolocalization>();
				}
			}	
		}
		catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			bolFoundLista = false;
			contents = new List<FContent>();
			points = new List<Geolocalization>();
		}
					
		//Response.Write("contents:"+ contents.Count+"<br>");	

		int iIndex = contents.Count;
		fromContent = ((numPage * itemsXpage) - itemsXpage);
		int diff = (iIndex - ((numPage * itemsXpage)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toContent = iIndex - diff;
			
		if(itemsXpage>0){_totalCPages = iIndex/itemsXpage;}
		if(_totalCPages < 1) {
			_totalCPages = 1;
		}else if(iIndex % itemsXpage != 0 &&  (_totalCPages * itemsXpage) < iIndex) {
			_totalCPages = _totalCPages +1;	
		}
		
		string pgParams = "items="+itemsXpage;
		if(!String.IsNullOrEmpty(strParamPagFilter)){
			pgParams+="&"+strParamPagFilter;
		}
		
		/*
		Response.Write("iIndex:"+ iIndex+"<br>");
		Response.Write("itemsXpage:"+ itemsXpage+"<br>");
		Response.Write("numPage:"+ numPage+"<br>");
		Response.Write("fromContent:"+ fromContent+"<br>");
		Response.Write("diff:"+ diff+"<br>");
		Response.Write("toContent:"+ toContent+"<br>");
		Response.Write("_totalCPages:"+ _totalCPages+"<br>");
		Response.Write("pgParams:"+ pgParams+"<br>");
		*/
		
		this.pg1.totalPages = this._totalCPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPage;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = pgParams;	
		
		// init menu frontend
		this.mf1.modelPageNum = this.modelPageNum;
		this.mf1.categoryid = categoryid;	
		this.mf1.hierarchy = hierarchy;	
		this.mf2.modelPageNum = this.modelPageNum;
		this.mf2.categoryid = categoryid;	
		this.mf2.hierarchy = hierarchy;	
		this.mf3.modelPageNum = this.modelPageNum;
		this.mf3.categoryid = categoryid;	
		this.mf3.hierarchy = hierarchy;
		//this.mf4.modelPageNum = this.modelPageNum;
		//this.mf4.categoryid = categoryid;	
		//this.mf4.hierarchy = hierarchy;
		this.mf5.modelPageNum = this.modelPageNum;
		this.mf5.categoryid = categoryid;	
		this.mf5.hierarchy = hierarchy;
	}
	
	private void setMetaCategory(Category category)
	{
		_pageTitle = lang.getTranslated("frontend.page.title");
		_metaDescription = "";
		_metaKeyword = "";
		matchCategories = new List<int>();
		matchCategories.Add(category.id);	
		
		if (!String.IsNullOrEmpty(lang.getTranslated(category.pageTitle))) {
			_pageTitle= " " + lang.getTranslated(category.pageTitle);
		}else{
			if (!String.IsNullOrEmpty(category.pageTitle)) {
				_pageTitle= " " + category.pageTitle;
			}
		} 
		
		if (!String.IsNullOrEmpty(lang.getTranslated(category.metaDescription))) {
			_metaDescription+= " " + lang.getTranslated(category.metaDescription);
		}else{
			if (!String.IsNullOrEmpty(category.metaDescription)) {
				_metaDescription+= " " + category.metaDescription;
			}
		}
		
		if (!String.IsNullOrEmpty(lang.getTranslated(category.metaKeyword))) {
			_metaKeyword+= " " + lang.getTranslated(category.metaKeyword);
		}else{
			if (!String.IsNullOrEmpty(category.metaKeyword)) {
				_metaKeyword+= " " + category.metaKeyword;
			}
		} 			
	}
}
