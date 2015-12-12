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
protected ILoggerRepository lrep;

protected void Page_Init(Object sender, EventArgs e)
{
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	login.acceptedRoles = "1,2";
	if(!login.checkedUser()){
		return;
	}
	
	lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
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
	/*									
	String tmp = "id_objref: " +Request["id_objref"]+" -className: " + className+" -repositoryName: " + repositoryName+" -accessoryClass: " + accessoryClass+" -accessoryMethod: " + accessoryMethod+" -accessoryMethodModificator: " + accessoryMethodModificator+" -accessoryMethodParams: " + accessoryMethodParams+"<br>";
	builder = new StringBuilder("Exception: ")
	.Append("debug: ").Append(tmp);
	log = new Logger(builder.ToString(),"system","debug",DateTime.Now);		
	lrep.write(log);
	*/
	try
	{
		int id_objref = Convert.ToInt32(Request["id_objref"]);
		Assembly assembly = Assembly.Load("App_Code");
		RepositoryService reposervice = new RepositoryService();		
		
		MethodInfo getInst = null;
		Object o = null;
		
		if(!String.IsNullOrEmpty(repositoryName)){
			Object o2 = assembly.CreateInstance(reposervice.get(repositoryName).value);
			getInst = o2.GetType().GetMethod("getById");
			o = getInst.Invoke(o2, new object[]{id_objref});		
			MethodInfo upd = o2.GetType().GetMethod("delete");
			upd.Invoke(o2, new object[]{o});
			/*
			getInst = o.GetType().GetMethod("ToString");
			Object toStr = getInst.Invoke(o, null);
			
			builder = new StringBuilder("delete ")
			.Append(o.GetType().ToString()).Append(": ").Append(toStr.ToString());
			log = new Logger(builder.ToString(),login.userLogged.username,"info",DateTime.Now);
			lrep.write(log);
			*/
		}
		
		if(!String.IsNullOrEmpty(accessoryClass) && !String.IsNullOrEmpty(accessoryMethod) && !String.IsNullOrEmpty(accessoryMethodModificator) && !String.IsNullOrEmpty(accessoryMethodParams))
		{			
			// gestisco eventuali altre chiamate e metodi custom
			MethodInfo method;
			
			try
			{
				o = assembly.CreateInstance(reposervice.get(accessoryClass).value);
				method = o.GetType().GetMethod(accessoryMethod);
				method.Invoke(o,new object[]{Convert.ToInt32(accessoryMethodParams)});
			}catch(Exception ex){
				o=null;
			}
			
			if(o==null){
				o = assembly.CreateInstance(accessoryClass);

				if("static"==accessoryMethodModificator)
				{
					method = o.GetType().GetMethod(accessoryMethod,BindingFlags.Public|BindingFlags.Static);
					method.Invoke(null,new object[]{accessoryMethodParams});
				}
				else
				{
					method = o.GetType().GetMethod(accessoryMethod);
					method.Invoke(o,new object[]{accessoryMethodParams});
				}
			}
				
			//Response.Write("o: " + o.ToString()+"<br>");
			
			/*
			getInst = o.GetType().GetMethod("ToString");
			Object toStr = getInst.Invoke(o, null);
			
			builder = new StringBuilder("delete ")
			.Append(o.GetType().ToString()).Append(": ").Append(toStr.ToString());
			log = new Logger(builder.ToString(),login.userLogged.username,"info",DateTime.Now);
			lrep.write(log);
			*/
		}
	}
	catch(Exception ex)
	{
		/*
		builder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		*/
		//Response.Write(ex.Message+"<br><br>"+ex.StackTrace);
		Response.StatusCode = 400;
	}
}
</script>