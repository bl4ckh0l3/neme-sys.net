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
		
	IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log = new Logger();
	StringBuilder errorMsg = new StringBuilder();
	StringBuilder resp = new StringBuilder();
	int ischecked = 1;

	try
	{
		int idproduct = Convert.ToInt32(Request["id_prod"]);
		int quantity = Convert.ToInt32(Request["quantity"]);
		
		//Response.Write("idproduct: "+idproduct+"<br>");
		//Response.Write("quantity: "+quantity+"<br>");

		if(!String.IsNullOrEmpty(Request["prod_fields"]))
		{
			Dictionary<string, string> fieldValues = JsonConvert.DeserializeObject<Dictionary<string, string>>(Request["prod_fields"]);
			
			foreach(KeyValuePair<string, string> entry in fieldValues)
			{
				string key = entry.Key.Substring(entry.Key.IndexOf("-")+1);
				
				ProductFieldsValue pfv = prodrep.getProductFieldValueCached(Convert.ToInt32(key), entry.Value, true);
				
				//Response.Write("<br>"+pfv.ToString()+"<br>"); 
				
				if(pfv!=null && pfv.quantity != null)
				{
					if(quantity != 0 && (pfv.quantity-quantity) < 0)
					{
						ischecked = 0;
						errorMsg.Append(" - ").Append(entry.Value).Append(": ").Append(lang.getTranslated("backend.prodotti.view.table.label.qta_prod")).Append(" = ").Append(pfv.quantity);
						break;
					}	
				}
				
				List<ProductFieldsRelValue> pfrvalues = (List<ProductFieldsRelValue>)prodrep.getProductFieldRelValuesCached(idproduct, Convert.ToInt32(key), entry.Value, true);
				
				if(pfrvalues != null && pfrvalues.Count>0)
				{
					bool bolHasField = true;
					foreach(KeyValuePair<string, string> innerentry in fieldValues)
					{
						string innerkey = innerentry.Key.Substring(innerentry.Key.IndexOf("-")+1);
							
						if(!(key+entry.Value).Equals(innerkey+innerentry.Value))
						{
							//Response.Write("innerkey: "+innerkey+"<br>");
							ProductFieldsRelValue tmp = new ProductFieldsRelValue(idproduct, Convert.ToInt32(key), entry.Value, Convert.ToInt32(innerkey), innerentry.Value);
							//Response.Write("check "+tmp.ToString()+"<br>"); 
							 
							ProductFieldsRelValue tmpfrv = pfrvalues.Find(p => p.Equals(tmp));
							
							if(tmpfrv != null)
							{
								//Response.Write("found "+tmpfrv.ToString()+"<br>");
								if(quantity != 0 && (tmpfrv.quantity-quantity < 0))
								{		
									ischecked = 0;
									bolHasField = false;	
									errorMsg.Append(" - ").Append(innerentry.Value).Append(": ").Append(lang.getTranslated("backend.prodotti.view.table.label.qta_prod")).Append(" = ").Append(tmpfrv.quantity);
									break;
								}						
							}
						}
					}
					if(!bolHasField)
					{
						ischecked = 0;
						break;
					}
				}
			}			
		}
		
		resp.Append("{\"checked\":").Append("\""+ischecked+"\"").Append(",")
		.Append("\"message_error\":").Append("\""+errorMsg.ToString()+"\"").Append("}");
		Response.Write(resp.ToString());
		
	}
	catch(Exception ex)
	{
		errorMsg.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
		log = new Logger(errorMsg.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		
		resp.Append("{\"checked\":").Append("\"0\"").Append(",")
		.Append("\"message_error\":").Append("\""+errorMsg.ToString()+"\"").Append("}");
		Response.Write(resp.ToString());
	}
}
</script>