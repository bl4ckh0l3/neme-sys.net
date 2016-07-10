<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertcountry.aspx.cs" Inherits="_Country" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Web.UI" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Register TagPrefix="CommonMenu" TagName="insert" Src="~/backoffice/include/menu.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="CommonGeolocalization" TagName="insert" Src="~/backoffice/include/localization-widget.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/pagination.ascx" %>
<%//@ Reference Control="~/backoffice/include/localization-widget.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function insertCountry(){
	
	if(document.form_inserisci.country_code.value == ""){
		alert("<%=lang.getTranslated("backend.country.detail.js.alert.insert_country_code_value")%>");
		document.form_inserisci.country_code.focus();
		return;
	}
	
	if(document.form_inserisci.country_description.value == ""){
		alert("<%=lang.getTranslated("backend.country.detail.js.alert.insert_country_description_value")%>");
		document.form_inserisci.country_description.focus();
		return;
	}
	
	document.form_inserisci.submit()
}

var tempX = 0;
var tempY = 0;

jQuery(document).ready(function(){
	$(document).mousemove(function(e){
	tempX = e.pageX;
	tempY = e.pageY;
	}); 
})

function showDiv(elemID){
	var element = document.getElementById(elemID);
	var jquery_id= "#"+elemID;

	element.style.left=tempX+10;
	element.style.top=tempY+10;
	$(jquery_id).show(500);
	element.style.visibility = 'visible';		
	element.style.display = "block";
}

function hideDiv(elemID){
	var element = document.getElementById(elemID);

	element.style.visibility = 'hidden';
	element.style.display = "none";
}
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
		<table border="0" cellspacing="0" cellpadding="0" class="principal">
		<tr><td>
		<form action="/backoffice/countries/insertcountry.aspx" method="post" name="form_inserisci">
		  <input type="hidden" value="insert" name="operation">
		  <input type="hidden" value="<%=country.id%>" name="id">	
		  <div align="left" style="float:left;"><span class="labelForm"><%=lang.getTranslated("backend.country.detail.table.label.country_code")%></span><br>
		  <input type="text" name="country_code" value="<%=country.countryCode%>" class="formFieldTXT">&nbsp;&nbsp;
		  </div>	
		  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.country.detail.table.label.country_description")%></span><br>
		  <input type="text" name="country_description" value="<%=country.countryDescription%>" class="formFieldTXT"><!--&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_country_description');" class="labelForm" onmouseout="javascript:hideDiv('help_country_description');">?</a>
			  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_country_description">
			  <%//=lang.getTranslated("backend.country.detail.table.label.country_description_help_desc")%>
			  </div>-->
				<a href="javascript:showHideDiv('country_description_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a><br/>				
				<div style="visibility:hidden;position:absolute;margin-left:212px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="country_description_ml">
				<%foreach (Language x in languages){%>
					<input type="text" hspace="2" vspace="2" name="country_description_<%=x.label%>" id="country_description_<%=x.label%>" value="<%=mlangrep.translate("portal.commons.select.option.country."+country.countryCode, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
					&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
				<%}%>					
				</div>	
		  </div>
		  <br/><br/>	
		  <div align="left" style="float:left;"><span class="labelForm"><%=lang.getTranslated("backend.country.detail.table.label.state_region_code")%></span><br>
		  <input type="text" name="state_region_code" value="<%=country.stateRegionCode%>" class="formFieldTXT">&nbsp;&nbsp;
		  </div>	
		  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.country.detail.table.label.state_region_description")%></span><br>
		  <input type="text" name="state_region_description" value="<%=country.stateRegionDescription%>" class="formFieldTXT"><!--&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_state_region_description');" class="labelForm" onmouseout="javascript:hideDiv('help_state_region_description');">?</a>
			  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_state_region_description">
			  <%//=lang.getTranslated("backend.country.detail.table.label.state_region_description_help_desc")%>
			  </div>-->
				<a href="javascript:showHideDiv('state_region_description_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a><br/>				
				<div style="visibility:hidden;position:absolute;margin-left:212px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="state_region_description_ml">
				<%foreach (Language x in languages){%>
					<input type="text" hspace="2" vspace="2" name="state_region_description_<%=x.label%>" id="state_region_description_<%=x.label%>" value="<%=mlangrep.translate("portal.commons.select.option.country."+country.stateRegionCode, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
					&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
				<%}%>					
				</div>		
		  </div>
		  <br/><br/>	
		  <div align="left" style="float:left;padding-right:10px"><span class="labelForm"><%=lang.getTranslated("backend.country.detail.table.label.active")%></span><br>
			<select name="active" class="formFieldTXTShort">
			<OPTION VALUE="0" <%if (!country.active) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
			<OPTION VALUE="1" <%if (country.active) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
			</SELECT>	
		  </div>	
		  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.country.detail.table.label.use_for")%></span><br>
			<select name="use_for" class="formFieldTXT">
			<option value="1"<%if ("1"==country.useFor) { Response.Write("selected");}%>><%=lang.getTranslated("backend.country.use_for.registration")%></option>	
			<option value="2"<%if ("2"==country.useFor) { Response.Write("selected");}%>><%=lang.getTranslated("backend.country.use_for.purchase")%></option>	
			<option value="3"<%if ("3"==country.useFor) { Response.Write("selected");}%>><%=lang.getTranslated("backend.country.use_for.all")%></option>	
			</SELECT>
		  </div>
		  
		 <br/> 
		<input type="hidden" value="<%=pregeoloc_el_id%>" name="pregeoloc_el_id">
		<CommonGeolocalization:insert runat="server" elemType="3" ID="gl1" />
		</form>
		</td></tr>
		</table><br/>	    
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.country.detail.button.inserisci.label")%>" onclick="javascript:insertCountry();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/countries/countrylist.aspx?cssClass=LCT';" />
		<br/><br/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>