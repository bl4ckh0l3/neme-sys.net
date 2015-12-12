<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertfield.aspx.cs" Inherits="_ContentField" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Register TagPrefix="CommonMenu" TagName="insert" Src="~/backoffice/include/menu.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function insertField(){
	if(document.form_inserisci.description.value == "") {
		alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.insert_description")%>");
		document.form_inserisci.description.focus();
		return false;		
	}
	
	var type_val_ch = $('#id_type').val();
	var typec_val_ch = $('#id_type_content').val();

	document.form_inserisci.list_content_fields_values.value = "";	
	document.form_inserisci.list_content_fields_ml_values.value = "";	
	if((type_val_ch== 3 || type_val_ch== 4 || type_val_ch== 5 || type_val_ch== 6) && (typec_val_ch!=7) && (typec_val_ch!=8)){
		var hasEmpty = false;
		$("input:text[id*='field_values_']").each(function(){
			if($(this).attr('id').indexOf("_ml")<0){
				if($(this).val()==''){
					hasEmpty = true;
				}else{
					document.form_inserisci.list_content_fields_values.value +=$(this).val()+"##";
				}
			}else{
				if($(this).val()!=''){
					var lang = $(this).attr('id').substring($(this).attr('id').lastIndexOf("_")+1,$(this).attr('id').length);
					var counter = $(this).attr('id').substring($(this).attr('id').lastIndexOf("_ml_")+4,$(this).attr('id').lastIndexOf("_"+lang));
					var currvalue = $('#field_values_'+counter).val();
					//alert("id:"+$(this).attr('id')+" -lang:"+lang+" -counter:"+counter+" -currvalue:"+currvalue);
					document.form_inserisci.list_content_fields_ml_values.value +=currvalue+"|"+lang+"="+$(this).val()+"##";
				}				
			}
		});	
		
		if(hasEmpty){
			alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.insert_field_value")%>");
			return false;
		}
	}
	document.form_inserisci.list_content_fields_values.value = document.form_inserisci.list_content_fields_values.value.substring(0,document.form_inserisci.list_content_fields_values.value.lastIndexOf("##"));
	document.form_inserisci.list_content_fields_ml_values.value = document.form_inserisci.list_content_fields_ml_values.value.substring(0,document.form_inserisci.list_content_fields_ml_values.value.lastIndexOf("##"));
	//alert(document.form_inserisci.list_content_fields_ml_values.value);
	document.form_inserisci.submit();
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



function sortDropDownListByText(elem) {  
	$("select#"+elem).each(function() {  
		var selectedValue = $(this).val();  
		$(this).html($("option", $(this)).sort(function(a, b) {  
		return a.text == b.text ? 0 : a.text < b.text ? -1 : 1  
		}));  
		$(this).val(selectedValue);  
	});  
}

function changeFieldGroupDesc(){
	if($('#id_group').is(':visible')){
		$('#id_group').hide();
		$('#id_group_c').show();		
	}else{
		$('#id_group_c').hide();
		$('#id_group').show();		
	}	
}

function addFieldValues(){
	var fieldValCounter = 0;
	$("#field_values_div").find("span[id*='field_values_container']").each(function(){
		fieldValCounter = $(this).attr('id').substring($(this).attr('id').indexOf("field_values_container")+22,$(this).attr('id').length);
	});	
	fieldValCounter++;
	$("#field_values_div").append('<span id="field_values_container'+fieldValCounter+'"></span>');
	$("#field_values_container"+fieldValCounter).append($('<input type="text"/>').attr('id', "field_values_"+fieldValCounter).attr('name', "field_values_"+fieldValCounter).attr('class', "formFieldTXT").attr('value', "").keypress(function(event) {return notSpecialChar(event); }));
	var render=' <a href="';
	render+="javascript:showHideDiv('field_values_"+fieldValCounter+"_ml');";
	render+='" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:top;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>';
	render+='&nbsp;<a href="';
	render+="javascript:delFieldValues('"+fieldValCounter+"',' ',' ','field_values_container"+fieldValCounter+"',0);";
	render+='"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0" style="padding-top:5px;vertical-align:top;"></a><br/>';
	render+='<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_values_'+fieldValCounter+'_ml"></div>';
	$("#field_values_container"+fieldValCounter).append(render);
	<%foreach (Language x in languages){%>
		$("#field_values_"+fieldValCounter+"_ml").append($('<input type="text"/>').attr('id', "field_values_ml_"+fieldValCounter+"_<%=x.label%>").attr('name', "field_values_ml_"+fieldValCounter+"_<%=x.label%>").attr('class', "formFieldTXTInternationalization").attr('value', "").attr('hspace', "2").attr('vspace', "2"));
		$("#field_values_"+fieldValCounter+"_ml").append('&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>');
	<%}%>
} 

function delFieldValues(counter,id_element, value, field, remove){
	
	if(remove==1){
		var query_string = "id_field_value="+id_element+"&value="+value;
		//alert(query_string);
		$.ajax({
			type: "POST",
			url: "/backoffice/contents/ajaxdeletefieldvalue.aspx",
			data: query_string,
			success: function() {
			$("#"+field).remove();
			}
		});
	}else{
		$("#"+field).remove();
	}
}  

function onChangeFyeldTypeContent(){								
	var type_val_ch = $('#id_type').val();
	var typec_val_ch = $('#id_type_content').val();

	if((type_val_ch==3) && (typec_val_ch==7 || typec_val_ch==8)){
		$("#field_values_div").hide();
	}else if((type_val_ch== 3 || type_val_ch== 4) && (typec_val_ch!=7 && typec_val_ch!=8)){
		$("#field_values_div").show();
	}
}
</script>
</head>
<body onLoad="javascript:document.form_inserisci.description.focus();">
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
		<form action="/backoffice/contents/insertfield.aspx" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=field.id%>" name="id">
		  <input type="hidden" value="insert" name="operation">
		  <input type="hidden" value="" name="list_content_fields_values">
		  <input type="hidden" value="" name="list_content_fields_ml_values">
		  <input type="hidden" value="<%=Request["cssClass"]%>" name="cssClass">	
		<tr>
		<td>	
			<div align="left" style="float:top;padding-right:60px;">
				<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.description")%></span><br>
				<input type="text" name="description" value="<%=field.description%>" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialCharButUnderscore(event);">
				<a href="javascript:showHideDiv('description_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
				<br/>
				<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="description_ml">
				<%foreach (Language x in languages){%>
				<input type="text" hspace="2" vspace="2" name="description_<%=x.label%>" id="description_<%=x.label%>" value="<%=mlangrep.translate("backend.contenuti.detail.table.label.description_"+field.description, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
				&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
				<%}%>					
				</div>			
			</div><br/>			  
		  	<div align="left" style="float:top;padding-top:0px;height:40px;">			
				<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.group")%></span>
				<img onclick="javascipt:changeFieldGroupDesc();" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.field_reload")%>" hspace="2" vspace="0" border="0"><br/>
				<input type="text" name="id_group" id="id_group"  value="<%=field.groupDescription%>" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialChar(event);">
				<select name="id_group_c" id="id_group_c" style="display:none;min-width:150px;">
				<option></option>
				<%foreach(string x in fieldGroupNames){%>
				<option value="<%=x%>" <%if(x==field.groupDescription){Response.Write(" selected='selected'");}%>><%=x%></option>
				<%}%>
				</select>
				<a href="javascript:showHideDiv('id_group_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
				<br/>
				<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="id_group_ml">
				<%foreach (Language x in languages){%>
				<input type="text" hspace="2" vspace="2" name="id_group_<%=x.label%>" id="id_group_<%=x.label%>" value="<%=mlangrep.translate("backend.contenuti.detail.table.label.id_group_"+field.groupDescription, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
				&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
				<%}%>					
				</div>			
		  	</div><br> 
			<div align="left" style="float:left;padding-right:20px;">	
			<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.order")%></span><br>
			<input type="text" name="sorting" value="<%=field.sorting%>" class="formFieldTXTShort" maxlength="3" onkeypress="javascript:return isInteger(event);">		
			</div>	
		  <div align="left" style="float:left;padding-right:20px;"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.required")%></span><br>
			<select name="required" class="formFieldTXTShort">
			<option value="0"<%if (!field.required) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if (field.required) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>	
			</SELECT>
		  </div>	 	
		  <div align="left" style="float:left;padding-right:20px;"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.enabled")%></span><br>
			<select name="enabled" class="formFieldTXTShort">
			<option value="0"<%if (!field.enabled) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if (field.enabled) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>	
			</SELECT>
		  </div>	 	
		  <div align="left" style="float:left;padding-right:20px;"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.editable")%></span><br>
			<select name="editable" id="editable" class="formFieldTXTShort">
			<option value="0"<%if (!field.editable) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if (field.editable) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>	
			</SELECT>
		  </div>
		  <br><br><br>
		  <div align="left" style="float:left;padding-right:20px;padding-top:10px;">
		  	<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.type")%></span><br>
			<select name="id_type" id="id_type" class="formFieldSelectSimple">
				<%foreach(SystemFieldsType x in systemFieldsType){
				string stypeLabel = x.description;
				if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type.label."+x.description))){
					stypeLabel = lang.getTranslated("portal.commons.content_field.type.label."+x.description);
				}%>
				<option VALUE="<%=x.id%>" <%if (x.id==field.type) {Response.Write("selected");}%>><%=stypeLabel%></option>
				<%}%>
			</select>
		  </div>
 
		  <div align="left" style="padding-top:10px;">
		  <span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.type_content")%></span><br>
			<select name="id_type_content" id="id_type_content" class="formFieldSelectSimple" onchange="javascript:onChangeFyeldTypeContent();">
				<%foreach(SystemFieldsTypeContent x in systemFieldsTypeContent){
				string stypecLabel = x.description;
				if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type_content.label."+x.description))){
					stypecLabel = lang.getTranslated("portal.commons.content_field.type_content.label."+x.description);
				}%>
				<option VALUE="<%=x.id%>" <%if (x.id==field.typeContent) {Response.Write("selected");}%>><%=stypecLabel%></option>
				<%}%>
			</select>
		  </div><br>
		  <div align="left" id="field_values_div">
			<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.values")%></span>
			&nbsp;<a href="javascript:addFieldValues();"><img src="/backoffice/img/add.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.add_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.add_field_value")%>" hspace="5" vspace="0" border="0"></a><br/>
			<%if(fieldValues.Count>0){
				int counter = 0;
				foreach(ContentFieldsValue ufv in fieldValues){%>
					<span id="field_values_container<%=counter%>">
					<input type="text" name="field_values_<%=counter%>" id="field_values_<%=counter%>" value="<%=ufv.value%>" class="formFieldTXT" onkeypress="javascript:return notSpecialChar(event);">
					<a href="javascript:showHideDiv('field_values_<%=counter%>_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:top;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>&nbsp;<a href="javascript:delFieldValues('<%=counter%>','<%=field.id%>','<%=ufv.value%>','field_values_container<%=counter%>',1);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0" style="padding-top:5px;vertical-align:top;"></a><br/>
					<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_values_<%=counter%>_ml">
					<%foreach (Language x in languages){%>
					<input type="text" hspace="2" vspace="2" name="field_values_ml_<%=counter%>_<%=x.label%>" id="field_values_ml_<%=counter%>_<%=x.label%>" value="<%=mlangrep.translate("backend.contenuti.detail.table.label.field_values_"+field.description+"_"+ufv.value, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
					&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
					<%}%>					
					</div>
					</span>					
					<%counter++;
				}
			}else{%>
				<span id="field_values_container0">
				<input type="text" name="field_values_0" id="field_values_0" value="" class="formFieldTXT" onkeypress="javascript:return notSpecialChar(event);">
					<a href="javascript:showHideDiv('field_values_0_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:top;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>&nbsp;<a href="javascript:delFieldValues('0',' ',' ','field_values_container0',0);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a><br/>
					<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_values_0_ml">
					<%foreach (Language x in languages){%>
					<input type="text" hspace="2" vspace="2" name="field_values_ml_0_<%=x.label%>" id="field_values_ml_0_<%=x.label%>" value="" class="formFieldTXTInternationalization">
					&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
					<%}%>					
					</div>
				</span>
			<%}%>
		  </div>
		  <div align="left" id="max_lenght_div">
			  <span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.max_lenght")%></span><br>
			  <input type="text" name="max_lenght" value="<%if(field.maxLenght>0){Response.Write(field.maxLenght);}%>" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);">
		  </div>

			<script>							
			$("#id_group_c").change(function(){
				$("#id_group").val($('#id_group_c').val());
				$("#id_group_c").hide();
				$("#id_group").show();
			});							
			$("#id_group_c").blur(function(){
				$("#id_group").val($('#id_group_c').val());
				$("#id_group_c").hide();
				$("#id_group").show();
			});
									
			$('#id_type').change(function() {
				var type_val_ch = $('#id_type').val();
				if(type_val_ch==1 || type_val_ch==2 || type_val_ch==7 || type_val_ch==8 || type_val_ch==9 || type_val_ch==10){
					$("#field_values_div").hide();
					if(type_val_ch==7 || type_val_ch==8 || type_val_ch==9){
						$("#max_lenght_div").hide();
					}else{
						$("#max_lenght_div").show();
					}
					$("#editable").val(1);
					if(type_val_ch==8){
						$("#editable").val(0);
					}
				}else{
					$("#field_values_div").show();
					$("#max_lenght_div").hide();
					$("#editable").val(0);
				}

				if(type_val_ch!=3){
					$("select#id_type_content option[value=7]").remove();
					$("select#id_type_content option[value=8]").remove();
				}else{
					$("select#id_type_content").append($("<option></option>").attr("value",7).text("<%=country_opt_text%>"));
					$("select#id_type_content").append($("<option></option>").attr("value",8).text("<%=state_region_opt_text%>"));
				}

				sortDropDownListByText("id_type_content");
			});

		var type_val = $('#id_type').val();
		if(type_val==1 || type_val==2 || type_val==7 || type_val==8 || type_val==9 || type_val==10){
			$("#field_values_div").hide();
			if(type_val==7 || type_val==8 || type_val==9){
				$("#max_lenght_div").hide();
			}else{
				$("#max_lenght_div").show();
			}
		}else{
			$("#max_lenght_div").hide();
			$("#field_values_div").show();
			$("#editable").val(0);
		}

		if(type_val!=3){
			$("select#id_type_content option[value=7]").remove();
			$("select#id_type_content option[value=8]").remove();
		}/*else{
			$("select#id_type_content").append($("<option></option>").attr("value",7).text("<%=country_opt_text%>"));
			$("select#id_type_content").append($("<option></option>").attr("value",8).text("<%=state_region_opt_text%>"));
		}*/

		sortDropDownListByText("id_type_content");
		</script>
		</form>
		</td></tr>
		</table>
		<br/>
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.inserisci.label")%>" onclick="javascript:insertField();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/contents/contentlist.aspx?cssClass=LU&showtab=contentfield';" />
		<br/><br/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>