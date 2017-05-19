<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertads.aspx.cs" Inherits="_FeAds" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="MenuFrontendControl" TagName="insert" Src="~/public/layout/include/menu-frontend.ascx" %>
<%@ Register TagPrefix="UserMaskWidget" TagName="render" Src="~/public/layout/addson/user/user-mask-widget.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="3" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<link rel="stylesheet" href="/public/layout/css/area_user.css" type="text/css">
<script>

function sendForm(){
	if(controllaCampiInput()){	
		document.getElementById("loading").style.visibility = "visible";
		document.getElementById("loading").style.display = "block";
		document.form_inserisci.submit();
	}else{
		return;
	}
}

function confirmDelete(){
	if(confirmDel()){
		document.form_cancella_ads.submit();
	}else{
		return;
	}
}

function confirmDel(){
	return confirm('<%=lang.getTranslated("backend.contenuti.detail.js.alert.confirm_del_ad")%>');
}


function controllaCampiInput(){
	var thisPrice = document.form_inserisci.price.value;
	if(thisPrice.indexOf('.') != -1){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.use_only_comma")%>");
		document.form_inserisci.price.focus();
		return false;		
	}	

	return true;
}
</script>
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />
	<div id="container">
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>	
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>	
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>	
		<div id="backend-content">
			<table border="0" cellspacing="0" cellpadding="0" class="principal">
			<tr> 		  		  
				<td>
					<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.title")%></span><br>
					<%=content.title%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.abstract_field")%></span><br>
					<%=content.summary%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.text")%></span><br>
					<%=content.description%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.data_pub")%></span><br>
					<%=content.publishDate.ToString("dd/MM/yyyy HH:mm")%><br/><br/>				
				
					<form action="<%=secureURL%>area_user/ads/insertads.aspx" method="post" name="form_inserisci" enctype="multipart/form-data" accept-charset="UTF-8">
					<input type="hidden" value="<%=content.id%>" name="contentid"  id="contentid">
					<input type="hidden" value="<%=ads.id%>" name="adsid"  id="adsid">
					<input type="hidden" value="insert" name="operation">		 	
		  			<input type="hidden" value="<%=Request["cssClass"]%>" name="cssClass">				

					<span class="labelForm"><%=lang.getTranslated("backend.ads.detail.table.label.ads_type")%></span><br>
					<select name="ads_type" class="formFieldTXT">
					<option value="0" <%if(0==ads.type){Response.Write("selected");}%>><%=lang.getTranslated("backend.ads.lista.table.select.option.sell")%></option>
					<option value="1" <%if(1==ads.type){Response.Write("selected");}%>><%=lang.getTranslated("backend.ads.lista.table.select.option.buy")%></option>
					</select>
					<br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.ads.detail.table.label.price")%></span><br>
					<input type="text" name="price" value="<%=ads.price.ToString("#,###0.00")%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);">
					<br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.ads.detail.table.label.phone")%></span><br>
					<input type="text" name="phone" value="<%=ads.phone%>" class="formFieldTXT" />					
					<br/>
		  			
					<%if(bolFoundLista) {%>
						<br/>			
						<%foreach(Product product in products){
							IList<string> pelements = null;
							bool foundpel = prodsData.TryGetValue(product.id, out pelements);
							string prevprice = "0";
							string price = "0";
							string discountperc = "0";
							string suppdesc = "";
							string bolSkipPromotion = "0";
							string dateBuyPromotion = "";
							
							if(foundpel){
								prevprice = pelements[0];
								price = pelements[1];
								discountperc = pelements[2];
								suppdesc = pelements[3];
								bolSkipPromotion = pelements[4];
								dateBuyPromotion = pelements[5];
							}%>
							
							<br/><%if("0".Equals(bolSkipPromotion)){%><input type="checkbox" style="vertical-align:middle;" value="<%=product.id+"|"+product.keyword%>" name="promotional">&nbsp;<%}%>
							<b><%=productrep.getMainFieldTranslationCached(product.id, 1 , lang.currentLangCode, true,  product.name, true).value%></b><%if("1".Equals(bolSkipPromotion)){%>&nbsp;<span class="txtSmall">(<%=lang.getTranslated("frontend.area_user.ads.label.already_buy")%>&nbsp;<%=dateBuyPromotion%>)</span><%}%>
							<br/><%=productrep.getMainFieldTranslationCached(product.id, 2 , lang.currentLangCode, true,  product.summary, true).value%>
							<%if(!String.IsNullOrEmpty(discountperc) && Convert.ToDecimal(discountperc) > 0) {%><span class="testoBarrato"><%if(!String.IsNullOrEmpty(lang.getTranslated("backend.currency.symbol.label."+defCurrency.currency))) {Response.Write(lang.getTranslated("backend.currency.symbol.label."+defCurrency.currency));}else{Response.Write(defCurrency.currency);}%>&nbsp;<%=prevprice+"&nbsp;"+suppdesc%></span> -->&nbsp;<%}%>
							<%if(!String.IsNullOrEmpty(lang.getTranslated("backend.currency.symbol.label."+defCurrency.currency))){Response.Write(lang.getTranslated("backend.currency.symbol.label."+defCurrency.currency));}else{Response.Write(defCurrency.currency);}%>&nbsp;<%=price+"&nbsp;"+suppdesc%>	
							<%if(!String.IsNullOrEmpty(discountperc) && Convert.ToDecimal(discountperc) > 0) {Response.Write("<br/><strong>"+lang.getTranslated("frontend.template_prodotto.table.label.sconto")+" "+discountperc+"%</strong>");}%>		
							<br/><span class="txtUserPreference"><%=productrep.getMainFieldTranslationCached(product.id, 3 , lang.currentLangCode, true,  product.description, true).value%></span><br/>							
							
						<%}	
					}%>
						
		  			
					</form>
				</td>
			</tr>
			</table>
			<div id="loading" style="visibility:hidden;display:none;padding-top:10px;" align="center"><img src="/backoffice/img/loading.gif" vspace="0" hspace="0" border="0" alt="Loading..." width="200" height="50"></div>
			<br/>
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.inserisci.label")%>" onclick="javascript:sendForm();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%="/area_user/ads/contentlist.aspx?cssClass=LN"%>';" />
			<br/><br/>
			
			<%if(ads.id != -1) {%>		
				<form action="<%=secureURL%>area_user/ads/insertads.aspx" method="post" name="form_cancella_ads">
				<input type="hidden" value="<%=content.id%>" name="contentid"  id="contentid">
				<input type="hidden" value="<%=ads.id%>" name="adsid">
				<input type="hidden" value="delete" name="operation">
				<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.elimina.label")%>" onclick="javascript:confirmDelete();" />
				</form>
			<%}%>	
		</div>		
		<br style="clear: left" />
		<div>
		<MenuFrontendControl:insert runat="server" ID="mf5" index="5" model="horizontal"/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>