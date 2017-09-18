<%@ Page Language="C#" Debug="true" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<script runat="server">
public ASP.BoMultiLanguageControl lang;
protected IList<OrderProductAttachmentDownload> attachments;
protected bool hasAttach;
protected IProductRepository prodrep;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
		
	prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log;
	StringBuilder builder;
	hasAttach = false;
		
	try
	{
		int idOrder = Convert.ToInt32(Request["id_order"]);
		int provider = Convert.ToInt32(Request["provider"]);
		
		
		
		
	}
	catch(Exception ex)
	{
		builder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		//log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
		//lrep.write(log);
		//Response.Write(builder.ToString());
		Response.StatusCode = 400;
	}
}
</script>