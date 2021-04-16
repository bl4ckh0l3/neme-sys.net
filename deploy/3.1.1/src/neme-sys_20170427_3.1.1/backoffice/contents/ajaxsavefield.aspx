<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
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
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	string cssClass="LN";	
	login.acceptedRoles = "1,2";
	if(!login.checkedUser()){
		//Response.Redirect("~/login.aspx?error_code=002");
		Response.StatusCode = 400;
		return;
	}
		
	IContentRepository contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
	ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IMultiLanguageRepository mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
	Logger log = new Logger();
	StringBuilder errorMsg = new StringBuilder();
	IList<Language> languages;
	ContentField newField = new ContentField();

	try{			
		languages = langrep.getLanguageList();	
		if(languages == null){				
			languages = new List<Language>();						
		}
	}catch (Exception ex){
		languages = new List<Language>();
	}
			
	bool carryOn = true;
	try
	{
		if("addfield"==Request["operation"]){
			newField.id=-1;
		}else if("updfield"==Request["operation"]){
			newField = contrep.getContentFieldById(Convert.ToInt32(Request["id_field"]));
		}
		newField.idParentContent = Convert.ToInt32(Request["id_content"]);
		if(!String.IsNullOrEmpty(Request["pre_el_id"])){
			newField.idParentContent = Convert.ToInt32(Request["pre_el_id"]);					
		}
		newField.description = Request["field_description"];
		newField.groupDescription = Request["group_value"];
		newField.value = Request["field_value"];
		newField.type = Convert.ToInt32(Request["id_type"]);
		newField.typeContent = Convert.ToInt32(Request["id_type_content"]);
		int tmpsort = 0;
		if(!String.IsNullOrEmpty(Request["sorting"])){tmpsort = Convert.ToInt32(Request["sorting"]);}
		newField.sorting = tmpsort;
		bool tmpreq = false;
		if(!String.IsNullOrEmpty(Request["content_field_mandatory"])){tmpreq = Convert.ToBoolean(Convert.ToInt32(Request["content_field_mandatory"]));}
		newField.required = tmpreq;
		bool tmpenabled = false;
		if(!String.IsNullOrEmpty(Request["content_field_active"])){tmpenabled = Convert.ToBoolean(Convert.ToInt32(Request["content_field_active"]));}
		newField.enabled = tmpenabled;
		bool tmpedit = false;
		if(!String.IsNullOrEmpty(Request["content_field_editable"])){tmpedit = Convert.ToBoolean(Convert.ToInt32(Request["content_field_editable"]));}
		newField.editable = tmpedit;
		int tmpmlen = -1;
		if(!String.IsNullOrEmpty(Request["max_lenght"])){tmpmlen = Convert.ToInt32(Request["max_lenght"]);}
		newField.maxLenght = tmpmlen;
		
		// PREPARO LE LISTE DI CHIAVI MULTILINGUA DA INSERIRE/AGGIORNARE IN TRANSAZIONE
		IList<MultiLanguage> newtranslactions = new List<MultiLanguage>();
		IList<MultiLanguage> updtranslactions = new List<MultiLanguage>();
		IList<MultiLanguage> deltranslactions = new List<MultiLanguage>();	
		
		//Response.Write("field_description_ml:"+Request["field_description_ml"]+"<br>");			
		
		if(!String.IsNullOrEmpty(Request["field_description_ml"]))
		{
			IDictionary<string,string> mlvalues = new Dictionary<string,string>();
			string[] p = Regex.Split(Request["field_description_ml"],"##");
			if(p!=null){
				//Response.Write("Length:"+p.Length+"<br>");	
				foreach (string item in p){
					//Response.Write("field_description_ml item:"+item+"<br>");			
					string[] p2 = item.Split('=');
					if(p2!=null){
						mlvalues.Add(p2[0],p2[1]);
					}							
				}						
			} 
									
			if(mlvalues.Count>0)
			{
				MultiLanguage ml;
				foreach (Language x in languages){
					//*** insert subject
					ml = mlangrep.find("backend.contenuti.detail.table.label.field_description_"+newField.description, x.label);					
					if(ml != null){
						string tmpval = "";
						ml.value = "";
						mlvalues.TryGetValue(x.label, out tmpval);	
						
//log = new Logger("update -- tmpval:"+tmpval+"; - key: backend.contenuti.detail.table.label.field_description_; - newField.description:"+newField.description+ " - ml != null: "+ (ml != null),"system","debug",DateTime.Now);		
//lrep.write(log);							
						
						if(!String.IsNullOrEmpty(tmpval)){
							ml.value = tmpval;
							updtranslactions.Add(ml);
						}else{
							deltranslactions.Add(ml);									
						}
					}else{
						ml = new MultiLanguage();
						ml.keyword = "backend.contenuti.detail.table.label.field_description_"+newField.description;
						ml.langCode = x.label;
						string tmpval = "";
						ml.value = "";
						mlvalues.TryGetValue(x.label, out tmpval);

//log = new Logger("insert -- tmpval:"+tmpval+"; - key: backend.contenuti.detail.table.label.field_description_; - newField.description:"+newField.description+ " - ml != null: "+ (ml != null),"system","debug",DateTime.Now);		
//lrep.write(log);	

						if(!String.IsNullOrEmpty(tmpval)){	
							ml.value = tmpval;			
							newtranslactions.Add(ml);
						}
					}
				}	
			}			
		}
		
		//recupero i field values
		IList<ContentFieldsValue> newFieldValues = new List<ContentFieldsValue>();
		if(!String.IsNullOrEmpty(Request["list_content_fields"]) && !String.IsNullOrEmpty(Request["list_content_fields_values"]))
		{
			string[] pf = Regex.Split(Request["list_content_fields"],"##");
			string[] pfv = Regex.Split(Request["list_content_fields_values"],"##");
			
			//Response.Write("list_content_fields:"+Request["list_content_fields"]+"<br>");
			//Response.Write("list_content_fields_values:"+Request["list_content_fields_values"]+"<br>");
			
			if(pf!=null && pfv!=null && pf.Length==pfv.Length){
				int counter = 1;
				foreach (string item in pfv){
					ContentFieldsValue cfv = new ContentFieldsValue();
					cfv.idParentField = newField.id;
					cfv.value = item;
					cfv.sorting = counter;
					newFieldValues.Add(cfv);
					counter++;
				}						
			}					
		}
						
		try
		{
			contrep.saveCompleteContentField(newField, newFieldValues, newtranslactions, updtranslactions, deltranslactions);

			foreach(MultiLanguage value in updtranslactions){
				MultiLanguageRepository.cleanCache(value);
			}		
			foreach(MultiLanguage value in deltranslactions){
				MultiLanguageRepository.cleanCache(value);
			}		
			foreach(MultiLanguage value in newtranslactions){
				MultiLanguageRepository.cleanCache(value);
			}
			
			log.usr= login.userLogged.username;
			log.msg = "save content field: "+newField.ToString();
			log.type = "info";
			log.date = DateTime.Now;
			lrep.write(log);
		}
		catch(Exception ex)
		{
			throw;					
		}	
	}
	catch(Exception ex)
	{
		errorMsg.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
		carryOn = false;
	}
		
	if(carryOn){
		//Response.Redirect("/backoffice/contents/insertcontent.aspx?id="+Request["id_content"]+"&cssClass="+cssClass);
		Response.Write(newField.id);		
	}else{
		//Response.Redirect(url.ToString());
		//url = new StringBuilder("Exception: ")
		//.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		log = new Logger(errorMsg.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		Response.StatusCode = 400;
	}
}
</script>