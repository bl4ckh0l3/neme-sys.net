<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Text.RegularExpressions" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<script runat="server">
public ASP.BoMultiLanguageControl lang;
protected IDictionary<string,ShoppingCartProduct> products;
protected IShoppingCartRepository shoprep;
protected IProductRepository productrep;
protected bool hasProds;
protected UriBuilder builder;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage = 65001;		

	shoprep = RepositoryFactory.getInstance<IShoppingCartRepository>("IShoppingCartRepository");
	productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	hasProds = false;
	products = new Dictionary<string,ShoppingCartProduct>();

	builder = new UriBuilder(Request.Url);
	builder.Scheme = "http";
	builder.Port = -1;
	builder.Path="";	
	
	try
	{		
		ShoppingCart shoppingcart = shoprep.getByIdExtended(Convert.ToInt32(Request["id"]),true);
		if(shoppingcart.products != null && shoppingcart.products.Count>0){
			products = shoppingcart.products;
			hasProds = true;
		}

	}
	catch(Exception ex)
	{
		//Response.Write(ex.Message);
		products = new Dictionary<string,ShoppingCartProduct>();
	}	
}
</script>
<table border="0" cellpadding="0" cellspacing="0" class="secondary">
<tr>
<th><%=lang.getTranslated("backend.carrello.view.table.label.attached_prods_carrello")%></th>
</tr>
<tr>
<td>
<%if(hasProds) {%>
	 <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table" id="inner-table-product-field-list">
		<tr>
		<th width="200"><span class="labelForm"><%=lang.getTranslated("backend.carrello.view.table.header.nome_prod")%></span></th>
		<th width="100"><span class="labelForm"><%=lang.getTranslated("backend.carrello.view.table.header.qta_prod")%></span></th>
		<th width="40"><span class="labelForm"><%=lang.getTranslated("backend.carrello.view.table.header.fields_prod")%></span></th>
		</tr>		
		<%
		int intCount = 0;
		foreach(ShoppingCartProduct scp in products.Values){	
			Product prod = productrep.getByIdCached(scp.idProduct, true);
			IDictionary<int,IList<ShoppingCartProductField>> spfs = shoprep.findItemFields(scp.idCart, scp.idProduct, scp.productCounter, -1);
			
			string productFields = "";
			if(spfs != null && spfs.Count>0){
				IList<ShoppingCartProductField> scprl = spfs[scp.productCounter];
				foreach(ShoppingCartProductField spf in scprl){
					string flabel = lang.getTranslated("backend.prodotti.detail.table.label.field_description_"+spf.description+"_"+prod.keyword);
					if(String.IsNullOrEmpty(flabel)){
						flabel = spf.description;
					}
					
					if(spf.fieldType==8){
						productFields+=flabel+":&nbsp;<a target='_blank' href='"+builder.ToString()+"/public/upload/files/shoppingcarts/"+spf.idCart+"/"+spf.value+"'>"+spf.value+"</a><br/>";
					}else{
						productFields+=flabel+":&nbsp;<b>"+spf.value+"</b><br/>";
					}
				}
			}			
			%>
			<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
				<td style="vertical-align:top;"><%=scp.productName%></td>
				<td style="vertical-align:top;"><%=scp.productQuantity%></td>
				<td style="vertical-align:top;"><%=productFields%></td>
			</tr>
			<%intCount++;
		}%>
	</table>
<%}%>
</td>
</tr>
</table>