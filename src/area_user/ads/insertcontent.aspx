<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertcontent.aspx.cs" Inherits="_FeContent" Debug="false" ValidateRequest="false"%>
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
<%@ Register TagPrefix="CommonGeolocalization" TagName="insert" Src="~/area_user/ads/localization-widget.ascx" %>
<%@ Register Assembly="FredCK.FCKeditorV2" Namespace="FredCK.FCKeditorV2" TagPrefix="FCKeditorV2" %>
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
<script src="/common/js/hashtable.min.js"></script>
<script>
var listPreviewGerContent = new Hashtable();
<%foreach(string z in previewUrls.Keys){%>
	listPreviewGerContent.put("<%=z%>","<%=previewUrls[z][0]+"|"+previewUrls[z][1]+"|"+previewUrls[z][2]+"|"+previewUrls[z][3]%>");	
<%}%>

var fieldTypesList = new Hashtable();
<%foreach(SystemFieldsType sft in systemFieldsType){%>
fieldTypesList.put(<%=sft.id%>,'<%=sft.description%>');
<%}%>

var countryList = new Hashtable();
<%foreach(Country jc in countries){%>
countryList.put('<%=jc.countryCode%>','<%=jc.countryDescription%>');
<%}%>

var stateRegionList = new Hashtable();
<%foreach(Country jsr in stateRegions){%>
stateRegionList.put('<%=jsr.stateRegionCode%>','<%=jsr.countryDescription+" "+jsr.stateRegionDescription%>');
<%}%>

var pathPreviewContent = "";
var hierarchyPreviewContent = "";
var catidPreviewContent = "";
	
function previewContent(contentid){
	var templatePreviewPath = "";
	
	templatePreviewPath = templatePreviewPath + pathPreviewContent+"?content_preview=1&contentid="+contentid+"&hierarchy="+hierarchyPreviewContent+"&categoryid="+catidPreviewContent;
	if(pathPreviewContent != "" && pathPreviewContent != "#" && contentid > 0){
		openWin(templatePreviewPath,'templatecontent',970,600,150,60);
	}else{
		alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.preview_content_disabled")%>");
	}
}

function changeTemplatePreviewContentGer(gerPreviewChanged){
	var tmpValue = listPreviewGerContent.get(gerPreviewChanged);
	var items = tmpValue.split('|');
	if(items != null){
		hierarchyPreviewContent = items[0];
		catidPreviewContent = items[1];
		pathPreviewContent = items[2];
	}
}


function changeNumMaxImgs(){
	if(document.form_inserisci.numMaxImgs.value == ""){
		alert("<%=lang.getTranslated("backend.templates.detail.js.alert.insert_value")%>");
		document.form_inserisci.numMaxImgs.focus();
		return;
	}else if(isNaN(document.form_inserisci.numMaxImgs.value) || document.form_inserisci.numMaxImgs.value == "0"){
		alert("<%=lang.getTranslated("backend.templates.detail.js.alert.isnan_value")%>");
		document.form_inserisci.numMaxImgs.focus();
		return;		
	}
	renderNumImgsTable(document.form_inserisci.numMaxImgs.value);
}

function renderNumImgsTable(counter){
	$(".attach_table_rows").remove();
	
	var render ="";
	
	for(var i=1;i<=counter;i++){
		render=render+'<tr class="attach_table_rows">';
			render=render+'<td><input type="file" id="fileupload'+i+'" name="fileupload'+i+'" class="formFieldTXT"></td>';
			render=render+'<td>';			
			if(i==1){
			render=render+'<div id="text_label_new'+i+'" style="display:none;">';
			render=render+'<input type="text" name="fileupload_label_new'+i+'" id="fileupload_label_new'+i+'" onblur="javascript:prepareInsertAttachLabel(this,'+i+');" class="formFieldSelectTypeFile">';
			render=render+'</div>';
			}		
			render=render+'<div id="select_label_new'+i+'">';
			render=render+'<select id="fileupload_label'+i+'" name="fileupload_label'+i+'" class="formFieldSelectTypeFile">';			
			render=render+'</select>';
			if(i==1){
			render=render+'<a href="javascript:addAttachLabel('+i+');"><img vspace="0" hspace="4" border="0" align="top" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.add_type")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.label.add_type")%>" src="/backoffice/img/add.png"></a>';
			render=render+'<a href="javascript:delAttachLabel(\'#fileupload_label'+i+'\');"><img vspace="0" hspace="4" border="0" align="top" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.del_type")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.label.del_type")%>" src="/backoffice/img/delete.png"></a>';
			}			
			render=render+'</div></td>';
			render=render+'<td><input type="text" name="fileupload_dida'+i+'" class="formFieldTXT"></td>';
			render=render+'<td>';
			if(i==1){
			render=render+'<input type="text" value="'+counter+'" name="numMaxImgs" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);"><a href="javascript:changeNumMaxImgs();"><img src="/common/img/refresh.gif" vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.change_num_imgs")%>"></a>';
			}
			render=render+'</td>';
		render=render+'</tr>';
	}

	$("#add_attach_table").append(render);
	
	var reloadedlist = "";
	var query_string = "operation=reload";	
	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "<%=secureURL%>area_user/ads/ajaxattachlabel.aspx",
		data: query_string,
		success: function(response) {
			$("select[name*='fileupload_label']").each(function(){
				$(this).append(response);
			});
		},
		error: function(response) {
			//alert(response.responseText);	
		}
	});

}

function modifyField(row,refreshrows){
	$(row).show();	
	$(refreshrows).hide();
}

function backField(row,refreshrows){
	$(row).hide();	
	$(refreshrows).show();	
}

function changeFieldGroupDesc(ifField){
	if($('#group_value_'+ifField).is(':visible')){
		$('#group_value_'+ifField).hide();
		$('#group_value_c_'+ifField).show();		
	}else{
		$('#group_value_c_'+ifField).hide();
		$('#group_value_'+ifField).show();		
	}	
}

function changeFieldName(ifField){
	if($('#field_description_'+ifField).is(':visible')){
		$('#field_description_'+ifField).hide();
		$('#field_description_c_'+ifField).show();		
	}else{
		$('#field_description_c_'+ifField).hide();
		$('#field_description_'+ifField).show();		
	}	
}

function deleteAttach(id_attach,row, file_path){
	if(confirm("<%=lang.getTranslated("backend.contenuti.detail.js.alert.confirm_del_attach")%>")){		
		var query_string = "id_attach="+id_attach+"&file_path="+file_path;
		
		$.ajax({
			async: true,
			type: "POST",
			cache: false,
			url: "<%=secureURL%>area_user/ads/ajaxdeleteattach.aspx",
			data: query_string,
			success: function(response) {
				//alert(response);	
				$('#'+row).hide();		
			},
			error: function() {
				$('#'+row).show();
				/*
				$("#ajaxresp").empty();
				$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_delete_item")%>");
				$("#ajaxresp").fadeIn(1500,"linear");
				$("#ajaxresp").fadeOut(600,"linear");
				*/
			}
		});
	}
}

function deleteField(id_objref, row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.contenuti.detail.js.alert.confirm_del_field")%>")){			
		var query_string = "id_field="+id_objref;
		
		$.ajax({
			async: true,
			type: "POST",
			cache: false,
			url: "<%=secureURL%>area_user/ads/ajaxdeletefield.aspx",
			data: query_string,
			success: function(response) {
				//alert(response);	
				$('#'+row).hide();	
				$('#'+refreshrows+'_edit_'+id_objref).hide();	

				var classon = "table-list-on";
				var classoff = "table-list-off";
				var counter = 1;	
				
				$("tr[id*='"+refreshrows+"']").each(function(){
					if($(this).is(':visible')){
						if(counter % 2 == 0){
							$(this).attr("class",classoff);
						}else{
							$(this).attr("class",classon);
						}
						counter+=1;
					}
				});
			},
			error: function(response) {
				//alert("error: "+response.responseText);
				$('#'+row).show();				
				$("#ajaxresp").empty();
				$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_delete_item")%>");
				$("#ajaxresp").fadeIn(1500,"linear");
				$("#ajaxresp").fadeOut(600,"linear");				
			}
		});		
		
		
	}
}

function sendForm(saveEsc){
	if(controllaCampiInput()){		
		if(saveEsc==0){
			document.form_inserisci.savesc.value=0;
		}
		document.getElementById("loading").style.visibility = "visible";
		document.getElementById("loading").style.display = "block";
		document.form_inserisci.submit();
	}else{
		return;
	}
}

function confirmDelete(){
	if(confirmDel()){
		document.form_cancella_news.submit();
	}else{
		return;
	}
}

function confirmDel(){
	return confirm('<%=lang.getTranslated("backend.contenuti.detail.js.alert.confirm_del_news")%>');
}


function controllaCampiInput(){
	//valorizzo il campo nascosto "usr_languages" con la lista delle lingue separate da "|"
	var strLanguages = "";
	strLanguages+=listLanguages
	if(strLanguages.charAt(strLanguages.length -1) == "|"){
		strLanguages = strLanguages.substring(0, strLanguages.length -1);
	}	
	document.form_inserisci.content_languages.value = strLanguages;
	//alert("content_languages:"+document.form_inserisci.content_languages.value+";");


	if(document.form_inserisci.send_newsletter){
		if(document.form_inserisci.send_newsletter.value == 1 && document.form_inserisci.choose_newsletter.value == ""){
			alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.choose_newsletter_template")%>");
			document.form_inserisci.choose_newsletter.focus();
			return false;
		}
	}
	
	if(document.form_inserisci.title.value == ""){
		alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.insert_title")%>");
		document.form_inserisci.title.focus();
		return false;
	}

	$("#add_attach_table").find("input:text[name*='_dida']").each(function(){
		$(this).attr('value', replaceChars($(this).val()));
		$(this).attr('value', replaceChars2($(this).val()));
	});

	return true;
}


function replaceChars(inString){
	var outString = inString;
	var pos= 0;

	// ricerca e escaping degli apici
	/*var quote2= -1;
	do {
		quote2= outString.indexOf('\'', pos);
		if (quote2 >= 0) {
			outString= outString.substring(0, quote2) + "&#39;" + outString.substring(quote2 +1);
			pos= quote2+2;
		}
	} while (quote2 >= 0);*/
	
	// ricerca e escaping dei new line
	pos= 0;
	var linefeed= -1;
	do {
		linefeed= outString.indexOf('\n', pos);
		if (linefeed >= 0) {
			outString= outString.substring(0, linefeed) + "\\n" + outString.substring(linefeed +1);
			pos= linefeed+2;
		}
	} while (linefeed >= 0);
	
	// ricerca e escaping dei line feed
	pos= 0;
	var creturn= -1;
	do {
		creturn= outString.indexOf('\r', pos);
		if (creturn >= 0) {
			outString= outString.substring(0, creturn) + "\\r" + outString.substring(creturn +1);
			pos= creturn+2;
		}
	} while (creturn >= 0);

	//ricerca lettere accentate èéàòùì
	//&egrave;&eacute;&agrave;&ograve;&ugrave;&igrave;
	pos= 0;
	var letter= -1;
	do {
		letter= outString.indexOf('è', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&egrave;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	letter= -1;
	do {
		letter= outString.indexOf('é', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&eacute;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	letter= -1;
	do {
		letter= outString.indexOf('à', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&agrave;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	letter= -1;
	do {
		letter= outString.indexOf('ò', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&ograve;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	letter= -1;
	do {
		letter= outString.indexOf('ù', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&ugrave;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	letter= -1;
	do {
		letter= outString.indexOf('ì', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&igrave;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	
	// ricerca degli href e delle ancore	
	pos= 0;
	var href= -1;
	do {
		href= outString.indexOf('href=', pos);
		if (href >= 0) {
			var url = outString.substring(href,outString.indexOf('>', href));
			if(url.indexOf('#') >=0){
				outString= outString.substring(0, href+6) + outString.substring(outString.indexOf('#', href+6));
			}
			pos= href+6;
		}
	} while (href >= 0);
	

	return outString;	
}

function replaceChars2(inString){
	var outString2 = inString;
	var pos2= 0;

	// ricerca e escaping degli apici
	var quote2= -1;
	do {
		quote2= outString2.indexOf('\'', pos2);
		if (quote2 >= 0) {
			outString2= outString2.substring(0, quote2) + "&#39;" + outString2.substring(quote2 +1);
			pos2= quote2+2;
		}
	} while (quote2 >= 0);
	
	// ricerca e escaping dei doppi apici
	pos2= 0;
	var doublequote= -1;
	do {
		doublequote= outString2.indexOf('\"', pos2);
		if (doublequote >= 0) {
			outString2= outString2.substring(0, doublequote) + "&quot;" + outString2.substring(doublequote +1);
			pos2= doublequote+2;
		}
	} while (doublequote >= 0);

	return outString2;	
}

function replaceDefaultEditorChars(inString){
	var outStringDef = inString;

	// ricerca caratteri di default dell'editor html: <br type=&quot;_moz&quot; /> oppure <br type="_moz" /> oppure &lt;br type=&quot;_moz&quot; /&gt; oppure &lt;br /&gt; oppure <br />
	if(outStringDef =='<br type=&quot;_moz&quot; />' || outStringDef =='<br type="_moz" />' || outStringDef =='&lt;br type=&quot;_moz&quot; /&gt;' || outStringDef =='&lt;br /&gt;' || outStringDef =='<br />'){
		outStringDef = "";
	}

	return outStringDef;	
}

function showHideDivArrow(elemDiv,elemArrow){
	var elementDiv = document.getElementById(elemDiv);
	var elementArrow = document.getElementById(elemArrow);
	if(elementDiv.style.visibility == 'visible'){
		elementArrow.src='<%="/backoffice/img/div_freccia.gif"%>';
	}else if(elementDiv.style.visibility == 'hidden'){
		elementArrow.src='<%="/backoffice/img/div_freccia2.gif"%>';
	}
}

function hierarchy2double(hierarchy){			
	var gerarchiaDbl= 0.0;
	var scale= 1.0 / 100.0;
	
	var p = hierarchy.split('.');

	if(p!=null){		
		for(var counter = 0;counter<p.length;counter++){
			var level = Number(p[counter]);
			gerarchiaDbl = gerarchiaDbl + (level * scale);	
			scale = scale / 100.0;					
		}
	} 

	return gerarchiaDbl;
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

function addFieldValues(fieldValCounter){
	var counter = 0;
	$("#field_values_div_"+fieldValCounter).find("span[id*='field_values_container']").each(function(){
		counter = $(this).attr('id').substring($(this).attr('id').indexOf("field_values_container"+fieldValCounter)+23+fieldValCounter.length,$(this).attr('id').length);
	});	

	counter++;
	counter=fieldValCounter+"_"+counter;
	$("#add_field_values_div_"+fieldValCounter).append('<span id="field_values_container'+counter+'"></span>');

	var currtypeval = $('#id_type_'+fieldValCounter).val();
	
	//alert("fieldValCounter:"+fieldValCounter+" - currtypeval:"+currtypeval);
	
	if(currtypeval==3 || currtypeval==6){
		$("#field_values_container"+counter).append($('<input type="checkbox"/>').attr('id', "field_checkedvaluesc"+counter).attr('name', "field_checkedvalues"+fieldValCounter).attr('value', "").attr('style', "display:none;"));
		$("#field_values_container"+counter).append($('<input type="radio"/>').attr('id', "field_checkedvaluesr"+counter).attr('name', "field_checkedvalues"+fieldValCounter).attr('value', ""));	
	}else{
		$("#field_values_container"+counter).append($('<input type="radio"/>').attr('id', "field_checkedvaluesr"+counter).attr('name', "field_checkedvalues"+fieldValCounter).attr('value', "").attr('style', "display:none;"));	
		$("#field_values_container"+counter).append($('<input type="checkbox"/>').attr('id', "field_checkedvaluesc"+counter).attr('name', "field_checkedvalues"+fieldValCounter).attr('value', ""));						
	}
		
	$("#field_values_container"+counter).append('&nbsp;').append($('<input type="text"/>').attr('id', "field_values"+counter).attr('name', "field_values"+counter).attr('class', "formFieldTXT").attr('value', "").keypress(function(event) {return notSpecialChar(event); }));
	var render='&nbsp;<a href="';
	render+="javascript:delFieldValues('"+counter+"','"+fieldValCounter+"',' ','field_values_container"+counter+"',0);";
	render+='"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a><br/>';
	$("#field_values_container"+counter).append(render);
} 

function delFieldValues(counter,id_element, value, field, remove){
	
	if(remove==1){
		var query_string = "id_field_value="+id_element+"&value="+value;
		//alert(query_string);
		$.ajax({
			type: "POST",
			url: "<%=secureURL%>area_user/ads/ajaxdeletefieldvalue.aspx",
			data: query_string,
			success: function() {
			$("#"+field).remove();
			}
		});
	}else{
		$("#"+field).remove();
	}
} 

function onloadFieldsTypes(){
	$("select[name*='id_type']").each(function(){
		if($(this).attr('name').indexOf("id_type_content")<0 && ($(this).val() != "") && ($(this).val() != 'undefined')){
			var type_counter = $(this).attr('id').substring($(this).attr('id').indexOf("id_type_")+8,$(this).attr('id').length);
			var type_val = $(this).val();
			if(type_val==1 || type_val==2 || type_val==7 || type_val==8 || type_val==9 || type_val==10){
				$("#field_values_div_"+type_counter).hide();
				
				if(type_val==8 || type_val==7 || type_val==9){
					$('#max_lenght_container_'+type_counter).hide();
				}else{
					$('#max_lenght_container_'+type_counter).show();
				}				
				
				if(type_val==8){
					$('#field_value_box_'+type_counter).hide();
				}else{
					$('#field_value_box_'+type_counter).show();
				}
				
				$("#content_field_editable_"+type_counter).attr('disabled',false);				
				
				if($("#content_field_editable_"+type_counter).is(':checked')){					
					if(type_val==1 || type_val==7){
						$('#baseFieldHidden_h_'+type_counter).hide();
						$('#baseFieldHtmlEditor_e_'+type_counter).hide();
						$('#baseFieldTextarea_ta_'+type_counter).hide();
						$('#baseFieldPassword_p_'+type_counter).hide();
						$('#baseFieldText_t_'+type_counter).show();
					}else if(type_val==2){
						$('#baseFieldHidden_h_'+type_counter).hide();
						$('#baseFieldHtmlEditor_e_'+type_counter).hide();
						$('#baseFieldText_t_'+type_counter).hide();
						$('#baseFieldPassword_p_'+type_counter).hide();
						$('#baseFieldTextarea_ta_'+type_counter).show();
					}else if(type_val==9){	
						$('#baseFieldHidden_h_'+type_counter).hide();
						$('#baseFieldText_t_'+type_counter).hide();
						$('#baseFieldTextarea_ta_'+type_counter).hide();
						$('#baseFieldPassword_p_'+type_counter).hide();
						$('#baseFieldHtmlEditor_e_'+type_counter).show();			
					}else if(type_val==10){
						$('#baseFieldHidden_h_'+type_counter).hide();
						$('#baseFieldHtmlEditor_e_'+type_counter).hide();
						$('#baseFieldText_t_'+type_counter).hide();
						$('#baseFieldTextarea_ta_'+type_counter).hide();
						$('#baseFieldPassword_p_'+type_counter).show();
					}else{			
						$('#baseFieldText_t_'+type_counter).hide();
						$('#baseFieldTextarea_ta_'+type_counter).hide();
						$('#baseFieldPassword_p_'+type_counter).hide();
						$('#baseFieldHtmlEditor_e_'+type_counter).hide();
						$('#baseFieldHidden_h_'+type_counter).show();
					}
				}else{
					$('#field_value_box_'+type_counter).hide();
					$('#baseFieldText_t_'+type_counter).hide();
					$('#baseFieldTextarea_ta_'+type_counter).hide();
					$('#baseFieldPassword_p_'+type_counter).hide();
					$('#baseFieldHtmlEditor_e_'+type_counter).hide();
					$('#baseFieldHidden_h_'+type_counter).hide();
				}			
			}else{
				$('#max_lenght_container_'+type_counter).hide();
				$("#field_values_div_"+type_counter).show();
				$('#field_value_box_'+type_counter).hide();
				$("#content_field_editable_"+type_counter).attr('checked',false);
				$("#content_field_editable_"+type_counter).attr('disabled',true);
			}	
					
			if(type_val!=3){
				$("select#id_type_content_"+type_counter+" option[value=7]").remove();
				$("select#id_type_content_"+type_counter+" option[value=8]").remove();
			}/*else{
				$("select#id_type_content_"+type_counter).append($("<option></option>").attr("value",7).text("<%=country_opt_text%>"));
				$("select#id_type_content_"+type_counter).append($("<option></option>").attr("value",8).text("<%=state_region_opt_text%>"));
			}*/
		
			sortDropDownListByText("id_type_content_"+type_counter);		
		
				
			var typec_val = $('#id_type_content_'+type_counter).val();
			if((type_val== 3) && (typec_val==7 || typec_val==8)){
				$("#field_values_div_"+type_counter).hide();
				if(typec_val==7){
					$("#field_values_div_state_region_"+type_counter).hide();
					$("#field_values_div_country_"+type_counter).show();
				}else if(typec_val==8){
					$("#field_values_div_country_"+type_counter).hide();
					$("#field_values_div_state_region_"+type_counter).show();
				}
			}else if((type_val== 3 || type_val== 4) && (typec_val!=7 && typec_val!=8)){
				$("#field_values_div_country_"+type_counter).hide();
				$("#field_values_div_state_region_"+type_counter).hide();
				$("#field_values_div_"+type_counter).show();
			}
		}
	}); 	
}

function onChangeFieldsType(counter){
	var type_val_ch = $('#id_type_'+counter).val();

	if(type_val_ch==1 || type_val_ch==2 || type_val_ch==7 || type_val_ch==8 || type_val_ch==9 || type_val_ch==10){
		var current_value = $("#field_value_"+counter).val();
		
		if(type_val_ch==1 || type_val_ch==7){
			$('#baseFieldHidden_h_'+counter).hide();
			$('#baseFieldHtmlEditor_e_'+counter).hide();
			$('#baseFieldTextarea_ta_'+counter).hide();
			$('#baseFieldPassword_p_'+counter).hide();
			$('#baseFieldText_t_'+counter).show();
		}else if(type_val_ch==2){
			$('#baseFieldHidden_h_'+counter).hide();
			$('#baseFieldHtmlEditor_e_'+counter).hide();
			$('#baseFieldText_t_'+counter).hide();
			$('#baseFieldPassword_p_'+counter).hide();
			$('#baseFieldTextarea_ta_'+counter).show();
		}else if(type_val_ch==9){	
			$('#baseFieldHidden_h_'+counter).hide();
			$('#baseFieldText_t_'+counter).hide();
			$('#baseFieldTextarea_ta_'+counter).hide();
			$('#baseFieldPassword_p_'+counter).hide();
			$('#baseFieldHtmlEditor_e_'+counter).show();			
		}else if(type_val_ch==10){
			$('#baseFieldHidden_h_'+counter).hide();
			$('#baseFieldHtmlEditor_e_'+counter).hide();
			$('#baseFieldText_t_'+counter).hide();
			$('#baseFieldTextarea_ta_'+counter).hide();
			$('#baseFieldPassword_p_'+counter).show();
		}else{			
			$('#baseFieldText_t_'+counter).hide();
			$('#baseFieldTextarea_ta_'+counter).hide();
			$('#baseFieldPassword_p_'+counter).hide();
			$('#baseFieldHtmlEditor_e_'+counter).hide();
			$('#baseFieldHidden_h_'+counter).show();
		}
		
		if(type_val_ch==7 || type_val_ch==8 || type_val_ch==9){
			$('#max_lenght_container_'+counter).hide();
		}else{
			$('#max_lenght_container_'+counter).show();
		}

		$("#field_values_div_"+counter).hide();		
		if(type_val_ch!=8){
			$('#field_value_box_'+counter).show();
			$("#content_field_editable_"+counter).attr('checked',true);
			$("#content_field_editable_"+counter).attr('disabled',false);
		}else{
			$('#field_value_box_'+counter).hide();
			$("#content_field_editable_"+counter).attr('checked',false);
			$("#content_field_editable_"+counter).attr('disabled',true);		
		}
		$("[id*='field_values"+counter+"']").val('');		
	}else{
		// cambio la lista checkbox o radio dell'elenco dei valori a seconda del type
		$("[id*='field_checkedvaluesc"+counter+"']").val('');
		$("[id*='field_checkedvaluesr"+counter+"']").val('');
		if(type_val_ch==3 || type_val_ch==6){
			$("[id*='field_checkedvaluesc"+counter+"']").hide();
			$("[id*='field_checkedvaluesr"+counter+"']").show();
		}else{
			$("[id*='field_checkedvaluesr"+counter+"']").hide();
			$("[id*='field_checkedvaluesc"+counter+"']").show();		
		}
	
		$("#field_values_div_"+counter).show();
		$('#field_value_box_'+counter).hide();
		$("[name*='field_value_"+counter+"']").val('');
		var currentceditor = $("#field_value_e_"+counter).cleditor()[0];	
		currentceditor.refresh();
		$('#max_lenght_container_'+counter).hide();
		$("#content_field_editable_"+counter).attr('checked',false);
		$("#content_field_editable_"+counter).attr('disabled',true);
	}
	
	if(type_val_ch!=3){
		$("select#id_type_content_"+counter+" option[value=7]").remove();
		$("select#id_type_content_"+counter+" option[value=8]").remove();
		$("#field_values_div_country_"+counter).hide();
		$("#field_values_div_state_region_"+counter).hide();
	}else{
		$("select#id_type_content_"+counter).append($("<option></option>").attr("value",7).text("<%=country_opt_text%>"));
		$("select#id_type_content_"+counter).append($("<option></option>").attr("value",8).text("<%=state_region_opt_text%>"));
	}

	sortDropDownListByText("id_type_content_"+counter);
}

function onChangeFyeldTypeContent(counter){								
	var type_val_ch = $('#id_type_'+counter).val();
	var typec_val_ch = $('#id_type_content_'+counter).val();

	if((type_val_ch==3) && (typec_val_ch==7 || typec_val_ch==8)){
		$("#field_values_div_"+counter).hide();
		if(typec_val_ch==7){
			$("#field_values_div_state_region_"+counter).hide();
			$("#field_values_div_country_"+counter).show();
		}else if(typec_val_ch==8){
			$("#field_values_div_country_"+counter).hide();
			$("#field_values_div_state_region_"+counter).show();
		}
	}else if((type_val_ch== 3 || type_val_ch== 4) && (typec_val_ch!=7 && typec_val_ch!=8)){
		$("#field_values_div_"+counter).show();
		$("#field_values_div_country_"+counter).hide();
		$("#field_values_div_state_region_"+counter).hide();
	}
}

function onClickFieldEditable(counter){
	var editable = $('#content_field_editable_'+counter).is(':checked');

	if((editable)){
		var type_val_ch = $('#id_type_'+counter).val();

		if(type_val_ch==1 || type_val_ch==7){
			$('#baseFieldHidden_h_'+counter).hide();
			$('#baseFieldHtmlEditor_e_'+counter).hide();
			$('#baseFieldTextarea_ta_'+counter).hide();
			$('#baseFieldPassword_p_'+counter).hide();
			$('#baseFieldText_t_'+counter).show();
		}else if(type_val_ch==2){
			$('#baseFieldHidden_h_'+counter).hide();
			$('#baseFieldHtmlEditor_e_'+counter).hide();
			$('#baseFieldText_t_'+counter).hide();
			$('#baseFieldPassword_p_'+counter).hide();
			$('#baseFieldTextarea_ta_'+counter).show();
		}else if(type_val_ch==9){	
			$('#baseFieldHidden_h_'+counter).hide();
			$('#baseFieldText_t_'+counter).hide();
			$('#baseFieldTextarea_ta_'+counter).hide();
			$('#baseFieldPassword_p_'+counter).hide();
			$('#baseFieldHtmlEditor_e_'+counter).show();			
		}else if(type_val_ch==10){
			$('#baseFieldHidden_h_'+counter).hide();
			$('#baseFieldHtmlEditor_e_'+counter).hide();
			$('#baseFieldText_t_'+counter).hide();
			$('#baseFieldTextarea_ta_'+counter).hide();
			$('#baseFieldPassword_p_'+counter).show();
		}else{			
			$('#baseFieldText_t_'+counter).hide();
			$('#baseFieldTextarea_ta_'+counter).hide();
			$('#baseFieldPassword_p_'+counter).hide();
			$('#baseFieldHtmlEditor_e_'+counter).hide();
			$('#baseFieldHidden_h_'+counter).show();
		}
		
		$('#field_value_box_'+counter).show();
	}else{
		$('#field_value_box_'+counter).hide();
		$("[name*='field_value_"+counter+"']").val('');
		var currentceditor = $("#field_value_e_"+counter).cleditor()[0];	
		currentceditor.refresh();
	}
}

function showNewFieldAdd(){
	var show = $('#show_new_field_add').is(':visible');

	if((show)){
		$('#show_new_field_add').hide();
		$('#show_new_field').show();
	}else{
		$('#show_new_field').hide();
		$('#show_new_field_add').show();
	}	
}

function saveField(counter,row,refreshrow, modify, subcounter){	
	if(modify==1){
		document.form_create_field.operation.value="updfield";
	}else{
		document.form_create_field.operation.value="addfield";
	}
	document.form_create_field.id_field.value = $('#id_field_'+counter).val();
	document.form_create_field.group_value.value = $('#group_value_'+counter).val();	
	document.form_create_field.field_description.value = $('#field_description_'+counter).val();
	
	if(document.form_create_field.field_description.value == "") {
		alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.insert_description")%>");
		$('#field_description_'+counter).focus();
		return;		
	}else if(isSpecialCharButUnderscoreAndMinus(document.form_create_field.field_description.value)) {
		alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.not_use_special_char")%>");
		$('#field_description_'+counter).focus();
		return;		
	}
	
	if($('#content_field_active_'+counter).is(':checked')){	
		document.form_create_field.content_field_active.value = $('#content_field_active_'+counter).val();	
	}else{
		document.form_create_field.content_field_active.value = "";
	}
	if($('#content_field_mandatory_'+counter).is(':checked')){	
		document.form_create_field.content_field_mandatory.value = $('#content_field_mandatory_'+counter).val();	
	}else{
		document.form_create_field.content_field_mandatory.value = "";
	}
	if($('#content_field_editable_'+counter).is(':checked')){	
		document.form_create_field.content_field_editable.value = $('#content_field_editable_'+counter).val();	
	}else{
		document.form_create_field.content_field_editable.value = "";
	}
	document.form_create_field.sorting.value = $('#sorting_'+counter).val();	
	document.form_create_field.max_lenght.value = $('#max_lenght_'+counter).val();	
	document.form_create_field.id_type.value = $('#id_type_'+counter).val();	
	document.form_create_field.id_type_content.value = $('#id_type_content_'+counter).val();	
	
	var tmp_type = document.form_create_field.id_type.value;
	var tmp_type_content = document.form_create_field.id_type_content.value;
	var current_value = "";
	if(tmp_type==1 || tmp_type==7){
		current_value = $('#field_value_t_'+counter).val();
	}else if(tmp_type==2){
		current_value = $('#field_value_ta_'+counter).val();
	}else if(tmp_type==9){	
		current_value = $('#field_value_e_'+counter).val();			
	}else if(tmp_type==10){
		current_value = $('#field_value_p_'+counter).val();
	}else if(tmp_type==3 || tmp_type==4 || tmp_type==5 || tmp_type==6){
		if(tmp_type_content==7){		
			current_value = $('#field_value_ct_'+counter).val();
		}else if(tmp_type_content==8){
			current_value = $('#field_value_sr_'+counter).val();		
		}else{
			$('[name*="field_checkedvalues'+counter+'"]').each( function(){
				var partialid = $(this).attr('id');
				partialid = partialid.substring(partialid.indexOf("field_checkedvalues")+20,partialid.length);
				if($(this).is(':visible') && $(this).is(':checked')){
					var current_val = $('#field_values'+partialid).val();
					if(current_val != ""){
						current_value+=current_val+",";
					}
				}
			});
			if(current_value != ""){
				current_value = current_value.substring(0,current_value.length-1);
			}
		}
	}else{			
		current_value = $('#field_value_h_'+counter).val();
	}
	document.form_create_field.field_value.value = current_value;

	// check for empty value if field is editable
	if($('#content_field_editable_'+counter).is(':checked') && current_value == ""){
		alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.insert_value")%>");
		if(tmp_type==1 || tmp_type==7){
			$('#field_value_t_'+counter).focus();
		}else if(tmp_type==2){
			$('#field_value_ta_'+counter).focus();
		}else if(tmp_type==9){	
			$('#field_value_e_'+counter).cleditor()[0].focus(); 			
		}else if(tmp_type==10){
			$('#field_value_p_'+counter).focus();
		}
		return;
	}


	document.form_create_field.field_description_ml.value = "";
	$('input:text[id*="field_description_'+counter+'_"]').each( function(){	
		if($(this).val() != ""){
			var key = $(this).attr('id');
			key = key.substring(key.indexOf("field_description_"+counter+"_")+19+counter.toString().length,key.length);
			document.form_create_field.field_description_ml.value +=key+"="+$(this).val()+"##"; 
		}
	});
	document.form_create_field.field_description_ml.value = document.form_create_field.field_description_ml.value.substring(0,document.form_create_field.field_description_ml.value.lastIndexOf("##"));
	
	document.form_create_field.list_content_fields.value = "";
	document.form_create_field.list_content_fields_values.value = "";
	$('input:text[name*="field_values'+counter+'_"]').each( function(){	
		if($(this).val() != ""){
			document.form_create_field.list_content_fields.value +=$(this).attr('name')+"##"; 
			document.form_create_field.list_content_fields_values.value +=$(this).val()+"##"; 
		}
	});
	document.form_create_field.list_content_fields.value = document.form_create_field.list_content_fields.value.substring(0,document.form_create_field.list_content_fields.value.lastIndexOf("##"));
	document.form_create_field.list_content_fields_values.value = document.form_create_field.list_content_fields_values.value.substring(0,document.form_create_field.list_content_fields_values.value.lastIndexOf("##"));


	var preview_new_field = "";
	preview_new_field += "group_value="+document.form_create_field.group_value.value;
	preview_new_field += "&field_description="+document.form_create_field.field_description.value;
	preview_new_field += "&content_field_active="+document.form_create_field.content_field_active.value;
	preview_new_field += "&content_field_mandatory="+document.form_create_field.content_field_mandatory.value;
	preview_new_field += "&content_field_editable="+document.form_create_field.content_field_editable.value;
	preview_new_field += "&sorting="+document.form_create_field.sorting.value;
	preview_new_field += "&max_lenght="+document.form_create_field.max_lenght.value;
	preview_new_field += "&id_type="+document.form_create_field.id_type.value;
	preview_new_field += "&id_type_content="+document.form_create_field.id_type_content.value;
	preview_new_field += "&field_value="+document.form_create_field.field_value.value;
	preview_new_field += "&id_content="+document.form_create_field.id_content.value;
	preview_new_field += "&pre_el_id="+document.form_create_field.pre_el_id.value;
	preview_new_field += "&field_description_ml="+document.form_create_field.field_description_ml.value;
	preview_new_field += "&list_content_fields="+document.form_create_field.list_content_fields.value;
	preview_new_field += "&list_content_fields_values="+document.form_create_field.list_content_fields_values.value;
	preview_new_field += "&id_field="+document.form_create_field.id_field.value;
	preview_new_field += "&operation="+document.form_create_field.operation.value;
	//alert(preview_new_field);

	var query_string = preview_new_field;
	//alert("query_string: "+query_string);

	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		data: $('#form_create_field').serialize(),
		url: "<%=secureURL%>area_user/ads/ajaxsavefield.aspx",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			changeRowListData(counter,row,refreshrow, modify, response, subcounter);
		},
		error: function (response) {
			/*var r = jQuery.parseJSON(response.responseText);
			alert("Message: " + r.Message);
			alert("StackTrace: " + r.StackTrace);
			alert("ExceptionType: " + r.ExceptionType);*/
			//alert("error: "+response.responseText);
			$("#ajaxresp").empty();
			$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_updated_field")%>");
			$("#ajaxresp").fadeIn(1500,"linear");
			$("#ajaxresp").fadeOut(600,"linear");
		}
	});
}

function changeRowListData(counter,row,refreshrow, modify, newidfield, subcounter){
	if(modify==1){
		var ajxactive = "<%=lang.getTranslated("portal.commons.yes")%>";
		if(document.form_create_field.content_field_active.value==""){ajxactive = "<%=lang.getTranslated("portal.commons.no")%>";}
		$('#td_content_field_active_'+counter).text(ajxactive);
		var ajxmandatory = "<%=lang.getTranslated("portal.commons.yes")%>";
		if(document.form_create_field.content_field_mandatory.value==""){ajxmandatory = "<%=lang.getTranslated("portal.commons.no")%>";}
		$('#td_content_field_mandatory_'+counter).text(ajxmandatory);
		var ajxeditable = "<%=lang.getTranslated("portal.commons.yes")%>";
		if(document.form_create_field.content_field_editable.value==""){ajxeditable = "<%=lang.getTranslated("portal.commons.no")%>";}
		$('#td_content_field_editable_'+counter).text(ajxeditable);
		$('#td_content_field_sort_'+counter).text(document.form_create_field.sorting.value);
		$('#td_content_field_group_'+counter).text(document.form_create_field.group_value.value);
		$('#td_content_field_name_'+counter).text(document.form_create_field.field_description.value);
		var modtype = document.form_create_field.id_type.value;
		var modtype_content = document.form_create_field.id_type_content.value;
		var modvalue = document.form_create_field.field_value.value;
		$('#td_content_field_type_'+counter).text(fieldTypesList.get(modtype));
		if(modtype==3 && (modtype_content==7 || modtype_content==8)){
			if(modtype_content==7){			
				var tmpmodval = modvalue.substring(0,modvalue.indexOf('_'));
				$('#td_content_field_value_'+counter).html(countryList.get(tmpmodval));
			}else if(modtype_content==8){
				var tmpmodval = modvalue.substring(0,modvalue.indexOf('_'));
				$('#td_content_field_value_'+counter).html(stateRegionList.get(tmpmodval));
			}
		}else{
			$('#td_content_field_value_'+counter).html(modvalue);
		}
		$(row).hide();	
		$('#'+refreshrow+counter).show();	
	}else{
		if(modify==0){
			showNewFieldAdd();
		}else{
			var rowtmp = row.replace(/#tr_ccontent_field_edit_/g, "#tr_ccontent_field_");
			backField(row,rowtmp);
		}
		
		var newHtmlSource = "";
		var countsuffix = counter;
		var subcountsuffix = subcounter;

		newHtmlSource+= $('<input type="hidden"/>').attr('id', "id_field_"+newidfield).attr('name', "id_field_"+newidfield).attr('value', newidfield);
		newHtmlSource+= '<tr class="table-list-off" id="tr_content_field_'+newidfield+'">';
			newHtmlSource+= '<td style="padding:0px; ">';
			newHtmlSource+= '<a href="';
			newHtmlSource+= "javascript:deleteField("+newidfield+",'tr_content_field_"+newidfield+"','tr_content_field_');";
			newHtmlSource+= '">';
			newHtmlSource+= '<img vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" src="/backoffice/img/delete.png">';
			newHtmlSource+= '</a></td>';
			newHtmlSource+= '<td style="padding:0px; "><a href="';
			newHtmlSource+= "javascript:modifyField('#tr_content_field_edit_"+newidfield+"','#tr_content_field_"+newidfield+"');";
			newHtmlSource+= '">';
			newHtmlSource+= '<img vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" alt="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" src="/backoffice/img/pencil.png">';
			newHtmlSource+= '</a></td>';
			newHtmlSource+= '<td style="text-align:center;" id="td_content_field_active_'+newidfield+'">';			
			if(document.form_create_field.content_field_active.value==""){
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.no")%>';
			}else{
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.yes")%>';
			}
			newHtmlSource+= '</td>';
			newHtmlSource+= '<td style="text-align:center;" id="td_content_field_mandatory_'+newidfield+'">';			
			if(document.form_create_field.content_field_mandatory.value==""){
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.no")%>';
			}else{
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.yes")%>';
			}
			newHtmlSource+= '</td>';
			newHtmlSource+= '<td style="text-align:center;" id="td_content_field_editable_'+newidfield+'">';		
			if(document.form_create_field.content_field_editable.value==""){
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.no")%>';
			}else{
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.yes")%>';
			}
			newHtmlSource+= '</td>';
			newHtmlSource+= '<td style="text-align:center;" id="td_content_field_sort_'+newidfield+'">'+document.form_create_field.sorting.value+'&nbsp;</td>';
			newHtmlSource+= '<td id="td_content_field_group_'+newidfield+'">'+document.form_create_field.group_value.value+'&nbsp;</td>';
			newHtmlSource+= '<td id="td_content_field_name_'+newidfield+'">'+document.form_create_field.field_description.value+'&nbsp;</td>';
			newHtmlSource+= '<td id="td_content_field_type_'+newidfield+'">'+fieldTypesList.get(document.form_create_field.id_type.value)+'</td>';
			newHtmlSource+= '<td id="td_content_field_value_'+newidfield+'">'+document.form_create_field.field_value.value+'</td>';					
		newHtmlSource+= '</tr>';

		newHtmlSource+= '<tr id="tr_content_field_edit_'+newidfield+'" class="table-list-off" style="display:none;">';
			newHtmlSource+= '<td style="padding:0px;vertical-align:top;padding-top:5px;">';
				newHtmlSource+= '<a href="';
				newHtmlSource+= "javascript:backField('#tr_content_field_edit_"+newidfield+"','#tr_content_field_"+newidfield+"');";
				newHtmlSource+= '">';
				newHtmlSource+= '<img align="left" vspace="0" hspace="4" border="0" title="<%=lang.getTranslated("backend.commons.back")%>" src="/backoffice/img/arrow_left.png" style="cursor:pointer;">';
				newHtmlSource+= '</a>';
			newHtmlSource+= '</td>';
			newHtmlSource+= '<td style="padding:0px;vertical-align:top;padding-top:5px;">';
				newHtmlSource+= '<a href="';
				newHtmlSource+= "javascript:saveField("+newidfield+",'#tr_content_field_edit_"+newidfield+"','tr_content_field_',1,"+subcounter+");";
				newHtmlSource+= '">';
				newHtmlSource+= '<img align="left" vspace="0" hspace="4" border="0" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.save_field")%>" src="/backoffice/img/disk.png" style="cursor:pointer;">';
				newHtmlSource+= '</a>';
			newHtmlSource+= '</td>';
			newHtmlSource+= '<td style="padding-bottom:10px;" colspan="8">';
			
			var myRegExp;
			var edithtml = $('#new_field_container'+counter).clone(true,true).html();					
			myRegExp = new RegExp(/.cleditor\(\)/g);
			edithtml = edithtml.replace(myRegExp, '.cleditor()[0].refresh()');
			myRegExp = new RegExp("delFieldValues\\('"+countsuffix,"ig");
			edithtml = edithtml.replace(myRegExp, "delFieldValues('"+newidfield);
			myRegExp = new RegExp(",'field_values_container"+countsuffix+"_","ig");
			edithtml = edithtml.replace(myRegExp, ",'field_values_container"+newidfield+"_");
			
			myRegExp = new RegExp("',0\\);\">","ig");
			edithtml = edithtml.replace(myRegExp, "',1);\">");
			
			myRegExp = new RegExp(/value="-1"/g);	
			edithtml = edithtml.replace(myRegExp, 'value=\"'+newidfield+'\"');		
			myRegExp = new RegExp("value=\""+countsuffix+"\"","ig");	
			edithtml = edithtml.replace(myRegExp, 'value=\"'+newidfield+'\"');	
			myRegExp = new RegExp("\\("+countsuffix+"\\)","ig");	
			edithtml = edithtml.replace(myRegExp, "("+newidfield+")");
			myRegExp = new RegExp("\\('"+countsuffix+"'\\)","ig");
			edithtml = edithtml.replace(myRegExp, "('"+newidfield+"')");
			
			myRegExp = new RegExp(",'"+countsuffix+"',","ig");
			edithtml = edithtml.replace(myRegExp, ",'"+newidfield+"',");
			
			
			myRegExp = new RegExp(countsuffix+"_","ig");
			edithtml = edithtml.replace(myRegExp, newidfield+"_");
			myRegExp = new RegExp("_"+countsuffix,"ig");
			edithtml = edithtml.replace(myRegExp, "_"+newidfield);	
			myRegExp = new RegExp("field_checkedvalues"+countsuffix,"ig");
			edithtml = edithtml.replace(myRegExp, "field_checkedvalues"+newidfield);	
			myRegExp = new RegExp(newidfield+'_'+newidfield,'ig');
			edithtml = edithtml.replace(myRegExp, newidfield+"_0");
			
			newHtmlSource+= edithtml;
			newHtmlSource+= '</td>';
		newHtmlSource+= '</tr>';	
		
		$('#inner-table-content-field-list').append(newHtmlSource);

		var classon = "table-list-on";
		var classoff = "table-list-off";
		var counter = 1;	
		
		$("tr[id*='tr_content_field_']").each(function(){
			if($(this).is(':visible')){
				if(counter % 2 == 0){
					$(this).attr("class",classoff);
				}else{
					$(this).attr("class",classon);
				}
				counter+=1;
			}
		});

		if(modify==2){
			$('#group_value_'+newidfield).attr('readonly',false);
			$('#group_value_'+newidfield).attr('style', "background:#FFFFFF;color:#000000;");
			
			$('#field_description_'+newidfield).attr('readonly',false);
			$('#field_description_'+newidfield).attr('style', "background:#FFFFFF;color:#000000;");
			
			$('#max_lenght_'+newidfield).attr('readonly',false);
			$('#max_lenght_'+newidfield).attr('style', "background:#FFFFFF;color:#000000;");
			
			$('#content_field_editable_'+newidfield).attr('readonly',false);
			$('#content_field_editable_'+newidfield).attr('disabled',false);
			$('#content_field_editable_'+newidfield).attr('style', "background:#FFFFFF;color:#000000;");

			$("select[id*='id_type_"+newidfield+"'] option").each(function(){
				$(this).css('display','block');
			});

			$("select[id*='id_type_content_"+newidfield+"'] option").each(function(){
				$(this).css('display','block');
			});

			$("input[id*='field_values"+newidfield+"_']").each(function(){
				$(this).attr('readonly',false);
				$(this).attr('style', "background:#FFFFFF;color:#000000;");
			});
				
			$("#grouprotate_clockwise_"+newidfield).show();
			$("#descrotate_clockwise_"+newidfield).show();
			$("#descmultilang_"+newidfield).show();										
			$("#imgaddfieldvalue_"+newidfield).show();
			$("img[id*='imgdelfieldvalue_"+newidfield+"_']").each(function(){
				$(this).show();
			});
		}


		$('#group_value_'+newidfield).val($('#group_value_'+countsuffix).val());
		$('#field_description_'+newidfield).val($('#field_description_'+countsuffix).val());
		$('#sorting_'+newidfield).val($('#sorting_'+countsuffix).val());
		$('#max_lenght_'+newidfield).val($('#max_lenght_'+countsuffix).val());
		$('#id_type_'+newidfield).val($('#id_type_'+countsuffix).val());
		$('#id_type_content_'+newidfield).val($('#id_type_content_'+countsuffix).val());
		
		if($('#content_field_active_'+countsuffix).is(':checked')){	
			$('#content_field_active_'+newidfield).attr('checked',true);	
		}else{
			$('#content_field_active_'+newidfield).attr('checked',false);
		}
		if($('#content_field_mandatory_'+countsuffix).is(':checked')){	
			$('#content_field_mandatory_'+newidfield).attr('checked',true);	
		}else{
			$('#content_field_mandatory_'+newidfield).attr('checked',false);
		}
		if($('#content_field_editable_'+countsuffix).is(':checked')){	
			$('#content_field_editable_'+newidfield).attr('checked',true);
		}else{
			$('#content_field_editable_'+newidfield).attr('checked',false);
		}

		$('[name*="field_values'+countsuffix+'_"]').each( function(){
				var thisname = $(this).attr('name');	
				thisname = thisname.substring(thisname.lastIndexOf('_')+1);		
				$('#field_values'+newidfield+"_"+thisname).val($(this).val());
		});

		var tmp_type = $('#id_type_'+newidfield).val();
		var tmp_type_content = $('#id_type_content_'+newidfield).val();
		if(tmp_type==1 || tmp_type==7){
			$('#field_value_t_'+newidfield).val($('#field_value_t_'+countsuffix).val());
		}else if(tmp_type==2){
			$('#field_value_ta_'+newidfield).val($('#field_value_ta_'+countsuffix).val());
		}else if(tmp_type==9){	
			$('#field_value_e_'+newidfield).val($('#field_value_e_'+countsuffix).val()).blur();		
		}else if(tmp_type==10){
			$('#field_value_p_'+newidfield).val($('#field_value_p_'+countsuffix).val());
		}else if(tmp_type==3 || tmp_type==4 || tmp_type==5 || tmp_type==6){	
			$("[id*='field_checkedvaluesc"+newidfield+"']").val('');
			$("[id*='field_checkedvaluesr"+newidfield+"']").val('');
			if(tmp_type==3 || tmp_type==6){
				$("[id*='field_checkedvaluesc"+newidfield+"']").hide();
				$("[id*='field_checkedvaluesr"+newidfield+"']").show();
			}else{
				$("[id*='field_checkedvaluesr"+newidfield+"']").hide();
				$("[id*='field_checkedvaluesc"+newidfield+"']").show();		
			}		
			if(tmp_type_content==7){
				var tmpmodval = $('#field_value_ct_'+countsuffix).val();			
				tmpmodval = tmpmodval.substring(0,tmpmodval.indexOf('_'));
				$('#td_content_field_value_'+newidfield).html(countryList.get(tmpmodval));
				$('#field_value_ct_'+newidfield).val($('#field_value_ct_'+countsuffix).val());
			}else if(tmp_type_content==8){
				var tmpmodval = $('#field_value_sr_'+countsuffix).val();			
				tmpmodval = tmpmodval.substring(0,tmpmodval.indexOf('_'));
				$('#td_content_field_value_'+newidfield).html(stateRegionList.get(tmpmodval));
				$('#field_value_sr_'+newidfield).val($('#field_value_sr_'+countsuffix).val());				
			}else{
				$('[name*="field_checkedvalues'+countsuffix+'"]').each( function(){
					var partialid = $(this).attr('id');					
					var newid = partialid.substring(0,partialid.indexOf("field_checkedvalues")+20)+newidfield+partialid.substring(partialid.indexOf(countsuffix+"_")+countsuffix.toString().length,partialid.lenght);
					if($(this).is(':checked')){
						//alert("newid:"+newid);
						$('#'+newid).attr('checked',true);
					}
				});
			}	
		}else{			
			$('#field_value_h_'+newidfield).val($('#field_value_h_'+countsuffix).val());
		}
	}
}

$(document).ready(function(){
	onloadFieldsTypes();
});
</script>
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />
	<div id="container">
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>	
		<div id="backend-content">
			<table border="0" cellspacing="0" cellpadding="0" class="principal">
			<tr> 		  		  
				<td>
					<form action="<%=secureURL%>area_user/ads/ajaxsavefield.aspx" method="post" id="form_create_field" name="form_create_field" enctype="multipart/form-data" accept-charset="UTF-8">
					  <input type="hidden" value="addfield" name="operation">		
					  <input type="hidden" value="<%=content.id%>" name="id_content">
					  <input type="hidden" value="" name="id_field">
					  <input type="hidden" value="<%=pre_el_id%>" name="pre_el_id">				
					  <input type="hidden" value="" name="group_value">				
					  <input type="hidden" value="" name="field_description">	
					  <input type="hidden" value="" name="field_description_ml">					  
					  <input type="hidden" value="" name="content_field_active">	
					  <input type="hidden" value="" name="content_field_mandatory">	
					  <input type="hidden" value="" name="content_field_editable">	
					  <input type="hidden" value="" name="sorting">	
					  <input type="hidden" value="" name="max_lenght">	
					  <input type="hidden" value="" name="id_type">	
					  <input type="hidden" value="" name="id_type_content">		
					  <input type="hidden" value="" name="field_value">
					  <input type="hidden" value="" name="list_content_fields">
					  <input type="hidden" value="" name="list_content_fields_values">			
					</form>
					<form action="<%=secureURL%>area_user/ads/insertcontent.aspx" method="post" name="form_inserisci" enctype="multipart/form-data" accept-charset="UTF-8">
					<input type="hidden" value="<%=content.id%>" name="id"  id="id">
					<input type="hidden" value="<%=pre_el_id%>" name="pre_el_id">
					<input type="hidden" value="insert" name="operation">
					<input type="hidden" value="1" name="savesc">			 	
		  			<input type="hidden" value="<%=Request["cssClass"]%>" name="cssClass">				
					<div class="labelForm" align="left"><%=lang.getTranslated("backend.contenuti.detail.table.label.title")%></div>
					<div id="divTitle" align="left">
					<textarea name="title" class="formFieldTXTAREAAbstract"><%=HttpUtility.HtmlEncode(content.title)%></textarea>
					</div><br/>
					<div align="left" style="float:left;padding-right: 5px;">				
						<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.page_title")%></span><br/>
						<input type="text" name="page_title" value="<%=HttpUtility.HtmlEncode(content.pageTitle)%>" class="formFieldTXT">
					  </div>
					  <div align="left" style="float:left;padding-right: 5px;">
					  <span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.meta_description")%></span><br/>
					    <input type="text" name="meta_description" value="<%=HttpUtility.HtmlEncode(content.metaDescription)%>" class="formFieldTXT">
					  </div>
					 <div align="left" style="padding-bottom:20px;">
					 <span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.meta_keyword")%></span><br/>
					    <input type="text" name="meta_keyword" value="<%=HttpUtility.HtmlEncode(content.metaKeyword)%>" class="formFieldTXT">
					</div>
					<br>
					
					<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divSummary1');showHideDivArrow('divSummary1','arrow1');"><img src="<%if (!String.IsNullOrEmpty(content.summary)){Response.Write("/backoffice/img/div_freccia.gif");}else{Response.Write("/backoffice/img/div_freccia2.gif");}%>" vspace="0" hspace="0" border="0" align="right" id="arrow1"><%=lang.getTranslated("backend.contenuti.detail.table.label.abstract_field")%></div>
					<div id="divSummary1"  <%if (!String.IsNullOrEmpty(content.summary)){Response.Write("style=visibility:visible;display:block;");}else{Response.Write("style=visibility:hidden;display:none;");}%> align="left">
					<FCKeditorV2:FCKeditor ID="summary" ImageBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" LinkBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" Height="200px" runat="server"></FCKeditorV2:FCKeditor>
					</div><br>
					
					<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divText');showHideDivArrow('divText','arrowText');"><img src="<%if (!String.IsNullOrEmpty(content.description)){Response.Write("/backoffice/img/div_freccia.gif");}else{Response.Write("/backoffice/img/div_freccia2.gif");}%>" vspace="0" hspace="0" border="0" align="right" id="arrowText"><%=lang.getTranslated("backend.contenuti.detail.table.label.text")%></div>
					<div id="divText"  <%if (!String.IsNullOrEmpty(content.description)){Response.Write("style=visibility:visible;display:block;");}else{Response.Write("style=visibility:hidden;display:none;");}%> align="left">
					<FCKeditorV2:FCKeditor ID="description" ImageBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" LinkBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" Height="400px" runat="server"></FCKeditorV2:FCKeditor>	
					</div><br>

					<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>

					<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divCommonContentFields');showHideDivArrow('divCommonContentFields','arrowFields');"><img src="/backoffice/img/div_freccia2.gif" vspace="0" hspace="0" border="0" align="right" id="arrowFields"><%=lang.getTranslated("backend.contenuti.detail.table.label.common_product_fields")%></div>
					<div id="divCommonContentFields" style="visibility:hidden;display:none;padding-top:2px;" align="left">
					  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table" id="inner-table-content-field-list-common">
						<tr>
						<th width="16">&nbsp;</th>
						<th width="16">&nbsp;</th>
						<th width="40"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_attivo")%></span></th>
						<th width="70" style="vertical-align:middle;"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_mandatory")%></span></th>
						<th width="70" style="vertical-align:middle;"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_editable")%></span></th>
						<th width="70" style="text-align:center;"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_sort")%></span></th>
						<th width="170"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_group")%></span></th>
						<th width="150"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_name")%></span></th>
						<th width="100"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_type")%></span></th>
						<th><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_values")%></span></th>
						</tr>
					  <!--<tbody>-->
					<%int counterCommon = 0;
					int valuesCounterCommon = 0;
					foreach(ContentField cf in commonfields){
						if(cf.common){							
							string labelFormCommon = cf.description;%>
							<input type="hidden" value="<%=cf.id%>" name="id_field" id="id_field_<%=cf.id%>">	  
							<tr class="<%if(counterCommon % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_ccontent_field_<%=cf.id%>">
							<td style="padding:0px; "><img width="16"  vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="" alt="" src="/backoffice/img/spacer.gif"></td>
							<td style="padding:0px; "><a href="javascript:modifyField('#tr_ccontent_field_edit_<%=cf.id%>','#tr_ccontent_field_<%=cf.id%>');"><img vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" alt="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" src="/backoffice/img/add.png"></a></td>
							<td style="text-align:center;" id="td_content_field_active_<%=cf.id%>"><%=lang.getTranslated("backend.commons.no")%></td>
							<td style="text-align:center;" id="td_content_field_mandatory_<%=cf.id%>"><%if(cf.required){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="text-align:center;" id="td_content_field_editable_<%=cf.id%>"><%if(cf.editable){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="text-align:center;" id="td_content_field_sort_<%=cf.id%>"><%=cf.sorting%></td>
							<td id="td_content_field_group_<%=cf.id%>"><%=cf.groupDescription%></td>
							<td id="td_content_field_name_<%=cf.id%>"><%=labelFormCommon%></td>
							<td id="td_content_field_type_<%=cf.id%>">
							<%string currtypeCommon = "";
							foreach(SystemFieldsType x in systemFieldsType){
								if(cf.type==x.id){
									currtypeCommon=x.description;
									break;
								}
							}
							Response.Write(currtypeCommon);%>
							</td>
							<td id="td_content_field_value_<%=cf.id%>">
								<%if(cf.type==3){
									if(cf.typeContent==7 && !String.IsNullOrEmpty(cf.value)){
										string tmpcfvalCommon = cf.value.Substring(0,cf.value.IndexOf('_'));
										foreach(Country c in countries){
											if(tmpcfvalCommon == c.countryCode){
												Response.Write(c.countryDescription);
												break;
											}
										}
									}else if(cf.typeContent==8 && !String.IsNullOrEmpty(cf.value)){
										string tmpcfvalCommon = cf.value.Substring(0,cf.value.IndexOf('_'));
										foreach(Country sr in stateRegions){
											if(tmpcfvalCommon == sr.stateRegionCode){
												Response.Write(sr.countryDescription+" "+sr.stateRegionDescription);
												break;
											}
										}									
									}else{
										Response.Write(cf.value);
									}
								}else{
									Response.Write(cf.value);
								}%>
							</td>					
							 </tr>
							 
							 <tr style="display:none;" id="tr_ccontent_field_edit_<%=cf.id%>">
								 <td style="padding:0px;vertical-align:top;padding-top:5px;">
								 <a href="javascript:backField('#tr_ccontent_field_edit_<%=cf.id%>','#tr_ccontent_field_<%=cf.id%>');"><img style="cursor:pointer;" align="left" src="/backoffice/img/arrow_left.png" title="<%=lang.getTranslated("backend.commons.back")%>" hspace="4" vspace="0" border="0"></a>
								 </td>
								 <td style="padding:0px;vertical-align:top;padding-top:5px;">
								 <a href="javascript:saveField(<%=cf.id%>,'#tr_ccontent_field_edit_<%=cf.id%>','tr_content_field_',2,<%=valuesCounterCommon%>);"><img style="cursor:pointer;" align="left" src="/backoffice/img/disk.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.save_field")%>" hspace="4" vspace="0" border="0"></a>
								 </td>
								 <td id="new_field_container<%=cf.id%>" colspan="8" style="padding-bottom:10px;">
								<input type="hidden" value="<%=cf.id%>" name="id_field" id="id_field_<%=cf.id%>">						 
								 <div style="float:left;padding-right:20px;padding-top:5px;min-width:360px;">	
									 <div style="float:left;padding-right:10px; height:30px;min-width:155px;" >												
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_group")%></span>
										<img id="grouprotate_clockwise_<%=cf.id%>" onclick="javascipt:changeFieldGroupDesc(<%=cf.id%>);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.field_reload")%>" hspace="2" vspace="0" border="0"><br/>
										<input type="text" name="group_value" id="group_value_<%=cf.id%>"  value="<%=cf.groupDescription%>" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialChar(event);">
										<select name="group_value_c" id="group_value_c_<%=cf.id%>" style="display:none;min-width:150px;">
										<option></option>
										<%foreach(string x in fieldGroupNames){%>
										<option value="<%=x%>"><%=x%></option>
										<%}%>
										</select>
									 </div>
									 <div style="float:top;padding-right:10px; height:40px;min-width:185px;display:block;" >
										 <span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_name")%></span>
										<img id="descrotate_clockwise_<%=cf.id%>" onclick="javascipt:changeFieldName(<%=cf.id%>);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.field_reload")%>" hspace="2" vspace="0" border="0"><br/>
										<input type="text" name="field_description" id="field_description_<%=cf.id%>" value="<%=cf.description%>" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialCharButUnderscore(event);">
										<select name="field_description_c" id="field_description_c_<%=cf.id%>" style="display:none;min-width:150px;vertical-align:top;">
										<option></option>
										<%foreach(string x in fieldNames){%>
										<option value="<%=x%>"><%=x%></option>
										<%}%>
										</select>
										<a href="javascript:showHideDiv('field_description_<%=cf.id%>_ml');" class="labelForm"><img id="descmultilang_<%=cf.id%>" width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
										<br/>
										<div style="visibility:hidden;position:relative;left:+165px;width:236px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_description_<%=cf.id%>_ml">
										<%foreach (Language x in languages){%>
											<input type="text" hspace="2" vspace="2" name="field_description_<%=cf.id%>_<%=x.label%>" id="field_description_<%=cf.id%>_<%=x.label%>" value="" class="formFieldTXTInternationalization">
											&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
										<%}%>									
										</div>
									
									
									 </div>
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
										 <input type="checkbox" value="1" id="content_field_active_<%=cf.id%>" name="content_field_active">
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_attivo")%></span>
									 </div>
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
										 <input type="checkbox" value="1" id="content_field_mandatory_<%=cf.id%>" name="content_field_mandatory" <%if(cf.required){Response.Write("checked='checked'");}%>>
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_mandatory")%></span>
									 </div>
									 <div style="float:top;padding-right:10px;padding-top:5px;" >
										 <input type="checkbox" value="1" id="content_field_editable_<%=cf.id%>" name="content_field_editable" onclick="javascript:onClickFieldEditable(<%=cf.id%>);" <%if(cf.editable){Response.Write("checked='checked'");}%>>
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_editable")%></span>
									 </div>	
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_sort")%></span><br/>
										<input type="text" name="sorting" id="sorting_<%=cf.id%>" value="<%=cf.sorting%>" class="formFieldTXTShort" maxlength="3" onkeypress="javascript:return isInteger(event);">
									 </div>
									 <div style="float:top;padding-right:10px;padding-top:5px;" >
										<span id="max_lenght_container_<%=cf.id%>" class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.max_lenght")%><br/>	
										<input type="text" name="max_lenght" id="max_lenght_<%=cf.id%>" value="<%if(cf.maxLenght>0){Response.Write(cf.maxLenght);}%>" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);">
										</span>
									 </div>					 
								 </div>
								<script type="text/javascript">							
										$("#group_value_c_<%=cf.id%>").change(function(){
											$("#group_value_<%=cf.id%>").val($('#group_value_c_<%=cf.id%>').val());
											$("#group_value_c_<%=cf.id%>").hide();
											$("#group_value_<%=cf.id%>").show();
										});							
										$("#group_value_c_<%=cf.id%>").blur(function(){
											$("#group_value_<%=cf.id%>").val($('#group_value_c_<%=cf.id%>').val());
											$("#group_value_c_<%=cf.id%>").hide();
											$("#group_value_<%=cf.id%>").show();
										});
															
										$("#field_description_c_<%=cf.id%>").change(function(){
											$("#field_description_<%=cf.id%>").val($('#field_description_c_<%=cf.id%>').val());
											$("#field_description_c_<%=cf.id%>").hide();
											$("#field_description_<%=cf.id%>").show();
										});
															
										$("#field_description_c_<%=cf.id%>").blur(function(){
											$("#field_description_<%=cf.id%>").val($('#field_description_c_<%=cf.id%>').val());
											$("#field_description_c_<%=cf.id%>").hide();
											$("#field_description_<%=cf.id%>").show();
										});
								</script>
															 
								 <div style="float:left;padding-right:10px;padding-top:5px;">							 
									<div style="float:top;padding-right:20px;">
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.type")%></span><br>										
										<select name="id_type" id="id_type_<%=cf.id%>" class="formFieldSelectSimple" onchange="javascript:onChangeFieldsType(<%=cf.id%>);">
											<%foreach(SystemFieldsType x in systemFieldsType){
												string stypeLabel = x.description;
												if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type.label."+x.description))){
													stypeLabel = lang.getTranslated("portal.commons.content_field.type.label."+x.description);
												}%>
												<option VALUE="<%=x.id%>" <%if (x.id==cf.type) {Response.Write(" selected");}%>><%=stypeLabel%></option>
											<%}%>
										</select>
									</div>	
									<div style="float:top;padding-right:20px;width:auto;vertical-align:top;margin-top:5px;">
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.type_content")%></span><br>
										<select name="id_type_content" id="id_type_content_<%=cf.id%>" class="formFieldSelectSimple" onchange="javascript:onChangeFyeldTypeContent(<%=cf.id%>);">
											<%foreach(SystemFieldsTypeContent x in systemFieldsTypeContent){
												string stypecLabel = x.description;
												if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type_content.label."+x.description))){
													stypecLabel = lang.getTranslated("portal.commons.content_field.type_content.label."+x.description);
												}%>
												<option VALUE="<%=x.id%>" <%if (x.id==cf.typeContent) {Response.Write(" selected");}%>><%=stypecLabel%></option>
											<%}%>
										</select>											
									</div>								 
								 </div>	
								 
									<div style="float:left;padding-left:20px;padding-right:10px;padding-top:0px;">
										<div align="left" id="field_values_div_<%=cf.id%>">
											  <span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.values")%></span>
											&nbsp;<a href="javascript:addFieldValues('<%=cf.id%>');"><img id="imgaddfieldvalue_<%=cf.id%>" src="/backoffice/img/add.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.add_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.add_field_value")%>" hspace="5" vspace="0" border="0"></a>
											  <%
												int totalCounterCommon = 0;
												IList<ContentFieldsValue> objListValues = contrep.getContentFieldValues(cf.id);
												if(objListValues != null){
													totalCounterCommon = objListValues.Count;
												}
												
												if(totalCounterCommon > 0) {
													string[] savedValues = null;
													if (!String.IsNullOrEmpty(cf.value)){
														savedValues = cf.value.Split(',');
													}
													
													foreach(ContentFieldsValue j in objListValues){
														string currfvchecked = "";
														if(savedValues != null){
															foreach(string x in savedValues){
																if(x==j.value){
																	currfvchecked = " checked='checked'";
																	break;
																}
															}
														}
														%>
														<span id="field_values_container<%=cf.id+"_"+valuesCounterCommon%>">
														<br/>
														<%if(cf.type==3 || cf.type==6){%>
															<input type="checkbox" id="field_checkedvaluesc<%=cf.id+"_"+valuesCounterCommon%>" name="field_checkedvalues<%=cf.id%>" value="" style="display:none;">
															<input type="radio" <%=currfvchecked%> id="field_checkedvaluesr<%=cf.id+"_"+valuesCounterCommon%>" name="field_checkedvalues<%=cf.id%>" value="">												
														<%}else{%>
															<input type="radio" id="field_checkedvaluesr<%=cf.id+"_"+valuesCounterCommon%>" name="field_checkedvalues<%=cf.id%>" value="" style="display:none;">
															<input type="checkbox" <%=currfvchecked%> id="field_checkedvaluesc<%=cf.id+"_"+valuesCounterCommon%>" name="field_checkedvalues<%=cf.id%>" value="">
														<%}%>
														<input type="text" id="field_values<%=cf.id+"_"+valuesCounterCommon%>" name="field_values<%=cf.id+"_"+valuesCounterCommon%>" value="<%=j.value%>" class="formFieldTXT" onkeypress="javascript:return notSpecialChar(event);">&nbsp;<a href="javascript:delFieldValues('<%=cf.id+"_"+valuesCounterCommon%>','<%=cf.id%>','<%=j.value%>','field_values_container<%=cf.id+"_"+valuesCounterCommon%>',1);"><img id="imgdelfieldvalue_<%=cf.id+"_"+valuesCounterCommon%>" src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
														</span>
														<%valuesCounterCommon++;
													}
												}
											  
												if(totalCounterCommon == 0) {%>
													<span id="field_values_container<%=cf.id+"_"+valuesCounterCommon%>">
													<br/>
													<%if(cf.type==3 || cf.type==6){%>
														<input type="checkbox" id="field_checkedvaluesc<%=cf.id+"_"+valuesCounterCommon%>" name="field_checkedvalues<%=cf.id%>" value="" style="display:none;">
														<input type="radio" id="field_checkedvaluesr<%=cf.id+"_"+valuesCounterCommon%>" name="field_checkedvalues<%=cf.id%>" value="">												
													<%}else{%>
														<input type="radio" id="field_checkedvaluesr<%=cf.id+"_"+valuesCounterCommon%>" name="field_checkedvalues<%=cf.id%>" value="" style="display:none;">
														<input type="checkbox" id="field_checkedvaluesc<%=cf.id+"_"+valuesCounterCommon%>" name="field_checkedvalues<%=cf.id%>" value="">
													<%}%>
													<input type="text" id="field_values<%=cf.id+"_"+valuesCounterCommon%>" name="field_values<%=cf.id+"_"+valuesCounterCommon%>" value="" class="formFieldTXT" onkeypress="javascript:return notSpecialChar(event);">&nbsp;<a href="javascript:delFieldValues('<%=cf.id+"_"+valuesCounterCommon%>','<%=cf.id%>','','field_values_container<%=cf.id+"_"+valuesCounterCommon%>',1);"><img id="imgdelfieldvalue_<%=cf.id+"_"+valuesCounterCommon%>" src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
													</span>
													<%valuesCounterCommon++;
												}%>
											  <div id="add_field_values_div_<%=cf.id%>"></div>							 
										</div>

										<div align="left" style="display:none;margin-top:20px;" id="field_values_div_country_<%=cf.id%>">
											<%
											if(countries != null && countries.Count>0){%>
												<select name="field_value_<%=cf.id%>" id="field_value_ct_<%=cf.id%>">
												<option value=""></option>
												<%foreach(Country x in countries){
													string checkRpValue = x.countryCode+"_"+x.id;%>
													<option value="<%=x.countryCode%>_<%=x.id%>" <%if(checkRpValue==cf.value){Response.Write(" selected");}%>><%=x.countryDescription%></option>
												<%}%>
												</select>										
											<%}%>
										</div>
										<div align="left" style="display:none;margin-top:20px;" id="field_values_div_state_region_<%=cf.id%>">
											<%
											if(stateRegions != null && stateRegions.Count>0){%>
												<select name="field_value_<%=cf.id%>" id="field_value_sr_<%=cf.id%>">
												<option value=""></option>
												<%foreach(Country x in stateRegions){
													string checkRpValue = x.stateRegionCode+"_"+x.id;%>
													<option value="<%=x.stateRegionCode%>_<%=x.id%>" <%if(checkRpValue==cf.value){Response.Write(" selected");}%>><%=x.countryDescription+" "+x.stateRegionDescription%></option>
												<%}%>
												</select>											
											<%}%>
										</div>

									</div>	
									<div id="field_value_box_<%=cf.id%>" style="float:top;padding-right:20px;width:auto;vertical-align:top;padding-top:5px;clear:both;">
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_values")%></span><br>									
										<div id="baseFieldText_t_<%=cf.id%>" style="<%if(cf.type!=1 && cf.type!=7){%>display:none;<%}%>">
											<input type="text" name="field_value_<%=cf.id%>" id="field_value_t_<%=cf.id%>" value="<%=cf.value%>" class="formFieldTXTLong" onkeypress="/*javascript:return notSpecialChar(event);*/">			
										</div>		
										<div id="baseFieldTextarea_ta_<%=cf.id%>" style="<%if(cf.type!=2){%>display:none;<%}%>">
											<textarea name="field_value_<%=cf.id%>" id="field_value_ta_<%=cf.id%>" class="formFieldTXTAREAAbstract"><%=cf.value%></textarea>										
										</div>								
										<div id="baseFieldPassword_p_<%=cf.id%>" style="<%if(cf.type!=10){%>display:none;<%}%>">
											<input type="password" name="field_value_<%=cf.id%>" id="field_value_p_<%=cf.id%>" value="<%=cf.value%>" class="formFieldTXTLong" onkeypress="/*javascript:return notSpecialChar(event);*/">			
										</div>	
										<div id="baseFieldHtmlEditor_e_<%=cf.id%>" style="<%if(cf.type!=9){%>display:none;<%}%>">			
										</div>
										<script>								
										$.cleditor.defaultOptions.width = 600;
										$.cleditor.defaultOptions.height = 200;
										$.cleditor.defaultOptions.controls = "bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image";		
										$(document).ready(function(){
											$("#baseFieldHtmlEditor_e_<%=cf.id%>").empty();
											$("#baseFieldHtmlEditor_e_<%=cf.id%>").append($('<textarea/>').attr('id', "field_value_e_<%=cf.id%>").attr('name', "field_value_<%=cf.id%>").attr('value', '<%=cf.value%>'));	
											$("#field_value_e_<%=cf.id%>").cleditor();
										});
										</script>	
										<div id="baseFieldHidden_h_<%=cf.id%>" style="<%if(cf.type==9 || cf.type==1 || cf.type==2 || cf.type==7){%>display:none;<%}%>">
											<input type="hidden" name="field_value_<%=cf.id%>" id="field_value_h_<%=cf.id%>" value="<%=cf.value%>">			
										</div>								
									</div>				 
								 </td>								 							 


								<script type="text/javascript">		
										$("#group_value_<%=cf.id%>").attr('readonly',true);
										$("#group_value_<%=cf.id%>").attr('style', "background:#E5E5E5;color:#9B8787;");
										
										$("#field_description_<%=cf.id%>").attr('readonly',true);
										$("#field_description_<%=cf.id%>").attr('style', "background:#E5E5E5;color:#9B8787;");
										
										$("#max_lenght_<%=cf.id%>").attr('readonly',true);
										$("#max_lenght_<%=cf.id%>").attr('style', "background:#E5E5E5;color:#9B8787;");
										
										$('#content_field_editable_<%=cf.id%>').attr('readonly',true);
										$('#content_field_editable_<%=cf.id%>').attr('disabled',true);
										$('#content_field_editable_<%=cf.id%>').attr('style', "background:#E5E5E5;color:#9B8787;");										
										

										$("select[id*='id_type_<%=cf.id%>'] option").each(function(){
											if($(this).val()!=<%=cf.type%>){
												$(this).css('display','none');
											}
										});

										$("select[id*='id_type_content_<%=cf.id%>'] option").each(function(){
											if($(this).val()!=<%=cf.typeContent%>){
												$(this).css('display','none');
											}
										});

										$("input[id*='field_values<%=cf.id%>_']").each(function(){
											$(this).attr('readonly',true);
											$(this).attr('style', "background:#E5E5E5;color:#9B8787;");
										});
										
										$("#grouprotate_clockwise_<%=cf.id%>").hide();
										$("#descrotate_clockwise_<%=cf.id%>").hide();	
										$("#descmultilang_<%=cf.id%>").hide();											
										$("#imgaddfieldvalue_<%=cf.id%>").hide();
										$("img[id*='imgdelfieldvalue_<%=cf.id%>_']").each(function(){
											$(this).hide();
										});
								</script>
							 </tr>
							<%counterCommon++;
						}
					}%>
					<!--</tbody>-->
					  </table>


					</div>
					 <br/><br/>


					<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divContentFields');showHideDivArrow('divContentFields','arrowFields');"><img src="<%if (hasContentFields){Response.Write("/backoffice/img/div_freccia.gif"); }else{ Response.Write("/backoffice/img/div_freccia2.gif");}%>" vspace="0" hspace="0" border="0" align="right" id="arrowFields"><%=lang.getTranslated("backend.contenuti.detail.table.label.product_fields")%></div>
					<div id="divContentFields" <%if (hasContentFields) { Response.Write("style=\"visibility:visible;display:block;padding-top:2px;\""); }else{ Response.Write("style=\"visibility:hidden;display:none;padding-top:2px;\"");}%> align="left">
					<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0" style="margin-bottom:10px;">
					<tr id="show_new_field">
						<td colspan="3" style="text-align:left;padding-top:5px;">
							<img onclick="javascipt:showNewFieldAdd();" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/add.png" title="<%=lang.getTranslated("backend.contenuti.lista.label.create_field")%>" alt="<%=lang.getTranslated("backend.contenuti.lista.button.create_field.label")%>" hspace="1" vspace="0" border="0">
							&nbsp;<%=lang.getTranslated("backend.contenuti.lista.label.create_field")%>
						</td>
					</tr>
					<tr style="display:none;" id="show_new_field_add">
					<td style="padding:0px;padding-top:5px;">
						<img onclick="javascipt:showNewFieldAdd();" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_left.png" title="<%=lang.getTranslated("backend.commons.back")%>" hspace="2" vspace="0" border="0">
					</td>
					<td style="padding:0px;padding-top:5px;">
						<img onclick="javascipt:saveField(0,'#tr_content_field_edit_0','tr_content_field_',0,0);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/application_add.png" title="<%=lang.getTranslated("backend.contenuti.lista.button.inserisci_field.label")%>" hspace="2" vspace="0" border="0">
					</td>												  
					<td id="new_field_container0">
						<input type="hidden" value="-1" name="id_field" id="id_field_0">
						 <div style="float:left;padding-right:20px;padding-top:5px;min-width:360px;">	
							 <div style="float:left;padding-right:10px; height:30px;min-width:155px;" >
								<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_group")%></span>
								<img onclick="javascipt:changeFieldGroupDesc(0);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.field_reload")%>" hspace="2" vspace="0" border="0"><br/>
								<input type="text" name="group_value" id="group_value_0"  value="" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialChar(event);">
								<select name="group_value_c" id="group_value_c_0" style="display:none;min-width:150px;">
								<option></option>
								<%foreach(string x in fieldGroupNames){%>
								<option value="<%=x%>"><%=x%></option>
								<%}%>
								</select>
							 </div>
							 <div style="float:top;padding-right:10px; height:40px;min-width:185px;display:block;" >
								 <span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_name")%></span>
								<img onclick="javascipt:changeFieldName(0);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.field_reload")%>" hspace="2" vspace="0" border="0"><br/>
								<input type="text" name="field_description" id="field_description_0" value="" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialCharButUnderscore(event);">
								<select name="field_description_c" id="field_description_c_0" style="display:none;min-width:150px;vertical-align:top;">
								<option></option>
								<%foreach(string x in fieldNames){%>
								<option value="<%=x%>"><%=x%></option>
								<%}%>
								</select>
								<a href="javascript:showHideDiv('field_description_0_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
								<br/>
								<div style="visibility:hidden;position:relative;left:+165px;width:236px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_description_0_ml">
								<%foreach (Language x in languages){%>
									<input type="text" hspace="2" vspace="2" name="field_description_0_<%=x.label%>" id="field_description_0_<%=x.label%>" value="" class="formFieldTXTInternationalization">
									&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
								<%}%>									
								</div>
							 </div>						 
							 <div style="float:left;padding-right:10px;padding-top:5px;" >
								 <input type="checkbox" value="1" id="content_field_active_0" name="content_field_active">
								 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_attivo")%></span>
							 </div>
							 <div style="float:left;padding-right:10px;padding-top:5px;" >
								 <input type="checkbox" value="1" id="content_field_mandatory_0" name="content_field_mandatory">
								 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_mandatory")%></span>
							 </div>
							 <div style="float:top;padding-right:10px;padding-top:5px;" >
								 <input type="checkbox" value="1" id="content_field_editable_0" onclick="javascript:onClickFieldEditable(0);" name="content_field_editable">
								 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_editable")%></span>
							 </div>	
							 <div style="float:left;padding-right:10px;padding-top:5px;" >
								<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_sort")%></span><br/>
								<input type="text" name="sorting" id="sorting_0" value="0" class="formFieldTXTShort" maxlength="3" onkeypress="javascript:return isInteger(event);">
							 </div>
							 <div style="float:top;padding-right:10px;padding-top:5px;" >
								<span class="labelForm" id="max_lenght_container_0"><%=lang.getTranslated("backend.contenuti.detail.table.label.max_lenght")%><br/>	
								<input type="text" name="max_lenght"  id="max_lenght_0" value="" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);">
								</span>
							 </div>					 
						 </div>
						<script type="text/javascript">							
								$("#group_value_c_0").change(function(){
									$("#group_value_0").val($('#group_value_c_0').val());
									$("#group_value_c_0").hide();
									$("#group_value_0").show();
								});							
								$("#group_value_c_0").blur(function(){
									$("#group_value_0").val($('#group_value_c_0').val());
									$("#group_value_c_0").hide();
									$("#group_value_0").show();
								});
													
								$("#field_description_c_0").change(function(){
									$("#field_description_0").val($('#field_description_c_0').val());
									$("#field_description_c_0").hide();
									$("#field_description_0").show();
								});
													
								$("#field_description_c_0").blur(function(){
									$("#field_description_0").val($('#field_description_c_0').val());
									$("#field_description_c_0").hide();
									$("#field_description_0").show();
								});
						</script>
													 
						 <div style="float:left;padding-right:10px;padding-top:5px;">							 
							<div style="float:top;padding-right:20px;">
								<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.type")%></span><br>
								<select name="id_type" id="id_type_0" class="formFieldSelectSimple" onchange="javascript:onChangeFieldsType(0);">
									<%foreach(SystemFieldsType x in systemFieldsType){
									string stypeLabel = x.description;
									if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type.label."+x.description))){
										stypeLabel = lang.getTranslated("portal.commons.content_field.type.label."+x.description);
									}%>
									<option VALUE="<%=x.id%>"><%=stypeLabel%></option>
									<%}%>
								</select>
							</div>	
							<div style="float:top;padding-right:20px;width:auto;vertical-align:top;margin-top:5px;">
								<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.type_content")%></span><br>
								<select name="id_type_content" id="id_type_content_0" class="formFieldSelectSimple" onchange="javascript:onChangeFyeldTypeContent(0);">
									<%foreach(SystemFieldsTypeContent x in systemFieldsTypeContent){
									string stypecLabel = x.description;
									if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type_content.label."+x.description))){
										stypecLabel = lang.getTranslated("portal.commons.content_field.type_content.label."+x.description);
									}%>
									<option VALUE="<%=x.id%>"><%=stypecLabel%></option>
									<%}%>
								</select>
							</div>								 
						 </div>		
						 
						<div style="float:left;padding-left:20px;padding-right:10px;padding-top:0px;">
							<div align="left" id="field_values_div_0">
								<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.values")%></span>
								&nbsp;<a href="javascript:addFieldValues('0');"><img src="/backoffice/img/add.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.add_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.add_field_value")%>" hspace="5" vspace="0" border="0"></a>
								<span id="field_values_container0_0">
								<br/>
								<input type="radio" id="field_checkedvaluesr0_0" name="field_checkedvalues0" value="" style="display:none;">	
								<input type="checkbox" id="field_checkedvaluesc0_0" name="field_checkedvalues0" value="" style="display:none;">							
								<input type="text" name="field_values0_0" id="field_values0_0" value="" class="formFieldTXT" onkeypress="javascript:return notSpecialChar(event);">&nbsp;<a href="javascript:delFieldValues('0','0',' ','field_values_container0_0',0);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
								</span>
								<div id="add_field_values_div_0"></div>							 
							</div>

							<div align="left" style="display:none;margin-top:20px;" id="field_values_div_country_0">
								<%
								if(countries != null && countries.Count>0){%>
									<select name="field_value_0" id="field_value_ct_0">
									<option value=""></option>
									<%foreach(Country x in countries){%>
										<option value="<%=x.countryCode%>_<%=x.id%>"><%=x.countryDescription%></option>
									<%}%>
									</select>										
								<%}%>
							</div>
							<div align="left" style="display:none;margin-top:20px;" id="field_values_div_state_region_0">
								<%
								if(stateRegions != null && stateRegions.Count>0){%>
									<select name="field_value_0" id="field_value_sr_0">
									<option value=""></option>
									<%foreach(Country x in stateRegions){%>
										<option value="<%=x.stateRegionCode%>_<%=x.id%>"><%=x.countryDescription+" "+x.stateRegionDescription%></option>
									<%}%>
									</select>											
								<%}%>
							</div>
									
							<script>	
							jQuery(document).ready(function(){
								var currtypeval = $('#id_type_0').val();
								if(currtypeval==3 || currtypeval==6){
									$('#field_checkedvaluesr0_0').show();
								}else{
									$('#field_checkedvaluesc0_0').show();							
								}
							});							
							</script>							
						</div>	
						<div id="field_value_box_0" style="float:top;padding-right:20px;width:auto;vertical-align:top;padding-top:5px;clear:both;">
							<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_values")%></span><br>									
							<div id="baseFieldText_t_0" style="display:none;">
								<input type="text" name="field_value_0" id="field_value_t_0" value="" class="formFieldTXTLong">			
							</div>		
							<div id="baseFieldTextarea_ta_0" style="display:none;">
								<textarea name="field_value_0" id="field_value_ta_0" class="formFieldTXTAREAAbstract"></textarea>										
							</div>								
							<div id="baseFieldPassword_p_0" style="display:none;">
								<input type="password" name="field_value_0" id="field_value_p_0" value="" class="formFieldTXTLong">			
							</div>	
							<div id="baseFieldHtmlEditor_e_0" style="display:none;">
								<!--<textarea name="field_value_0" id="field_value_e_0" class="formFieldTXTAREAAbstract"></textarea>-->			
							</div>
							<script>
							$.cleditor.defaultOptions.width = 600;
							$.cleditor.defaultOptions.height = 200;
							$.cleditor.defaultOptions.controls = "bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image";		
							$(document).ready(function(){
								$("#baseFieldHtmlEditor_e_0").empty();
								$("#baseFieldHtmlEditor_e_0").append($('<textarea/>').attr('id', "field_value_e_0").attr('name', "field_value_0").attr('value', ''));	
								$("#field_value_e_0").cleditor();
							});
							</script>	
							<div id="baseFieldHidden_h_0" style="display:none;">
								<input type="hidden" name="field_value_0" id="field_value_h_0" value="">			
							</div>								
						</div>					
					</td>
					</tr>
					</table>						
					  
					  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table" id="inner-table-content-field-list">
						<tr>
						<th width="16">&nbsp;</th>
						<th width="16">&nbsp;</th>
						<th width="40"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_attivo")%></span></th>
						<th width="70" style="vertical-align:middle;"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_mandatory")%></span></th>
						<th width="70" style="vertical-align:middle;"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_editable")%></span></th>
						<th width="70" style="text-align:center;"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_sort")%></span></th>
						<th width="170"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_group")%></span></th>
						<th width="150"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_name")%></span></th>
						<th width="100"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_type")%></span></th>
						<th><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_values")%></span></th>
						</tr>
					  <!--<tbody>-->
					<%int counter = 0;
					int valuesCounter = 0;
					foreach(ContentField cf in content.fields){
						if(!cf.common){
							string fieldCssClass="";
							
							string labelForm = cf.description;
							//if not(lang.getTranslated("backend.contenuti.detail.table.label."&objField.getDescription())="") then labelForm = lang.getTranslated("backend.contenuti.detail.table.label."&objField.getDescription())%>	
							<input type="hidden" value="<%=cf.id%>" name="id_field" id="id_field_<%=cf.id%>">	  
							<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_content_field_<%=cf.id%>">
							<td style="padding:0px; "><a href="javascript:deleteField(<%=cf.id%>,'tr_content_field_<%=cf.id%>','tr_content_field_');"><img vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" src="/backoffice/img/delete.png"></a></td>
							<td style="padding:0px; "><a href="javascript:modifyField('#tr_content_field_edit_<%=cf.id%>','#tr_content_field_<%=cf.id%>');"><img vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" alt="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" src="/backoffice/img/pencil.png"></a></td>
							<td style="text-align:center;" id="td_content_field_active_<%=cf.id%>"><%if(cf.enabled){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="text-align:center;" id="td_content_field_mandatory_<%=cf.id%>"><%if(cf.required){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="text-align:center;" id="td_content_field_editable_<%=cf.id%>"><%if(cf.editable){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="text-align:center;" id="td_content_field_sort_<%=cf.id%>"><%=cf.sorting%></td>
							<td id="td_content_field_group_<%=cf.id%>"><%=cf.groupDescription%></td>
							<td id="td_content_field_name_<%=cf.id%>"><%=labelForm%></td>
							<td id="td_content_field_type_<%=cf.id%>">
							<%string currtype = "";
							foreach(SystemFieldsType x in systemFieldsType){
								if(cf.type==x.id){
									currtype=x.description;
									break;
								}
							}
							Response.Write(currtype);%>
							</td>
							<td id="td_content_field_value_<%=cf.id%>">
								<%if(cf.type==3){
									if(cf.typeContent==7 && !String.IsNullOrEmpty(cf.value)){
										string tmpcfval = cf.value.Substring(0,cf.value.IndexOf('_'));
										foreach(Country c in countries){
											if(tmpcfval == c.countryCode){
												Response.Write(c.countryDescription);
												break;
											}
										}
									}else if(cf.typeContent==8 && !String.IsNullOrEmpty(cf.value)){
										string tmpcfval = cf.value.Substring(0,cf.value.IndexOf('_'));
										foreach(Country sr in stateRegions){
											if(tmpcfval == sr.stateRegionCode){
												Response.Write(sr.countryDescription+" "+sr.stateRegionDescription);
												break;
											}
										}									
									}else{
										Response.Write(cf.value);
									}
								}else{
									Response.Write(cf.value);
								}%>
							</td>					
							 </tr>
							 
							 <tr style="display:none;" id="tr_content_field_edit_<%=cf.id%>">
								 <td style="padding:0px;vertical-align:top;padding-top:5px;">
								 <a href="javascript:backField('#tr_content_field_edit_<%=cf.id%>','#tr_content_field_<%=cf.id%>');"><img style="cursor:pointer;" align="left" src="/backoffice/img/arrow_left.png" title="<%=lang.getTranslated("backend.commons.back")%>" hspace="4" vspace="0" border="0"></a>
								 </td>
								 <td style="padding:0px;vertical-align:top;padding-top:5px;">
								 <a href="javascript:saveField(<%=cf.id%>,'#tr_content_field_edit_<%=cf.id%>','tr_content_field_',1,<%=valuesCounter%>);"><img style="cursor:pointer;" align="left" src="/backoffice/img/disk.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.save_field")%>" hspace="4" vspace="0" border="0"></a>
								 </td>
								 <td colspan="8" style="padding-bottom:10px;">	<!-- <%if(counter<content.fields.Count-1){%>border-bottom:1px solid #000;<%}%> -->						 
								 <div style="float:left;padding-right:20px;padding-top:5px;min-width:360px;">	
									 <div style="float:left;padding-right:10px; height:30px;min-width:155px;" >
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_group")%></span>
										<img onclick="javascipt:changeFieldGroupDesc(<%=cf.id%>);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.field_reload")%>" hspace="2" vspace="0" border="0"><br/>
										<input type="text" name="group_value" id="group_value_<%=cf.id%>"  value="<%=cf.groupDescription%>" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialChar(event);">
										<select name="group_value_c" id="group_value_c_<%=cf.id%>" style="display:none;min-width:150px;">
										<option></option>
										<%foreach(string x in fieldGroupNames){%>
										<option value="<%=x%>"><%=x%></option>
										<%}%>
										</select>
									 </div>
									 <div style="float:top;padding-right:10px; height:40px;min-width:185px;display:block;" >
										 <span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_name")%></span>
										<img onclick="javascipt:changeFieldName(<%=cf.id%>);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.field_reload")%>" hspace="2" vspace="0" border="0"><br/>
										<input type="text" name="field_description" id="field_description_<%=cf.id%>" value="<%=cf.description%>" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialCharButUnderscore(event);">
										<select name="field_description_c" id="field_description_c_<%=cf.id%>" style="display:none;min-width:150px;vertical-align:top;">
										<option></option>
										<%foreach(string x in fieldNames){%>
										<option value="<%=x%>"><%=x%></option>
										<%}%>
										</select>
										<a href="javascript:showHideDiv('field_description_<%=cf.id%>_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
										<br/>
										<div style="visibility:hidden;position:relative;left:+165px;width:236px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_description_<%=cf.id%>_ml">
										<%foreach (Language x in languages){%>
											<input type="text" hspace="2" vspace="2" name="field_description_<%=cf.id%>_<%=x.label%>" id="field_description_<%=cf.id%>_<%=x.label%>" value="<%=mlangrep.translate("backend.contenuti.detail.table.label.field_description_"+cf.description, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
											&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
										<%}%>									
										</div>
									 </div>						 
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
										 <input type="checkbox" value="1" id="content_field_active_<%=cf.id%>" name="content_field_active" <%if(cf.enabled){Response.Write("checked='checked'");}%>>
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_attivo")%></span>
									 </div>
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
										 <input type="checkbox" value="1" id="content_field_mandatory_<%=cf.id%>" name="content_field_mandatory" <%if(cf.required){Response.Write("checked='checked'");}%>>
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_mandatory")%></span>
									 </div>
									 <div style="float:top;padding-right:10px;padding-top:5px;" >
										 <input type="checkbox" value="1" id="content_field_editable_<%=cf.id%>" onclick="javascript:onClickFieldEditable(<%=cf.id%>);" name="content_field_editable" <%if(cf.editable){Response.Write("checked='checked'");}%>>
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_editable")%></span>
									 </div>	
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_sort")%></span><br/>
										<input type="text" name="sorting" id="sorting_<%=cf.id%>" value="<%=cf.sorting%>" class="formFieldTXTShort" maxlength="3" onkeypress="javascript:return isInteger(event);">
									 </div>
									 <div style="float:top;padding-right:10px;padding-top:5px;" >
										<span id="max_lenght_container_<%=cf.id%>" class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.max_lenght")%><br/>	
										<input type="text" name="max_lenght" id="max_lenght_<%=cf.id%>" value="<%if(cf.maxLenght>0){Response.Write(cf.maxLenght);}%>" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);">
										</span>
									 </div>					 
								 </div>
								<script type="text/javascript">							
										$("#group_value_c_<%=cf.id%>").change(function(){
											//$("#group_value").text($("#list option:selected").val());
											$("#group_value_<%=cf.id%>").val($('#group_value_c_<%=cf.id%>').val());
											$("#group_value_c_<%=cf.id%>").hide();
											$("#group_value_<%=cf.id%>").show();
										});							
										$("#group_value_c_<%=cf.id%>").blur(function(){
											//$("#group_value").text($('#list option:selected').val());
											$("#group_value_<%=cf.id%>").val($('#group_value_c_<%=cf.id%>').val());
											$("#group_value_c_<%=cf.id%>").hide();
											$("#group_value_<%=cf.id%>").show();
										});
															
										$("#field_description_c_<%=cf.id%>").change(function(){
											$("#field_description_<%=cf.id%>").val($('#field_description_c_<%=cf.id%>').val());
											$("#field_description_c_<%=cf.id%>").hide();
											$("#field_description_<%=cf.id%>").show();
										});
															
										$("#field_description_c_<%=cf.id%>").blur(function(){
											$("#field_description_<%=cf.id%>").val($('#field_description_c_<%=cf.id%>').val());
											$("#field_description_c_<%=cf.id%>").hide();
											$("#field_description_<%=cf.id%>").show();
										});
								</script>
															 
								 <div style="float:left;padding-right:10px;padding-top:5px;">							 
									<div style="float:top;padding-right:20px;">
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.type")%></span><br>
										<select name="id_type" id="id_type_<%=cf.id%>" class="formFieldSelectSimple" onchange="javascript:onChangeFieldsType(<%=cf.id%>);">
											<%foreach(SystemFieldsType x in systemFieldsType){
											string stypeLabel = x.description;
											if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type.label."+x.description))){
												stypeLabel = lang.getTranslated("portal.commons.content_field.type.label."+x.description);
											}%>
											<option VALUE="<%=x.id%>" <%if (x.id==cf.type) {Response.Write("selected");}%>><%=stypeLabel%></option>
											<%}%>
										</select>
									</div>	
									<div style="float:top;padding-right:20px;width:auto;vertical-align:top;margin-top:5px;">
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.type_content")%></span><br>
										<select name="id_type_content" id="id_type_content_<%=cf.id%>" class="formFieldSelectSimple" onchange="javascript:onChangeFyeldTypeContent(<%=cf.id%>);">
											<%foreach(SystemFieldsTypeContent x in systemFieldsTypeContent){
											string stypecLabel = x.description;
											if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type_content.label."+x.description))){
												stypecLabel = lang.getTranslated("portal.commons.content_field.type_content.label."+x.description);
											}%>
											<option VALUE="<%=x.id%>" <%if (x.id==cf.typeContent) {Response.Write("selected");}%>><%=stypecLabel%></option>
											<%}%>
										</select>
									</div>								 
								 </div>		
								 
									<div style="float:left;padding-left:20px;padding-right:10px;padding-top:0px;">
										<div align="left" id="field_values_div_<%=cf.id%>">
											  <span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.values")%></span>
											  &nbsp;<a href="javascript:addFieldValues('<%=cf.id%>');"><img src="/backoffice/img/add.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.add_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.add_field_value")%>" hspace="5" vspace="0" border="0"></a>
											  <%
												int totalCounter = 0;
												IList<ContentFieldsValue> objListValues = contrep.getContentFieldValues(cf.id);
												if(objListValues != null){
													totalCounter = objListValues.Count;
												}
												
												if(totalCounter > 0) {
													string[] savedValues = null;
													if (!String.IsNullOrEmpty(cf.value)){
														savedValues = cf.value.Split(',');
													}
													
													foreach(ContentFieldsValue j in objListValues){
														string currfvchecked = "";
														if(savedValues != null){
															foreach(string x in savedValues){
																if(x==j.value){
																	currfvchecked = " checked='checked'";
																	break;
																}
															}
														}
														%>
														<span id="field_values_container<%=cf.id+"_"+valuesCounter%>">
														<br/>
														<%if(cf.type==3 || cf.type==6){%>
															<input type="checkbox" id="field_checkedvaluesc<%=cf.id+"_"+valuesCounter%>" name="field_checkedvalues<%=cf.id%>" value="" style="display:none;">
															<input type="radio" <%=currfvchecked%> id="field_checkedvaluesr<%=cf.id+"_"+valuesCounter%>" name="field_checkedvalues<%=cf.id%>" value="">												
														<%}else{%>
															<input type="radio" id="field_checkedvaluesr<%=cf.id+"_"+valuesCounter%>" name="field_checkedvalues<%=cf.id%>" value="" style="display:none;">
															<input type="checkbox" <%=currfvchecked%> id="field_checkedvaluesc<%=cf.id+"_"+valuesCounter%>" name="field_checkedvalues<%=cf.id%>" value="">
														<%}%>
														<input type="text" id="field_values<%=cf.id+"_"+valuesCounter%>" name="field_values<%=cf.id+"_"+valuesCounter%>" value="<%=j.value%>" class="formFieldTXT" onkeypress="javascript:return notSpecialChar(event);">&nbsp;<a href="javascript:delFieldValues('<%=cf.id+"_"+valuesCounter%>','<%=cf.id%>','<%=j.value%>','field_values_container<%=cf.id+"_"+valuesCounter%>',1);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
														</span>
														<%valuesCounter++;
													}
												}
											  
												if(totalCounter == 0) {%>
													<span id="field_values_container<%=cf.id+"_"+valuesCounter%>">
													<br/>
													<%if(cf.type==3 || cf.type==6){%>
														<input type="checkbox" id="field_checkedvaluesc<%=cf.id+"_"+valuesCounter%>" name="field_checkedvalues<%=cf.id%>" value="" style="display:none;">
														<input type="radio" id="field_checkedvaluesr<%=cf.id+"_"+valuesCounter%>" name="field_checkedvalues<%=cf.id%>" value="">												
													<%}else{%>
														<input type="radio" id="field_checkedvaluesr<%=cf.id+"_"+valuesCounter%>" name="field_checkedvalues<%=cf.id%>" value="" style="display:none;">
														<input type="checkbox" id="field_checkedvaluesc<%=cf.id+"_"+valuesCounter%>" name="field_checkedvalues<%=cf.id%>" value="">
													<%}%>
													<input type="text" id="field_values<%=cf.id+"_"+valuesCounter%>" name="field_values<%=cf.id+"_"+valuesCounter%>" value="" class="formFieldTXT" onkeypress="javascript:return notSpecialChar(event);">&nbsp;<a href="javascript:delFieldValues('<%=cf.id+"_"+valuesCounter%>',' ',' ','field_values_container<%=cf.id+"_"+valuesCounter%>',0);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
													</span>
													<%valuesCounter++;
												}%>
											  <div id="add_field_values_div_<%=cf.id%>"></div>							 
										</div>

										<div align="left" style="display:none;margin-top:20px;" id="field_values_div_country_<%=cf.id%>">
											<%
											if(countries != null && countries.Count>0){%>
												<select name="field_value_<%=cf.id%>" id="field_value_ct_<%=cf.id%>">
												<option value=""></option>
												<%foreach(Country x in countries){
													string checkRpValue = x.countryCode+"_"+x.id;%>
													<option value="<%=x.countryCode%>_<%=x.id%>" <%if(checkRpValue==cf.value){Response.Write(" selected");}%>><%=x.countryDescription%></option>
												<%}%>
												</select>										
											<%}%>
										</div>
										<div align="left" style="display:none;margin-top:20px;" id="field_values_div_state_region_<%=cf.id%>">
											<%
											if(stateRegions != null && stateRegions.Count>0){%>
												<select name="field_value_<%=cf.id%>" id="field_value_sr_<%=cf.id%>">
												<option value=""></option>
												<%foreach(Country x in stateRegions){
													string checkRpValue = x.stateRegionCode+"_"+x.id;%>
													<option value="<%=x.stateRegionCode%>_<%=x.id%>" <%if(checkRpValue==cf.value){Response.Write(" selected");}%>><%=x.countryDescription+" "+x.stateRegionDescription%></option>
												<%}%>
												</select>											
											<%}%>
										</div>

									</div>	
									<div id="field_value_box_<%=cf.id%>" style="float:top;padding-right:20px;width:auto;vertical-align:top;padding-top:5px;clear:both;">
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_values")%></span><br>									
										<div id="baseFieldText_t_<%=cf.id%>" style="<%if(cf.type!=1 && cf.type!=7){%>display:none;<%}%>">
											<input type="text" name="field_value_<%=cf.id%>" id="field_value_t_<%=cf.id%>" value="<%=cf.value%>" class="formFieldTXTLong" onkeypress="/*javascript:return notSpecialChar(event);*/">			
										</div>		
										<div id="baseFieldTextarea_ta_<%=cf.id%>" style="<%if(cf.type!=2){%>display:none;<%}%>">
											<textarea name="field_value_<%=cf.id%>" id="field_value_ta_<%=cf.id%>" class="formFieldTXTAREAAbstract"><%=cf.value%></textarea>										
										</div>								
										<div id="baseFieldPassword_p_<%=cf.id%>" style="<%if(cf.type!=10){%>display:none;<%}%>">
											<input type="password" name="field_value_<%=cf.id%>" id="field_value_p_<%=cf.id%>" value="<%=cf.value%>" class="formFieldTXTLong" onkeypress="/*javascript:return notSpecialChar(event);*/">			
										</div>	
										<div id="baseFieldHtmlEditor_e_<%=cf.id%>" style="<%if(cf.type!=9){%>display:none;<%}%>">			
										</div>
										<script>								
										$.cleditor.defaultOptions.width = 600;
										$.cleditor.defaultOptions.height = 200;
										$.cleditor.defaultOptions.controls = "bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image";		
										$(document).ready(function(){
											<%string ceVal = cf.value.Replace("\r\n", "").Replace("\n", "").Replace("\r", "").Replace("'", "&#39;");%>
											var ceVal = '<%=ceVal%>';
											$("#baseFieldHtmlEditor_e_<%=cf.id%>").empty();
											$("#baseFieldHtmlEditor_e_<%=cf.id%>").append($('<textarea/>').attr('id', "field_value_e_<%=cf.id%>").attr('name', "field_value_<%=cf.id%>").attr('value', ceVal));	
											$("#field_value_e_<%=cf.id%>").cleditor();
										});
										</script>	
										<div id="baseFieldHidden_h_<%=cf.id%>" style="<%if(cf.type==9 || cf.type==1 || cf.type==2 || cf.type==7){%>display:none;<%}%>">
											<input type="hidden" name="field_value_<%=cf.id%>" id="field_value_h_<%=cf.id%>" value="<%=cf.value%>">			
										</div>								
									</div>				 
								 </td>
							 </tr>
							<%counter++;
						}
					}%>
					<!--</tbody>-->
					  </table>
					  </div>
					 <br/><br/>
					  
					<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divAttachments');showHideDivArrow('divAttachments','arrowAttach');"><img src="<%if (content.attachments != null && content.attachments.Count>0){Response.Write("/backoffice/img/div_freccia.gif");}else{Response.Write("/backoffice/img/div_freccia2.gif");}%>" vspace="0" hspace="0" border="0" align="right" id="arrowAttach"><%=lang.getTranslated("backend.news.view.table.label.attached_files")%></div>
					<div id="divAttachments" <%if (content.attachments != null && content.attachments.Count>0){Response.Write("style=visibility:visible;display:block;");}else{Response.Write("style=visibility:hidden;display:none;");}%> align="left">
					<%if(content.attachments != null && content.attachments.Count>0){%>		
						<table border="0" cellspacing="0" cellpadding="0" class="principal" id="modify_attach_table">
						  <tr>
							<td width="250"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_to_del")%></span></td>
							<td width="170"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_type_label")%></span></td>
							<td><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_dida")%></span></td>
						  </tr>
						<%
						int attachCounter = 1;
						foreach(ContentAttachment ca in content.attachments){%>
						  <tr id="filemodifyrow<%=attachCounter%>">
							<td><%=ca.fileName%>
							<input type="hidden" value="<%=ca.id%>" name="filemodify_id<%=attachCounter%>">
							</td>
							<td>
							<select name="filemodify_label<%=attachCounter%>" class="formFieldSelectTypeFile">
							<%foreach(ContentAttachmentLabel xType in contentAttachmentLabel){%>
							<option value="<%=xType.id%>" <%if(xType.id==ca.fileLabel){Response.Write("selected");}%>><%=xType.description%></option>
							<%}%>
							</select>
							</td>
							<td>
							<input type="text" name="filemodify_dida<%=attachCounter%>" value="<%=ca.fileDida%>" class="formFieldTXT">
							&nbsp;<a href="javascript:deleteAttach(<%=ca.id%>,'filemodifyrow<%=attachCounter%>','<%=ca.filePath+ca.fileName%>');"><img vspace="0" hspace="4" border="0" align="top" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" src="/backoffice/img/delete.png"></a>
							</td>
						  </tr>
							<%attachCounter++;
						}%>
						<input type="hidden" value="<%=attachCounter%>" name="attach_counter">
						</table>
					<%}%>
					
					<table border="0" cellspacing="0" cellpadding="0" class="principal" id="add_attach_table">
					  <tr>
						<td width="250"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.attachment")%></span></td>
						<td width="170"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_type_label")%></span></td>
						<td><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_dida")%></span></td>
						<td><span class="labelForm"><%=lang.getTranslated("backend.commons.detail.table.label.change_num_imgs")%></span></td>
					  </tr>
					  <%for(int i=1;i<=numMaxAttachs;i++){%>
					  <tr class="attach_table_rows">
						<td>
						<input type="file" name="fileupload<%=i%>" id="fileupload<%=i%>" class="formFieldTXT">
						<input type="hidden" value="" name="fileupload_name<%=i%>" id="fileupload_name<%=i%>">
						<script>
						$('#fileupload<%=i%>').blur(function() {
							$('#fileupload_name<%=i%>').val($('#fileupload<%=i%>').val());
							//alert($('#fileupload_name<%=i%>').val());
						});					
						</script>						
						</td>
						<td>
						<select id="fileupload_label<%=i%>" name="fileupload_label<%=i%>" class="formFieldSelectTypeFile">
						<%foreach(ContentAttachmentLabel xType in contentAttachmentLabel){%>
						<option value="<%=xType.id%>"><%=xType.description%></option>
						<%}%>
						</select></td>
						<td><input type="text" name="fileupload_dida<%=i%>" class="formFieldTXT"></td>
						<td><%if(i==1){%><input type="text" value="<%=numMaxAttachs%>" name="numMaxImgs" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);"><a href="javascript:changeNumMaxImgs();"><img src=<%="/common/img/refresh.gif"%> vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.change_num_imgs")%>"></a><%}%>&nbsp;</td>
					  </tr>
					 <%}%>	 
					</table>			
					</div>					
					 <br/><br/>
					
					<div class="labelForm" align="left"><%=lang.getTranslated("backend.contenuti.detail.table.label.keyword")%></div>
					<div id="divTitle" align="left">
					<input type="text" name="keyword" value="<%=HttpUtility.HtmlEncode(content.keyword)%>" class="formFieldTXTLong" />
					</div><br>

					<CommonGeolocalization:insert runat="server" elemType="1" ID="gl1" />
					
					<div style="float:left;"> 
						<!-- ******** RENDER CATEGORY BOX AND LANGUAGE BOX ************ -->
						<%=CategoryService.renderCategoryBox(lang.getTranslated("backend.utenti.detail.table.label.categories"), categories, lang.currentLangCode, lang.defaultLangCode, login.userLogged, "content_categories", true, contentcategories)%>
						<br><br>
						<input type="hidden" value="" name="content_languages">	
						<%=LanguageService.renderLanguageBox("listLanguages", "langbox_sx", "langbox_dx", lang.getTranslated("backend.contenuti.detail.table.label.language_x_contenuti"), lang.getTranslated("backend.contenuti.detail.table.label.language_disp"), contentlanguages, languages, true, true, lang.currentLangCode, lang.defaultLangCode, login.userLogged)%>					
						<br/>
					</div>
					
					<div style="float:left; width:320px;padding-left:30px;">
							<div style="float:top;padding-right:40px;padding-top:5px;">
						  	<!-- ********************************** CAMPI PER DATA PUBBLICAZIONE ************************* -->
							<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.data_pub")%></span><br>
							<input type="text" class="formFieldTXTMedium2" id="publish_date" name="publish_date" value="<%=content.publishDate.ToString("dd/MM/yyyy HH.mm")%>">
							</div>
							<script>						
							$(function() {
								$('#publish_date').datetimepicker({
									/*showButtonPanel: false,
									dateFormat: 'dd/mm/yy',
									timeFormat: 'HH.mm'*/								
									format:'d/m/Y H.i',
									closeOnDateSelect:true
								});	
								//$('#ui-datepicker-div').hide();				
							});
							</script>	
							
							<div style="float:top;padding-top:10px;">	  
							<!-- ********************************** CAMPI PER DATA CANCELLAZIONE ************************* -->
							<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.data_del")%></span><br>
							<input type="text" class="formFieldTXTMedium2" id="delete_date" name="delete_date" value="<%=content.deleteDate.ToString("dd/MM/yyyy HH.mm")%>">
							</div>
							<script>						
							$(function() {
								$('#delete_date').datetimepicker({
									/*showButtonPanel: false,
									dateFormat: 'dd/mm/yy',
									timeFormat: 'HH.mm'*/								
									format:'d/m/Y H.i',
									closeOnDateSelect:true
								});		
								//$('#ui-datepicker-div').hide();			
							});
							</script> 
						
						<br><br>
						<div style="float:top;"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.stato_contenuto")%></span><br>
						<select name="status" class="formFieldTXT">
						<option value="0" <%if (content.status == 0) { Response.Write("selected");}%>><%=lang.getTranslated("backend.contenuti.lista.table.select.option.edit")%></option>
						<option value="1" <%if (content.status == 1) { Response.Write("selected");}%>><%=lang.getTranslated("backend.contenuti.lista.table.select.option.public")%></option>
						</select>&nbsp;&nbsp;
						</div>
						
						<div style="padding-top:5px; ">
						<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.button.label.preview_contenuti")%></span><br>
						<%if(content.id != -1) {%>
							<select name="choose_preview_cat" id="choose_preview_cat" class="formFieldTXT" onChange="changeTemplatePreviewContentGer(this.value);">
							<option value=""></option>		
							</select>	
							<a href="javascript:previewContent('<%=content.id%>')"><%=lang.getTranslated("backend.contenuti.detail.button.label.preview_contenuti")%></a>
							<br>
							<script>
							var tmpKey;
							var tmpValue;
							var orderedPreview = new Hashtable();
							var arrKeys = listPreviewGerContent.keys();
							for(var z=0; z<arrKeys.length; z++){
								tmpKey = arrKeys[z];
								tmpValue = listPreviewGerContent.get(tmpKey);
								tmpKey = hierarchy2double(tmpKey);
								arrKeys[z] = tmpKey;
								orderedPreview.put(tmpKey,tmpValue);
							}
							arrKeys = orderedPreview.keys().sort();
							
							for(var z=0; z<arrKeys.length; z++){
								tmpKey = arrKeys[z];
								tmpValue = orderedPreview.get(tmpKey);
								var items = tmpValue.split('|');
								if(items != null){
								$('#choose_preview_cat').append("<option value=\""+items[0]+"\">"+items[3]+"</option>");
								}
							}
							</SCRIPT>
						<%}%>
						</div>
				  	</div>					
					</form>
				</td>
			</tr>
			</table>
			<div id="loading" style="visibility:hidden;display:none;padding-top:10px;" align="center"><img src="/backoffice/img/loading.gif" vspace="0" hspace="0" border="0" alt="Loading..." width="200" height="50"></div>
			<br/>
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.inserisci_esci.label")%>" onclick="javascript:sendForm(1);" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.inserisci.label")%>" onclick="javascript:sendForm(0);" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=secureURL+"area_user/ads/contentlist.aspx?cssClass=LN"%>';" />
			<br/><br/>
			
			<%if(content.id != -1) {%>		
				<form action="<%=secureURL%>area_user/ads/insertcontent.aspx" method="post" name="form_cancella_news">
				<input type="hidden" value="<%=content.id%>" name="id">
				<input type="hidden" value="delete" name="operation">
				<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.elimina.label")%>" onclick="javascript:confirmDelete();" />
				</form>
			<%}%>	
			
			<form action="<%=secureURL%>area_user/ads/insertcontent.aspx" method="get" name="form_reload_page">
			<input type="hidden" name="id" value="<%=content.id%>">
			</form>
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