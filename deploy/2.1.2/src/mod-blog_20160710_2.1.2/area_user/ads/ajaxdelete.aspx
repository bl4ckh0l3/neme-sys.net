<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
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
	login.acceptedRoles = "3";
	if(!login.checkedUser()){
		return;
	}
	
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log;
	StringBuilder builder;
	
	string objtype = Request["objtype"];
	string className = "";
	string repositoryName = "";
	string accessoryClass = "";
	string accessoryMethod = "";
	string accessoryMethodModificator = "";
	string accessoryMethodParams = "";
	
	if(!String.IsNullOrEmpty(objtype)){
		string[] p = objtype.Split('|');
		if(p!=null){
			className = p[0];
			repositoryName = p[1];
			
			if(p.Length>=3){
				accessoryClass = p[2];
			}
			if(p.Length>=4){
				accessoryMethod = p[3];
			}
			if(p.Length>=5){
				accessoryMethodModificator = p[4];
			}
			if(p.Length>=6){
				accessoryMethodParams = p[5];
			}
		}								
	}
										
	Response.Write("className: " + className+" -repositoryName: " + repositoryName+" -accessoryClass: " + accessoryClass+" -accessoryMethod: " + accessoryMethod+" -accessoryMethodParams: " + accessoryMethodParams+"<br>");
	
	try
	{
		int id_objref = Convert.ToInt32(Request["id_objref"]);
		Assembly assembly = Assembly.Load("App_Code");
		RepositoryService reposervice = new RepositoryService();
		Object o2 = assembly.CreateInstance(reposervice.get(repositoryName).value);		
		
		MethodInfo getInst = o2.GetType().GetMethod("getById");
		Object o = getInst.Invoke(o2, new object[]{id_objref});

		MethodInfo upd = o2.GetType().GetMethod("delete");
		upd.Invoke(o2, new object[]{o});
			
		// gestisco eventuali altre chiamate e metodi custom
		if(!String.IsNullOrEmpty(accessoryClass) && !String.IsNullOrEmpty(accessoryMethod) && !String.IsNullOrEmpty(accessoryMethodModificator) && !String.IsNullOrEmpty(accessoryMethodParams))
		{
			Object o3 = assembly.CreateInstance(accessoryClass);
			//Response.Write("o3: " + o3.ToString()+"<br>");
			MethodInfo method;
			if("static"==accessoryMethodModificator)
			{
				method = o3.GetType().GetMethod(accessoryMethod,BindingFlags.Public|BindingFlags.Static);
				method.Invoke(null,new object[]{accessoryMethodParams});
			}
			else
			{
				method = o3.GetType().GetMethod(accessoryMethod);
				method.Invoke(o3,new object[]{accessoryMethodParams});
			}
		}

		getInst = o.GetType().GetMethod("ToString");
		Object toStr = getInst.Invoke(o, null);
		
		builder = new StringBuilder("delete ")
		.Append(o.GetType().ToString()).Append(": ").Append(toStr.ToString());
		log = new Logger(builder.ToString(),login.userLogged.username,"info",DateTime.Now);
		lrep.write(log);		
	}
	catch(Exception ex)
	{
		builder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		Response.StatusCode = 400;
	}
}
</script>