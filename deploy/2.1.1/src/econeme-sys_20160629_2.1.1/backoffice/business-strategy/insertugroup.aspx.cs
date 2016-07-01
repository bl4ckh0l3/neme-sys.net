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

public partial class _UserGroup : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected UserGroup usergroup;
	protected IList<SupplementGroup> supplements;
	
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
		cssClass="LM";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		IUserRepository userrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		ISupplementGroupRepository suprep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
		usergroup = new UserGroup();		
		usergroup.id = -1;		
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();

		// recupero elementi della pagina necessari
		try{			
			supplements = suprep.getSupplementGroups();	
			if(supplements == null){				
				supplements = new List<SupplementGroup>();						
			}
		}catch (Exception ex){
			supplements = new List<SupplementGroup>();
		}
		
		if(!String.IsNullOrEmpty(Request["id_group"]) && Request["id_group"]!= "-1")
		{
			try{
				usergroup = userrep.getUserGroupById(Convert.ToInt32(Request["id_group"]));
			}catch (Exception ex){
				usergroup = new UserGroup();		
				usergroup.id = -1;
			}	
		}	

		//******** INSERISCO NUOVA CATEGORIA / MODIFICO ESISTENTE						
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;
			try
			{			
				string short_desc = Request["short_desc"];
				string long_desc = Request["long_desc"];
				bool bolDefGroup = Convert.ToBoolean(Convert.ToInt32(Request["default_group"]));	
				if(bolDefGroup){
					IList<UserGroup> checklist = userrep.getAllUserGroup();
					foreach(UserGroup ug in checklist){
						if(ug.defaultGroup && ug.id != usergroup.id){
							Response.Redirect("/backoffice/business-strategy/insertugroup.aspx?err=1&cssClass="+cssClass+"&id_group="+usergroup.id);
							break;						
						}
					}
				}
				if(carryOn)
				{	
					bool bolProdDisc = Convert.ToBoolean(Convert.ToInt32(Request["prod_disc"]));
					bool bolUserdisc = Convert.ToBoolean(Convert.ToInt32(Request["user_disc"]));
					decimal margin = 0;
					if(!String.IsNullOrEmpty(Request["margin"])){
						margin = Convert.ToDecimal(Request["margin"]);
					}
					decimal discount = 0;
					if(!String.IsNullOrEmpty(Request["discount"])){
						discount = Convert.ToDecimal(Request["discount"]);
					}
					
					int taxsGroup = -1;
					if(!String.IsNullOrEmpty(Request["taxs_group"])){
						taxsGroup = Convert.ToInt32(Request["taxs_group"]);	
					}
					
					usergroup.shortDesc = short_desc;
					usergroup.longDesc = long_desc;
					usergroup.defaultGroup = bolDefGroup;
					usergroup.applyProdDiscount = bolProdDisc;
					usergroup.applyUserDiscount = bolUserdisc;
					usergroup.margin = margin;
					usergroup.discount = discount;
					usergroup.supplementGroup = taxsGroup;
					
					//Response.Write(usergroup.ToString());
				
					if(usergroup.id != -1){
						userrep.updateUserGroup(usergroup);
					}else{
						userrep.insertUserGroup(usergroup);
					}
					
					log.usr= login.userLogged.username;
					log.msg = "save usergroup: "+usergroup.ToString();
					log.type = "info";
					log.date = DateTime.Now;
					lrep.write(log);	
				}
			}
			catch (Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));					
				carryOn = false;
				//Response.Write(ex.Message);
			}									
								
			if(carryOn){
				Response.Redirect("/backoffice/business-strategy/strategylist.aspx?cssClass="+cssClass);		
			}else{
				Response.Redirect(url.ToString());
			}			
		}		

	}
}