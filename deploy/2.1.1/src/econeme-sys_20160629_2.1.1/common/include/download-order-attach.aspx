<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
public ASP.UserLoginControl login;
protected ConfigurationService confservice;
	
protected void Page_Init(Object sender, EventArgs e)
{
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(object sender, EventArgs e) 
{	
	
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	IProductRepository productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	confservice = new ConfigurationService();
	int orderId = -1;
	int attachId = -1;
	string BASE_PATH = "~/app_data/products/";

	//se il sito � offline rimando a pagina default
	if ("1".Equals(confservice.get("go_offline").value)) 
	{
		UriBuilder defRedirect = new UriBuilder(Request.Url);
		defRedirect.Port = -1;	
		defRedirect.Path = "";			
		defRedirect.Query = "";
		Response.Redirect(defRedirect.ToString());
	}
	
	try
	{
		if(!String.IsNullOrEmpty(Request["orderid"])){
			orderId = Convert.ToInt32(Request["orderid"]);
		}
		
		if(!String.IsNullOrEmpty(Request["attachid"])){
			attachId = Convert.ToInt32(Request["attachid"]);
		}
		
		FOrder order = orderep.getByIdExtended(orderId, true);
		bool hasDownAttach = false;
		OrderProductAttachmentDownload selected = null;
		ProductAttachmentDownload down = null;
		
		if(order!=null && order.downloadNotified){
			if(order.products != null && order.products.Count>0){
				foreach(OrderProduct op in order.products.Values){
					if(op.productType==1){
						IList<OrderProductAttachmentDownload> attachments = orderep.getAttachmentDownload(order.id, op.idProduct);
						if(attachments != null && attachments.Count>0){
							foreach(OrderProductAttachmentDownload d in attachments){
								// check if is still valid download
								if(attachId==d.id && OrderService.canDownloadAttachment(d)){
									down =  productrep.getProductAttachmentDownloadById(d.idDownFile);
									if(down != null){
										hasDownAttach = true;
										selected = d;
										break;
									}
								}
							}
						}
					}
				}
			}
		}
		
		if(hasDownAttach){
			/******** other way to implements, it's work fine but the current one it's more compact about lines of code
			FileStream fs = File.OpenRead(Server.MapPath(BASE_PATH+down.filePath+down.fileName));			
			int length = (int)fs.Length;
			byte[] buffer;
			
			using (BinaryReader br = new BinaryReader(fs))
			{
				buffer = br.ReadBytes(length);
			}
			*/
			
			Response.Clear();
			Response.ClearHeaders();
			Response.Buffer = true;
			Response.Cache.SetCacheability(HttpCacheability.NoCache);
			Response.ContentType = down.contentType; 
			Response.AppendHeader("Content-Disposition", "attachment; filename="+down.fileName); 
			Response.BinaryWrite(File.ReadAllBytes(Server.MapPath(BASE_PATH+down.filePath+down.fileName)));
	
			//Response.BinaryWrite(buffer);
			
			Response.Flush();
			Response.Close();	
			
			//****** update OrderProductAttachmentDownload
			selected.downloadCounter=selected.downloadCounter+1;
			selected.downloadDate=DateTime.Now;
			orderep.updateAttachmentDownload(selected);
			
			Response.End();	
		}
	}catch (Exception ex){
		Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
}	
</script>