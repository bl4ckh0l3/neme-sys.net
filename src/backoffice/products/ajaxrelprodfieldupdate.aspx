<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="Newtonsoft.Json" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Data" %>
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
		
	IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log = new Logger();
	StringBuilder errorMsg = new StringBuilder();
	StringBuilder result = new StringBuilder();
			
	bool carryOn = true;
	try
	{
		int id_prod = Convert.ToInt32(Request["id_prod"]);
		int id_field = Convert.ToInt32(Request["id_field"]);
		string field_val = Request["field_val"];
		int id_field_rel = Convert.ToInt32(Request["id_field_rel"]);
		string field_rel_val = Request["field_rel_val"];
		int qta_rel = 0;
		if(!String.IsNullOrEmpty(Request["qta_rel"])){
			qta_rel = Convert.ToInt32(Request["qta_rel"]);
		}
		string field_desc = Request["field_desc"];
		string optype = Request["optype"];
		
		result.Append("{")
		.Append("\"id_prod\":\"").Append(id_prod).Append("\",")
		.Append("\"id_field\":\"").Append(id_field).Append("\",")
		.Append("\"field_val\":\"").Append(field_val).Append("\",")
		.Append("\"id_field_rel\":\"").Append(id_field_rel).Append("\",")
		.Append("\"field_rel_val\":\"").Append(field_rel_val).Append("\",")
		.Append("\"qta_rel\":\"").Append(qta_rel).Append("\",")
		.Append("\"field_desc\":\"").Append(field_desc).Append("\"")
		.Append("}");
		
		if("update"==optype){
			prodrep.insertProductFieldRelValue(id_prod, id_field, field_val, id_field_rel, field_rel_val, qta_rel, field_desc);
		}else if("delete"==optype){
			prodrep.deleteProductFieldRelValue(id_prod, id_field, field_val, id_field_rel, field_rel_val);
		}	
	}
	catch(Exception ex)
	{
		errorMsg.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
		carryOn = false;
		//Response.Write(ex.Message);
	}
		
	if(carryOn){
		//Response.Redirect("/backoffice/products/insertproduct.aspx?id="+Request["id_product"]+"&cssClass="+cssClass);
		Response.Write(result.ToString());		
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