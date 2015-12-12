<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<script runat="server">
protected void Page_Load(Object sender, EventArgs e)
{
	IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log;
	StringBuilder builder;
		
	try
	{
		int id_objref = Convert.ToInt32(Request["id_attach"]);
		int type = Convert.ToInt32(Request["attach_type"]);
		if(type==0){
			prodrep.deleteProductAttachment(id_objref);
			ProductService.deleteAttachment(Request["file_path"],type);
		}else if(type==1){
			prodrep.deleteProductAttachmentDownload(id_objref);
			ProductService.deleteAttachment(Request["file_path"], type);		
		}
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