<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
private ASP.UserLoginControl login;

protected void Page_Init(Object sender, EventArgs e)
{
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	//Response.Clear();
	//Response.ContentType = "text/html";
	login.acceptedRoles = "3";
	if(!login.checkedUser()){
		return;
	}
	
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log;
	StringBuilder builder;
	
	string fieldName = Request["field_name"];
	string fieldValue = Request["field_val"];
	string objtype = Request["objtype"];
	string className = "";
	string repositoryName = "";
	string fieldType = "";
	string getMethod = "getById";
	string updateMethod = "update";
	
	if(!String.IsNullOrEmpty(objtype)){
		string[] p = objtype.Split('|');
		if(p!=null){
			className = p[0];
			repositoryName = p[1];
			fieldType = p[2];
			
			if(p.Length>=4){
				getMethod = p[3];
			}
			if(p.Length>=5){
				updateMethod = p[4];
			}
		}								
	}
	
	try
	{
		int id_objref = Convert.ToInt32(Request["id_objref"]);
		
		Assembly assembly = Assembly.Load("App_Code");
		RepositoryService reposervice = new RepositoryService();
		Object o2 = assembly.CreateInstance(reposervice.get(repositoryName).value);
		
		MethodInfo getInst = o2.GetType().GetMethod(getMethod);
		Object o = getInst.Invoke(o2, new object[]{id_objref});

		//Converto il valore verso il tipo corretto
		if(fieldType=="int"){
			o.GetType().GetProperty(fieldName).SetValue(o,Convert.ToInt32(fieldValue), null);
		}else if(fieldType=="decimal"){
			o.GetType().GetProperty(fieldName).SetValue(o,Convert.ToDecimal(fieldValue), null);			
		}else if(fieldType=="string"){
			o.GetType().GetProperty(fieldName).SetValue(o,fieldValue, null);			
		}else if(fieldType=="date"){
			o.GetType().GetProperty(fieldName).SetValue(o,Convert.ToDateTime(fieldValue), null);			
		}else if(fieldType=="datetime"){
			o.GetType().GetProperty(fieldName).SetValue(o,DateTime.ParseExact(fieldValue, "dd/MM/yyyy HH.mm", null), null);			
		}else if(fieldType=="bool"){
			o.GetType().GetProperty(fieldName).SetValue(o,Convert.ToBoolean(Convert.ToInt32(fieldValue)), null);			
		}else{
			if(!String.IsNullOrEmpty(fieldType)){
				string[] p = fieldType.Split('.');
				if(p!=null){
					string obj = p[0];
					string field= p[1];
					string type = p[2];
					
					Object o3 = assembly.CreateInstance("com.nemesys.model."+obj);
					if(type=="int"){
						o3.GetType().GetProperty(field).SetValue(o3,Convert.ToInt32(fieldValue), null);
					}else if(type=="decimal"){
						o3.GetType().GetProperty(field).SetValue(o3,Convert.ToDecimal(fieldValue), null);			
					}else if(type=="string"){
						o3.GetType().GetProperty(field).SetValue(o3,fieldValue, null);			
					}else if(type=="date"){
						o3.GetType().GetProperty(field).SetValue(o3,Convert.ToDateTime(fieldValue), null);			
					}else if(type=="datetime"){
						o3.GetType().GetProperty(field).SetValue(o3,DateTime.ParseExact(fieldValue, "dd/MM/yyyy HH.mm", null), null);			
					}else if(type=="bool"){
						o3.GetType().GetProperty(field).SetValue(o3,Convert.ToBoolean(Convert.ToInt32(fieldValue)), null);			
					}
					o.GetType().GetProperty(fieldName).SetValue(o,o3, null);
				}				
			}
		}

		MethodInfo upd = o2.GetType().GetMethod(updateMethod);
		upd.Invoke(o2, new object[]{o});	

		getInst = o.GetType().GetMethod("ToString");
		Object toStr = getInst.Invoke(o, null);
		
		builder = new StringBuilder("save ")
		.Append(o.GetType().ToString()).Append(": ").Append(toStr.ToString());
		log = new Logger(builder.ToString(),login.userLogged.username,"info",DateTime.Now);
		lrep.write(log);
	}
	catch(Exception ex)
	{
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
		builder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		Response.StatusCode = 400;
	}
}
</script>