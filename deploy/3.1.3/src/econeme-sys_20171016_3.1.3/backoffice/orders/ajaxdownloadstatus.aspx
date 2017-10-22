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
		int idProduct = Convert.ToInt32(Request["id_element"]);
		
		attachments = orderep.getAttachmentDownload(idOrder, idProduct);
		if(attachments != null && attachments.Count>0){
			hasAttach = true;
		}
	}
	catch(Exception ex)
	{
		builder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		//log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
		//lrep.write(log);
		Response.Write(builder.ToString());
		Response.StatusCode = 400;
	}
}
</script>
<%if(hasAttach){%>
	<table border="0" cellpadding="0" cellspacing="0" id="order-table-down-status">
		<%foreach(OrderProductAttachmentDownload c in attachments){
			ProductAttachmentDownload pad = prodrep.getProductAttachmentDownloadById(c.idDownFile);
			if(pad != null){%>
				<tr class="filename">
				<td colspan="4"><%=lang.getTranslated("backend.popup.label.filename")%>: <%=pad.fileName%></td>
				</tr>
				<tr>
				<th><%=lang.getTranslated("backend.popup.label.max_download")%>:</th>
				<td><%if(c.maxDownload == -1){Response.Write(lang.getTranslated("backend.popup.label.unlimited_download"));}else{Response.Write(c.maxDownload);}%></td>
				<th><%=lang.getTranslated("backend.popup.label.download_counter")%>:</th>
				<td><%=c.downloadCounter%></td>
				</tr>
				<tr>
				<th><%=lang.getTranslated("backend.popup.label.expire_date")%>:</th>
				<td><%if(c.expireDate.Year == 9999){Response.Write(lang.getTranslated("backend.popup.label.unlimited_download"));}else{Response.Write(c.expireDate.ToString("dd/MM/yyyy HH:mm:ss"));}%></td>
				<th><%=lang.getTranslated("backend.popup.label.download_date")%>:</th>
				<td><%if(c.downloadDate.Year == 9999){Response.Write("");}else{Response.Write(c.downloadDate.ToString("dd/MM/yyyy HH:mm:ss"));}%></td>
				</tr>
			<%}
		}%>
	</table>
<%}else{%>
	<div align="center"><%=lang.getTranslated("backend.popup.label.no_prod_download")%></div><br>
<%}%>