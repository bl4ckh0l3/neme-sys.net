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

public partial class _Default : Page 
{
	public ASP.MultiLanguageControl lang;
	protected string hierarchy;
	protected string categoryid;
	protected string forcedLangCode;
	protected string resolved;
	
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	}
	
	protected void Page_Load(object sender, EventArgs e) 
	{
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;
		hierarchy = "";
		categoryid = "";
		forcedLangCode = "";
		resolved = "";
		ConfigurationService confService = new ConfigurationService();
		string thisLangCode = lang.currentLangCode;
		if(String.IsNullOrEmpty(thisLangCode)){
			thisLangCode = lang.defaultLangCode;
		}
		
		if (!"1".Equals(confService.get("go_offline").value)) 
		{
			try
			{
				UriBuilder builder0 = CommonService.getBaseUrl(Request.Url.ToString(),2);
				
				resolved = TemplateService.resolveDefaultPath(builder0.Scheme, thisLangCode, Request["categoryid"], Request["hierarchy"], out forcedLangCode, out categoryid, out hierarchy);
				//Response.Write("resolved:"+resolved);
				if(!String.IsNullOrEmpty(resolved)){
					builder0.Path = resolved;		
					resolved = builder0.ToString();	
				}
			}
			catch (Exception ex){
				//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				resolved = "";
			}
			//Response.Write("Context.Items[hierarchy]: " + Context.Items["hierarchy"]+"<br><br>Context.Items[categoryid]: "+Context.Items["categoryid"]+"<br><br>");
			
			//UriBuilder urlBuilder = new UriBuilder(resolved);
			//Response.Redirect(urlBuilder.Path,true);			
			//Server.Transfer("~"+urlBuilder.Path, true);				
		}
	}
}
