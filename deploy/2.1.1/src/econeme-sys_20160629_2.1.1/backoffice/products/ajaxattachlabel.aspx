<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
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
		if(Request["operation"]=="delete")
		{
			int id_objref = Convert.ToInt32(Request["id_attach_label"]);
			prodrep.deleteProductAttachmentLabel(id_objref);
		}
		else if(Request["operation"]=="insert")
		{
			ProductAttachmentLabel entry = prodrep.insertProductAttachmentLabel(Request["label_description"]);
			Response.Write(entry.id);			
		}
		else if(Request["operation"]=="reload")
		{
			IList<ProductAttachmentLabel> entries = prodrep.getProductAttachmentLabel();
			foreach(ProductAttachmentLabel c in entries)
			{
				Response.Write("<option value=\""+c.id+"\">"+c.description+"</option>");	
			}		
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