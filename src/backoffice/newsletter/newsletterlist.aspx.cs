using System;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.services;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

public partial class _NewsletterList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected INewsletterRepository newslrep;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected string cssClass;		
	protected IList<Newsletter> newsletters;
	protected IList<MailMsg> templates;
	protected string mailTemlateName;	
	
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
		cssClass="LNL";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
	
		newslrep = RepositoryFactory.getInstance<INewsletterRepository>("INewsletterRepository");	
		IMailRepository mailrep = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
		mailTemlateName = "";

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["newsletterItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["newsletterItems"];
		}else{
			if (Session["newsletterItems"] != null) {
				itemsXpage = (int)Session["newsletterItems"];
			}else{
				Session["newsletterItems"] = 20;
				itemsXpage = (int)Session["newsletterItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["newsletterPage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["newsletterPage"];
		}else{
			if (Session["newsletterPage"] != null) {
				numPage = (int)Session["newsletterPage"];
			}else{
				Session["newsletterPage"]= 1;
				numPage = (int)Session["newsletterPage"];
			}
		}

		try
		{
			templates = mailrep.findByCategory("newsletter");	    	
		}
		catch (Exception ex)
		{
			templates = new List<MailMsg>();
		}
		
		long totalcount=0L;
		try
		{			
			newsletters = newslrep.find(numPage, itemsXpage, out totalcount);
			if(newsletters != null)
			{				
				bolFoundLista = true;					
			}	    	
		}
		catch (Exception ex)
		{
			newsletters = new List<Newsletter>();
			bolFoundLista = false;
		}
	
		if(itemsXpage>0){_totalPages = (int)totalcount/itemsXpage;}
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