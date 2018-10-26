using System;
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
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class _Results : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected FContent content;
	protected int numPage, modelPageNum;
	protected IList<int> matchCategories = null;
	protected IDictionary<string, IList<ContentAttachment>> attachmentsDictionary = null;
	protected IList<ContentAttachmentLabel> attachmentsLabel = null;
	protected IList<ContentField> contentFields = null;
	protected string hierarchy;
	protected string categoryid;
	protected string detailURL = "#";
	
	protected List<Transfer> tresult = new List<Transfer>();
	protected DateTime searchDtOut = DateTime.Now;
	protected DateTime searchDtRtn = DateTime.Now;
	protected string searchFrom = null;
	protected string searchTo = null;
	protected IDictionary<string,string> types = new Dictionary<string,string>();
	protected IDictionary<int,int> durations = new Dictionary<int,int>();
	protected List<int> sortedDurations = new List<int>();
	protected string minDuration = "0";
	protected string maxDuration = "0";
	protected string durationsRange = "";
	protected int passengers = 0;
	
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
		IContentRepository contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");	
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		confservice = new ConfigurationService();
		Logger log = new Logger();

		//se il sito � offline rimando a pagina default
		if ("1".Equals(confservice.get("go_offline").value)) 
		{
			UriBuilder defRedirect = new UriBuilder(Request.Url);
			defRedirect.Port = -1;	
			defRedirect.Path = "";			
			defRedirect.Query = "";
			Response.Redirect(defRedirect.ToString());
		}	
		
		StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
		string basePath = Request.Path.ToLower();
		string newLangCode = "";
		
		Category category = null;
		Template template = null;	
		IList<int> matchLanguages = null;
		numPage = 1;
		string status = "1";
		int orderBy = 1;
		modelPageNum = 1;
		hierarchy = (string)HttpContext.Current.Items["hierarchy"];
		categoryid = (string)HttpContext.Current.Items["categoryid"];
		attachmentsDictionary = new Dictionary<string, IList<ContentAttachment>>();
		attachmentsLabel = contentrep.getContentAttachmentLabelCached(true);
		contentFields = new List<ContentField>();
		
		//url for search api development
		//string baseSearchApi = "https://orange.indigo-connect.com/e/3/search?";
		//string baseApiKey = "priv_FwHibPUhdRhesMuwFLRFPHfAb";
		
		//url for search api production
		string baseSearchApi = "https://green.indigo-connect.com/e/3/search?";
		string baseApiKey = "priv_pmYRungYEWXcwmftLgPyVAeiQvpXdLPJvY";
		
		if (!String.IsNullOrEmpty(Request["page"])) {
			numPage = Convert.ToInt32(Request["page"]);
		}		
		
		try
		{
			if(!String.IsNullOrEmpty(Request["hierarchy"]))
			{
				hierarchy = Request["hierarchy"];
			}
			if(!String.IsNullOrEmpty(Request["categoryid"]))
			{
				categoryid = Request["categoryid"];
			}
					
			// tento di risolvere la categoria e il template in base ai parametri della request
			if(!String.IsNullOrEmpty(categoryid))
			{
				category = catrep.getByIdCached(Convert.ToInt32(categoryid), true);
				hierarchy = category.hierarchy;				
			}
			if(CategoryService.isCategoryNull(category))
			{	
				if(!String.IsNullOrEmpty(hierarchy))
				{
					category = catrep.getByHierarchyCached(hierarchy, true);	
				}			
			}	
			
			if(!CategoryService.isCategoryNull(category)){				
				setMetaCategory(category);
				if(category.idTemplate>0){
					template = templrep.getByIdCached(category.idTemplate,true);
				}
			}
										
			if(template == null)
			{
				template = TemplateService.resolveTemplateByVirtualPath(basePath, lang.currentLangCode, out newLangCode);
				
				//Response.Write("template:"+ template.ToString() +"<br>");
				//Response.Write("category is null:"+ CategoryService.isCategoryNull(category) +"<br>");
				
				if(CategoryService.isCategoryNull(category) && template != null)
				{
					//Response.Write("template.id:"+ template.id +"<br>");
					//Response.Write("page:"+ Page.Request.RawUrl.ToString() +"<br>");
					
					string pageUrl = Page.Request.RawUrl.ToString();
					if(!String.IsNullOrEmpty(pageUrl) && pageUrl.IndexOf("?")>0){
						pageUrl = pageUrl.Substring(0,pageUrl.IndexOf("?"));
					}
					//Response.Write("page after:"+ pageUrl +"<br>");
					
					category = catrep.getByTemplateCached(template.id, pageUrl, true);
					
					//Response.Write("category:"+ category.ToString() +"<br>");
					
					if(!CategoryService.isCategoryNull(category))
					{
						//Response.Write("category:"+ category.ToString() +"<br>");
						
						if(String.IsNullOrEmpty(Request["lang_code"]) && !String.IsNullOrEmpty(newLangCode)){
							HttpContext.Current.Items["lang-code"] = newLangCode;
							lang.set();
						}	
						hierarchy = category.hierarchy;					
						setMetaCategory(category); 					
					}
				}
			}
			if(!CategoryService.isCategoryNull(category))
			{
				categoryid = category.id.ToString();
			}
							
			// tento il recupero del contenuto tramite id
			if(!String.IsNullOrEmpty(Request["contentid"]))
			{
				content = contentrep.getByIdCached(Convert.ToInt32(Request["contentid"]), true);	
			}			

			// se non trovo nulla tento il recupero dalla categoria
			if(ContentService.isContentNull(content))
			{	
				if (!String.IsNullOrEmpty(lang.currentLangCode)) {
					matchLanguages = new List<int>();
					matchLanguages.Add(langrep.getByLabel(lang.currentLangCode).id);
				}
		
				if (!String.IsNullOrEmpty(Request["content_preview"])) {
					status = null;
				}
					
				if(!String.IsNullOrEmpty(Request["order_by"]))
				{
					orderBy = Convert.ToInt32(Request["order_by"]);	
				}
								
				try
				{			
					IList<FContent> contents = contentrep.find(null,"search-results",status,0,null,null,orderBy,matchCategories,matchLanguages,true,true,true,true,true);
					
					//Response.Write("contents != null:"+ contents!=null +"<br>");
					
					if(contents != null){								
						foreach(FContent c in contents){
							content = c;
							break;      
						}					
					}	
				}
				catch (Exception ex){
					//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					throw;
				}
				
			}
		}catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			content = null;
		}
		
		//gestisco attachment
		if(content != null)
		{
			if (!String.IsNullOrEmpty(lang.getTranslated(content.pageTitle))) {
				_pageTitle+= " " + lang.getTranslated(content.pageTitle);
			}else{
				if (!String.IsNullOrEmpty(content.pageTitle)) {
					_pageTitle+= " " + content.pageTitle;
				}
			}
			
			if (!String.IsNullOrEmpty(lang.getTranslated(content.metaDescription))) {
				_metaDescription+= " " + lang.getTranslated(content.metaDescription);
			}else{
				if (!String.IsNullOrEmpty(content.metaDescription)) {
					_metaDescription+= " " + content.metaDescription;
				}
			}
			
			if (!String.IsNullOrEmpty(lang.getTranslated(content.metaKeyword))) {
				_metaKeyword+= " " + lang.getTranslated(content.metaKeyword);
			}else{
				if (!String.IsNullOrEmpty(content.metaKeyword)) {
					_metaKeyword+= " " + content.metaKeyword;
				}
			}
					
			bool langHasSubDomainActive = false;
			string langUrlSubdomain = "";
			Language language = langrep.getByLabel(lang.currentLangCode, true);
			if(!LanguageService.isLanguageNull(language))
			{	
				langHasSubDomainActive = language.subdomainActive;
				langUrlSubdomain = language.urlSubdomain;
			}

			
			ctitle.Text = content.title;
			csummary.Text = content.summary;
			cdescription.Text = content.description;
			
			if(content.attachments != null)
			{
				foreach(ContentAttachment ca in content.attachments)
				{				
					int label = ca.fileLabel;
					string alabel = "";
					foreach(ContentAttachmentLabel cal in attachmentsLabel)
					{
						if(cal.id==label)
						{
							alabel = cal.description;
							break;
						}
					}
					
					if(attachmentsDictionary.ContainsKey(alabel))
					{
						IList<ContentAttachment> items = null;
						if(attachmentsDictionary.TryGetValue(alabel, out items)){
							items.Add(ca);
							attachmentsDictionary[alabel] = items;
						}
					}
					else
					{
						IList<ContentAttachment> items = new List<ContentAttachment>();
						items.Add(ca);
						attachmentsDictionary[alabel] = items;
					}
				}
			}
			
			// gestisco i field per contenuto
			if(content.fields != null && content.fields.Count>0){
				contentFields = content.fields;
			}
		}
		
		
		
		
		/*************  START TRANFER SEARCH **************/		
		
		string sfrom_type = Request["from_type"];
		string sfrom = Request["pickupLatitude"]+","+Request["pickupLongitude"];
		string sto_type = Request["to_type"];
		string sto = Request["dropoffLatitude"]+","+Request["dropoffLongitude"];
		//string sdtout = Request["pickupDate"]+"T12:00";
		//string sdtout = DateTime.ParseExact(Request["pickupDate"], "dd/MM/yyyyTHH:mm", null).ToString("yyyy-MM-ddTHH:mm");
		string sdtout = DateTime.ParseExact(Request["pickupDate"], "dd/MM/yyyy HH:mm", null).ToString("yyyy-MM-ddTHH:mm");
		string sdtrtn = "";
		if(!string.IsNullOrEmpty(Request["returnDate"])){
			//sdtrtn = Request["returnDate"]+"T12:00";
			//sdtrtn = DateTime.ParseExact(Request["returnDate"], "dd/MM/yyyyTHH:mm", null).ToString("yyyy-MM-ddTHH:mm");
			sdtrtn = DateTime.ParseExact(Request["returnDate"], "dd/MM/yyyy HH:mm", null).ToString("yyyy-MM-ddTHH:mm");
		}
		passengers = Convert.ToInt32(Request["passenger"]);
		
		string urlCall = baseSearchApi;
		urlCall+="from_type="+sfrom_type;
		urlCall+="&from="+sfrom;
		urlCall+="&to_type="+sto_type;
		urlCall+="&to="+sto;
		urlCall+="&out_dt="+sdtout;
		if(!string.IsNullOrEmpty(sdtrtn)){
			urlCall+="&rtn_dt="+sdtrtn;
		}
		urlCall+="&language="+lang.currentLangCode.ToLower();
		
		//Response.Write(urlCall);
		log.usr= "frontend";
		log.msg = "save transfer search: "+urlCall;
		log.type = "info";
		log.date = DateTime.Now;
		lrep.write(log);

		RestClient client = new com.nemesys.model.RestClient();
		
		client.Headers = new Dictionary<string,string>();
		client.Headers.Add("api-key",baseApiKey);
		client.EndPoint = @urlCall;		
		
		string jsonresult = "";
		
		
		try
		{
			string[] json = client.MakeRequest();
			jsonresult = json[0];
			
			// manage results
			if(!string.IsNullOrEmpty(jsonresult)){
				//Response.Write("<code>");
				//Response.Write(jsonresult);
				//Response.Write("</code>");		
			
				JObject o = JObject.Parse(@jsonresult);
				
				//Response.Write("JObject:<br>"+o+"<br>");	
				
				JToken results = null;
				
				
				if(o.TryGetValue("results",out results)){
					int counter = 1;
					foreach(JToken jt in results){
						Transfer t = new Transfer();
						
						string service_type = jt.SelectToken("summary.booking.mode").ToString();
						if (!String.IsNullOrEmpty(service_type)) {
							if(!String.IsNullOrEmpty(lang.getTranslated("frontend.transfer.result.type.label."+service_type))){
								service_type = lang.getTranslated("frontend.transfer.result.type.label."+service_type);
							}
						}
						//Response.Write("service_name: "+service_name+"<br>");
						string op = jt.SelectToken("out.operator").ToString();	
						//Response.Write("operator: "+op+"<br>");	
						string seats = jt.SelectToken("out.max_pax").ToString();
						//Response.Write("seats: 1-"+seats+" passeggeri<br>");
						
						//string logo = jt.SelectToken("summary.logo.bw").ToString();
						string logo = jt.SelectToken("summary.logo").ToString();
						//Response.Write("<img src="+logo+" width=70 align=left><br>");
						string image = jt.SelectToken("summary.image").ToString();
						//Response.Write("<img src="+image+" width=200 align=left><br>");
						
						string luggage = "";
						var luggages = jt["extras"]["out"].Children();
						foreach(JToken jl in luggages){
							if("bagstandard".Equals(jl.SelectToken("name").ToString())){
								luggage = jl.SelectToken("max").ToString();
								break;
							}
						}
						//Response.Write(luggage +" valigie<br>");	
						
						//string duration = jt.SelectToken("summary.out.duration").ToString();
						//Response.Write("duration: "+duration+"<br>");	
						
						// calculate trip duration based on departur and arrival date; the duration fields it's inconsistent
						string dt = jt.SelectToken("summary.out.dt").ToString();
						string dtArrive = jt.SelectToken("summary.out.dt_arrive").ToString();
						DateTime dtParsed = DateTime.Parse(dt);
						DateTime dtArriveParsed = DateTime.Parse(dtArrive);
						System.TimeSpan diffResult = dtArriveParsed.Subtract(dtParsed);
						int duration = Convert.ToInt32(diffResult.TotalMinutes);
						//Response.Write("duration: "+duration+"<br>");	
						
						string cost = jt.SelectToken("cost.user_amount").ToString();
						string currency = jt.SelectToken("cost.user_currency").ToString();
						
						//Response.Write("amount: "+currency+" "+cost+"<br>");
						
						string dOut = jt.SelectToken("out_dt").ToString();
						string dRtn = null;
						if(jt.SelectToken("rtn_dt") !=null){
							dRtn = jt.SelectToken("rtn_dt").ToString();
						}
						string from = jt.SelectToken("out.from.display2").ToString();
						string to = jt.SelectToken("out.to.display2").ToString();
						
						string deeplink = jt.SelectToken("deeplink.landing").ToString();
				
						
						t.serviceName=service_type;
						t.operatorName=op;
						t.seat=Convert.ToInt32(seats);
						t.logo=logo;
						t.image=image;
						t.maxLuggage=Convert.ToInt32(luggage);
						//t.duration=Convert.ToInt32(duration);
						t.duration=duration;
						t.amount=Convert.ToDecimal(cost);
						t.currency=currency;
						//t.dOut = DateTime.ParseExact(dOut, "yyyy-MM-ddTHH:mm:ss", null);
						t.dOut = DateTime.Parse(dOut);
						if(!string.IsNullOrEmpty(dRtn)){
							//t.dRtn = DateTime.ParseExact(dRtn, "yyyy-MM-ddTHH:mm:ss", null);
							t.dRtn = DateTime.Parse(dRtn);
						}
						t.from = from;
						t.to = to;
						t.deeplink = deeplink;
						
						tresult.Add(t);
						
						//add types for filters
						types[t.serviceName] = t.serviceName;
						durations[t.duration] = t.duration;
						
						counter++;
					}
					
					if(tresult.Count>0){
						Transfer tmp = tresult[0];
							
						searchDtOut = tmp.dOut;
						if(!string.IsNullOrEmpty(Request["returnDate"])){
							searchDtRtn = tmp.dRtn;
						}
						searchFrom = tmp.from;
						searchTo = tmp.to;	
						
						tresult.Sort();
						
						foreach(int d in durations.Keys){
							sortedDurations.Add(d);
						}
						sortedDurations.Sort();
						
						minDuration = sortedDurations[0].ToString();
						maxDuration = sortedDurations[sortedDurations.Count-1].ToString();
						
						foreach(int d in sortedDurations){
							durationsRange += d+","; 
						}
						if(!string.IsNullOrEmpty(durationsRange)){
							durationsRange = durationsRange.Substring(0,durationsRange.Length-1);
						}
					}
				}
			}			
			
		}catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			jsonresult = "";
		}
		
		/*************  END TRANFER SEARCH **************/			
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
