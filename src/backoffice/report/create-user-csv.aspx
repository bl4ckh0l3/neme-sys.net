<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;
	
protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Clear();				
	Response.ContentType = "text/csv";
	Response.AddHeader("content-disposition", "attachment;  filename=csv_user.csv");
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	login.acceptedRoles = "1";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}

	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	INewsletterRepository newslrep = RepositoryFactory.getInstance<INewsletterRepository>("INewsletterRepository");
	IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
	StringBuilder result = new StringBuilder();
	string search_key = "";
	int order_by = 1;
	string rolef = "";
	string publicf = null;
	string activef = null;	
	IList<User> users;	
	IList<UserField> usrfields;
	IList<UserGroup> groupsu;
	IList<Newsletter> newsletters;
	bool bolFoundLista = false;	
	bool bolFoundField = false;
	bool bolHasFieldFilterActive = false;
	IDictionary<int,string> filteredFieldsActive = new Dictionary<int,string>();

	try{				
		groupsu = usrrep.getAllUserGroup();
		if(groupsu == null){				
			groupsu = new List<UserGroup>();						
		}
	}catch (Exception ex){
		groupsu = new List<UserGroup>();
	}
	try{				
		newsletters = newslrep.findActive();		
		if(newsletters == null){				
			newsletters = new List<Newsletter>();						
		}
	}catch (Exception ex){
		newsletters = new List<Newsletter>();
	}

	if (!String.IsNullOrEmpty(Request["search_key"])) {
		search_key = Request["search_key"];
	}
	if (!String.IsNullOrEmpty(Request["rolef"])) {
		rolef = Request["rolef"];
	}
	if (!String.IsNullOrEmpty(Request["publicf"])) {
		publicf = Request["publicf"];
	}
	if (!String.IsNullOrEmpty(Request["activef"])) {
		activef = Request["activef"];
	}
	if (!String.IsNullOrEmpty(Request["order_by"])) {
		order_by = Convert.ToInt32(Request["order_by"]);
	}
		
	try
	{
		users = new List<User>();
		try
		{
			users = usrrep.find(search_key, rolef, activef, publicf, "false", order_by, false, false, false, false, true,true);
			if(users != null)
			{				
				bolFoundLista = true;					
			}    	
		}
		catch (Exception ex)
		{
			users = new List<User>();
			bolFoundLista = false;
			//Response.Write("user list error: "+ex.Message);
		}

		//***************** RECUPERO LISTA USER FIELDS 
		try
		{
			List<string> usesFor = new List<string>();
			usesFor.Add("1");
			usesFor.Add("3");
			usrfields = usrrep.getUserFields("true",usesFor);
			if(usrfields != null)
			{				
				bolFoundField = true;

				foreach(UserField uf in usrfields){
					if(uf.type==1 || uf.type==7){
						if(!String.IsNullOrEmpty(Request["user_field_"+uf.id])){
							filteredFieldsActive.Add(uf.id,Request["user_field_"+uf.id]);
							bolHasFieldFilterActive = true;
						}
					}
				}				
			}    	
		}
		catch (Exception ex)
		{
			usrfields = new List<UserField>();
			bolFoundField = false;
			//Response.Write("user field error: "+ex.Message);
		}

		//***************** APPLICO I FILTRI ALLA LISTA UTENTI
		if(bolHasFieldFilterActive){
			IList<User> toRemove = new List<User>();
			IList<bool> itemsRemove = null;
			foreach(User u in users){
				itemsRemove = new List<bool>();
				foreach (int i in filteredFieldsActive.Keys){
					bool remove=true;
					string valuetmp = "";
					if(u.fields != null && u.fields.Count>0){
						foreach(UserFieldsMatch ufm in u.fields){
							if(i==ufm.idParentField){
								valuetmp = ufm.value;
								break;
							}							
						}
					}
				
					string[] arrFilteredField = filteredFieldsActive[i].Split(',');
					if(arrFilteredField != null){
						foreach(string x in arrFilteredField){
							if(valuetmp==x){	
								remove=false;																
								break;
							}							
						}
					}
					itemsRemove.Add(remove);
				}
				bool doRemove = false;
				foreach(bool x in itemsRemove){
					doRemove = doRemove || x;
				}
				
				
				if(doRemove){	
					toRemove.Add(u);
				}
			}
			if(toRemove.Count>0){
				foreach(User ur in toRemove){
					users.Remove(ur);
				}
			}
		}		

		//***************** SE � STATO IMPOSTATO UN ORDINAMENTO SUI FILTRI RIORDINO LA LISTA UTENTI IN BASE AL FILTRO SELEZIONATO					
		if(!String.IsNullOrEmpty(Request["order_by_fields"])) {
			string order_by_fields = Request["order_by_fields"];	
			users = UserService.sortUserByField(users, Convert.ToInt32(order_by_fields));
		}
		
		
		//CREATE CSV HEADER
		result.Append(lang.getTranslated("backend.utenti.detail.table.label.username").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.utenti.include.table.header.email").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.utenti.include.table.header.user_role").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.utenti.include.table.header.user_active").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.utenti.detail.table.label.user_group").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.utenti.detail.table.label.public_profile").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.utenti.include.table.header.sconto").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.utenti.include.table.header.admin_comments").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.utenti.detail.table.label.subscribe_newsletter").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.utenti.include.table.header.date_insert").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.utenti.include.table.header.date_modify").ToUpper());		
		if(bolFoundField){
			foreach(UserField uf in usrfields){
				string description = UserService.translate("backend.utenti.detail.table.label.description_"+uf.description, uf.description, lang.currentLangCode, lang.defaultLangCode);
				result.Append(",").Append(description.ToUpper());
			}
		}
		result.Append(System.Environment.NewLine);
		
		//APPEND CSV ROWS
		foreach(User usr in users){
			string urole = usr.role.labelU;
			string uactive = "";
			if (usr.isActive) { 
				uactive = lang.getTranslated("backend.commons.yes");
			}else{ 
				uactive = lang.getTranslated("backend.commons.no");
			}			
			string ugroup = "";
			UserGroup groupu = usrrep.getUserGroup(usr);
			if (groupu!=null) {
				ugroup = groupu.shortDesc;
			}
			string upublic = "";
			if (usr.isPublicProfile) { 
				upublic = lang.getTranslated("backend.commons.yes");
			}else{ 
				upublic = lang.getTranslated("backend.commons.no");
			}
			string uboComments = usr.boComments;
			uboComments=uboComments.Replace("\"","\"\"");
			string unewsletters = "";
			if(newsletters!=null) {
				foreach(Newsletter x in newsletters){									
					if(usr.newsletters!=null && usr.newsletters.Count>0){
						foreach(UserNewsletter un in usr.newsletters){
							if(un.newsletterId==x.id){
								unewsletters+=x.description+", ";
								break;
							}
						}
					}				  
				}
				if(!String.IsNullOrEmpty(unewsletters)){
					unewsletters = unewsletters.Substring(0,unewsletters.LastIndexOf(','));
				}
			}

			
			result.Append("\"").Append(usr.username).Append("\",")
			.Append("\"").Append(usr.email).Append("\",")
			.Append("\"").Append(urole).Append("\",")
			.Append("\"").Append(uactive).Append("\",")
			.Append("\"").Append(ugroup).Append("\",")
			.Append("\"").Append(upublic).Append("\",")
			.Append("\"").Append(usr.discount.ToString()).Append("\",")
			.Append("\"").Append(uboComments).Append("\",")
			.Append("\"").Append(unewsletters).Append("\",")
			.Append("\"").Append(usr.insertDate.ToString("dd/MM/yyyy")).Append("\",")
			.Append("\"").Append(usr.modifyDate.ToString("dd/MM/yyyy")).Append("\"");			
			if(bolFoundField){
				foreach(UserField uf in usrfields){
					if(usr.fields != null && usr.fields.Count>0){
						result.Append(",\"");
						foreach(UserFieldsMatch f in usr.fields){
							if(uf.id==f.idParentField){
								result.Append(f.value.Replace("\"","\"\""));
								break;
							}								
						}
						result.Append("\"");
					}else{
						result.Append(",\"").Append("\"");
					}
				}
			}			
			
			result.Append(System.Environment.NewLine);
		}			
	}
	catch (Exception ex)
	{
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
		
	Response.Write(result.ToString());
	Response.End();
}
</script>