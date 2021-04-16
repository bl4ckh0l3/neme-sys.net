using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections.Generic;

public partial class _LogList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	public int itemsXpage, numPage;
	public string paramType, paramDateFrom, paramDateTo, paramDelete;	
	public string cssClass;		
	public IDictionary<int, Logger> logs;
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
		cssClass="LL";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		
		paramDelete = Request["delete_log"];
		if(paramDelete == "1") {		
			lrep.deleteBy(Request["log_type"],Request["dta_from"],Request["dta_to"]);	
		}

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["logsItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["logsItems"];
			Session["logsPage"] = 1;
		}else{
			if (Session["logsItems"] != null) {
				itemsXpage = (int)Session["logsItems"];
			}else{
				Session["logsItems"] = 20;
				itemsXpage = (int)Session["logsItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["logsPage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["logsPage"];
		}else{
			if (Session["logsPage"] != null) {
				numPage = (int)Session["logsPage"];
			}else{
				Session["logsPage"]= 1;
				numPage = (int)Session["logsPage"];
			}
		}	
			

		if (!String.IsNullOrEmpty(Request["log_type"])) {
			Session["log_type"] = Request["log_type"];
			paramType = (string)Session["log_type"];
			Session["logsPage"] = 1;
		}else{
			if (Session["log_type"] != null) {;
				paramType = (string)Session["log_type"];
			}else{
				Session["log_type"] = "";
				paramType = (string)Session["log_type"];
			}
		}
		if (!String.IsNullOrEmpty(Request["dta_from"])) {
			Session["dta_from"] = Request["dta_from"];
			paramDateFrom = (string)Session["dta_from"];
			Session["logsPage"] = 1;
		}else{
			if (Session["dta_from"] != null) {
				paramDateFrom = (string)Session["dta_from"];
			}else{
				Session["dta_from"] = DateTime.Now.ToString("dd/MM/yyyy");
				paramDateFrom = (string)Session["dta_from"];
			}
		}
		if (!String.IsNullOrEmpty(Request["dta_to"])) {
			Session["dta_to"] = Request["dta_to"];
			paramDateTo = (string)Session["dta_to"];
			Session["logsPage"]= 1;
		}else{
			if (Session["dta_to"] != null) {
				paramDateTo = (string)Session["dta_to"];
			}else{
				Session["dta_to"] = DateTime.Now.ToString("dd/MM/yyyy");
				paramDateTo = (string)Session["dta_to"];
			}
		}

		if(!String.IsNullOrEmpty(Request["resetMenu"]) && Request["resetMenu"] == "1") 
		{
			Session["logsPage"] = 1;
			numPage = (int)Session["logsPage"];
			Session["log_type"] = "";
			paramType = (string)Session["log_type"];
			Session["dta_from"] = DateTime.Now.ToString("dd/MM/yyyy");
			paramDateFrom = (string)Session["dta_from"];
			Session["dta_to"]= DateTime.Now.ToString("dd/MM/yyyy");
			paramDateTo = (string)Session["dta_to"];
		}
		long totalcount=0L;
		try
		{	    
			logs = lrep.find(paramType,paramDateFrom,paramDateTo, numPage, itemsXpage,out totalcount);
		}
		catch (Exception ex)
		{
		    //Response.Write("An error occured: " + ex.Message);
			logs = new Dictionary<int, Logger>();
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
		this.pg1.parameters = "items="+itemsXpage+"&cssClass="+cssClass;	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPage;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = "items="+itemsXpage+"&cssClass="+cssClass;	
	}
}