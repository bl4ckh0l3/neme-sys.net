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
	}
	
	try
	{
		if(logged){
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
		
		if(carryOn)
		{
			int idproduct = Convert.ToInt32(Request["id_prod"]);
	
			if(shoppingCart.products != null && shoppingCart.products.Count>0)
			{
				foreach(KeyValuePair<string, ShoppingCartProduct> scps in shoppingCart.products)
				{
					if(scps.Key.StartsWith(idproduct.ToString()+"|"))
					{	
						qtachecked += scps.Value.productQuantity;
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