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
		
	IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	IShoppingCartRepository shoprep = RepositoryFactory.getInstance<IShoppingCartRepository>("IShoppingCartRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	ConfigurationService confservice = new ConfigurationService();
	Logger log = new Logger();
	StringBuilder errorMsg = new StringBuilder();
	int qtachecked = 0;
	int idCart = -1;
	ShoppingCart shoppingCart = null;
	string acceptDate = "";
	
	string shopcartcufoff = confservice.get("day_carrello_is_valid").value;
	if(!String.IsNullOrEmpty(shopcartcufoff)){
		acceptDate = DateTime.Now.AddDays(-Convert.ToInt32(shopcartcufoff)).ToString("dd/MM/yyyy");
		//Response.Write(acceptDate);
	}
	
	try
	{
		if(logged){
			//Response.Write("login.userLogged.role.isGuest(): "+login.userLogged.role.isGuest()+"<br>");
		
			if(!login.userLogged.role.isGuest()){
				carryOn = false;
			}else{
				shoppingCart = shoprep.getByIdUser(login.userLogged.id, acceptDate, true);
				if(shoppingCart != null){
					idCart = shoppingCart.id;
					carryOn = true;
				}
			}
		}else{
			shoppingCart = shoprep.getByIdUser(Math.Abs(Session.SessionID.GetHashCode()), acceptDate, true);
			if(shoppingCart != null){
				idCart = shoppingCart.id;
				carryOn = true;
			}			
		}
		
	
		//Response.Write("carryOn: "+carryOn+"<br>");
		//Response.Write("Session.SessionID: "+Session.SessionID+"<br>");
		//Response.Write("Convert.ToInt32(Session.SessionID): "+Math.Abs(Session.SessionID.GetHashCode())+"<br>");
		
		if(carryOn)
		{
			int idproduct = Convert.ToInt32(Request["id_prod"]);
			IList<string> fieldValues = null;
			
			if(!String.IsNullOrEmpty(Request["prod_fields"]))
			{
				Dictionary<string, string> fieldValsDict = JsonConvert.DeserializeObject<Dictionary<string, string>>(Request["prod_fields"]);
				fieldValues = new List<string>();
				foreach(KeyValuePair<string, string> entry in fieldValsDict)
				{
					string key = entry.Key.Substring(entry.Key.IndexOf("-")+1);
					fieldValues.Add(key+"|"+entry.Value);
				}
			}
			
			//int prodcounter = Convert.ToInt32(Request["prod_counter"]);
			//int quantity = Convert.ToInt32(Request["qta_prod"]);
			//Response.Write("idproduct: "+idproduct+"<br>");
			//Response.Write("idCart: "+idCart+"<br>");
			//Response.Write("prodcounter: "+prodcounter+"<br>");
			//Response.Write("quantity: "+quantity+"<br>");
	
			if(shoppingCart.products != null && shoppingCart.products.Count>0)
			{
				foreach(KeyValuePair<string, ShoppingCartProduct> scps in shoppingCart.products)
				{
					//Response.Write("scps.Key: "+scps.Key+"<br>scps.Value.idCart: "+scps.Value.idCart+"<br>scps.Value.idProduct: "+scps.Value.idProduct+"<br>scps.Value.productCounter: "+scps.Value.productCounter+"<br>scps.Value.productName: "+scps.Value.productName+"<br>");	
				
					if(scps.Key.StartsWith(idproduct.ToString()+"|"))
					{	
						IDictionary<int,IList<ShoppingCartProductField>> pfs = shoprep.findItemFields(scps.Value.idCart, scps.Value.idProduct, scps.Value.productCounter,-1);
						//Response.Write("pfs==null: "+(pfs==null)+"<br>");
						
						if(pfs != null && pfs.Count>0)
						{
							//Response.Write("pfs.Count: "+pfs.Count+"<br>");
						
							IList<ShoppingCartProductField> lscpf = null;
							if (pfs.TryGetValue(scps.Value.productCounter, out lscpf) && fieldValues != null && fieldValues.Count>0)
							{
								bool foundMatch = true;	
							
								foreach(ShoppingCartProductField scpf in lscpf)
								{
									//Response.Write("fieldValues.Contains("+scpf.idField+"|"+scpf.value+"): "+fieldValues.Contains(scpf.idField+"|"+scpf.value)+"<br>");
									
									if((scpf.fieldType==3 || scpf.fieldType==4 || scpf.fieldType==5 || scpf.fieldType==6) && !fieldValues.Contains(scpf.idField+"|"+scpf.value)){
										foundMatch = false;
										break;
									}
								}
								//Response.Write("foundMatch: "+foundMatch+"<br>");
								
								if(foundMatch){
									qtachecked = scps.Value.productQuantity;
									break;
								}
							}	
						}
					}
				}
			}
		}
		
		Response.Write(qtachecked.ToString());
		
	}
	catch(Exception ex)
	{
		errorMsg.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
		log = new Logger(errorMsg.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		
		Response.Write("0");
	}
}
</script>