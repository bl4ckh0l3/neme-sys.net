using System;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Collections.Generic;
using com.nemesys.model;
using com.nemesys.services;
using com.nemesys.database.repository;

public partial class _Configuration : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	ConfigurationService confservice = new ConfigurationService();
	public string cssClass;		
	public IList<Config> configs;
	
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
		cssClass="CP";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		Logger log = new Logger();
		bool carryOn = true;

		if(!String.IsNullOrEmpty(Request["keyword"]) && Request["operation"]=="insert")
		{
			try
			{
				Config config = new Config();
				config.key=Request["keyword"];
				config.description=Request["description"];
				config.value=Request["value"];
				config.alert=Request["alert"];
				config.type=Request["type"];
				config.type_values=Request["type_values"];
				config.is_base=Convert.ToBoolean(Convert.ToInt32(Request["is_base"]));
				confservice.insert(config);
			
				log.usr= login.userLogged.username;
				log.msg = "insert new system configuration variable--> key: "+Request["keyword"]+"; value: "+Request["value"];
				log.type = "info";
				log.date = DateTime.Now;
				lrep.write(log);						
			}catch (Exception ex){
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				carryOn = false;						
			}
			
			if(!carryOn){
				Response.Redirect(url.ToString());						
			}
		}

		if(!String.IsNullOrEmpty(Request["key"]))
		{
			Config config = confservice.get(Request["key"]);
			if(config != null)
			{	
				try
				{
					if(Request["operation"]=="delete"){
						confservice.delete(config.key);
					}else{
						config.value = Request["value"];
						confservice.update(config);
					}
					log.usr= login.userLogged.username;
					log.msg = "modifed system configuration variable--> key: "+Request["key"]+"; value: "+Request["value"];
					log.type = "info";
					log.date = DateTime.Now;
					lrep.write(log);						
				}catch (Exception ex){
					url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));	
					carryOn = false;					
				}
				if(!carryOn){
					Response.Redirect(url.ToString());						
				}
			}
		} 
						
		try
		{   
			configs = confservice.getAllConfigurations();
		}
		catch (Exception ex)
		{
		    //Response.Write("An error occured: " + ex.Message);
			configs = new List<Config>();
		}
	}
}