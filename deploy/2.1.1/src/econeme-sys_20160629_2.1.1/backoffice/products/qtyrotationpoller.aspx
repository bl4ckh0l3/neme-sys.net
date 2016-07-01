<%@ Page Language="C#"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Web.Caching" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	
	try{
		IList<Product> products = prodrep.find("","","1",-1,-1,"1,2,3",null,null,-1,null,null,false,false,false,false,false,false);
		if(products != null && products.Count>0){
			string rotation_mode_tmp_d ="";
			string rotation_mode_tmp_w ="";
			string rotation_mode_tmp_h ="";
			foreach(Product product in products){
				//Response.Write("<br>name:"+product.name+"<br>");
				//Response.Write("quantity:"+product.quantity+"<br>");
				//Response.Write("quantityRotationMode:"+product.quantityRotationMode+"<br>");
				//Response.Write("rotationModeValue:"+product.rotationModeValue+"<br>");
				//Response.Write("reloadQuantity:"+product.reloadQuantity+"<br>");

				bool canRotate = false;
				if(!String.IsNullOrEmpty(product.rotationModeValue) && product.reloadQuantity>0){
					string[] values = product.rotationModeValue.Split('|');
					if(values != null && values.Length==3){
						rotation_mode_tmp_d = values[0];
						rotation_mode_tmp_w = values[1];
						rotation_mode_tmp_h = values[2];
						canRotate = true;
					}
				}
				
				//Response.Write("rotation_mode_tmp_d:"+rotation_mode_tmp_d+"<br>");
				//Response.Write("rotation_mode_tmp_w:"+rotation_mode_tmp_w+"<br>");
				//Response.Write("rotation_mode_tmp_h:"+rotation_mode_tmp_h+"<br>");


				switch (product.quantityRotationMode)
				{
				    case 1:
					if(canRotate){
						DateTime current = DateTime.Now;	
						//Response.Write("current.ToString():"+current.ToString()+"<br>");								
						System.TimeSpan diffResult;
						
						ProductRotation pr = prodrep.getProductRotation(product.id, product.quantityRotationMode);
						if(pr!=null){
							StringBuilder dateString = new StringBuilder()
							.Append(pr.lastUpdate.Day).Append("/")
							.Append(pr.lastUpdate.Month).Append("/")
							.Append(pr.lastUpdate.Year).Append(" ")
							.Append(rotation_mode_tmp_h);	
							//Response.Write("pr dateString.ToString():"+dateString.ToString()+"<br>");						
							DateTime dateValue = DateTime.Parse(dateString.ToString());
							//Response.Write("pr dateValue.ToString():"+dateValue.ToString()+"<br>");
							diffResult = current.Subtract(dateValue);
						}else{
							StringBuilder dateString = new StringBuilder()
							.Append(current.Day).Append("/")
							.Append(current.Month).Append("/")
							.Append(current.Year).Append(" ")
							.Append(rotation_mode_tmp_h);	
							//Response.Write("dateString.ToString():"+dateString.ToString()+"<br>");						
							DateTime dateValue = DateTime.Parse(dateString.ToString()).AddDays(-1);
							//Response.Write("dateValue.ToString():"+dateValue.ToString()+"<br>");
							diffResult = current.Subtract(dateValue);
							pr = new ProductRotation(product.id, product.quantityRotationMode, product.rotationModeValue, current);
						}
						//Response.Write("diffResult.TotalMinutes:"+diffResult.TotalMinutes+"<br>");
						if (diffResult.TotalMinutes >= 1440) {// 1440=24h	
							pr.lastUpdate=current;
							//Response.Write("pr.ToString():"+pr.ToString()+"<br>");
							prodrep.saveCompleteProductRotation(product.id, product.reloadQuantity, pr);
						}
					}
					break;
				    case 2:
					if(canRotate){
						DateTime current = DateTime.Now;	
						//Response.Write("current.ToString():"+current.ToString()+"<br>");								
						System.TimeSpan diffResult;
						
						ProductRotation pr = prodrep.getProductRotation(product.id, product.quantityRotationMode);
						if(pr!=null){
							int thisDayOfWeek = ProductService.getDayOfWeek(rotation_mode_tmp_w);
							//Response.Write("pr current.DayOfWeek:"+Convert.ToInt32(current.DayOfWeek)+"<br>");
							int checkDay = thisDayOfWeek-Convert.ToInt32(current.DayOfWeek);
							//Response.Write("pr!=null<br>- thisDayOfWeek:"+thisDayOfWeek+"<br>- current.Day:"+current.DayOfWeek.ToString()+"<br>- checkDay(thisDayOfWeek-current.Day):"+checkDay+"<br>");	
							
							StringBuilder dateString = new StringBuilder()
							.Append(pr.lastUpdate.Day).Append("/")
							.Append(pr.lastUpdate.Month).Append("/")
							.Append(pr.lastUpdate.Year).Append(" ")
							.Append(rotation_mode_tmp_h);	
							//Response.Write("pr dateString.ToString():"+dateString.ToString()+"<br>");						
							DateTime dateValue = DateTime.Parse(dateString.ToString()).AddDays(checkDay);
							//Response.Write("pr dateValue.ToString():"+dateValue.ToString()+"<br>");
							diffResult = current.Subtract(dateValue);
						}else{
							int thisDayOfWeek = ProductService.getDayOfWeek(rotation_mode_tmp_w);
							int checkDay = thisDayOfWeek-Convert.ToInt32(current.DayOfWeek);
						
							StringBuilder dateString = new StringBuilder()
							.Append(current.Day).Append("/")
							.Append(current.Month).Append("/")
							.Append(current.Year).Append(" ")
							.Append(rotation_mode_tmp_h);	
							//Response.Write("dateString.ToString():"+dateString.ToString()+"<br>");						
							DateTime dateValue = DateTime.Parse(dateString.ToString()).AddDays(checkDay-7);
							//Response.Write("dateValue.ToString():"+dateValue.ToString()+"<br>");
							diffResult = current.Subtract(dateValue);
							pr = new ProductRotation(product.id, product.quantityRotationMode, product.rotationModeValue, current);
						}
						//Response.Write("diffResult.TotalMinutes:"+diffResult.TotalMinutes+"<br>");
						if (diffResult.TotalMinutes >= 10080) {// 10080=7gg	
							pr.lastUpdate=current;
							//Response.Write("pr.ToString():"+pr.ToString()+"<br>");
							prodrep.saveCompleteProductRotation(product.id, product.reloadQuantity, pr);
						}						
					}					
					break;
				    case 3:
					if(canRotate){
						DateTime current = DateTime.Now;	
						//Response.Write("current.ToString():"+current.ToString()+"<br>");								
						System.TimeSpan diffResult;
						
						ProductRotation pr = prodrep.getProductRotation(product.id, product.quantityRotationMode);
						if(pr!=null){
							int thisDayOfMOnth = Convert.ToInt32(rotation_mode_tmp_d);
							//Response.Write("pr thisDayOfMOnth:"+thisDayOfMOnth+"<br>");
							int checkDay = thisDayOfMOnth-current.Day;
							//Response.Write("pr!=null<br>- thisDayOfMOnth:"+thisDayOfMOnth+"<br>- current.Day:"+current.Day+"<br>- checkDay(thisDayOfMOnth-current.Day):"+checkDay+"<br>");	
							
							StringBuilder dateString = new StringBuilder()
							.Append(pr.lastUpdate.Day).Append("/")
							.Append(pr.lastUpdate.Month).Append("/")
							.Append(pr.lastUpdate.Year).Append(" ")
							.Append(rotation_mode_tmp_h);	
							//Response.Write("pr dateString.ToString():"+dateString.ToString()+"<br>");						
							DateTime dateValue = DateTime.Parse(dateString.ToString()).AddDays(checkDay);
							//Response.Write("pr dateValue.ToString():"+dateValue.ToString()+"<br>");
							diffResult = current.Subtract(dateValue);
						}else{
							int thisDayOfMOnth = Convert.ToInt32(rotation_mode_tmp_d);
							int checkDay = thisDayOfMOnth-current.Day;
						
							StringBuilder dateString = new StringBuilder()
							.Append(current.Day).Append("/")
							.Append(current.Month).Append("/")
							.Append(current.Year).Append(" ")
							.Append(rotation_mode_tmp_h);	
							//Response.Write("dateString.ToString():"+dateString.ToString()+"<br>");						
							DateTime dateValue = DateTime.Parse(dateString.ToString()).AddDays(checkDay).AddMonths(-1);
							//Response.Write("dateValue.ToString():"+dateValue.ToString()+"<br>");
							diffResult = current.Subtract(dateValue);
							pr = new ProductRotation(product.id, product.quantityRotationMode, product.rotationModeValue, current);
						}
						//Response.Write("diffResult.TotalMinutes:"+diffResult.TotalMinutes+"<br>");
						if (diffResult.TotalMinutes >= 43200) {// 43200=30gg
							pr.lastUpdate=current;
							//Response.Write("pr.ToString():"+pr.ToString()+"<br>");
							prodrep.saveCompleteProductRotation(product.id, product.reloadQuantity, pr);
						}						
					}					
					break;
				    default:
					break;
				}				
			}
		}
	}catch(Exception ex){
		Logger log;
		StringBuilder builder1 = new StringBuilder("Exception qty rotation: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		log = new Logger(builder1.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);			
	}
}
</script>