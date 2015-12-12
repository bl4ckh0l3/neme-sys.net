using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using NHibernate;
using NHibernate.Criterion;

public partial class _Newsletter : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected Newsletter newsletter;
	protected IList<MailMsg> templates;
	
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
		INewsletterRepository newslrep = RepositoryFactory.getInstance<INewsletterRepository>("INewsletterRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		IMailRepository mailrep = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
		newsletter = new Newsletter();		
		newsletter.id = -1;		
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				newsletter = newslrep.getById(Convert.ToInt32(Request["id"]));
			}catch (Exception ex){
				newsletter = new Newsletter();		
				newsletter.id = -1;
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

		//******** INSERISCO NUOVA CATEGORIA / MODIFICO ESISTENTE						
		if("insert".Equals(Request["operation"]))
		{				
			string description = Request["description"];
			bool isActive = Convert.ToBoolean(Convert.ToInt32(Request["active"]));	
			
			int idTemplate = -1;
			if(!String.IsNullOrEmpty(Request["templateid"])){
				idTemplate = Convert.ToInt32(Request["templateid"]);	
			}
			
			int idVoucher = -1;
			if(!String.IsNullOrEmpty(Request["voucherid"])){
				idVoucher = Convert.ToInt32(Request["voucherid"]);	
			}
			
			newsletter.description = description;
			newsletter.isActive = isActive;
			newsletter.templateId = idTemplate;
			newsletter.idVoucherCampaign = idVoucher;

			bool carryOn = true;
			try
			{			
				if(newsletter.id != -1){
					newslrep.update(newsletter);
				}else{
					newslrep.insert(newsletter);
				}
				
				log.usr= login.userLogged.username;
				log.msg = "save newsletter: "+newsletter.ToString();
				log.type = "info";
				log.date = DateTime.Now;
				lrep.write(log);	
			}
			catch (Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));					
				carryOn = false;
			}									
								
			if(carryOn){
				Response.Redirect("/backoffice/newsletter/newsletterlist.aspx?cssClass="+cssClass);		
			}else{
				Response.Redirect(url.ToString());
			}			
		}		

	}
}