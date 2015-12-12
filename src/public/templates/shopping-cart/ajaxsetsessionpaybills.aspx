<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="Newtonsoft.Json" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
			
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}	

protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;		
	login.acceptedRoles = "";
	bool logged = login.checkedUser();
	bool carryOn = false;
		
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log = new Logger();
	StringBuilder errorMsg = new StringBuilder();
	
	try
	{
		string operation = Request["operation"];
		
		//Response.Write("operation: "+operation+"<br>");
		
		foreach (string x in Request.Form.AllKeys)
		{
			//Response.Write("x: "+x+"<br>");
		
			if(!"operation".Equals(x)){
				if(Session[x] != null && "del".Equals(operation)){
					string sessionTmp = (string)Session[x];
					Session[x]="";
					foreach(string q in sessionTmp.Split(',')){
						if(!q.Trim().Equals(Request.Form[x])){
							Session[x]+=q.Trim()+",";
						}
					}
					if(((string)Session[x]).Trim().EndsWith(",")){
						Session[x]=((string)Session[x]).Substring(0,((string)Session[x]).Length-1);
					}
					//Response.Write("del Session[x]: "+Session[x]+"<br>");
				}else if(Session[x] != null && "add".Equals(operation)){
					Session[x]+=","+Request.Form[x].Trim();
					//Response.Write("add Session[x]: "+Session[x]+"<br>");
				}else if("addone".Equals(operation)){
					Session[x]=Request.Form[x].Trim();
					//Response.Write("addone Session[x]: "+Session[x]+"<br>");
				}else{
					Session[x]=Request.Form[x].Trim();
					//Response.Write("Session[x]: "+Session[x]+"<br>");
				}
			}
		}
	}
	catch(Exception ex)
	{
		errorMsg.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
		log = new Logger(errorMsg.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
	}
}
</script>