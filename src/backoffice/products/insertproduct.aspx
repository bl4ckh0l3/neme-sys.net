<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertproduct.aspx.cs" Inherits="_Product" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
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
<%@ Register TagPrefix="CommonGeolocalization" TagName="insert" Src="~/backoffice/include/localization-widget.ascx" %>
<%@ Register Assembly="FredCK.FCKeditorV2" Namespace="FredCK.FCKeditorV2" TagPrefix="FCKeditorV2" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script src="/common/js/hashtable.js"></script>
<script>
var curr_qta_val;

var listPreviewGerProduct = new Hashtable();
<%foreach(string z in previewUrls.Keys){%>
	listPreviewGerProduct.put("<%=z%>","<%=previewUrls[z][0]+"|"+previewUrls[z][1]+"|"+previewUrls[z][2]+"|"+previewUrls[z][3]%>");	
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

var pathPreviewProduct = "";
var hierarchyPreviewProduct = "";
var catidPreviewProduct = "";
	
function previewProduct(productid){
	var templatePreviewPath = "";
	
	templatePreviewPath = templatePreviewPath + pathPreviewProduct+"?product_preview=1&productid="+productid+"&hierarchy="+hierarchyPreviewProduct+"&categoryid="+catidPreviewProduct;
	if(pathPreviewProduct != "" && pathPreviewProduct != "#" && productid > 0){
		openWin(templatePreviewPath,'templateproduct',970,600,150,60);
	}else{
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.preview_product_disabled")%>");
	}
}

function changeTemplatePreviewProductGer(gerPreviewChanged){
	var tmpValue = listPreviewGerProduct.get(gerPreviewChanged);
	var items = tmpValue.split('|');
	if(items != null){
		hierarchyPreviewProduct = items[0];
		catidPreviewProduct = items[1];
		pathPreviewProduct = items[2];
	}
}


function changeNumMaxImgs(suffix){
	if($('#numMaxImgs'+suffix).val() == ""){
		alert("<%=lang.getTranslated("backend.templates.detail.js.alert.insert_value")%>");
		$('#numMaxImgs'+suffix).focus();
		return;
	}else if(isNaN($('#numMaxImgs'+suffix).val()) || $('#numMaxImgs'+suffix).val() == "0"){
		alert("<%=lang.getTranslated("backend.templates.detail.js.alert.isnan_value")%>");
		$('#numMaxImgs'+suffix).focus();
		return;		
	}
	renderNumImgsTable($('#numMaxImgs'+suffix).val(), suffix);
}

function renderNumImgsTable(counter, suffix){
	$(".attach_table_rows"+suffix).remove();
	
	var render ="";
	
	for(var i=1;i<=counter;i++){
		render=render+'<tr class="attach_table_rows'+suffix+'">';
		
			render=render+'<td><input type="file" id="fileupload'+i+suffix+'" name="fileupload'+i+suffix+'" class="formFieldTXT"><input type="hidden" value="" name="fileupload_name'+i+suffix+'" id="fileupload_name'+i+suffix+'">';
			render=render+'<script>';
			render=render+"$('#fileupload"+i+suffix+"').blur(function() {";
				render=render+"$('#fileupload_name"+i+suffix+"').val($('#fileupload"+i+suffix+"').val());";
			render=render+'});';				
			render=render+'<\/script>';		
			render=render+'</td><td>';						
			if(i==1){
			render=render+'<div id="text_label_new'+i+suffix+'" style="display:none;">';
			render=render+'<input type="text" name="fileupload_label_new'+i+suffix+'" id="fileupload_label_new'+i+suffix+'" onblur="javascript:prepareInsertAttachLabel(this,\''+i+suffix+'\');" class="formFieldSelectTypeFile">';
			render=render+'</div>';
			}		
			render=render+'<div id="select_label_new'+i+suffix+'">';
			render=render+'<select id="fileupload_label'+i+suffix+'" name="fileupload_label'+i+suffix+'" class="formFieldSelectTypeFile">';			
			render=render+'</select>';
			if(i==1){
			render=render+'<a href="javascript:addAttachLabel(\''+i+suffix+'\');"><img vspace="0" hspace="4" border="0" align="top" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.add_type")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.label.add_type")%>" src="/backoffice/img/add.png"></a>';
			render=render+'<a href="javascript:delAttachLabel(\'#fileupload_label'+i+suffix+'\');"><img vspace="0" hspace="4" border="0" align="top" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.del_type")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.label.del_type")%>" src="/backoffice/img/delete.png"></a>';
			}			
			render=render+'</div></td>';
			render=render+'<td><input type="text" name="fileupload_dida'+i+suffix+'" class="formFieldTXT"></td>';
			render=render+'<td>';
			if(i==1){
			render=render+'<input type="text" value="'+counter+'" name="numMaxImgs'+suffix+'" id="numMaxImgs'+suffix+'" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);"><a href="javascript:changeNumMaxImgs(\''+suffix+'\');"><img src="/common/img/refresh.gif" vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.change_num_imgs")%>"></a>';
			}
			render=render+'</td>';
		render=render+'</tr>';
	}

	$("#add_attach_table"+suffix).append(render);
	
	var reloadedlist = "";
	var query_string = "operation=reload";	
	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/backoffice/products/ajaxattachlabel.aspx",
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

function addAttachLabel(id_label){
	$('#select_label_new'+id_label).hide();
	$('#text_label_new'+id_label).show();
}

function prepareInsertAttachLabel(field, id){
	var value = field.value;
	insertAttachLabel(id, value);
}

function insertAttachLabel(id, description){
	if(description != ""){
		var query_string = "label_description="+description+"&operation=insert";
		
		$.ajax({
			async: true,
			type: "POST",
			cache: false,
			url: "/backoffice/products/ajaxattachlabel.aspx",
			data: query_string,
			success: function(response) {
				var newid = response;
				$("select[name*='_label']").each(function(){
					$(this).append("<option value="+newid+">"+description+"</option>");
				});
				
				$('#select_label_new'+id).show();
				$('#text_label_new'+id).hide();		
			},
			error: function() {
				/*
				$("#ajaxresp").empty();
				$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_delete_item")%>");
				$("#ajaxresp").fadeIn(1500,"linear");
				$("#ajaxresp").fadeOut(600,"linear");
				*/
			}
		});	
	}else{
		$('#select_label_new'+id).show();
		$('#text_label_new'+id).hide();		
	}
}

function delAttachLabel(id_label){
	if(confirm("<%=lang.getTranslated("backend.contenuti.detail.js.alert.confirm_del_attach_label")%>")){	
		var idlabel = $(id_label).val();
		var query_string = "id_attach_label="+idlabel+"&operation=delete";
		
		$.ajax({
			async: true,
			type: "POST",
			cache: false,
			url: "/backoffice/products/ajaxattachlabel.aspx",
			data: query_string,
			success: function(response) {
				//$(id_label+" option[value='"+idlabel+"']").remove();		
				$("select[name*='_label']").each(function(){
					$(this).children("option").each(function(){
						if($(this).val()==idlabel){
							$(this).remove();
						}	
					});
				});		
			},
			error: function() {
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

function deleteAttach(id_attach,row, file_path, attach_type){
	if(confirm("<%=lang.getTranslated("backend.contenuti.detail.js.alert.confirm_del_attach")%>")){		
		var query_string = "id_attach="+id_attach+"&file_path="+file_path+"&attach_type="+attach_type;
		
		$.ajax({
			async: true,
			type: "POST",
			cache: false,
			url: "/backoffice/products/ajaxdeleteattach.aspx",
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
	return confirm('<%=lang.getTranslated("backend.prodotti.detail.js.alert.confirm_del_prod")%>');
}


function controllaCampiInput(){
	//valorizzo il campo nascosto "usr_languages" con la lista delle lingue separate da "|"
	var strLanguages = "";
	strLanguages+=listLanguages
	if(strLanguages.charAt(strLanguages.length -1) == "|"){
		strLanguages = strLanguages.substring(0, strLanguages.length -1);
	}	
	document.form_inserisci.product_languages.value = strLanguages;
	//alert("product_languages:"+document.form_inserisci.product_languages.value+";");


	if(document.form_inserisci.prod_type.value == 2){
		if(document.form_inserisci.key_ads_type.value == ""){
			alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.insert_ads_type")%>");
			document.form_inserisci.key_ads_type.focus();
			return false;
		}	
		
		if(document.form_inserisci.key_ads_duration.value == ""){
			alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.insert_ads_duration")%>");
			document.form_inserisci.key_ads_duration.focus();
			return false;
		}		
	
		document.form_inserisci.keyword.value = document.form_inserisci.key_ads_type.value+"#"+document.form_inserisci.key_ads_duration.value;
	}	
	
	if(document.form_inserisci.keyword.value == ""){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.insert_cod_prod")%>");
		document.form_inserisci.keyword.focus();
		return false;
	}
	
	if(document.form_inserisci.name.value == ""){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.insert_prod_name")%>");
		document.form_inserisci.name.focus();
		return false;
	}

	var thisPrice = document.form_inserisci.price.value;
	if(thisPrice == ""){
		alert("<%=lang.getTranslated("backend.currency.detail.js.alert.insert_valore_value")%>");
		document.form_inserisci.price.focus();
		return;
	}else if(thisPrice.indexOf('.') != -1){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.use_only_comma")%>");
		document.form_inserisci.price.focus();
		return;		
	}
	var thisDiscount = document.form_inserisci.discount.value;
	if(thisDiscount == ""){
		alert("<%=lang.getTranslated("backend.currency.detail.js.alert.insert_valore_value")%>");
		document.form_inserisci.discount.focus();
		return;
	}else if(thisDiscount.indexOf('.') != -1){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.use_only_comma")%>");
		document.form_inserisci.discount.focus();
		return;		
	}

	/*
	CONTROLLO SULLA QUANTITA' INSERITA:
	- ILLIMITATA = valore -1
	- VALORE = valore del campo quantity
	*/
	if($("#sel_qta_prod").val()==0){
		document.form_inserisci.quantity.value = -1;
	}else{
		if(document.form_inserisci.quantity.value == ""){
			alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.insert_qta_prod")%>");
			document.form_inserisci.quantity.focus();
			return;
		}else if(isNaN(document.form_inserisci.quantity.value)){
			alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.isnan_value")%>");
			document.form_inserisci.quantity.focus();
			return;		
		}
	}
	
	//alert("document.form_inserisci.quantity.value: "+document.form_inserisci.quantity.value);

	var global_qta = 0;
	if(document.form_inserisci.quantity.value>-1){
		global_qta = $("input[name='quantity']").val();	
	}else{	
		cleanFieldValuesQta(true);
	}
	
	var send_form = true;
	$("#inner-table-product-field-list table[name*='inner-table-rel-field_']").each( function(){
		var field_sum_qta = 0;

		var this_field_rel_id = $(this).attr("name");
		this_field_rel_id = this_field_rel_id.substring(this_field_rel_id.indexOf("inner-table-rel-field_")+22, this_field_rel_id.length);
		var prod_field_name = $('#td_product_field_name_'+this_field_rel_id).text();
		var stopIteration = false;

		$(this).find("input[name*='qta_field_value_']").each( function(){
			field_sum_qta+=Number($(this).val());
			ref_field_sum = 0;
			var suffix = $(this).attr("name");
			suffix = suffix.substring(suffix.indexOf("qta_field_value_")+16, suffix.length);
			var prod_field_val_name = $('.sp_qta_field_value_'+suffix).text();
			ref_field_sum = $('#rel_qta_sum_check_'+suffix).text();
			ref_field_sum = ref_field_sum.substring(ref_field_sum.indexOf("[")+1, ref_field_sum.lastIndexOf("]"));
			if(isNaN(ref_field_sum) || ref_field_sum==""){return true;}

			if(Number(ref_field_sum)!=Number($(this).val())){
				alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.sum_rel_qta_not_match")%>\n- "+prod_field_name+": "+prod_field_val_name+"\n- <%=lang.getTranslated("backend.prodotti.detail.table.label.qta_fields")%>: "+$(this).val()+" --> "+ref_field_sum);
				send_form = false;	
				stopIteration = true;		
				return false;
			}	
		});
		if(stopIteration){return false;}
		
		if(field_sum_qta!=global_qta){
			alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.sum_qta_not_match")%>\n- "+prod_field_name+"\n- <%=lang.getTranslated("backend.prodotti.detail.table.label.qta_tot_prod")%>: "+global_qta+"\n- <%=lang.getTranslated("backend.prodotti.detail.table.label.qta_fields")%>: "+field_sum_qta);
			send_form = false;			
			return false;
		}
	});
	if(!send_form){return;}

		  
	document.form_inserisci.list_prod_fields_values_qty.value = "";
	$("#inner-table-product-field-list table[name*='inner-table-rel-field_']").each( function(){
		$(this).find("input[name*='qta_field_value_']").each( function(){
			var fvname = $(this).attr("name").substring($(this).attr("name").indexOf("qta_field_value_")+16, $(this).attr("name").length);
			document.form_inserisci.list_prod_fields_values_qty.value += "\""+fvname+"\":\""+$(this).val()+"\",";
		});
	});
	document.form_inserisci.list_prod_fields_values_qty.value = document.form_inserisci.list_prod_fields_values_qty.value.substring(0,document.form_inserisci.list_prod_fields_values_qty.value.lastIndexOf(","));
	document.form_inserisci.list_prod_fields_values_qty.value = "{"+document.form_inserisci.list_prod_fields_values_qty.value;
	document.form_inserisci.list_prod_fields_values_qty.value += "}";
	//alert("document.form_inserisci.list_prod_fields_values_qty.value:\n"+document.form_inserisci.list_prod_fields_values_qty.value);
	
	
	document.form_inserisci.rotation_mode_value.value = "";				
	document.form_inserisci.rotation_mode_value.value += "\"d\":\""+encodeURIComponent($("#rotation_mode_tmp_d").val())+"\",";	
	document.form_inserisci.rotation_mode_value.value += "\"w\":\""+encodeURIComponent($("#rotation_mode_tmp_w").val())+"\",";	
	document.form_inserisci.rotation_mode_value.value += "\"h\":\""+encodeURIComponent($("#rotation_mode_tmp_h").val())+"\"";	
	document.form_inserisci.rotation_mode_value.value = "{"+document.form_inserisci.rotation_mode_value.value;
	document.form_inserisci.rotation_mode_value.value += "}";	
	//document.form_inserisci.rotation_mode_value.value = $("#rotation_mode_tmp_d").val()+"|"+$("#rotation_mode_tmp_w").val()+"|"+$("#rotation_mode_tmp_h").val();
	//alert("document.form_inserisci.rotation_mode_value.value:\n"+document.form_inserisci.rotation_mode_value.value);

	//recupero i valori dei checkbox con i prodotti correlati
	var q;
	var strProdRels = "";
	if(document.form_inserisci.id_prod_rel != null){
		if(document.form_inserisci.id_prod_rel.length == null){
			if(document.form_inserisci.id_prod_rel.checked){
				strProdRels = strProdRels + document.form_inserisci.id_prod_rel.value + "|";
			}
		}else{
			for(q=0; q<document.form_inserisci.id_prod_rel.length; q++){
				if(document.form_inserisci.id_prod_rel[q].checked){		
					strProdRels = strProdRels + document.form_inserisci.id_prod_rel[q].value + "|";
				}
			}
		}
	}
	if(strProdRels.charAt(strProdRels.length -1) == "|"){
		strProdRels = strProdRels.substring(0, strProdRels.length -1);
	}	
	document.form_inserisci.list_prod_relations.value = strProdRels;	
	
	
	//set file attached and filed to download
	var numMaxImgs = $("#numMaxImgs").val();
	for(n=1; n<=numMaxImgs; n++){
		$('#fileupload_name'+n).val($('#fileupload'+n).val());
	}	
	
	var numMaxImgsd = $("#numMaxImgsd").val();
	for(n=1; n<=numMaxImgsd; n++){
		$('#fileupload_name'+n+'d').val($('#fileupload'+n+'d').val());
	}

	return true;
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

function saveField(counter,row,refreshrow, modify, subcounter){	
	if(modify==1){
		document.form_create_field.operation.value="updfield";
	}else{
		document.form_create_field.operation.value="addfield";
	}
	document.form_create_field.id_field.value = $('#id_field_'+counter).val();
	document.form_create_field.group_value.value = $('#group_value_'+counter).val();	
	document.form_create_field.field_description.value = $('#field_description_'+counter).val();
	
	if(document.form_inserisci.keyword.value == ""){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.insert_cod_prod")%>");
		document.form_inserisci.keyword.focus();
		return false;
	}
	document.form_create_field.prod_code.value = document.form_inserisci.keyword.value;
	
	if(document.form_create_field.field_description.value == "") {
		alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.insert_description")%>");
		$('#field_description_'+counter).focus();
		return;		
	}else if(isSpecialCharButUnderscoreAndMinus(document.form_create_field.field_description.value)) {
		alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.not_use_special_char")%>");
		$('#field_description_'+counter).focus();
		return;		
	}

	var getout = false;
	$('#inner-table-product-field-list input:text[name="field_description"]').each( function(){	
		/*alert(
		"\n- name: "+$(this).attr('name')+
		"\n- id: "+$(this).attr('id')+
		"\n- value: "+$(this).val()+
		"\n- doc...field_description.value: "+document.form_create_field.field_description.value+
		//"\n- indexOf: "+$(this).attr('id').indexOf($('#field_description_'+counter).attr('id'))+
		"\n- field_description-counter id: "+$('#field_description_'+counter).attr('id')+
		"\n- counter: "+counter+
		"\n- is visible: "+$(this).is(':visible')	+
		"\n- is disabled: "+$(this).is(':disabled')	
		);*/
		if($(this).val() != "" && document.form_create_field.field_description.value == $(this).val() && ($(this).attr('id')!=$('#field_description_'+counter).attr('id')) && $(this).is(':disabled') == false){
			alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.description_exists")%>");
			$('#field_description_'+counter).focus();
			getout = true;
			return false;											
		}
	});
	if(getout){return;}
	
	if(isSpecialCharButUnderscoreAndMinus(document.form_create_field.group_value.value)) {
		alert("<%=lang.getTranslated("backend.contenuti.detail.js.alert.not_use_special_char")%>");
		$('#group_value_'+counter).focus();
		return;		
	}
	
	if($('#product_field_active_'+counter).is(':checked')){	
		document.form_create_field.product_field_active.value = $('#product_field_active_'+counter).val();	
	}else{
		document.form_create_field.product_field_active.value = "";
	}
	if($('#product_field_mandatory_'+counter).is(':checked')){	
		document.form_create_field.product_field_mandatory.value = $('#product_field_mandatory_'+counter).val();	
	}else{
		document.form_create_field.product_field_mandatory.value = "";
	}
	if($('#product_field_editable_'+counter).is(':checked')){	
		document.form_create_field.product_field_editable.value = $('#product_field_editable_'+counter).val();	
	}else{
		document.form_create_field.product_field_editable.value = "";
	}
	document.form_create_field.sorting.value = $('#sorting_'+counter).val();	
	document.form_create_field.max_lenght.value = $('#max_lenght_'+counter).val();	
	document.form_create_field.id_type.value = $('#id_type_'+counter).val();	
	document.form_create_field.id_type_content.value = $('#id_type_content_'+counter).val();	
	
	var isNotRotable = false;
	if(document.form_create_field.id_type.value==3 || 
	   document.form_create_field.id_type.value==4 || 
	   document.form_create_field.id_type.value==5 || 
	   document.form_create_field.id_type.value==6){
		isNotRotable = true;
	}
	if(isNotRotable && $("#rotation_mode").val()>0){
		alert("<%=lang.getTranslated("backend.prodotti.detail.table.label.invalidfor_rotation_quantity")%>");
		return;
	}

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
	if($('#product_field_editable_'+counter).is(':checked') && current_value == ""){
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


	//******************  START: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/

	document.form_create_field.field_description_ml.value = "";
	$('input:text[id*="field_description_'+counter+'_"]').each( function(){	
		if($(this).val() != ""){
			var key = $(this).attr('id');
			key = key.substring(key.indexOf("field_description_"+counter+"_")+19+counter.toString().length,key.length);
			myRegExp = new RegExp(/"/g);
			thisvalml = $(this).val();			
			thisvalml = thisvalml.replace(myRegExp, '\&quot;');				
			document.form_create_field.field_description_ml.value += "\""+key+"\":\""+encodeURIComponent(thisvalml)+"\",";		
		}
	});
	document.form_create_field.field_description_ml.value = document.form_create_field.field_description_ml.value.substring(0,document.form_create_field.field_description_ml.value.lastIndexOf(","));
	document.form_create_field.field_description_ml.value = "{"+document.form_create_field.field_description_ml.value;
	document.form_create_field.field_description_ml.value += "}";
	//alert("document.form_create_field.field_description_ml.value:\n"+document.form_create_field.field_description_ml.value);
	
	document.form_create_field.group_value_ml.value = "";
	$('input:text[id*="group_value_'+counter+'_"]').each( function(){	
		if($(this).val() != ""){
			var key = $(this).attr('id');
			key = key.substring(key.indexOf("group_value_"+counter+"_")+13+counter.toString().length,key.length); 
			myRegExp = new RegExp(/"/g);
			thisvalml = $(this).val();			
			thisvalml = thisvalml.replace(myRegExp, '\&quot;');				
			document.form_create_field.group_value_ml.value += "\""+key+"\":\""+encodeURIComponent(thisvalml)+"\",";	
		}
	});
	document.form_create_field.group_value_ml.value = document.form_create_field.group_value_ml.value.substring(0,document.form_create_field.group_value_ml.value.lastIndexOf(","));
	document.form_create_field.group_value_ml.value = "{"+document.form_create_field.group_value_ml.value;
	document.form_create_field.group_value_ml.value += "}";
	//alert("document.form_create_field.group_value_ml.value:\n"+document.form_create_field.group_value_ml.value);

	
	document.form_create_field.list_product_fields_values.value = "";
	document.form_create_field.list_product_fields_values_qty.value = "";
	document.form_create_field.list_product_fields_values_ml.value = "";
	
	$('input:text[name*="field_values'+counter+'_"]').each( function(){	
		if($(this).val() != ""){
			var key = $(this).attr('name');
			myRegExp = new RegExp(/"/g);
			thisvalml = $(this).val();			
			thisvalml = thisvalml.replace(myRegExp, '\&quot;');				
			document.form_create_field.list_product_fields_values.value += "\""+key+"\":\""+encodeURIComponent(thisvalml)+"\",";	
			var tmpqty = 0;
			var tmpkey = key.substring(key.indexOf("field_values")+12,key.lastIndexOf("_"));
			if($("#qta_field_value_"+tmpkey+"_"+thisvalml).val()!="" && $("#qta_field_value_"+tmpkey+"_"+thisvalml).val()!=undefined){
				tmpqty = $("#qta_field_value_"+tmpkey+"_"+thisvalml).val();
			}
			document.form_create_field.list_product_fields_values_qty.value += "\""+key+"\":\""+tmpqty+"\",";
			
			if((tmp_type== 3 || tmp_type== 4 || tmp_type== 5 || tmp_type== 6) && (tmp_type_content!=7) && (tmp_type_content!=8)){
				var hasTrans = false;
				var langtoken = "";
				var valcounter = key.substring(key.indexOf("field_values")+12,key.length);
				
				//alert("valcounter: "+valcounter);
				
				$('input:text[id*="field_values_ml_'+valcounter+'_"]').each( function(){	
					if($(this).val() != ""){
						hasTrans = true;
						var keyf = $(this).attr('id');
						keyf = keyf.substring(keyf.indexOf("field_values_ml"+valcounter+"_")+18+valcounter.toString().length,keyf.length); 
						//alert("keyf: "+keyf);
						myRegExp = new RegExp(/"/g);
						thisvalmlf = $(this).val();			
						thisvalmlf = thisvalmlf.replace(myRegExp, '\&quot;');						
						langtoken += "\""+keyf+"\":\""+encodeURIComponent(thisvalmlf)+"\",";
						//alert("langtoken: "+langtoken);						
					}
				});
				
				if(langtoken.length>0){
					langtoken = langtoken.substring(0,langtoken.lastIndexOf(","));
					langtoken = "{"+langtoken+"}"
				}
				//alert("langtoken after substit: "+langtoken);
				//alert("hasTrans: "+hasTrans);
				
				if(hasTrans){
					document.form_create_field.list_product_fields_values_ml.value += 
					"\""+encodeURIComponent(thisvalml)+"\":["+
					langtoken+
					"],";
				}
						
				/* example:
				
				"currvalue": [{
					"EN": "sfdfadsf",
					"IT": "SsadfdfsGML"
				}]
				*/
				
			}
		}
	});
	document.form_create_field.list_product_fields_values.value = document.form_create_field.list_product_fields_values.value.substring(0,document.form_create_field.list_product_fields_values.value.lastIndexOf(","));
	document.form_create_field.list_product_fields_values.value = "{"+document.form_create_field.list_product_fields_values.value;
	document.form_create_field.list_product_fields_values.value += "}";
	//alert("document.form_create_field.list_product_fields_values.value:\n"+document.form_create_field.list_product_fields_values.value);
	
	document.form_create_field.list_product_fields_values_qty.value = document.form_create_field.list_product_fields_values_qty.value.substring(0,document.form_create_field.list_product_fields_values_qty.value.lastIndexOf(","));
	document.form_create_field.list_product_fields_values_qty.value = "{"+document.form_create_field.list_product_fields_values_qty.value;
	document.form_create_field.list_product_fields_values_qty.value += "}";
	//alert("document.form_create_field.list_product_fields_values_qty.value:\n"+document.form_create_field.list_product_fields_values_qty.value);
	
	document.form_create_field.list_product_fields_values_ml.value = document.form_create_field.list_product_fields_values_ml.value.substring(0,document.form_create_field.list_product_fields_values_ml.value.lastIndexOf(","));
	document.form_create_field.list_product_fields_values_ml.value = "{"+document.form_create_field.list_product_fields_values_ml.value;
	document.form_create_field.list_product_fields_values_ml.value += "}";
	//alert("document.form_create_field.list_product_fields_values_ml.value:\n"+document.form_create_field.list_product_fields_values_ml.value);

	
	if((tmp_type== 1 || tmp_type== 2 || tmp_type== 9) && (tmp_type_content!=7) && (tmp_type_content!=8)){
		if(tmp_type==1){
			document.form_create_field.field_value_t_ml.value = "";
			$('input:text[id*="field_value_t_'+counter+'_"]').each( function(){	
				//alert("\n- field_value_t_ value: "+ $(this).val());	
				if($(this).val() != ""){
					var key = $(this).attr('id');
					key = key.substring(key.indexOf("field_value_t_"+counter+"_")+15+counter.toString().length,key.length);
					myRegExp = new RegExp(/"/g);
					thisvalml = $(this).val();			
					thisvalml = thisvalml.replace(myRegExp, '\&quot;');				
					document.form_create_field.field_value_t_ml.value += "\""+key+"\":\""+encodeURIComponent(thisvalml)+"\",";		
				}
			});
			document.form_create_field.field_value_t_ml.value = document.form_create_field.field_value_t_ml.value.substring(0,document.form_create_field.field_value_t_ml.value.lastIndexOf(","));
			document.form_create_field.field_value_t_ml.value = "{"+document.form_create_field.field_value_t_ml.value;
			document.form_create_field.field_value_t_ml.value += "}";
			//alert("document.form_create_field.field_value_t_ml.value:\n"+document.form_create_field.field_value_t_ml.value);			
		}else if(tmp_type==2){
			document.form_create_field.field_value_ta_ml.value = "";
			$('textarea[id*=field_value_ta_'+counter+'_]').each( function(){	
				//alert("\n- id: "+$(this).attr('id')+"\n- value: "+ $(this).val());
				if($(this).val() != ""){
					var key = $(this).attr('id');
					key = key.substring(key.indexOf("field_value_ta_"+counter+"_")+16+counter.toString().length,key.length);
					myRegExp = new RegExp(/"/g);
					thisvalml = $(this).val();			
					thisvalml = thisvalml.replace(myRegExp, '\&quot;');				
					document.form_create_field.field_value_ta_ml.value += "\""+key+"\":\""+encodeURIComponent(thisvalml)+"\",";		
				}
			});
			document.form_create_field.field_value_ta_ml.value = document.form_create_field.field_value_ta_ml.value.substring(0,document.form_create_field.field_value_ta_ml.value.lastIndexOf(","));
			document.form_create_field.field_value_ta_ml.value = "{"+document.form_create_field.field_value_ta_ml.value;
			document.form_create_field.field_value_ta_ml.value += "}";
			//alert("document.form_create_field.field_value_ta_ml.value:\n"+document.form_create_field.field_value_ta_ml.value);
		}else if(tmp_type==9){	
			document.form_create_field.field_value_e_ml.value = "";
			/*alert(
			"\n- #field_value_e_"+counter+".value: "+$('#field_value_e_'+counter).val()+
			"\n- #field_value_e_"+counter+"_ml.value: "+$('#field_value_e_'+counter+'_ml').val()+
			"\n- #field_value_e_"+counter+"_EN.value: "+$('#field_value_e_'+counter+'_EN').val()+
			"\n- #field_value_e_"+counter+"_IT.value: "+$('#field_value_e_'+counter+'_IT').val()+
			"\n- input:hidden[id*=field_value_e_"+counter+"_] size: "+$('input:hidden[id*=field_value_e_'+counter+'_]').size()
			);*/
			$('input:hidden[id*="field_value_e_'+counter+'_"]').each( function(){
				/*alert(
				"\n- field_value_e_ id: "+ $(this).attr('id') + 
				"\n- field_value_e_ value: "+ $(this).val() + 
				"\n- no field _ml: "+($(this).attr('id').indexOf("_ml")<0)
				);*/
				if($(this).val() != "" && $(this).attr('id').indexOf("_ml")<0){
					var key = $(this).attr('id');
					key = key.substring(key.indexOf("field_value_e_"+counter+"_")+15+counter.toString().length,key.length);
					myRegExp = new RegExp(/"/g);
					thisvalml = $(this).val();			
					thisvalml = thisvalml.replace(myRegExp, '\&quot;');				
					document.form_create_field.field_value_e_ml.value += "\""+key+"\":\""+encodeURIComponent(thisvalml)+"\",";		
				}
			});
			document.form_create_field.field_value_e_ml.value = document.form_create_field.field_value_e_ml.value.substring(0,document.form_create_field.field_value_e_ml.value.lastIndexOf(","));
			document.form_create_field.field_value_e_ml.value = "{"+document.form_create_field.field_value_e_ml.value;
			document.form_create_field.field_value_e_ml.value += "}";
			//alert("document.form_create_field.field_value_e_ml.value:\n"+document.form_create_field.field_value_e_ml.value);
		}	
	}
	
	//TODO: MFT
	// completare con gli altri campi dei fields: 
	// - description: DONE
	// - group: DONE
	// - select/radio/checkbox: DONE
	// - text/textarea: DONE
	// - html-editor: DONE

	//******************  END: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/

	var preview_new_field = "";
	preview_new_field += "group_value="+document.form_create_field.group_value.value;
	preview_new_field += "&field_description="+document.form_create_field.field_description.value;
	preview_new_field += "&product_field_active="+document.form_create_field.product_field_active.value;
	preview_new_field += "&product_field_mandatory="+document.form_create_field.product_field_mandatory.value;
	preview_new_field += "&product_field_editable="+document.form_create_field.product_field_editable.value;
	preview_new_field += "&sorting="+document.form_create_field.sorting.value;
	preview_new_field += "&max_lenght="+document.form_create_field.max_lenght.value;
	preview_new_field += "&id_type="+document.form_create_field.id_type.value;
	preview_new_field += "&id_type_content="+document.form_create_field.id_type_content.value;
	preview_new_field += "&field_value="+document.form_create_field.field_value.value;
	preview_new_field += "&id_product="+document.form_create_field.id_product.value;
	preview_new_field += "&prod_code="+document.form_create_field.prod_code.value;
	preview_new_field += "&pre_el_id="+document.form_create_field.pre_el_id.value;

	//******************  START: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/
	
	preview_new_field += "&field_description_ml="+document.form_create_field.field_description_ml.value;
	preview_new_field += "&group_value_ml="+document.form_create_field.group_value_ml.value;
	preview_new_field += "&list_product_fields_values_ml="+document.form_create_field.list_product_fields_values_ml.value;
	preview_new_field += "&field_value_t_ml="+document.form_create_field.field_value_t_ml.value;
	preview_new_field += "&field_value_ta_ml="+document.form_create_field.field_value_ta_ml.value;
	preview_new_field += "&field_value_e_ml="+document.form_create_field.field_value_e_ml.value;
	
	//TODO: MFT
	// completare con gli altri campi dei fields: 
	// - description: DONE
	// - group: DONE
	// - select/radio/checkbox: DONE
	// - text/textarea: DOING
	// - html-editor: DOING
	
	//******************  END: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/
	
	preview_new_field += "&list_product_fields_values="+document.form_create_field.list_product_fields_values.value;
	preview_new_field += "&list_product_fields_values_qty="+document.form_create_field.list_product_fields_values_qty.value;
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
		url: "/backoffice/products/ajaxsavefield.aspx",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			var obj = jQuery.parseJSON(response);
			var newfieldresp = obj.newfieldid;
			var newdescresp = obj.newfielddesc;
			var fieldvalresp = obj.fieldsvalues;
			var fieldqtyresp = obj.fieldsvaluesqty;
			changeRowListData(counter,row,refreshrow, modify, newfieldresp, subcounter, fieldvalresp, fieldqtyresp, newdescresp);
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

function changeRowListData(counter,row,refreshrow, modify, newidfield, subcounter, fieldvalresp, fieldqtyresp, newdescresp){
	//alert("modify: "+modify);

	if(modify==1){
		var ajxactive = "<%=lang.getTranslated("portal.commons.yes")%>";
		if(document.form_create_field.product_field_active.value==""){ajxactive = "<%=lang.getTranslated("portal.commons.no")%>";}
		$('#td_product_field_active_'+counter).text(ajxactive);
		var ajxmandatory = "<%=lang.getTranslated("portal.commons.yes")%>";
		if(document.form_create_field.product_field_mandatory.value==""){ajxmandatory = "<%=lang.getTranslated("portal.commons.no")%>";}
		$('#td_product_field_mandatory_'+counter).text(ajxmandatory);
		var ajxeditable = "<%=lang.getTranslated("portal.commons.yes")%>";
		if(document.form_create_field.product_field_editable.value==""){ajxeditable = "<%=lang.getTranslated("portal.commons.no")%>";}
		$('#td_product_field_editable_'+counter).text(ajxeditable);	
		$('#td_product_field_sort_'+counter).text(document.form_create_field.sorting.value);
		$('#td_product_field_group_'+counter).text(document.form_create_field.group_value.value);
		$('#td_product_field_name_'+counter).text(document.form_create_field.field_description.value);
		var modtype = document.form_create_field.id_type.value;
		var modtype_content = document.form_create_field.id_type_content.value;
		var modvalue = document.form_create_field.field_value.value;
		$('#td_product_field_type_'+counter).text(fieldTypesList.get(modtype));
		if(modtype==3 && (modtype_content==7 || modtype_content==8)){
			if(modtype_content==7){			
				var tmpmodval = modvalue.substring(0,modvalue.indexOf('_'));
				$('#td_product_field_value_'+counter).html(countryList.get(tmpmodval));
			}else if(modtype_content==8){
				var tmpmodval = modvalue.substring(0,modvalue.indexOf('_'));
				$('#td_product_field_value_'+counter).html(stateRegionList.get(tmpmodval));
			}
		}else if((modtype==3 || modtype==4 || modtype==5 || modtype==6) && modtype_content!=7 && modtype_content!=8){
			//if(document.form_inserisci.quantity.value>-1){
			
				//**************** erase qty row for deleted fields value ***************
				$("span[class*='sp_qta_field_value_"+counter+"_']").each( function(){
					var doRemove = true;
					var fname = $(this).text();
					$('[name*="field_values'+counter+'_"]').each( function(){			
						var thisval = $(this).val();
						//alert("- fname:"+fname+"\n- thisval:"+thisval);
						if(fname==thisval){
							doRemove = false;
							return false;
						}
					});
					if(doRemove){
						$('#tr_inner_rel_field_'+counter+'_'+fname).remove();
					}
				});
				
				
				//**************** add qty row for new fields value ***************
				$('[name*="field_values'+counter+'_"]').each( function(){	
					var doAdd = true;				
					var thisval = $(this).val();
					$("span[class*='sp_qta_field_value_"+counter+"_']").each( function(){	
						var fname = $(this).text();
						//alert("- fname:"+fname+"\n- thisval:"+thisval);
						if(fname==thisval){
							doAdd = false;
							return false;
						}
					});
					if(doAdd){
						var editqtyfvaluestr = $("#inner-table-rel-field_0 tr[class*='tr_inner_rel_field_0']:first").clone(true,true);	
						editqtyfvaluestr.find("span[class='sp_qta_field_value_0_']").text(thisval);
																
						editqtyfvaluestr.find("[class*='_"+0+"_']").each( function(){
							if($(this).attr('class').indexOf('_'+thisval)<0){
								$(this).attr("class",$(this).attr('class')+thisval);
							}
						});
						editqtyfvaluestr.find("[id*='_"+0+"_']").each( function(){
							if($(this).attr('id').indexOf('_'+thisval)<0){
								$(this).attr("id",$(this).attr('id')+thisval);
							}
						});
						editqtyfvaluestr.find("[name*='_"+0+"_']").each( function(){
							if($(this).attr('name').indexOf('_'+thisval)<0){
								$(this).attr("name",$(this).attr('name')+thisval);
							}
						});
						
						//manage select
						//var logging = "";
						var thisselect = editqtyfvaluestr.find("select[name*='select_field_value_']");
						
						var valoptions = [];
						var valoptionscheck = [];
						
						$("table[id='inner-table-product-field-list'] select[name*='select_field_value_']").each( function(){
							//logging+= "\n\n- select name: "+$(this).attr('name');
							if($(this).attr('name').indexOf("select_field_value_"+counter+"_")<0){
								var hasAssociation = false;
								var thisfieldid= $(this).attr('name').split("_")[3];
							
								if($(this).children().length>0){
									$(this).children().each( function(){
										var thisoption = $(this).clone(true,true);
										if(valoptionscheck.indexOf(thisoption.text())==-1 && (thisoption.text().indexOf($("#td_product_field_name_"+counter).text())<0)){
											var thisoptval = thisoption.val();
											var tovsplit = thisoptval.split('|');
											if(tovsplit != null && tovsplit.length>0){
												var prodid=tovsplit[0];
												var relid=tovsplit[1];
												var relval=tovsplit[2];
												var thisid=counter;
												var thival=thisval;
												var reldesc=tovsplit[5];
												thisoptval = prodid+"|"+relid+"|"+relval+"|"+thisid+"|"+thival+"|"+reldesc;
											}
											
											thisoption.val(thisoptval);
											thisoption.attr('disabled', 'disabled');
											valoptions.push(thisoption);
											valoptionscheck.push(thisoption.text());
											hasAssociation = true;
											//logging+="\n\n- text:"+thisoption.text()+"\n- value:"+thisoption.val();
										}
									});
								}
								if(!hasAssociation){
									var checkname = $(this).closest("tr").closest("table").closest("td").closest("tr").find('td[id*="td_product_field_name_"]').text();
									var valuelist = $(this).closest("tr").closest("table").closest("td").closest("tr").closest("table").find('#tr_product_field_edit_'+thisfieldid+' input[name*="field_values'+thisfieldid+'_"]');

									valuelist.each( function(){
										/*
										alert(
										"\n- checkname:"+checkname+
										"\n- thisfieldid:"+thisfieldid+
										"\n- $(this).attr('name'):"+$(this).attr('name')+
										"\n- $(this).val():"+$(this).val()+
										"\n- thisval:"+thisval+
										"\n- newidfield:"+newidfield
										);
										*/
										var thisoption = $('<option/>').attr('value',document.form_inserisci.id.value+'|'+thisfieldid+'|'+$(this).val()+'|||'+checkname).text(checkname+': '+$(this).val());
										
										if(valoptionscheck.indexOf(thisoption.text())==-1){
											var thisoptval = thisoption.val();
											var tovsplit = thisoptval.split('|');
											if(tovsplit != null && tovsplit.length>0){
												var prodid=tovsplit[0];
												var relid=tovsplit[1];
												var relval=tovsplit[2];
												var thisid=newidfield;
												var thival=thisval;
												var reldesc=tovsplit[5];
												thisoptval = prodid+"|"+relid+"|"+relval+"|"+thisid+"|"+thival+"|"+reldesc;
											}
											
											thisoption.val(thisoptval);
											thisoption.attr('disabled', 'disabled');
											valoptions.push(thisoption);
											valoptionscheck.push(thisoption.text());
										}
									});
								}
							}
						});
						for(index = 0; index < valoptions.length; index++) {
							thisselect.append(valoptions[index]);
						}
						
						//alert(logging);
						
						editqtyfvaluestr = editqtyfvaluestr.html();
						var myRegExpq = "";
						myRegExpq = new RegExp("select_field_value_"+0+"_\'","ig");
						editqtyfvaluestr = editqtyfvaluestr.replace(myRegExpq, "select_field_value_"+0+"_"+thisval+"\'");
						myRegExpq = new RegExp("qta_field_rel_value_"+0+"_\'","ig");
						editqtyfvaluestr = editqtyfvaluestr.replace(myRegExpq, "qta_field_rel_value_"+0+"_"+thisval+"\'");
						myRegExpq = new RegExp("result_container_"+0+"_\'","ig");
						editqtyfvaluestr = editqtyfvaluestr.replace(myRegExpq, "result_container_"+0+"_"+thisval+"\'");
						myRegExpq = new RegExp("'"+0+"_\'","ig");
						editqtyfvaluestr = editqtyfvaluestr.replace(myRegExpq, "'"+0+"_"+thisval+"\'");	
						var strText = '<tr class="tr_inner_rel_field_'+0+'">'+editqtyfvaluestr+'</'+'tr>';							
						
						myRegExpq = new RegExp("_"+0+"_","ig");
						strText = strText.replace(myRegExpq, "_"+counter+"_");
				
						myRegExpq = new RegExp("_"+0+"\"","ig");
						strText = strText.replace(myRegExpq, "_"+counter+"\"");					
						
						myRegExpq = new RegExp("'"+0+"'","ig");
						strText = strText.replace(myRegExpq, "'"+counter+"'");						
						
						myRegExpq = new RegExp("fieldValueSlideToggle\\('"+0+"_","ig");
						strText = strText.replace(myRegExpq, "fieldValueSlideToggle('"+counter+"_");
						
						//alert(strText);				
				
						$('#inner-table-rel-field_'+counter).find('tbody').append(strText);						
					}
				});
			//}			
		}else{
			//$('#td_product_field_value_'+counter).html(modvalue);		
		}
		
		checkAllQtys(fieldvalresp, fieldqtyresp, newidfield, newdescresp);
		
		$(row).hide();	
		$('#'+refreshrow+counter).show();	
	}else{
		if(modify==0){
			showNewFieldAdd();
		}else{
			var rowtmp = row.replace(/#tr_cproduct_field_edit_/g, "#tr_cproduct_field_");
			backField(row,rowtmp);
		}
		
		var newHtmlSource = "";
		var countsuffix = counter;
		var subcountsuffix = subcounter;

		newHtmlSource+= $('<input type="hidden"/>').attr('id', "id_field_"+newidfield).attr('name', "id_field_"+newidfield).attr('value', newidfield);
		newHtmlSource+= '<tr class="table-list-off" id="tr_product_field_'+newidfield+'">';
			newHtmlSource+= '<td style="padding:0px; ">';
			newHtmlSource+= '<a href="';
			newHtmlSource+= "javascript:deleteField("+newidfield+",'tr_product_field_"+newidfield+"','tr_product_field_');";
			newHtmlSource+= '">';
			newHtmlSource+= '<img vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" src="/backoffice/img/delete.png">';
			newHtmlSource+= '</a></td>';
			newHtmlSource+= '<td style="padding:0px; "><a href="';
			newHtmlSource+= "javascript:modifyField('#tr_product_field_edit_"+newidfield+"','#tr_product_field_"+newidfield+"');";
			newHtmlSource+= '">';
			newHtmlSource+= '<img vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" alt="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" src="/backoffice/img/pencil.png">';
			newHtmlSource+= '</a></td>';
			newHtmlSource+= '<td style="text-align:center;" id="td_product_field_active_'+newidfield+'">';			
			if(document.form_create_field.product_field_active.value==""){
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.no")%>';
			}else{
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.yes")%>';
			}
			newHtmlSource+= '</td>';
			newHtmlSource+= '<td style="text-align:center;" id="td_product_field_mandatory_'+newidfield+'">';			
			if(document.form_create_field.product_field_mandatory.value==""){
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.no")%>';
			}else{
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.yes")%>';
			}
			newHtmlSource+= '</td>';
			newHtmlSource+= '<td style="text-align:center;" id="td_product_field_editable_'+newidfield+'">';		
			if(document.form_create_field.product_field_editable.value==""){
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.no")%>';
			}else{
				newHtmlSource+= '<%=lang.getTranslated("backend.commons.yes")%>';
			}
			newHtmlSource+= '</td>';
			newHtmlSource+= '<td style="text-align:center;" id="td_product_field_sort_'+newidfield+'">'+document.form_create_field.sorting.value+'&nbsp;</td>';
			newHtmlSource+= '<td id="td_product_field_group_'+newidfield+'">'+document.form_create_field.group_value.value+'&nbsp;</td>';
			newHtmlSource+= '<td id="td_product_field_name_'+newidfield+'">'+document.form_create_field.field_description.value+'</td>';
			newHtmlSource+= '<td id="td_product_field_type_'+newidfield+'">'+fieldTypesList.get(document.form_create_field.id_type.value)+'</td>';			
			newHtmlSource+= '<td id="td_product_field_value_'+newidfield+'">';
			
			if(($('#id_type_'+countsuffix).val()==3 || $('#id_type_'+countsuffix).val()==4 || $('#id_type_'+countsuffix).val()==5 || $('#id_type_'+countsuffix).val()==6) && $('#id_type_content_'+countsuffix).val()!=7 && $('#id_type_content_'+countsuffix).val()!=8){
				if(modify==0){
					var myRegExpq = "";
					var editqtyfvalues = $('#td_product_field_value_'+countsuffix).clone(true,true); //.html()
					var editqtyfvaluestr = editqtyfvalues.find('#inner-table-rel-field_'+countsuffix+' .tr_inner_rel_field_'+countsuffix).clone(true,true);
					editqtyfvalues.find('#inner-table-rel-field_'+countsuffix+' .tr_inner_rel_field_'+countsuffix).remove();
					
					$('[name*="field_values'+countsuffix+'_"]').each( function(){							
							myRegExpq = new RegExp("_"+countsuffix+"_","ig");
							var thisval = $(this).val();
							
							var editqtyfvaluestrtmp = editqtyfvaluestr.clone(true,true);							
							editqtyfvaluestrtmp.find("span[class='sp_qta_field_value_"+countsuffix+"_']").text($(this).val());
							
							editqtyfvaluestrtmp.find("[class*='_"+countsuffix+"_']").each( function(){
								if($(this).attr('class').indexOf('_'+thisval)<0){
									$(this).attr("class",$(this).attr('class')+thisval);
								}
							});
							editqtyfvaluestrtmp.find("[id*='_"+countsuffix+"_']").each( function(){
								if($(this).attr('id').indexOf('_'+thisval)<0){
									$(this).attr("id",$(this).attr('id')+thisval);
								}
							});
							editqtyfvaluestrtmp.find("[name*='_"+countsuffix+"_']").each( function(){
								if($(this).attr('name').indexOf('_'+thisval)<0){
									$(this).attr("name",$(this).attr('name')+thisval);
								}
							});
							
							//manage select
							//var logging = "";
							var thisselect = editqtyfvaluestrtmp.find("select[name*='select_field_value_']");
							
							var valoptions = [];
							var valoptionscheck = [];
							
							$("table[id='inner-table-product-field-list'] select[name*='select_field_value_']").each( function(){
								//logging+= "\n\n- select name: "+$(this).attr('name');
								var hasAssociation = false;
								var thisfieldid= $(this).attr('name').split("_")[3];
								if($(this).children().length>0){
									$(this).children().each( function(){
										var thisoption = $(this).clone(true,true);
										if(valoptionscheck.indexOf(thisoption.text())==-1){
											var thisoptval = thisoption.val();
											var tovsplit = thisoptval.split('|');
											if(tovsplit != null && tovsplit.length>0){
												var prodid=tovsplit[0];
												var relid=tovsplit[1];
												var relval=tovsplit[2];
												var thisid=newidfield;
												var thival=thisval;
												var reldesc=tovsplit[5];
												thisoptval = prodid+"|"+relid+"|"+relval+"|"+thisid+"|"+thival+"|"+reldesc;
											}
											
											thisoption.val(thisoptval);
											thisoption.attr('disabled', 'disabled');
											valoptions.push(thisoption);
											valoptionscheck.push(thisoption.text());
											hasAssociation = true;
											//logging+="\n\n- text:"+thisoption.text()+"\n- value:"+thisoption.val();
										}
									});
								}
								if(!hasAssociation){
									var checkname = $(this).closest("tr").closest("table").closest("td").closest("tr").find('td[id*="td_product_field_name_"]').text();
									var valuelist = $(this).closest("tr").closest("table").closest("td").closest("tr").closest("table").find('#tr_product_field_edit_'+thisfieldid+' input[name*="field_values'+thisfieldid+'_"]');

									valuelist.each( function(){
										/*
										alert(
										"\n- checkname:"+checkname+
										"\n- thisfieldid:"+thisfieldid+
										"\n- $(this).attr('name'):"+$(this).attr('name')+
										"\n- $(this).val():"+$(this).val()+
										"\n- thisval:"+thisval+
										"\n- newidfield:"+newidfield
										);
										*/
										var thisoption = $('<option/>').attr('value',document.form_inserisci.id.value+'|'+thisfieldid+'|'+$(this).val()+'|||'+checkname).text(checkname+': '+$(this).val());
										
										if(valoptionscheck.indexOf(thisoption.text())==-1){
											var thisoptval = thisoption.val();
											var tovsplit = thisoptval.split('|');
											if(tovsplit != null && tovsplit.length>0){
												var prodid=tovsplit[0];
												var relid=tovsplit[1];
												var relval=tovsplit[2];
												var thisid=newidfield;
												var thival=thisval;
												var reldesc=tovsplit[5];
												thisoptval = prodid+"|"+relid+"|"+relval+"|"+thisid+"|"+thival+"|"+reldesc;
											}
											
											thisoption.val(thisoptval);
											thisoption.attr('disabled', 'disabled');
											valoptions.push(thisoption);
											valoptionscheck.push(thisoption.text());
										}
									});
								}
							});
							for(index = 0; index < valoptions.length; index++) {
								thisselect.append(valoptions[index]);
							}
							
							//alert(logging);
							
							editqtyfvaluestrtmp = editqtyfvaluestrtmp.html();
							myRegExpq = new RegExp("select_field_value_"+countsuffix+"_\'","ig");
							editqtyfvaluestrtmp = editqtyfvaluestrtmp.replace(myRegExpq, "select_field_value_"+countsuffix+"_"+thisval+"\'");
							myRegExpq = new RegExp("qta_field_rel_value_"+countsuffix+"_\'","ig");
							editqtyfvaluestrtmp = editqtyfvaluestrtmp.replace(myRegExpq, "qta_field_rel_value_"+countsuffix+"_"+thisval+"\'");
							myRegExpq = new RegExp("result_container_"+countsuffix+"_\'","ig");
							editqtyfvaluestrtmp = editqtyfvaluestrtmp.replace(myRegExpq, "result_container_"+countsuffix+"_"+thisval+"\'");
							myRegExpq = new RegExp("'"+countsuffix+"_\'","ig");
							editqtyfvaluestrtmp = editqtyfvaluestrtmp.replace(myRegExpq, "'"+countsuffix+"_"+thisval+"\'");	
							var strText = '<tr class="tr_inner_rel_field_'+countsuffix+'" id="tr_inner_rel_field_'+countsuffix+'_'+thisval+'">'+editqtyfvaluestrtmp+'</'+'tr>';							
							editqtyfvalues.find('tbody').append(strText);								
					});
					
					
					editqtyfvalues = editqtyfvalues.html();
					
					myRegExpq = new RegExp("_"+countsuffix+"_","ig");
					editqtyfvalues = editqtyfvalues.replace(myRegExpq, "_"+newidfield+"_");
			
					myRegExpq = new RegExp("_"+countsuffix+"\"","ig");
					editqtyfvalues = editqtyfvalues.replace(myRegExpq, "_"+newidfield+"\"");					
					
					myRegExpq = new RegExp("'"+countsuffix+"'","ig");
					editqtyfvalues = editqtyfvalues.replace(myRegExpq, "'"+newidfield+"'");						
					
					myRegExpq = new RegExp("fieldValueSlideToggle\\('"+countsuffix+"_","ig");
					editqtyfvalues = editqtyfvalues.replace(myRegExpq, "fieldValueSlideToggle('"+newidfield+"_");
					
					//alert(editqtyfvalues);
				}else{
					var editqtyfvalues = $('#td_product_field_value_'+countsuffix).clone(true,true).html();
					var myRegExpq = new RegExp(countsuffix,"ig");
					editqtyfvalues = editqtyfvalues.replace(myRegExpq, newidfield);	
				}							
				newHtmlSource+= editqtyfvalues;
				
			}
			newHtmlSource+= '</td>';
			
		newHtmlSource+= '</tr>';
			
		newHtmlSource+= '<tr id="tr_product_field_edit_'+newidfield+'" class="table-list-off" style="display:none;">';
			newHtmlSource+= '<td style="padding:0px;vertical-align:top;padding-top:5px;">';
				newHtmlSource+= '<a href="';
				newHtmlSource+= "javascript:backField('#tr_product_field_edit_"+newidfield+"','#tr_product_field_"+newidfield+"');";
				newHtmlSource+= '">';
				newHtmlSource+= '<img align="left" vspace="0" hspace="4" border="0" title="<%=lang.getTranslated("backend.commons.back")%>" src="/backoffice/img/arrow_left.png" style="cursor:pointer;">';
				newHtmlSource+= '</a>';
			newHtmlSource+= '</td>';
			newHtmlSource+= '<td style="padding:0px;vertical-align:top;padding-top:5px;">';
				newHtmlSource+= '<a href="';
				newHtmlSource+= "javascript:saveField("+newidfield+",'#tr_product_field_edit_"+newidfield+"','tr_product_field_',1,"+subcounter+");";
				newHtmlSource+= '">';
				newHtmlSource+= '<img align="left" vspace="0" hspace="4" border="0" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.save_field")%>" src="/backoffice/img/disk.png" style="cursor:pointer;">';
				newHtmlSource+= '</a>';
			newHtmlSource+= '</td>';
			newHtmlSource+= '<td style="padding-bottom:10px;" colspan="8">';
			
			var myRegExp;
			var edithtml = $('#new_field_container'+counter).clone(true,true).html();

			//alert(edithtml);
			//$("#field_value_e_"+countsuffix+").cleditor();
			//$("#field_value_e_"+countsuffix+"_ml").cleditor();
			var eprefix = '$("#field_value_e_'+countsuffix+'").cleditor();';
			var emlprefix = '$("#field_value_e_'+countsuffix+'_ml").cleditor();';
			edithtml = edithtml.replace(eprefix, '//'+eprefix);
			edithtml = edithtml.replace(emlprefix, '//'+emlprefix);

			//myRegExp = new RegExp(/.cleditor\(\)/g);
			//edithtml = edithtml.replace(myRegExp, '.cleditor()[0].refresh()');
			
			//alert(edithtml);
			
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
		
		$('#inner-table-product-field-list').append(newHtmlSource);
		
		if(document.form_inserisci.quantity.value != "" && document.form_inserisci.quantity.value>-1){
			$("#inner-table-rel-field_"+newidfield).show();			
		}

		var classon = "table-list-on";
		var classoff = "table-list-off";
		var counter = 1;	
		
		$("tr[id*='tr_product_field_']").each(function(){
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
			
			$('#product_field_editable_'+newidfield).attr('readonly',false);
			$('#product_field_editable_'+newidfield).attr('disabled',false);
			$('#product_field_editable_'+newidfield).attr('style', "background:#FFFFFF;color:#000000;");

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
			$("#descgmultilang_"+newidfield).show();										
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
		
		if($('#product_field_active_'+countsuffix).is(':checked')){	
			$('#product_field_active_'+newidfield).attr('checked',true);	
		}else{
			$('#product_field_active_'+newidfield).attr('checked',false);
		}
		if($('#product_field_mandatory_'+countsuffix).is(':checked')){	
			$('#product_field_mandatory_'+newidfield).attr('checked',true);	
		}else{
			$('#product_field_mandatory_'+newidfield).attr('checked',false);
		}
		if($('#product_field_editable_'+countsuffix).is(':checked')){	
			$('#product_field_editable_'+newidfield).attr('checked',true);
		}else{
			$('#product_field_editable_'+newidfield).attr('checked',false);
		}

		$('[name*="field_values'+countsuffix+'_"]').each( function(){
				var thisname = $(this).attr('name');	
				thisname = thisname.substring(thisname.lastIndexOf('_')+1);		
				$('#field_values'+newidfield+"_"+thisname).val($(this).val());
		});


		//******************  START: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/
	
		$('[name*="field_description_'+countsuffix+'_"]').each( function(){
				var thisname = $(this).attr('name');	
				//alert("field_description name:"+ thisname+" - value:"+$(this).val());
				thisname = thisname.substring(thisname.lastIndexOf('_')+1);		
				$('#field_description_'+newidfield+"_"+thisname).val($(this).val());
		});					
	
		$('[name*="group_value_'+countsuffix+'_"]').each( function(){
				var thisname = $(this).attr('name');	
				//alert("group_value name:"+ thisname+" - value:"+$(this).val());
				thisname = thisname.substring(thisname.lastIndexOf('_')+1);		
				$('#group_value_'+newidfield+"_"+thisname).val($(this).val());
		});					
	
		$('[name*="field_values'+countsuffix+'_"]').each( function(){
			if($(this).val() != ""){
				var key = $(this).attr('name');
				//alert("key: "+key+" - value: "+$(this).val());
				if(
					(
						$('#id_type_'+countsuffix).val()== 3 || 
						$('#id_type_'+countsuffix).val()== 4 || 
						$('#id_type_'+countsuffix).val()== 5 || 
						$('#id_type_'+countsuffix).val()== 6
					) 
					&& ($('#id_type_content_'+countsuffix).val()!=7) && ($('#id_type_content_'+countsuffix).val()!=8)
				){
				
					var valcounter = key.substring(key.indexOf("field_values")+12,key.length);	
					
					$('[name*="field_values_ml_'+valcounter+'_"]').each( function(){
							var thisname = $(this).attr('name');	
							//alert("\n- thisname:"+ thisname+"\n- value:"+$(this).val()+ "\n- id:"+$(this).attr('id')+ "\n- newidfield:"+newidfield+ "\n- valcounter:"+valcounter);							
							thisname = thisname.substring(thisname.indexOf("field_values_ml_"+valcounter+"_")+16,thisname.length);
							thisname = thisname.substring(thisname.indexOf("_")+1,thisname.length);							
							//alert("thisname: "+thisname);							
							//alert("value set on field id:#field_values_ml_"+newidfield+"_"+thisname);							
							$('#field_values_ml_'+newidfield+"_"+thisname).val($(this).val());
					});	
					
				}
			}
		});	
		
		//alert("id_type_: "+$('#id_type_'+countsuffix).val());
		
		if((
		$('#id_type_'+countsuffix).val()== 1 || 
		$('#id_type_'+countsuffix).val()== 2 || 
		$('#id_type_'+countsuffix).val()== 9) && ($('#id_type_content_'+countsuffix).val()!=7) && ($('#id_type_content_'+countsuffix).val()!=8)){	
			$("#field_value_t_"+newidfield).val($("#field_value_t_"+countsuffix).val());
			$('[name*="field_value_t_'+countsuffix+'_"]').each( function(){
					var thisname = $(this).attr('name');	
					//alert("field_value_t_ name:"+ thisname+" - value:"+$(this).val());
					thisname = thisname.substring(thisname.lastIndexOf('_')+1);		
					$('#field_value_t_'+newidfield+"_"+thisname).val($(this).val());
			});					
		
			$("#field_value_ta_"+newidfield).val($("#field_value_ta_"+countsuffix).val());
			$('[name*="field_value_ta_'+countsuffix+'_"]').each( function(){
					var thisname = $(this).attr('name');	
					//alert("field_value_ta_ name:"+ thisname+" - value:"+$(this).val());
					thisname = thisname.substring(thisname.lastIndexOf('_')+1);		
					$('#field_value_ta_'+newidfield+"_"+thisname).val($(this).val());
			});					
		
			$("#field_value_e_"+newidfield).val($("#field_value_e_"+countsuffix).val());
			$('[name*="field_value_e_'+countsuffix+'_"]').each( function(){
					var thisname = $(this).attr('name');	
					/*alert(
					"\n- field_value_e_   id:"+ $(this).attr('id')+
					"\n- field_value_e_   name:"+ thisname+
					"\n- value: "+$(this).val());*/
					thisname = thisname.substring(thisname.lastIndexOf('_')+1);		
					$('#field_value_e_'+newidfield+"_"+thisname).val($(this).val());
			});
			//alert("old value: "+ $("#field_value_e_"+countsuffix).val());
			//alert("new value: "+ $("#field_value_e_"+newidfield).val());
		}

		//TODO: MFT
		// completare con gli altri campi dei fields: 
		// - description: DONE
		// - group: DONE
		// - select/radio/checkbox: DONE
		// - text/textarea: DOING
		// - html-editor: DOING

		//******************  END: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/
	
	
		var tmp_type = $('#id_type_'+newidfield).val();
		var tmp_type_content = $('#id_type_content_'+newidfield).val();
		if(tmp_type==1 || tmp_type==7){
			$('#field_value_t_'+newidfield).val($('#field_value_t_'+countsuffix).val());
		}else if(tmp_type==2){
			$('#field_value_ta_'+newidfield).val($('#field_value_ta_'+countsuffix).val());
		}else if(tmp_type==9){	
			var nested_e = null;
			var nested_e_ml = null;
			$('#field_value_e_'+newidfield).val($('#field_value_e_'+countsuffix).val());
			$('#field_value_e_'+newidfield).cleditor()[0].focus();
			nested_e = $('#field_value_e_'+newidfield+'container .cleditorMain .cleditorMain').detach();
			$('#field_value_e_'+newidfield+'container').empty();
			$('#field_value_e_'+newidfield+'container').append(nested_e);
			$('#field_value_e_'+newidfield).cleditor()[0].refresh();				
			$('#field_value_e_'+newidfield+'_ml').cleditor()[0].focus();
			nested_e_ml = $('#trans_value_e_'+newidfield+'_txtarea .cleditorMain .cleditorMain').detach();
			$('#trans_value_e_'+newidfield+'_txtarea').empty();
			$('#trans_value_e_'+newidfield+'_txtarea').append(nested_e_ml);
			$('#field_value_e_'+newidfield+'_ml').cleditor()[0].refresh();	
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
				$('#td_product_field_value_'+newidfield).html(countryList.get(tmpmodval));
				$('#field_value_ct_'+newidfield).val($('#field_value_ct_'+countsuffix).val());
			}else if(tmp_type_content==8){
				var tmpmodval = $('#field_value_sr_'+countsuffix).val();			
				tmpmodval = tmpmodval.substring(0,tmpmodval.indexOf('_'));
				$('#td_product_field_value_'+newidfield).html(stateRegionList.get(tmpmodval));
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

		// check table quantity
		checkAllQtys(fieldvalresp, fieldqtyresp, newidfield, newdescresp);
	}
}

function modifyField(row,refreshrows){
	$(row).show();	
	$(refreshrows).hide();
	//checkAllQtys();
}

function deleteField(id_objref, row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.contenuti.detail.js.alert.confirm_del_field")%>")){			
		var query_string = "id_field="+id_objref;
		
		$.ajax({
			async: true,
			type: "POST",
			cache: false,
			url: "/backoffice/products/ajaxdeletefield.aspx",
			data: query_string,
			success: function(response) {
				//alert(response);	
				$('#'+row).remove();	
				$('#'+refreshrows+'edit_'+id_objref).remove();	

				/*$('#'+refreshrows+'edit_'+id_objref).find("input:text[name='field_description']").each(function(){
					$(this).attr('disabled','disabled');
					alert("deleteField - id: "+$(this).attr('id')+" - is disabled: "+$(this).attr('disabled'));
				});*/				

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
				
				//delete fields value from all select for related fields quantity
				//var thisfieldame = $("#td_product_field_name_"+id_objref).text();
				/*
				alert(
				"- id_objref:"+id_objref+
				"\n- thisfieldame text:"+$("#td_product_field_name_"+id_objref).text()+				
				"\n- thisfieldame value:"+$("#td_product_field_name_"+id_objref).val()+			
				"\n- thisfieldame html:"+$("#td_product_field_name_"+id_objref).html()
				);
				*/
				$("select[name*='select_field_value_']").each( function(){
					if($(this).children().length>0){
						$(this).children().each( function(){							
							/*alert(
							"- $(this).text():"+$(this).text()+
							"- $(this).val():"+$(this).val()+
							"\n- thisfieldame:"+thisfieldame+
							"\n- indexOf>=0:"+($(this).text().indexOf(thisfieldame+":")>=0)
							);
							*/
							if($(this).val().indexOf(document.form_inserisci.id.value+"|"+id_objref)>=0){	
								$(this).remove();
							}
						});			
					}
				});
				
				checkAllQtys();
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

function backField(row,refreshrows){
	$(row).hide();	
	$(refreshrows).show();	
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
		
	$("#field_values_container"+counter).append('&nbsp;').append($('<input type="text"/>').attr('id', "field_values"+counter).attr('name', "field_values"+counter).attr('class', "formFieldTXT").attr('value', "").keypress(function(event) {return notSpecialCharButUnderscore(event); }));
	
	/*
	var render='&nbsp;<a href="';
	render+="javascript:delFieldValues('"+counter+"','"+fieldValCounter+"',' ','field_values_container"+counter+"',0);";
	render+='"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a><br/>';
	*/

	
	var render='&nbsp;<a class="labelForm" href="';
	render+="javascript:showHideDiv('field_values"+counter+"_ml');";
	render+='">';
	render+='<img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:top;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>';
	render+='&nbsp;<a href="';
	render+="javascript:delFieldValues('"+counter+"','"+fieldValCounter+"','','field_values_container"+counter+"',0);";
	render+='">';
	render+='<img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a><br/>';
	render+='<div style="visibility:hidden;position:absolute;margin-left:24px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_values'+counter+'_ml">';
	<%foreach (Language x in languages){%>
	render+='<input type="text" hspace="2" vspace="2" name="field_values_ml_'+counter+'_<%=x.label%>" id="field_values_ml_'+counter+'_<%=x.label%>" value="" class="formFieldTXTInternationalization">';
	render+='&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>';
	<%}%>					
	render+='</div>';

	$("#field_values_container"+counter).append(render);
} 

function delFieldValues(counter,id_element, value, field, remove){	
	if(remove==1){
		var query_string = "id_field_value="+id_element+"&value="+value;
		//alert(query_string);
		$.ajax({
			type: "POST",
			url: "/backoffice/products/ajaxdeletefieldvalue.aspx",
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
				
				$("#product_field_editable_"+type_counter).attr('disabled',false);				
				
				if($("#product_field_editable_"+type_counter).is(':checked')){					
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
				$("#product_field_editable_"+type_counter).attr('checked',false);
				$("#product_field_editable_"+type_counter).attr('disabled',true);
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
			$("#product_field_editable_"+counter).attr('checked',true);
			$("#product_field_editable_"+counter).attr('disabled',false);
		}else{
			$('#field_value_box_'+counter).hide();
			$("#product_field_editable_"+counter).attr('checked',false);
			$("#product_field_editable_"+counter).attr('disabled',true);		
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
		$("#product_field_editable_"+counter).attr('checked',false);
		$("#product_field_editable_"+counter).attr('disabled',true);
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
	var editable = $('#product_field_editable_'+counter).is(':checked');

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
		$("[name*='field_value_t_"+counter+"_']").val('');
		$("[name*='field_value_ta_"+counter+"_']").val('');
		$("[name*='field_value_e_"+counter+"_']").val('');
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

function showHideTransProdField(fieldHide, fieldShow, field, lang_code, operation, iseditor){	
	//*** field ex: field_value_t_245_
	var field_prefix = "";
	if(operation==1){
		field_prefix = field.substring(0,field.lastIndexOf("_")+1);
		if(iseditor){
			$("#"+field_prefix+"ml").val($("#"+field_prefix+lang_code).val());
		}
		/*alert("operation 1:"+
		"\n- field("+field+") value: "+$("#"+field).val() +
		"\n- field_prefix-ml("+field_prefix+"ml) value: "+$("#"+field_prefix+"ml").val() +
		"\n- field_prefix+lang_code("+field_prefix+lang_code+") value: "+$("#"+field_prefix+lang_code).val()
		);*/
		$("[id*='ml_"+fieldShow+"']").attr('style', "border:none;");		
		$("#"+field_prefix.substring(0,field_prefix.lastIndexOf("_"))).attr("lang",lang_code);
	}else if(operation==0){
		field_prefix = field+"_";
		lang_code = $("#"+field).attr("lang");
		if(iseditor){		
			$("#"+field_prefix+lang_code).val($("#"+field_prefix+"ml").val());
			$("#"+field_prefix+"ml").val('','');
		}
		/*alert("operation 0:"+
		"\n- field("+field+") value: "+$("#"+field).val() +
		"\n- field_prefix-ml("+field_prefix+"ml) value: "+$("#"+field_prefix+"ml").val() +
		"\n- field_prefix+lang_code("+field_prefix+lang_code+") value: "+$("#"+field_prefix+lang_code).val()
		);*/
		$("[id*='ml_"+fieldHide+"']").attr('style', "border:none;");
	}
	
	/*alert(
	"\n- field_prefix:"+field_prefix+
	"\n- fieldHide:"+fieldHide+
	"\n- fieldShow:"+fieldShow+
	"\n- field:"+field+
	"\n- operation:"+operation+
	"\n- iseditor:"+iseditor+
	"\n- field_prefix-ml:"+field_prefix+"ml"+
	"\n- lang_code:"+lang_code+
	"\n- base field attr lang:"+$("#"+field_prefix.substring(0,field_prefix.lastIndexOf("_"))).attr("lang")
	);*/	
	
	$("[id*='"+field_prefix+"']").hide();
	if(operation==1){
		$('#ml_'+fieldShow+'_'+lang_code).attr('style', "border:1px solid #000000;");
	}
	$("#"+fieldHide).hide();
	$("#"+fieldShow).show();	
	if(iseditor){
		$("#"+field_prefix+"ml").cleditor()[0].refresh();
		$("#"+field_prefix+"ml").cleditor()[0].focus();
	}else{
		$("#"+field).show();
		$("#"+field).focus();		
	}
}

function previewComments(){	
	var query_string = "id_element="+$('#id').val()+"&element_type=2&mode=insert&container=commentsContainer";	
	//alert(query_string);
	
	$('#commentsContainer').empty();
	$('#commentsContainer').append('<div align="center" style="padding-top:150px;" id="loading-menu-comment"><img src="/common/img/loading_icon.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="vertical-align:middle;text-align:center;padding-top:0px;padding-bottom:0px;"></div>');	
	$('#commentsContainer').show();
	
	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/backoffice/include/ajaxpreviewcomments.aspx",
		data: query_string,
		success: function(response) {
			//alert(response);
			$('#commentsContainer').empty();
			$('#commentsContainer').append('<div align="right"><span style="cursor:pointer;text-decoration:underline;" onclick="javascript:hideCommentDiv();">x</span></div>');
			$('#commentsContainer').append(response);
		},
		error: function(response) {
			//alert(response.responseText);	
			$('#commentsContainer').hide();
			alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");
		}
	});	
}

function hideCommentDiv(){
	$('#commentsContainer').hide();
}

$(function() {
	$("#commentsContainer").draggable();
});

$(document).ready(function(){
	onloadFieldsTypes();
});

//********************** functions for multilanguage field management


function sendAjaxTransCommand(id_objref, main_field , lang_code, value, use_def, operation, fieldShow, fieldHide, defValue){
	var resp = "";

	if(operation=="find"){
		var query_string = "main_field="+main_field+
		"&plang_code="+lang_code+
		"&use_def="+use_def+
		"&id_objref="+id_objref+
		"&optype="+operation+
		"&def_val="+encodeURIComponent(defValue);
		//alert("query_string: "+query_string);
		
		$.ajax({
			async: false,
			type: "GET",
			cache: false,
			url: "/backoffice/products/ajaxprodtransupdate.aspx",
			data: query_string,
			success: function(response) {
				resp = response;
			},
			error: function() {
				$("#ajaxresp").empty();
				$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_updated_field")%>");
				$("#ajaxresp").fadeIn(1500,"linear");
				$("#ajaxresp").fadeOut(600,"linear");
				resp = "";
			}
		});
	}else if(operation=="show"){
		var query_string = "main_field="+main_field+
		"&plang_code="+lang_code+
		"&use_def="+use_def+
		"&id_objref="+id_objref+
		"&optype="+operation+
		"&field_show="+fieldShow+
		"&field_hide="+fieldHide+
		"&def_val="+encodeURIComponent(defValue);
		//alert("query_string: "+query_string);		
		
		$("#"+fieldShow+"_frm").attr('src',"/backoffice/products/ajaxprodtransupdate.aspx?" + query_string);
	}else if(operation=="write"){
		var query_string = "main_field="+main_field+"&plang_code="+lang_code+"&use_def="+use_def+"&id_objref="+id_objref+"&optype="+operation+"&field_val="+encodeURIComponent(value);
		//alert("query_string: ###"+query_string+"###");
	
		$.ajax({
			async: false,
			type: "GET",
			cache: false,
			url: "/backoffice/products/ajaxprodtransupdate.aspx",
			data: query_string,
			success: function(response) {
				/*$("#ajaxresp").empty();
				$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.ok_updated_field")%>");
				$("#ajaxresp").fadeIn(1500,"linear");
				$("#ajaxresp").fadeOut(600,"linear");*/
			},
			error: function() {
				$("#ajaxresp").empty();
				$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_updated_field")%>");
				$("#ajaxresp").fadeIn(1500,"linear");
				$("#ajaxresp").fadeOut(600,"linear");
			}
		});		
	}

	return resp;
}

function showHideTransField(fieldHide, fieldShow, field, id_objref, main_field , lang_code, def_val){
	
	if(main_field>1){
		$('#loading_zoom_'+fieldShow).show();	
		$("#"+fieldHide).hide();
		sendAjaxTransCommand(id_objref, main_field , lang_code, "", 0, "show", fieldShow, fieldHide, def_val);
	
		$("[id*='ml_"+fieldShow+"_']").attr('style', "border:none;");
		$('#ml_'+fieldShow+'_'+lang_code).attr('style', "border:1px solid #000000;");
		$("#"+fieldShow).show();	
		$('#loading_zoom_'+fieldShow).hide();
	}else{
		$('#loading_zoom_'+fieldShow).show();
		resp = sendAjaxTransCommand(id_objref, main_field , lang_code, "", 0, "find", "", "", def_val);
		$('#'+field).val(resp);
		$("[id*='ml_"+fieldShow+"_']").attr('style', "border:none;");
		$('#ml_'+fieldShow+'_'+lang_code).attr('style', "border:1px solid #000000;");
		$("#"+fieldHide).hide();
		$("#"+fieldShow).show();
		$('#loading_zoom_'+fieldShow).hide();
		$("#"+field).attr("lang",lang_code);
		$("#"+field).focus();
	}	
}

function saveFieldTranslation(fieldHide, fieldShow, field, id_objref, main_field){
	$('#loading_zoom_'+fieldHide).show();
	sendAjaxTransCommand(id_objref, main_field , $("#"+field).attr("lang"), $("#"+field).val(), 0, "write", "", "", "");
	$("[id*='ml_"+fieldHide+"_']").attr('style', "border:none;");
	$("#"+fieldHide).hide();
	$("#"+fieldShow).show();	
	$('#loading_zoom_'+fieldHide).hide();
}

function showEbuttons(id){
	$('#save_value_e_'+id+'_ml').show();
	$('#canc_value_e_'+id+'_ml').show();
	$('#field_value_e_'+id+'_ml').cleditor()[0].refresh();
	$('#field_value_e_'+id+'_ml').cleditor()[0].focus();
}

function changeQtaStato(){
	if($("#sel_qta_prod").val()==0){
		$("#quantity").val("-1");
		$("#quantity").attr('readonly', true);
		$("[id*='inner-table-rel-field_']").hide();		
		$("#quantity").hide();
		//$("#define_qta_prod").show();		
	}else{
		if($("#quantity").val()=="" || $("#quantity").val()=="-1"){
			$("#quantity").val("0");
		}
		$("#quantity").attr('readonly', false);	
		//$("#define_qta_prod").hide();	
		$("#quantity").show();	
		$("#inner-table-product-field-list table[id*='inner-table-rel-field_']").show();
	}
}

function reloadNumQtaType(qtaType) {
	/*
	*************  versione ajax (non funziona: il server aggiorna gli id field ma in pagina rimangono quelli vecchi) **********
	if(controllaCampiInput()){
		$("#form_inserisci #savesc").val("2");
		// prepare Options Object 
		var options = { 
			type: "POST", 
			dataType: "xml",
			url: '/backoffice/products/insertproduct.aspx',
			iframe:true,
			success: function(data){
				var new_prodid= $(data).find('prodid').text();
				//alert(new_prodid);
				if($("#form_inserisci #id").val()=="-1"){
					$("select[name*='select_field_value_']").each( function(){
						if($(this).children().length>0){		
							$(this).children().each( function(){
								var tmpval = $(this).val();
								var myRegExp = new RegExp("-1\\|","ig");
								tmpval = tmpval.replace(myRegExp, new_prodid+"|");								
								$(this).val(tmpval);
							});
						}
					});					
				}
				$("#form_inserisci #id").val(new_prodid);
				$("#form_inserisci #pre_el_id").val('');
				$("#form_create_field #id_product").val(new_prodid);
				$("#form_create_field #pre_el_id").val('');
				$("#select_qty_mode").show();
				$("#ins_esc_but").show();
				$("#ins_but").show();
				$("#del_but").show();
				$(".loading_autosave_prod").hide();
			},
			error: function(response) {
				//alert(response.responseText);
				$("#select_qty_mode").show();				
				$("#ins_esc_but").show();
				$("#ins_but").show();
				$("#del_but").show();
				$(".loading_autosave_prod").hide();
				alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");
			}
		}; 
		
		$("#ins_esc_but").hide();
		$("#ins_but").hide();
		$("#del_but").hide();
		$("#select_qty_mode").hide();
		$(".loading_autosave_prod").show();
		 
		// pass options to ajaxForm 
		$("#form_inserisci").ajaxSubmit(options);
		return false;
	}
	*/

	
	$("#ins_esc_but").hide();
	$("#ins_but").hide();
	$("#del_but").hide();
	$("#select_qty_mode").hide();
	$(".loading_autosave_prod").show();


	if(qtaType.value==0){
		document.form_inserisci.quantity.value = -1;
	}else{
		document.form_inserisci.quantity.value = 0;
	}
		
	if(controllaCampiInput()){	
		/*
		alert(
		"before sendForm:"+
		"\n- qtaType.value:"+qtaType.value+
		"\n- document.form_inserisci.quantity.value:"+document.form_inserisci.quantity.value+
		"\n- $(#sel_qta_prod).val():"+$("#sel_qta_prod").val()
		);
		*/
		
		sendForm(0);
	}else{
		/*
		alert(
		"before change:"+
		"\n- qtaType.value:"+qtaType.value+
		"\n- document.form_inserisci.quantity.value:"+document.form_inserisci.quantity.value+
		"\n- $(#sel_qta_prod).val():"+$("#sel_qta_prod").val()
		);
		*/
		if(qtaType.value==0){
			document.form_inserisci.quantity.value = 0;
			$("#sel_qta_prod").val('1');
		}else{
			document.form_inserisci.quantity.value = -1;
			$("#sel_qta_prod").val('0');
		}
		/*
		alert(
		"after change:"+
		"\n- qtaType.value:"+qtaType.value+
		"\n- document.form_inserisci.quantity.value:"+document.form_inserisci.quantity.value+
		"\n- $(#sel_qta_prod).val():"+$("#sel_qta_prod").val()
		);
		*/
	
		changeQtaStato();
		$("#select_qty_mode").show();
		$("#ins_esc_but").show();
		$("#ins_but").show();
		$("#del_but").show();
		$(".loading_autosave_prod").hide();
	}
}

function setCurrQtaVal(currQtaVal){
	curr_qta_val = currQtaVal;
}

function cleanFieldValuesQta(resetSilently){
	if(resetSilently){
		doCleanFieldValuesQta();
	}else{
		if(confirm("<%=lang.getTranslated("backend.prodotti.detail.js.alert.confirm_reset_qta_fields_value")%>")){
			doCleanFieldValuesQta();
		}else{
			$('#quantity').val(curr_qta_val);		
		}
	}
}
function doCleanFieldValuesQta(){
	$('#inner-table-product-field-list input:text[id*="qta_field_value_"]').each( function(){			
		/*
		alert(
		"\n- name: "+$(this).attr('name')+
		"\n- this id: "+$(this).attr('id')+
		"\n- value: "+$(this).val()
		);
		*/
		
		$(this).val(0);
	});			

	$('.img_field_value').hide();
}
					
function quantityRotationChange(field){
	/*alert(
	"\n- field.value:"+field.value+
	"\n- field.name:"+field.name+
	"\n- field.checked==true:"+(field.checked==true)
	);*/
		
	if(!checkIsQtyRotable() && $("#rotation_mode").val()>0){
		alert("<%=lang.getTranslated("backend.prodotti.detail.table.label.rotation_quantity_forbidden")%>");
		$("#rotation_mode").val('0');
	}
		
	if(field.value==0){
		$("#quantity_rotation_mode").hide();
		$("#quantity_rotation_cell").hide();
		$("#rotation_mode_tmp").hide();	
	}else{
		if($("#rotation_mode").val()==0){
			 $("#quantity_rotation_cell").hide();
		}else if($("#rotation_mode").val()==1){
			 setQtyRotationDaily();
			$("#quantity_rotation_cell").show();
		}else if($("#rotation_mode").val()==2){
			setQtyRotationWeekly();
			$("#quantity_rotation_cell").show();
		}else if($("#rotation_mode").val()==3){
			setQtyRotationMonthly();
			$("#quantity_rotation_cell").show();
		}
		$("#quantity_rotation_mode").show();
	}
}		

function setQtyRotationDaily() {
	$("#rotation_mode_tmp").show();	
	$("#rotation_mode_tmp_d").hide();
	$("#rotation_mode_tmp_w").hide();						
	$('#rotation_mode_tmp_h').datetimepicker({
		datepicker:false,
		format:'H.i',
		closeOnDateSelect:true
	});							
}

function setQtyRotationWeekly() {	
	$("#rotation_mode_tmp").show();	
	$("#rotation_mode_tmp_d").hide();
	$("#rotation_mode_tmp_w").show();						
	$('#rotation_mode_tmp_h').datetimepicker({
		datepicker:false,
		format:'H.i',
		closeOnDateSelect:true
	});								
}

function setQtyRotationMonthly() {	
	$("#rotation_mode_tmp").show();	
	$("#rotation_mode_tmp_d").show();
	$("#rotation_mode_tmp_w").hide();						
	$('#rotation_mode_tmp_h').datetimepicker({
		datepicker:false,
		format:'H.i',
		closeOnDateSelect:true
	});									
}

function checkIsQtyRotable(){
	var rotate = true;
	$('#inner-table-product-field-list select[name="id_type"]').each( function(){	
	
		/*alert(
		"\n- name: "+$(this).attr('name')+
		"\n- id: "+$(this).attr('id')+
		"\n- value: "+$(this).val()
		);*/
		
		if($(this).val() == 3 || $(this).val() == 4 || $(this).val() == 5 || $(this).val() == 6){
			rotate = false;
			return false;
		}
	});
	return rotate;
}

function checkQtaFieldValue(id, field){
	var max_qta = document.form_inserisci.quantity.value;
	var total_qta=0;
	total_qta+=Number(field.value);	

	$('#inner-table-product-field-list input:text[id*="qta_field_value_'+id+'_"]').each( function(){
		if($(this).attr('id')!=field.id){
			total_qta+=Number($(this).val());
		}
	
		/*alert(
		"\n- max_qta: "+max_qta+
		"\n- name: "+$(this).attr('name')+
		"\n- this id: "+$(this).attr('id')+
		"\n- field.id: "+field.id+
		"\n- value: "+$(this).val()+
		"\n- total_qta: "+total_qta
		);*/
	});

	if(total_qta>max_qta){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.wrong_max_qta_value")%>");
		field.value=0;
	}
	
	var idf = '#img'+field.name.substring(3,field.name.length);	
	if(Number(field.value)>0){
		$(idf).show();
	}else if(Number(field.value)==0){
		$(idf).hide();	
	}
		
	return;
}

function updateRelatedFieldProd(relField, relQta, resultContainer){
	var objRelF, objRelQ;
	var idProd, idField, fieldVal, idRelField, fieldRelVal; 

	objRelQ=$('#'+relQta).val();
	if(Number(objRelQ)<=0){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.insert_qta_prod")%>");
		return;
	}

	objRelF=$('#'+relField).val();
	if(objRelF==null || objRelF==undefined){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.field_not_changed")%>");
		return;
	}

	var arrFieldList = objRelF.split("|");
	idProd=arrFieldList[0];
	idRelField=arrFieldList[1];
	fieldRelVal=arrFieldList[2];
	idField=arrFieldList[3];
	fieldVal=arrFieldList[4];
	fieldDesc = arrFieldList[5];
	//alert("fieldDesc: "+fieldDesc);
	var otherAmounts = 0;
	var invertAmounts = 0;
	var compareAmounts = 0;

	//alert("otherAmounts start: "+otherAmounts);

	var objRef = $('#qta_field_value_'+idRelField+'_'+fieldRelVal);
	var objSelf = $('#qta_field_value_'+idField+'_'+fieldVal);
	//alert("objRef: "+'#qta_field_value_'+idRelField+'_'+fieldRelVal+"; typeofRef: "+typeof(objRef)+"; length: "+objRef.length+"; objRef.val: "+objRef.val()+"\n"+"objSelf: "+'#qta_field_value_'+idField+'_'+fieldVal+"; typeofSelf: "+typeof(objSelf)+"; length: "+objSelf.length+"; objSelf.val: "+objSelf.val());

	objRefVal = Number(objRef.val());
	objSelfVal = Number(objSelf.val());

	$('#result_container_'+idField+"_"+fieldVal).find("span[class*='rel_qta_check_"+idRelField+"_']").each(function(){
		//alert("class: "+$(this).attr("class")+"; text: "+$(this).text());
		if($(this).attr("class")!="rel_qta_check_"+idRelField+"_"+fieldRelVal){
			compareAmounts+=Number($(this).text());
		}
	});
	compareAmounts = Number(compareAmounts);
	//alert("objRelQ: "+objRelQ+"; objRefVal: "+objRefVal+"objSelfVal: "+objSelfVal);
	//alert("compareAmounts: "+compareAmounts);
	//alert("compareAmounts+objRelQ: "+(compareAmounts+Number(objRelQ)));

	if((compareAmounts+Number(objRelQ))>Number(objSelfVal)){
		var maxVal = objSelfVal-compareAmounts;
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.field_max_exceded")%>: "+maxVal);
		return;		
	}	

	$("span[class*='rel_qta_check_"+idField+"_']").each( function(){
		//alert("class: "+$(this).attr("class")+"; text: "+$(this).text());
		if($(this).parents('#result_container_'+idRelField+"_"+fieldRelVal).length>0){
			invertAmounts+=Number($(this).text());
		}
	});
	invertAmounts = Number(invertAmounts);
	//alert("invertAmounts: "+invertAmounts);

	if(invertAmounts>0){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.field_relation_exist")%>");
		return;		
	}

	$("span.rel_qta_check_"+idRelField+"_"+fieldRelVal).each( function(){
		//alert("class: "+$(this).attr("class")+"; text: "+$(this).text());
		if($(this).parents('.tr_inner_rel_field_'+idField).length>0 && $(this).parents('#result_container_'+idField+"_"+fieldVal).length==0){
			otherAmounts+=Number($(this).text());
		}
	});
	otherAmounts = Number(otherAmounts);
	//alert("objRelQ: "+objRelQ+"; otherAmounts: "+otherAmounts);
	//alert("sum: "+(Number(objRelQ)+otherAmounts));

	if(Number(objRelQ)>objSelfVal || Number(objRelQ)>objRefVal || (Number(objRelQ)+otherAmounts)>objRefVal){
		var maxVal = objSelfVal<objRefVal ? objSelfVal : objRefVal;
		maxVal = maxVal>(objRefVal-otherAmounts) ? (objRefVal-otherAmounts) : maxVal;
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.field_max_exceded")%>: "+maxVal);
		return;
	}
	
	var query_string = "id_prod="+idProd+"&id_field="+idField+"&field_val="+fieldVal+"&id_field_rel="+idRelField+"&field_rel_val="+fieldRelVal+"&qta_rel="+objRelQ+"&optype=update&field_desc="+fieldDesc;
	//alert(query_string);
	
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "/backoffice/products/ajaxrelprodfieldupdate.aspx",
		data: query_string,
		success: function(response) {
			//TODO: gestire correttamente il rendering del nuovo field rel
			
			//$("#"+resultContainer).empty();
			//$("#"+resultContainer).html(response);
			//alert(response);
			renderRelatedFieldProd(idProd, idField, fieldVal, idRelField, fieldRelVal, resultContainer, fieldDesc, objRelQ);
			checkAllQtys();
		},
		error: function() {
			alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.field_not_changed")%>");
		}
	});	
}

function deleteRelatedFieldProd(idProd, idField, fieldVal, idRelField, fieldRelVal, resultContainer, fieldDesc, quantity){
	
	var query_string = "id_prod="+idProd+"&id_field="+idField+"&field_val="+fieldVal+"&id_field_rel="+idRelField+"&field_rel_val="+fieldRelVal+"&qta_rel=&optype=delete";
	//alert(query_string);
	
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "/backoffice/products/ajaxrelprodfieldupdate.aspx",
		data: query_string,
		success: function(response) {
			//TODO: gestire correttamente il rendering del nuovo field rel
			//alert(response);
			renderDelRelatedFieldProd(idField, fieldVal, idRelField, fieldRelVal, fieldDesc, quantity);
			checkAllQtys();
		},
		error: function() {
			alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.field_not_changed")%>");
		}
	});	
}

function renderRelatedFieldProd(idProd, idField, fieldVal, idRelField, fieldRelVal, resultContainer, fieldDesc, quantity){
	var result = "";
	result+='<div id="container_del_field_rel_value_'+idField+'_'+fieldVal+'_'+fieldDesc+'_'+fieldRelVal+'"><img src="/backoffice/img/bullet_delete.png" id="img_del_field_rel_value_'+idField+'_'+fieldVal+'" align="absmiddle" border="0" hspace="0" vspace="0" style="cursor:pointer;"';
	result+='onclick="javascript:';
	result+="deleteRelatedFieldProd('"+idProd+"','"+idField+"','"+fieldVal+"','"+idRelField+"','"+fieldRelVal+"','result_container_"+idField+"_"+fieldVal+"','"+fieldDesc+"','"+quantity+"');";
	result+='">';
	result+='<span class="rel_qta_check_'+idRelField+'_'+fieldRelVal+'">'+quantity+'</span>';
	result+=':&nbsp;'+fieldDesc+'('+fieldRelVal+')';
	result+='</div>';
	
	$('#container_del_field_rel_value_'+idField+'_'+fieldVal+'_'+fieldDesc+'_'+fieldRelVal).remove();
	$("#"+resultContainer).append(result);
	
	if($('#rel_qta_sum_check_'+idField+'_'+fieldVal).text()==''){
		$('#rel_qta_sum_check_'+idField+'_'+fieldVal).append("["+Number(quantity)+"]");
	}else{
		var tmptext = $('#rel_qta_sum_check_'+idField+'_'+fieldVal).text();
		tmptext = tmptext.replace('[','');
		tmptext = tmptext.replace(']','');		

		var sumq=0;
		$('#result_container_'+idField+'_'+fieldVal+' span[class*="rel_qta_check_"]').each( function(){
			sumq+=Number($(this).text());
		});		
					
		tmptext = "["+Number(sumq)+"]";
		
		$('#rel_qta_sum_check_'+idField+'_'+fieldVal).empty();
		$('#rel_qta_sum_check_'+idField+'_'+fieldVal).append(tmptext);
	}
}

function renderDelRelatedFieldProd(idField, fieldVal, idRelField, fieldRelVal, fieldDesc, quantity){	
	$('#container_del_field_rel_value_'+idField+'_'+fieldVal+'_'+fieldDesc+'_'+fieldRelVal).remove();
	
	if($('#rel_qta_sum_check_'+idField+'_'+fieldVal).text()!=''){
		var tmptext = $('#rel_qta_sum_check_'+idField+'_'+fieldVal).text();
		tmptext = tmptext.replace('[','');
		tmptext = tmptext.replace(']','');		
		tmptext = Number(tmptext)-Number(quantity);
		if(tmptext<=0){		
			$('#rel_qta_sum_check_'+idField+'_'+fieldVal).empty();			
		}else{
			tmptext = "["+Number(tmptext)+"]";		
			$('#rel_qta_sum_check_'+idField+'_'+fieldVal).empty();
			$('#rel_qta_sum_check_'+idField+'_'+fieldVal).append(tmptext);			
		}
	}
}

function checkAllQtys(newvalues,newvaluesqty, newidfield, newdescresp){
	var foptions = []; 
	var prodid = document.form_inserisci.id.value;
	if(newvalues != "" && newvalues != undefined){		
		$.each(newvalues, function(i, item) {
		    var opt = $('<option/>').attr('value',prodid+'|'+newidfield+'|'+item+'|||'+newdescresp).text(newdescresp+': '+item);
		    foptions.push(opt);
		});
	}

	$("select[name*='select_field_value_']").each( function(){
		if($(this).children().length>0){		
			$(this).children().each( function(){
				$(this).attr('disabled', false);
			});
			$(this).showOptions();
		}
	});
			
			
	if(foptions.length>0){
		
		//**************************** delete option to select *****************
		$("select[name*='select_field_value_']").each( function(){
			if($(this).children().length>0){
				//alert("- newidfield:"+newidfield+" \n- select name:"+$(this).attr("name"));
				var selnamtmp=$(this).attr("name");
				if($(this).attr("name").indexOf("_"+newidfield+"_")<0){
					$(this).children().each( function(){
						if($(this).val().indexOf(prodid+"|"+newidfield+"|")>=0){
							var candel = true;	
							/*
							alert(
							"evaluating for remove: "+
							"\n- select name:"+selnamtmp+
							"\n- this.text:"+$(this).text()+
							"\n- this.val:"+$(this).val()+
							"\n- foptions.length:"+foptions.length+
							"\n- newidfield:"+newidfield+
							"\n- product.id:"+prodid
							);
							*/
							for(index = 0; index < foptions.length; index++) {								
								if($(this).text()==foptions[index].text()){		
									/*
									alert(
									"- cannot remove: "+foptions[index].text()+
									"\n- select name:"+selnamtmp+
									"\n- $(this).text():"+$(this).text()+
									"\n- $(this).val():"+$(this).val()
									);
									*/
									candel = false;
									break;
								}
							}
							
							if(candel){	
								/*
								alert(
								"- removing:"+
								"\n- select name:"+selnamtmp+
								"\n- $(this).text():"+$(this).text()+
								"\n- $(this).val():"+$(this).val()
								);
								*/
								$(this).remove();
							}
						}
					});				
				}
			}
		});
		
		
		//**************************** add option to select *****************
		$("select[name*='select_field_value_']").each( function(){
			if($(this).children().length>0 || $(this).attr("name") !="select_field_value_0_"){
				var checkname = $(this).closest("tr").closest("table").closest("td").closest("tr").find('td[id*="td_product_field_name_"]').text();
				var parenttr = $(this).closest("tr").closest("table").closest("td").closest("tr").attr("id");							
				/*
				alert(
				"\n- select name: "+$(this).attr("name")+
				"\n- checkname: "+checkname+
				"\n- newdescresp: "+newdescresp+
				"\n- newidfield: "+newidfield+
				"\n- parenttr: "+parenttr+
				"\n- indexOf parenttr: "+parenttr.indexOf("tr_cproduct_field_")							
				);
				*/
				if($(this).attr("name").indexOf("_"+newidfield+"_")<0 && checkname!=newdescresp){
					for(index = 0; index < foptions.length; index++) {
						var canadd = true;
						
						if($(this).children().length>0){
							$(this).children().each( function(){								
								/*
								alert(
								"- $(this).text():"+$(this).text()+
								"\n- foptions[index].text():"+foptions[index].text()+
								"\n- equals:"+($(this).text()==foptions[index].text())+
								"\n- indexOf checkname: "+$(this).text().indexOf(checkname+":")							
								);
								*/
								if($(this).text()==foptions[index].text()){					
									canadd = false;
									return false;
								}
							});
						}else{							
							/*
							alert(
							"\n- foptions[index].text():"+foptions[index].text()+
							"\n- newdescresp:"+newdescresp+
							"\n- checkname:"+checkname+
							"\n- indexOf checkname: "+foptions[index].text().indexOf(checkname+":")						
							);
							*/
							if(foptions[index].text().indexOf(checkname+":")==0){
								canadd = false;
							}
						}
						if(canadd){
							var tmparr = [];
							var tmpvl = $(this).prop("selectedIndex",0).val();
							if(tmpvl != null){
								tmparr = tmpvl.split("|");
							}else{
								tmpvl = $(this).attr("name");
								tmparr = tmpvl.split("_");								
							}
							var tmpfoptarr = foptions[index].val().split("|");
							if(tmparr != null && tmparr.length>0){
								tmpvl = tmpfoptarr[0]+"|"+tmpfoptarr[1]+"|"+tmpfoptarr[2]+"|"+tmparr[3]+"|"+tmparr[4]+"|"+tmpfoptarr[5];
							}
								
							foptions[index].val(tmpvl);
							/*
							alert(
							"appending option:"+
							"\n- this select:"+$(this).attr("name")+
							"\n- foptions[index].val():"+foptions[index].val()+
							"\n- foptions[index].text():"+foptions[index].text()//+
							//"\n- foptions[index].html():"+foptions[index].html()+
							//"\n- foptions[index]:"+foptions[index]
							);
							*/
							$(this).append('<option value="'+foptions[index].val()+'">'+foptions[index].text()+'</option>');
						}
					}	
				}	
			}
		});
	}

	$("table[name*='inner-table-rel-field_']").each( function(){
		var this_field_id = $(this).attr("name").substring($(this).attr("name").lastIndexOf("_")+1, $(this).attr("name").length);
		$(this).find("span[class*='rel_qta_check_']:first").each( function(){
			var this_field_rel_id = $(this).attr("class");
			this_field_rel_id = this_field_rel_id.substring(this_field_rel_id.indexOf("rel_qta_check_")+14, this_field_rel_id.lastIndexOf("_"));		
			
			/*
			alert(
			"Looping throw inner-table-rel-field_"+this_field_id+":[first:"+$(this).attr("class")+"]:"+
			"\n- this class: "+$(this).attr("class")+
			"\n- this id: "+$(this).attr("id")+
			"\n- this val: "+$(this).val()+
			"\n- this text: "+$(this).text()+
			"\n- rel_qta_check_ size: "+$("span[class*='rel_qta_check_']").size()
			);		
			*/
			
			$("select[name*='select_field_value_']").each( function(){		
				var this_select_name = $(this).attr("name");
				this_select_name = this_select_name.substring(this_select_name.indexOf("select_field_value_")+19, this_select_name.lastIndexOf("_"));					
				/*
				alert(
				"Looping throw select:["+$(this).attr("name")+"]"+
				"\n- this_field_id: "+this_field_id+
				"\n- this_field_rel_id: "+this_field_rel_id+
				"\n- this long name: "+$(this).attr("name")+
				"\n- this_select_name: "+this_select_name+
				"\n- value: "+$(this).val()
				);		
				*/											
				if(this_select_name==this_field_id){											
					$(this).children().each( function(){
						var tmpsval = $(this).val();
						if(tmpsval.indexOf(prodid+"|"+this_field_rel_id)!=0){
							/*
							alert("removing (this_select_name==this_field_id-->product.id|this_field_rel_id):"+
							"\n- this_select_name: "+this_select_name+
							"\n- this_field_id: "+this_field_id+
							"\n- value: "+$(this).val()+
							"\n- product.id:"+prodid+
							"\n- this_field_rel_id: "+this_field_rel_id+
							"\n- value indexof(product.id|this_field_rel_id): "+tmpsval.indexOf(prodid+"|"+this_field_rel_id)
							);
							*/
							$(this).attr('disabled', 'disabled');
						}
					});
				}else if(this_select_name==this_field_rel_id){
					$(this).children().each( function(){
						var tmpsval = $(this).val();
						if(tmpsval.indexOf(prodid+"|"+this_field_id)==0){
							/*
							alert("removing (this_select_name==this_field_rel_id-->product.id|this_field_id):"+
							"\n- this_select_name: "+this_select_name+
							"\n- this_field_rel_id: "+this_field_rel_id+
							"\n- value: "+$(this).val()+
							"\n- product.id:"+prodid+
							"\n- this_field_id: "+this_field_id
							);
							*/
							$(this).attr('disabled', 'disabled');
						}
					});						
				}else{
					$(this).children().each( function(){
						var tmpsval = $(this).val();
						if(tmpsval.indexOf(prodid+"|"+this_field_id)==0 && $("span[class*='rel_qta_check_"+this_field_id+"']").size()==0){
							/*
							alert("removing:"+
							"\n- value: "+$(this).val()+
							"\n- this_select_name: "+this_select_name+
							"\n- this_field_rel_id: "+this_field_rel_id+
							"\n- product.id:"+prodid+
							"\n- this_field_id: "+this_field_id+
							"\n- span rel_qta_check_ == 0: "+$("span[class*='rel_qta_check_"+this_field_id+"']").size()
							);
							*/
							$(this).attr('disabled', 'disabled');
						}
						if(tmpsval.indexOf(prodid+"|"+this_field_id)<0 && tmpsval.indexOf(prodid+"|"+this_field_rel_id)<0){
							/*
							alert("removing:"+
							"\n- value: "+$(this).val()+
							"\n- this_select_name: "+this_select_name+
							"\n- this_field_rel_id: "+this_field_rel_id+
							"\n- product.id:"+prodid+
							"\n- this_field_id: "+this_field_id+
							"\n- span rel_qta_check_ == 0: "+$("span[class*='rel_qta_check_"+this_field_id+"']").size()
							);
							*/
							$(this).attr('disabled', 'disabled');
						}
					});							
				}
				$(this).hideOptions();
			});		
		});	
	});	
}


(function($){
    $.fn.extend({hideOptions: function() {
        var s = this;
        return s.each(function(i,e) {
            var d = $.data(e, 'disabledOptions') || [];
            $(e).find("option[disabled=\"disabled\"]").each(function() {
                d.push($(this).detach());
            });
            $.data(e, 'disabledOptions', d);
        });
    }, showOptions: function() {
        var s = this;
        return s.each(function(i,e) {	    
            var d = $.data(e, 'disabledOptions') || [];
            for (var i in d) {
            	d[i].attr('disabled', false);
                $(e).append(d[i]);
            }
        });
    }});    
})(jQuery);

function fieldValueSlideToggle(idsuffix){
	$('#div_field_value_'+idsuffix).slideToggle();
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
			<tr> 		  		  
				<td>
					<form action="/backoffice/products/ajaxsavefield.aspx" method="post" id="form_create_field" name="form_create_field" enctype="multipart/form-data" accept-charset="UTF-8">
					  <input type="hidden" value="addfield" name="operation">		
					  <input type="hidden" value="<%=product.id%>" name="id_product" id="id_product">
					  <input type="hidden" value="" name="prod_code">
					  <input type="hidden" value="" name="id_field">
					  <input type="hidden" value="<%=pre_el_id%>" name="pre_el_id" id="pre_el_id">				
					  <input type="hidden" value="" name="group_value">				
					  <input type="hidden" value="" name="field_description">	
					  
					<!--//******************  START: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/-->
								
					<input type="hidden" value="" name="field_description_ml">	
					<input type="hidden" value="" name="group_value_ml">
					<input type="hidden" value="" name="list_product_fields_values_ml">	
					<input type="hidden" value="" name="field_value_t_ml">	
					<input type="hidden" value="" name="field_value_ta_ml">	
					<input type="hidden" value="" name="field_value_e_ml">					
							
					<!--
					//TODO: MFT
					// completare con gli altri campi dei fields: 
					// - description: DONE
					// - group: DONE
					// - select/radio/checkbox: DONE
					// - text/textarea: DOING
					// - html-editor: DOING
					
					//******************  END: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/-->
								
					  <input type="hidden" value="" name="product_field_active">	
					  <input type="hidden" value="" name="product_field_mandatory">	
					  <input type="hidden" value="" name="product_field_editable">	
					  <input type="hidden" value="" name="sorting">	
					  <input type="hidden" value="" name="max_lenght">	
					  <input type="hidden" value="" name="id_type">	
					  <input type="hidden" value="" name="id_type_content">		
					  <input type="hidden" value="" name="field_value">
					  <input type="hidden" value="" name="list_product_fields_values">
					  <input type="hidden" value="" name="list_product_fields_values_qty">			
					</form>
					<form action="/backoffice/products/insertproduct.aspx" method="post" id="form_inserisci" name="form_inserisci" enctype="multipart/form-data" accept-charset="UTF-8">
					<input type="hidden" value="<%=product.id%>" name="id"  id="id">
					<input type="hidden" value="<%=pre_el_id%>" name="pre_el_id" id="pre_el_id">
					<input type="hidden" value="insert" name="operation">
					<input type="hidden" value="1" id="savesc" name="savesc">			 	
		  			<input type="hidden" value="<%=Request["cssClass"]%>" name="cssClass">	
		
					<div class="labelForm" align="left"><%=lang.getTranslated("backend.prodotti.detail.table.label.nome_prod")%></div>
					<div style="display:none;position:absolute;" id="loading_zoom_trans_prod_name">
						<img src="/common/img/loading_icon3.gif" alt="" width="16" height="16" hspace="2" vspace="0" border="0">
					</div>
					<div id="divTitle" align="left">
					<textarea name="name" class="formFieldTXTAREAAbstract"><%=HttpUtility.HtmlEncode(product.name)%></textarea>
					</div>			
					<div id="trans_prod_name">
						<textarea id="nome_prod_trans" class="formFieldTXTAREAAbstract"></textarea>
					</div>
					<script>
					$("#trans_prod_name").hide();
					
					$("#nome_prod_trans").blur(function() {
						saveFieldTranslation('trans_prod_name','divTitle','nome_prod_trans', <%=pre_el_id_transfield%>, 1);
					});				
					</script>
					<div><%
					foreach (Language l in languages){
						if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
						<a title="<%=l.label%>" href="javascript:showHideTransField('divTitle', 'trans_prod_name', 'nome_prod_trans', <%=pre_el_id_transfield%>, 1 , '<%=l.label%>', '');"><img id="ml_trans_prod_name_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
						<%}
					}
					%>
					</div><br/>
					<div align="left" style="float:left;padding-right: 5px;">				
						<span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.page_title")%></span><br/>
						<input type="text" name="page_title" value="<%=HttpUtility.HtmlEncode(product.pageTitle)%>" class="formFieldTXT">
						<a href="javascript:showHideDiv('page_title_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
						<br/>
						<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="page_title_ml">
						<%foreach (Language x in languages){%>
						<input type="text" hspace="2" vspace="2" name="page_title_<%=x.label%>" id="page_title_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.page_title_"+product.keyword, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
						&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
						<%}%>					
						</div>				
					</div>
					  <div align="left" style="float:left;padding-right: 5px;">
					  <span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.meta_description")%></span><br/>
					    <input type="text" name="meta_description" value="<%=HttpUtility.HtmlEncode(product.metaDescription)%>" class="formFieldTXT">
						<a href="javascript:showHideDiv('meta_description_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
						<br/>
						<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="meta_description_ml">
						<%foreach (Language x in languages){%>
						<input type="text" hspace="2" vspace="2" name="meta_description_<%=x.label%>" id="meta_description_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.meta_description_"+product.keyword, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
						&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
						<%}%>					
						</div>					    
					  </div>
					 <div align="left" style="padding-bottom:20px;float:left;">
					 <span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.meta_keyword")%></span><br/>
					    <input type="text" name="meta_keyword" value="<%=HttpUtility.HtmlEncode(product.metaKeyword)%>" class="formFieldTXT">
						<a href="javascript:showHideDiv('meta_keyword_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
						<br/>
						<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="meta_keyword_ml">
						<%foreach (Language x in languages){%>
						<input type="text" hspace="2" vspace="2" name="meta_keyword_<%=x.label%>" id="meta_keyword_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.meta_keyword_"+product.keyword, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
						&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
						<%}%>						
						</div>				    
					</div>
					<br>
					
					<div id="divDetailHeaderSum" class="divDetailHeader" style="clear:both;" align="left" onClick="javascript:showHideDiv('divSummaryContainer');showHideDivArrow('divSummaryContainer','arrow1');"><img src="<%if (!String.IsNullOrEmpty(product.summary)){Response.Write("/backoffice/img/div_freccia.gif");}else{Response.Write("/backoffice/img/div_freccia2.gif");}%>" vspace="0" hspace="0" border="0" align="right" id="arrow1"><%=lang.getTranslated("backend.prodotti.detail.table.label.sommario_prod")%></div>					
					<div id="divSummaryContainer" <%if (!String.IsNullOrEmpty(product.summary)){Response.Write("style=visibility:visible;display:block;");}else{Response.Write("style=visibility:hidden;display:none;");}%>>
						<div style="display:none;position:absolute;" id="loading_zoom_trans_prod_summary">
							<img src="/common/img/loading_icon3.gif" alt="" width="16" height="16" hspace="2" vspace="0" border="0">
						</div>
						<div id="divSummary1" align="left">
						<FCKeditorV2:FCKeditor ID="summaryp" ImageBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" LinkBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" Height="200px" runat="server"></FCKeditorV2:FCKeditor>
						</div>			
						<div id="trans_prod_summary" style="width:100%;height:235px;">
							<iframe id="trans_prod_summary_frm" style="width:100%;height:235px;border:0px;" frameborder="0"></iframe>
						</div>
						<script>
						$("#trans_prod_summary").hide();					
						</script>
						<div><%
						foreach (Language l in languages){
							if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
							<a title="<%=l.label%>" href="javascript:showHideTransField('divSummary1', 'trans_prod_summary', 'summary_prod_trans', <%=pre_el_id_transfield%>, 2 , '<%=l.label%>', '');"><img id="ml_trans_prod_summary_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
							<%}
						}
						%>
						</div>
					</div><br/>
					
					<div id="divDetailHeaderText" class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divTextContainer');showHideDivArrow('divTextContainer','arrowText');"><img src="<%if (!String.IsNullOrEmpty(product.description)){Response.Write("/backoffice/img/div_freccia.gif");}else{Response.Write("/backoffice/img/div_freccia2.gif");}%>" vspace="0" hspace="0" border="0" align="right" id="arrowText"><%=lang.getTranslated("backend.prodotti.detail.table.label.desc_prod")%></div>
					<div id="divTextContainer" <%if (!String.IsNullOrEmpty(product.description)){Response.Write("style=visibility:visible;display:block;");}else{Response.Write("style=visibility:hidden;display:none;");}%>>
						<div style="display:none;position:absolute;" id="loading_zoom_trans_prod_description">
							<img src="/common/img/loading_icon3.gif" alt="" width="16" height="16" hspace="2" vspace="0" border="0">
						</div>
						<div id="divText" align="left">
						<FCKeditorV2:FCKeditor ID="descriptionp" ImageBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" LinkBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" Height="400px" runat="server"></FCKeditorV2:FCKeditor>	
						</div>
						<div id="trans_prod_description" style="width:100%;height:435px;">
							<iframe id="trans_prod_description_frm" style="width:100%;height:435px;border:0px;" frameborder="0"></iframe>
						</div>
						<script>
						$("#trans_prod_description").hide();					
						</script>
						<div><%
						foreach (Language l in languages){
							if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
							<a title="<%=l.label%>" href="javascript:showHideTransField('divText', 'trans_prod_description', 'description_prod_trans', <%=pre_el_id_transfield%>, 3 , '<%=l.label%>', '');"><img id="ml_trans_prod_description_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
							<%}
						}
						%>
						</div>
					</div><br>

					
					<div id="divCodLabel" class="labelForm" align="left"><%=lang.getTranslated("backend.prodotti.detail.table.label.cod_prod")%></div>
					<div id="divCod" align="left">
					<input type="text" name="keyword" value="<%=HttpUtility.HtmlEncode(product.keyword)%>" class="formFieldTXTLong" />
					</div>
					
					<div id="divCod4Ads" align="left" style="display:none;">
						<%
						string keyAdsType = "";
						string keyAdsDuration = "";
						if(!String.IsNullOrEmpty(product.keyword) && product.prodType==2){
							keyAdsType = product.keyword.Substring(0,product.keyword.LastIndexOf('#'));
							keyAdsDuration = product.keyword.Substring(product.keyword.LastIndexOf('#')+1);
						}
						%>
						<div style="float:left;padding-right:10px;">
						<div class="labelForm" align="left"><%=lang.getTranslated("backend.prodotti.detail.table.label.ads_type")%></div>
						<select name="key_ads_type" id="key_ads_type" class="formFieldTXT">
							<option value=""></option>
							<option value="ad-1" <%if ("ad-1".Equals(keyAdsType)) { Response.Write("selected"); }%>><%=lang.getTranslated("backend.prodotti.detail.table.label.ad-1")%></option>
							<option value="ad-2" <%if ("ad-2".Equals(keyAdsType)) { Response.Write("selected"); }%>><%=lang.getTranslated("backend.prodotti.detail.table.label.ad-2")%></option>
							<option value="ad-3" <%if ("ad-3".Equals(keyAdsType)) { Response.Write("selected"); }%>><%=lang.getTranslated("backend.prodotti.detail.table.label.ad-3")%></option>
							<option value="ad-4" <%if ("ad-4".Equals(keyAdsType)) { Response.Write("selected"); }%>><%=lang.getTranslated("backend.prodotti.detail.table.label.ad-4")%></option>		  
						</select>
						</div>
						<div style="float:top;">
						<div class="labelForm" align="left"><%=lang.getTranslated("backend.prodotti.detail.table.label.ads_duration")%></div>
						<select name="key_ads_duration" id="key_ads_duration" class="formFieldTXT">
							<option value=""></option>
							<option value="1" <%if ("1".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>1</option>
							<option value="2" <%if ("2".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>2</option>
							<option value="3" <%if ("3".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>3</option>
							<option value="4" <%if ("4".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>4</option>
							<option value="5" <%if ("5".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>5</option>	
							<option value="6" <%if ("6".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>6</option>	
							<option value="7" <%if ("7".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>7</option>	
							<option value="8" <%if ("8".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>8</option>	
							<option value="9" <%if ("9".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>9</option>	
							<option value="10" <%if ("10".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>10</option>	
							<option value="20" <%if ("20".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>20</option>	
							<option value="30" <%if ("30".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>30</option>	
							<option value="60" <%if ("60".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>60</option>	
							<option value="90" <%if ("90".Equals(keyAdsDuration)) { Response.Write("selected"); }%>>90</option>			  
						</select>
						</div>					
					</div>
					<br>
					
					<div id="ajaxresp" align="center" style="position:absolute;top:0px;background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>


					<!-- ************************************START PROD DEDICATED COMPONENT ***************************************** -->
					<div style="margin-bottom:10px">
						<span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.prod_type")%></span><br/>
						<select name="prod_type" id="prod_type" class="formFieldTXTSelect">
						<option value="0" <%if (product.prodType == 0){Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.type_portable")%></option>
						<option value="1" <%if (product.prodType == 1){Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.type_download")%></option>
						<option value="2" <%if (product.prodType == 2){Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.type_ads")%></option>
						</select>
					</div>
					
					<script type="text/javascript">		
						$(document).ready(function(){										
							// if prod_type==2 (ads) change product code element, from input to double select for ads type and expire date
							if($("#prod_type").val()==2){
								$("#divCodLabel").hide();
								$("#divCod").hide();
								$("#divCod4Ads").show();
							}else{
								$("#divCod4Ads").hide();
								$("#divCodLabel").show();
								$("#divCod").show();
							}
						});					
					
						$("#prod_type").change(function(){
							// if prod_type==2 (ads) change product code element, from input to double select for ads type and expire date
							if($("#prod_type").val()==2){
								$("#divCodLabel").hide();
								$("#divCod").hide();
								$("#divCod4Ads").show();
							}else{
								$("#divCod4Ads").hide();
								$("#divCodLabel").show();
								$("#divCod").show();
							}
						});
					</script>					

					<table border="0" cellspacing="0" cellpadding="0">
					<tr>
					<td><span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.prezzo_prod")%>&nbsp;&nbsp;&nbsp;</span><br/>
					<input type="text" name="price" value="<%=product.price.ToString("#0.00#")%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);">
					</td>	
					<td><span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.tassa_applicata")%></span><br/>
					<select name="id_supplement" class="formFieldTXT">
					<option value="-1"></option>
					<%
					if(hasSupplements){
						foreach(Supplement sup in supplements){%>
							<option value="<%=sup.id%>" <%if (product.idSupplement == sup.id) { Response.Write("selected"); }%>><%=sup.description%></option>	
						<%}
					}%>	  
					</select>
					</td>
					<td>
					<span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.taxs_group")%></span><br>
					<select name="id_supplement_group" class="formFieldTXT">
					<option value="-1"></option>
					<%
					if(hasSupplementsg){
						foreach(SupplementGroup supg in supplementsg){%>
							<option value="<%=supg.id%>" <%if (product.idSupplementGroup == supg.id) { Response.Write("selected"); }%>><%=supg.description%></option>	
						<%}
					}%>	  
					</select>		  
					</td>
					</tr>
					<tr>
					<td>&nbsp;</td>	
					<td valign="top"><span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.sconto_prod")%></span><br/>
					<input type="text" value="<%=product.discount.ToString("#0.00#")%>" name="discount" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">%
					</td>	
					<td valign="top"><span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.edit_buy_qta")%></span><br/>
					<select name="edit_buy_qty" class="formFieldTXTShort">
					<option value="0" <%if (!product.setBuyQta){ Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
					<option value="1" <%if (product.setBuyQta){ Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
					</select>
					</td>
					</tr>
					<tr>
					<td>
					<span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.qta_prod")%>&nbsp;&nbsp;&nbsp;</span><br/>		  
					<div id="select_qty_mode">
					<select name="sel_qta_prod" id="sel_qta_prod" class="formFieldTXTSelect" onchange="javascript:quantityRotationChange(this);reloadNumQtaType(this);">
					<option value="0" <%if (product.quantity == -1){ Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.qta_unlimited")%></option>
					<option value="1" <%if (product.quantity != -1){ Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.define_qta_prod")%></option>
					</select><br/>

					<!--
					<input type="radio" name="sel_qta_prod" value="0" <%if (product.quantity == -1){Response.Write("checked='checked'");}%> onclick="javascript:quantityRotationChange(this);/*changeQtaStato();*/reloadNumQtaType(-1);"> <%=lang.getTranslated("backend.prodotti.detail.table.label.qta_unlimited")%><br/>
					<input type="radio" name="sel_qta_prod" value="1" <%if (product.quantity != -1) {Response.Write("checked='checked'");}%> onclick="javascript:quantityRotationChange(this);/*changeQtaStato();*/reloadNumQtaType(<%if(product.id !=-1 && !(product.quantity == -1)){ Response.Write("document.form_inserisci.quantity.value");}else{Response.Write("0");}%>);"> 
					-->
					<input type="text" name="quantity" id="quantity" value="<%=product.quantity%>" class="formFieldTXTShort" <%if (product.quantity == -1){Response.Write("readonly");}%> onkeypress="javascript:return isInteger(event);" onfocus="javascript:setCurrQtaVal(document.form_inserisci.quantity.value);" onchange="javascript:cleanFieldValuesQta();">
					
					<!--<span id="define_qta_prod" style="display:none;"><%=lang.getTranslated("backend.prodotti.detail.table.label.define_qta_prod")%></span>-->
					
					</div>
					<script>
					changeQtaStato();
					</script>
					<div style="display:none;height:16px;" class="loading_autosave_prod">
						<img src="/common/img/loading_icon3.gif" alt="" width="16" height="16" hspace="2" vspace="0" border="0" align="left">
					</div>
					</td>	
					<td valign="top">
						<div id="quantity_rotation_mode" style="display:none;">
							<span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.rotation_mode")%></span><br/>
							<select name="rotation_mode" id="rotation_mode" class="formFieldTXT">
							<option value="0" <%if (product.quantityRotationMode==0){ Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.no_rotation")%></option>
							<option value="1" <%if (product.quantityRotationMode==1){ Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.d_rotation")%></option>
							<option value="2" <%if (product.quantityRotationMode==2){ Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.w_rotation")%></option>
							<option value="3" <%if (product.quantityRotationMode==3){ Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.m_rotation")%></option>
							</select><br/>
							<div id="rotation_mode_tmp">
							<select name="rotation_mode_tmp_d" id="rotation_mode_tmp_d" class="formFieldTXTShort">
								<%for(int i=1;i<=31;i++){%>
								<option value="<%=i%>" <%if (rotation_mode_tmp_d==i.ToString()){ Response.Write("selected");}%>><%=i%></option>
								<%}%>
							</select>
							<select name="rotation_mode_tmp_w" id="rotation_mode_tmp_w" class="formFieldTXTShort">
								<%foreach(string w in daysOfWeek){%>
								<option value="<%=w%>" <%if (rotation_mode_tmp_w==w){ Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.dayofweek.short."+w)%></option>
								<%}%>
							</select>
							<input type="text" name="rotation_mode_tmp_h" id="rotation_mode_tmp_h" value="<%=rotation_mode_tmp_h%>" style="width:40px;margin-top:1px;" class="formFieldTXTShort" onkeypress="/*javascript:return isDouble(event);*/">
							</div>
							<input type="hidden" value="" name="rotation_mode_value" id="rotation_mode_value">
						</div>
					</td>	
					<td valign="top" id="rotation_params_cell">
						<div id="quantity_rotation_cell" style="display:none;">
							<span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.rotation_quantity")%></span><br/>
							<input type="text" name="rotation_quantity" id="rotation_quantity" value="<%=product.reloadQuantity%>" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);">
							<%if(pr!=null){Response.Write("<div style=\"display:block;float:right;\"><b>"+lang.getTranslated("backend.prodotti.detail.table.label.rotation_quantity_lastupd")+"</b><br/>"+pr.lastUpdate.ToString("dd/MM/yyyy HH.mm")+"</div>");}%>
						</div>
					</td>
					</tr>
					</table>
					<script type="text/javascript">		
						$(document).ready(function(){	
							if($("#sel_qta_prod").val()==0){
								$("#quantity_rotation_mode").hide();
								$("#quantity_rotation_cell").hide();
								$("#rotation_mode_tmp").hide();
							}else{
								if(!checkIsQtyRotable() && $("#rotation_mode").val()>0){
									alert("<%=lang.getTranslated("backend.prodotti.detail.table.label.rotation_quantity_forbidden")%>");
									$("#rotation_mode").val('0')//.trigger('change');
								}
							
								if($("#rotation_mode").val()<=0){
									$("#quantity_rotation_cell").hide();
									$("#rotation_mode_tmp").hide();								
								}else{
									// render tmp rotation value depending of rotation_mode value
									if($("#rotation_mode").val()==1){
										 setQtyRotationDaily();
									}else if($("#rotation_mode").val()==2){
										setQtyRotationWeekly();
									}else if($("#rotation_mode").val()==3){
										setQtyRotationMonthly();
									}
									$("#quantity_rotation_cell").show();
								}
								$("#quantity_rotation_mode").show();
							}
						});				
					
						$("#rotation_mode").change(function(){	
							if(!checkIsQtyRotable() && $(this).val()>0){
								alert("<%=lang.getTranslated("backend.prodotti.detail.table.label.rotation_quantity_forbidden")%>");
								$(this).val('0')//.trigger('change');
							}
							
							if($(this).val()<=0){
								$("#quantity_rotation_cell").hide();
								$("#rotation_mode_tmp").hide();	
							}else if($(this).val()>=1){
								$("#quantity_rotation_cell").show();
								// render tmp rotation value depending of rotation_mode value
								if($(this).val()==1){
									 setQtyRotationDaily();
								}else if($(this).val()==2){
									setQtyRotationWeekly();
								}else if($(this).val()==3){
									setQtyRotationMonthly();
								}
							}
						});
					</script>
					<br/><br/>

					<div id="divAttachmentDownloads" align="left" style="display:none;">
						<table border="0" cellspacing="0" cellpadding="0" class="principal" id="down_add_attach_table">
							<tr>
							<td width="200">
							  <span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.max_download")%></span><br/>
							  <select name="max_download" class="formFieldTXTMedium">
							  <option value="-1" <%if (product.maxDownload == -1){Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.unlimited")%></option>
							  <option value="1" <%if (product.maxDownload == 1){Response.Write("selected");}%>>1</option>
							  <option value="2" <%if (product.maxDownload == 2){Response.Write("selected");}%>>2</option>
							  <option value="3" <%if (product.maxDownload == 3){Response.Write("selected");}%>>3</option>
							  <option value="4" <%if (product.maxDownload == 4){Response.Write("selected");}%>>4</option>
							  <option value="5" <%if (product.maxDownload == 5){Response.Write("selected");}%>>5</option>
							  <option value="6" <%if (product.maxDownload == 6){Response.Write("selected");}%>>6</option>
							  <option value="7" <%if (product.maxDownload == 7){Response.Write("selected");}%>>7</option>
							  <option value="8" <%if (product.maxDownload == 8){Response.Write("selected");}%>>8</option>
							  <option value="9" <%if (product.maxDownload == 9){Response.Write("selected");}%>>9</option>
							  <option value="10" <%if (product.maxDownload == 10){Response.Write("selected");}%>>10</option>
							  <option value="20" <%if (product.maxDownload == 20){Response.Write("selected");}%>>20</option>
							  <option value="30" <%if (product.maxDownload == 30){Response.Write("selected");}%>>30</option>
							  <option value="40" <%if (product.maxDownload == 40){Response.Write("selected");}%>>40</option>
							  <option value="50" <%if (product.maxDownload == 50){Response.Write("selected");}%>>50</option>
							  <option value="100" <%if (product.maxDownload == 100){Response.Write("selected");}%>>100</option>
							  </select><br/><br/></td>
							<td>
							  <span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.max_download_time")%></span><br/>
							  <select name="max_download_time" class="formFieldTXTMedium">
							  <option value="-1" <%if (product.maxDownloadTime == -1){Response.Write("selected");}%>><%=lang.getTranslated("backend.prodotti.detail.table.label.unlimited")%></option>
							  <option value="1" <%if (product.maxDownloadTime == 1){Response.Write("selected");}%>>1 <%=lang.getTranslated("backend.prodotti.detail.table.label.minute")%></option>
							  <option value="2" <%if (product.maxDownloadTime == 2){Response.Write("selected");}%>>2 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="3" <%if (product.maxDownloadTime == 3){Response.Write("selected");}%>>3 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="4" <%if (product.maxDownloadTime == 4){Response.Write("selected");}%>>4 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="5" <%if (product.maxDownloadTime == 5){Response.Write("selected");}%>>5 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="6" <%if (product.maxDownloadTime == 6){Response.Write("selected");}%>>6 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="7" <%if (product.maxDownloadTime == 7){Response.Write("selected");}%>>7 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="8" <%if (product.maxDownloadTime == 8){Response.Write("selected");}%>>8 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="9" <%if (product.maxDownloadTime == 9){Response.Write("selected");}%>>9 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="10" <%if (product.maxDownloadTime == 10){Response.Write("selected");}%>>10 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="30" <%if (product.maxDownloadTime == 30){Response.Write("selected");}%>>30 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="60" <%if (product.maxDownloadTime == 60){Response.Write("selected");}%>>60 <%=lang.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
							  <option value="720" <%if (product.maxDownloadTime == 720){Response.Write("selected");}%>>12 <%=lang.getTranslated("backend.prodotti.detail.table.label.hours")%></option>
							  <option value="1440" <%if (product.maxDownloadTime == 1440){Response.Write("selected");}%>>24 <%=lang.getTranslated("backend.prodotti.detail.table.label.hours")%></option>
							  <option value="4320" <%if (product.maxDownloadTime == 4320){Response.Write("selected");}%>>3 <%=lang.getTranslated("backend.prodotti.detail.table.label.days")%></option>
							  <option value="10080" <%if (product.maxDownloadTime == 10080){Response.Write("selected");}%>>7 <%=lang.getTranslated("backend.prodotti.detail.table.label.days")%></option>
							  <option value="21600" <%if (product.maxDownloadTime == 21600){Response.Write("selected");}%>>15 <%=lang.getTranslated("backend.prodotti.detail.table.label.days")%></option>
							  <option value="43200" <%if (product.maxDownloadTime == 43200){Response.Write("selected");}%>>30 <%=lang.getTranslated("backend.prodotti.detail.table.label.days")%></option>
							  </select><br/><br/></td>
							</tr>
						</table>
					
						<%if(product.dattachments != null && product.dattachments.Count>0){%>		
							<table border="0" cellspacing="0" cellpadding="0" class="principal" id="modify_attach_tabled">
							  <tr>
								<td width="250"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_to_del")%></span></td>
								<td width="170"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_type_label")%></span></td>
								<td><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_dida")%></span></td>
							  </tr>
							<%
							int attachCounter = 1;
							foreach(ProductAttachmentDownload ca in product.dattachments){%>
							  <tr id="filemodifyrow<%=attachCounter%>d">
								<td><%=ca.fileName%>
								<input type="hidden" value="<%=ca.id%>" name="filemodify_id<%=attachCounter%>d">
								</td>
								<td>
								<select name="filemodify_label<%=attachCounter%>d" class="formFieldSelectTypeFile">
								<%foreach(ProductAttachmentLabel xType in productAttachmentLabel){%>
								<option value="<%=xType.id%>" <%if(xType.id==ca.fileLabel){Response.Write("selected");}%>><%=xType.description%></option>
								<%}%>
								</select>
								</td>
								<td>
									<input type="text" name="filemodify_dida<%=attachCounter%>d" value="<%=ca.fileDida%>" class="formFieldTXT">
									<a href="javascript:showHideDiv('filemodify_dida<%=attachCounter%>d_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>&nbsp;<a href="javascript:deleteAttach(<%=ca.id%>,'filemodifyrow<%=attachCounter%>d','<%=ca.filePath+ca.fileName%>',1);"><img hspace="5" vspace="0" border="0" style="padding-top:5px;vertical-align:top;" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" src="/backoffice/img/delete.png"></a><br/>
									<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="filemodify_dida<%=attachCounter%>d_ml">
									<%foreach (Language x in languages){%>
									<input type="text" hspace="2" vspace="2" name="filemodify_dida<%=attachCounter%>d_<%=x.label%>" id="filemodify_dida<%=attachCounter%>d_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.filemodify_dida_d_"+ca.fileDida+product.keyword, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
									&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
									<%}%>						
									</div>	
								</td>
							  </tr>
								<%attachCounter++;
							}%>
							<input type="hidden" value="<%=attachCounter%>" name="attach_counterd">
							</table>
						<%}%>
						
						<table border="0" cellspacing="0" cellpadding="0" class="principal" id="add_attach_tabled">
						  <tr>
							<td width="250"><span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.download_attachment")%></span></td>
							<td width="170"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_type_label")%></span></td>
							<td><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_dida")%></span></td>
							<td><span class="labelForm"><%=lang.getTranslated("backend.commons.detail.table.label.change_num_imgs")%></span></td>
						  </tr>
						  <%for(int i=1;i<=numMaxAttachs;i++){%>
						  <tr class="attach_table_rowsd">
							<td>
							<input type="file" name="fileupload<%=i%>d" id="fileupload<%=i%>d" class="formFieldTXT">
							<input type="hidden" value="" name="fileupload_name<%=i%>d" id="fileupload_name<%=i%>d">						
							</td>
							<td>
							<%if(i==1){%><div id="text_label_new<%=i%>d" style="display:none;"><input type="text" name="fileupload_label_new<%=i%>d" id="fileupload_label_new<%=i%>d" onblur="javascript:prepareInsertAttachLabel(this,'<%=i%>d');" class="formFieldSelectTypeFile"></div><%}%>
							<div id="select_label_new<%=i%>d"><select id="fileupload_label<%=i%>d" name="fileupload_label<%=i%>d" class="formFieldSelectTypeFile">
							<%foreach(ProductAttachmentLabel xType in productAttachmentLabel){%>
							<option value="<%=xType.id%>"><%=xType.description%></option>
							<%}%>
							</select><%if(i==1){%><a href="javascript:addAttachLabel('<%=i%>d');"><img vspace="0" hspace="4" border="0" align="top" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.add_type")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.label.add_type")%>" src="/backoffice/img/add.png"></a><a href="javascript:delAttachLabel('#fileupload_label<%=i%>d');"><img vspace="0" hspace="4" border="0" align="top" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.del_type")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.label.del_type")%>" src="/backoffice/img/delete.png"></a><%}%>
							</div></td>
							<td>
								<input type="text" name="fileupload_dida<%=i%>d" class="formFieldTXT">
								<a href="javascript:showHideDiv('fileupload_dida<%=i%>d_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a><br/>
								<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="fileupload_dida<%=i%>d_ml">
								<%foreach (Language x in languages){%>
								<input type="text" hspace="2" vspace="2" name="fileupload_dida<%=i%>d_<%=x.label%>" id="fileupload_dida<%=i%>d_<%=x.label%>" value="" class="formFieldTXTInternationalization">
								&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
								<%}%>						
								</div>	
							</td>
							<td><%if(i==1){%><input type="text" value="<%=numMaxAttachs%>" name="numMaxImgsd" id="numMaxImgsd" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);"><a href="javascript:changeNumMaxImgs('d');"><img src=<%="/common/img/refresh.gif"%> vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.change_num_imgs")%>"></a><%}%>&nbsp;</td>
						  </tr>
						 <%}%>	 
						</table>			
					</div>					
					 <br/>
					<script type="text/javascript">		
						$(document).ready(function(){										
							if($("#prod_type").val()==0 || $("#prod_type").val()==2){
								$("#divAttachmentDownloads").hide();
							}else if($("#prod_type").val()==1){
								$("#divAttachmentDownloads").show();
							}
						});					
					
						$("#prod_type").change(function(){
							if($(this).val()==0 || $(this).val()==2){
								$("#divAttachmentDownloads").hide();
							}else if($(this).val()==1){
								$("#divAttachmentDownloads").show();
							}
						});
					</script>

					<!-- *************************************END PROD DEDICATED COMPONENT ****************************************** -->


					<!-- *******************************************START COMMON FIELDS BOX************************************************ -->
					
					<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divCommonProductFields');showHideDivArrow('divCommonProductFields','arrowFields');"><img src="/backoffice/img/div_freccia2.gif" vspace="0" hspace="0" border="0" align="right" id="arrowFields"><%=lang.getTranslated("backend.prodotti.detail.table.label.common_product_fields")%></div>
					<div id="divCommonProductFields" style="visibility:hidden;display:none;padding-top:2px;" align="left">
					  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table" id="inner-table-product-field-list-common">
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
					foreach(ProductField cf in commonfields){
						if(cf.common && cf.enabled){							
							string labelFormCommon = cf.description;

							bool hasCommonFieldValue= false;
							int totalCounterCommon = 0;
							IList<ProductFieldsValue> objListCommonValues = prodrep.getProductFieldValues(cf.id);
							if(objListCommonValues != null && objListCommonValues.Count>0){
								hasCommonFieldValue= true;
								totalCounterCommon = objListCommonValues.Count;
							}
							%>
							<input type="hidden" value="<%=cf.id%>" name="id_field" id="id_field_<%=cf.id%>">	  
							<tr class="<%if(counterCommon % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_cproduct_field_<%=cf.id%>">
							<td style="padding:0px; "><img width="16"  vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="" alt="" src="/backoffice/img/spacer.gif"></td>
							<td style="padding:0px; "><a href="javascript:modifyField('#tr_cproduct_field_edit_<%=cf.id%>','#tr_cproduct_field_<%=cf.id%>');"><img vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" alt="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" src="/backoffice/img/add.png"></a></td>
							<td style="text-align:center;" id="td_product_field_active_<%=cf.id%>"><%=lang.getTranslated("backend.commons.no")%></td>
							<td style="text-align:center;" id="td_product_field_mandatory_<%=cf.id%>"><%if(cf.required){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="text-align:center;" id="td_product_field_editable_<%=cf.id%>"><%if(cf.editable){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="text-align:center;" id="td_product_field_sort_<%=cf.id%>"><%=cf.sorting%></td>
							<td id="td_product_field_group_<%=cf.id%>"><%=cf.groupDescription%></td>
							<td id="td_product_field_name_<%=cf.id%>"><%=labelFormCommon%></td>
							<td id="td_product_field_type_<%=cf.id%>">
							<%string currtypeCommon = "";
							foreach(SystemFieldsType x in systemFieldsType){
								if(cf.type==x.id){
									currtypeCommon=x.description;
									break;
								}
							}
							Response.Write(currtypeCommon);%>
							</td>
							<td id="td_product_field_value_<%=cf.id%>">
								<%if(cf.type==3 || cf.type==4 || cf.type==5 || cf.type==6){
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
									}/*else{
										Response.Write(cf.value);
									}*/
									
									if(hasCommonFieldValue) {%>		
										<table width="100%" cellpadding="0" cellspacing="0" border="0" id="inner-table-rel-field_<%=cf.id%>" name="inner-table-rel-field_<%=cf.id%>" class="inner-table-rel-field" style="display:none;">
										<%foreach(ProductFieldsValue j in objListCommonValues){%>
											<tr class="tr_inner_rel_field_<%=cf.id%>"  id="tr_inner_rel_field_<%=cf.id%>_<%=j.value%>">
											<td width="16" valign="top"><img onclick="javascript:fieldValueSlideToggle('<%=cf.id%>_<%=j.value%>');" src="/backoffice/img/arrow_join.png" class="img_field_value" id="img_field_value_<%=cf.id%>_<%=j.value%>" border="0" hspace="0" vspace="0" style="cursor:pointer;display:none;" align="left"></td>
											<td width="43%" align="left"><input type="text" name="qta_field_value_<%=cf.id%>_<%=j.value%>" id="qta_field_value_<%=cf.id%>_<%=j.value%>" value="<%=j.quantity%>" class="" style="width:30px;height:13px;font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px;" onchange="javascript:checkQtaFieldValue('<%=cf.id%>',this);" onkeypress="javascript:return isInteger(event);">&nbsp;<span class="sp_qta_field_value_<%=cf.id%>_<%=j.value%>"><%=j.value%></span><br/>
											<div class="prodotto-choose-field-correlation" id="div_field_value_<%=cf.id%>_<%=j.value%>" style="display:none;">
											<select id="select_field_value_<%=cf.id%>_<%=j.value%>" name="select_field_value_<%=cf.id%>_<%=j.value%>">
											<%foreach(IDictionary<string,string> relFieldsVal in correlableFieldValues){
												if(!relFieldsVal["idfield"].Equals(cf.id.ToString())){%>
													<option value="<%=relFieldsVal["prodid"]%>|<%=relFieldsVal["idfield"]%>|<%=relFieldsVal["fvalue"]%>|<%=cf.id%>|<%=j.value%>|<%=relFieldsVal["fielddesc"]%>"><%=relFieldsVal["value"]%></option>													
												<%}
											}%>
											</select>&nbsp;
											<input type="text" id="qta_field_rel_value_<%=cf.id%>_<%=j.value%>" name="qta_field_rel_value_<%=cf.id%>_<%=j.value%>" value="0" class="" style="width:30px;height:13px;font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px;" onkeypress="javascript:return isInteger(event);" >&nbsp;
											<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="apply" onclick="javascript:updateRelatedFieldProd('select_field_value_<%=cf.id%>_<%=j.value%>','qta_field_rel_value_<%=cf.id%>_<%=j.value%>','result_container_<%=cf.id%>_<%=j.value%>');" />
											</div>
											</td>
											<td width="63%" align="left">
											<div class="rel_qta_sum" id="rel_qta_sum_check_<%=cf.id%>_<%=j.value%>"></div>
											<div style="float:left;" id="result_container_<%=cf.id%>_<%=j.value%>"></div>
											</td>
											</tr>
										<%}%>
										</table>	
									<%}									
								}/*else{
									Response.Write(cf.value);
								}*/%>
							</td>					
							 </tr>
							 
							 <tr style="display:none;" id="tr_cproduct_field_edit_<%=cf.id%>">
								 <td style="padding:0px;vertical-align:top;padding-top:5px;">
								 <a href="javascript:backField('#tr_cproduct_field_edit_<%=cf.id%>','#tr_cproduct_field_<%=cf.id%>');"><img style="cursor:pointer;" align="left" src="/backoffice/img/arrow_left.png" title="<%=lang.getTranslated("backend.commons.back")%>" hspace="4" vspace="0" border="0"></a>
								 </td>
								 <td style="padding:0px;vertical-align:top;padding-top:5px;">
								 <a href="javascript:saveField(<%=cf.id%>,'#tr_cproduct_field_edit_<%=cf.id%>','tr_product_field_',2,<%=valuesCounterCommon%>);"><img style="cursor:pointer;" align="left" src="/backoffice/img/disk.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.save_field")%>" hspace="4" vspace="0" border="0"></a>
								 </td>
								 <td id="new_field_container<%=cf.id%>" colspan="8" style="padding-bottom:10px;">
								<input type="hidden" value="<%=cf.id%>" name="id_field" id="id_field_<%=cf.id%>">						 
								 <div style="float:left;padding-right:20px;padding-top:5px;min-width:395px;">	
									 <div style="float:left;padding-right:10px; height:30px;min-width:155px;" >												
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_group")%></span>
										<img id="grouprotate_clockwise_<%=cf.id%>" onclick="javascipt:changeFieldGroupDesc(<%=cf.id%>);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.field_reload")%>" hspace="2" vspace="0" border="0"><br/>
										<input type="text" name="group_value" id="group_value_<%=cf.id%>"  value="<%=cf.groupDescription%>" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialCharButUnderscore(event);">
										<select name="group_value_c" id="group_value_c_<%=cf.id%>" style="display:none;min-width:150px;">
										<option></option>
										<%foreach(string x in fieldGroupNames){%>
										<option value="<%=x%>"><%=x%></option>
										<%}%>
										</select>
										<a href="javascript:showHideDiv('group_value_<%=cf.id%>_ml');" class="labelForm"><img id="descgmultilang_<%=cf.id%>" width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
										<br/>
										<div style="visibility:hidden;position:absolute;width:240px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="group_value_<%=cf.id%>_ml">
										<%foreach (Language x in languages){%>
											<input type="text" hspace="2" vspace="2" name="group_value_<%=cf.id%>_<%=x.label%>" id="group_value_<%=cf.id%>_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.id_group_"+cf.groupDescription, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
											&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
										<%}%>									
										</div>
									 </div>
									 <div style="float:left;padding-right:10px; height:40px;min-width:185px;display:block;" >
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
										<div style="visibility:hidden;position:absolute;width:240px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_description_<%=cf.id%>_ml">
										<%foreach (Language x in languages){%>
											<input type="text" hspace="2" vspace="2" name="field_description_<%=cf.id%>_<%=x.label%>" id="field_description_<%=cf.id%>_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.description_"+cf.description, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
											&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
										<%}%>									
										</div>									
									 </div>
									 <div style="float:left;padding-right:10px;padding-top:5px;clear:left;" >
										 <input type="checkbox" value="1" id="product_field_active_<%=cf.id%>" name="product_field_active">
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_attivo")%></span>
									 </div>
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
										 <input type="checkbox" value="1" id="product_field_mandatory_<%=cf.id%>" name="product_field_mandatory" <%if(cf.required){Response.Write("checked='checked'");}%>>
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_mandatory")%></span>
									 </div>
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
										 <input type="checkbox" value="1" id="product_field_editable_<%=cf.id%>" name="product_field_editable" onclick="javascript:onClickFieldEditable(<%=cf.id%>);" <%if(cf.editable){Response.Write("checked='checked'");}%>>
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_editable")%></span>
									 </div>	
									 <div style="float:left;padding-right:10px;padding-top:5px;clear:left;" >
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_sort")%></span><br/>
										<input type="text" name="sorting" id="sorting_<%=cf.id%>" value="<%=cf.sorting%>" class="formFieldTXTShort" maxlength="3" onkeypress="javascript:return isInteger(event);">
									 </div>
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
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
												if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.product_field.type.label."+x.description))){
													stypeLabel = lang.getTranslated("portal.commons.product_field.type.label."+x.description);
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
												if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.product_field.type_content.label."+x.description))){
													stypecLabel = lang.getTranslated("portal.commons.product_field.type_content.label."+x.description);
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
												if(totalCounterCommon > 0) {
													string[] savedValues = null;
													if (!String.IsNullOrEmpty(cf.value)){
														savedValues = cf.value.Split(',');
													}
													
													foreach(ProductFieldsValue j in objListCommonValues){
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
														<input type="text" id="field_values<%=cf.id+"_"+valuesCounterCommon%>" name="field_values<%=cf.id+"_"+valuesCounterCommon%>" value="<%=j.value%>" class="formFieldTXT" onkeypress="javascript:return notSpecialChar(event);">
														<a href="javascript:showHideDiv('field_values<%=cf.id+"_"+valuesCounterCommon%>_ml');" class="labelForm"><img id="imgdelfieldvalue_<%=cf.id+"_"+valuesCounterCommon%>_ml" width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:top;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
														<a href="javascript:delFieldValues('<%=cf.id+"_"+valuesCounterCommon%>','<%=cf.id%>','<%=j.value%>','field_values_container<%=cf.id+"_"+valuesCounterCommon%>',1);"><img id="imgdelfieldvalue_<%=cf.id+"_"+valuesCounterCommon%>" src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
														<div style="visibility:hidden;position:absolute;margin-left: 24px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_values<%=cf.id+"_"+valuesCounterCommon%>_ml">
														<%foreach (Language x in languages){%>
														<input type="text" hspace="2" vspace="2" name="field_values_ml_<%=cf.id+"_"+valuesCounterCommon%>_<%=x.label%>" id="field_values_ml_<%=cf.id+"_"+valuesCounterCommon%>_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+j.value, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
														&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
														<%}%>					
														</div>
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
													<input type="text" id="field_values<%=cf.id+"_"+valuesCounterCommon%>" name="field_values<%=cf.id+"_"+valuesCounterCommon%>" value="" class="formFieldTXT" onkeypress="javascript:return notSpecialChar(event);">
													<a href="javascript:showHideDiv('field_values<%=cf.id+"_"+valuesCounterCommon%>_ml');" class="labelForm"><img id="imgdelfieldvalue_<%=cf.id+"_"+valuesCounterCommon%>_ml" width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:top;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
													<a href="javascript:delFieldValues('<%=cf.id+"_"+valuesCounterCommon%>','<%=cf.id%>','','field_values_container<%=cf.id+"_"+valuesCounterCommon%>',0);"><img id="imgdelfieldvalue_<%=cf.id+"_"+valuesCounterCommon%>" src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
													<div style="visibility:hidden;position:absolute;margin-left: 24px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_values<%=cf.id+"_"+valuesCounterCommon%>_ml">
													<%foreach (Language x in languages){%>
													<input type="text" hspace="2" vspace="2" name="field_values_ml_<%=cf.id+"_"+valuesCounterCommon%>_<%=x.label%>" id="field_values_ml_<%=cf.id+"_"+valuesCounterCommon%>_<%=x.label%>" value="" class="formFieldTXTInternationalization">
													&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
													<%}%>					
													</div>
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
											<div id="field_value_t_<%=cf.id%>container" align="left">
											<input type="text" name="field_value_<%=cf.id%>" id="field_value_t_<%=cf.id%>" value="" class="formFieldTXTLong" onkeypress="/*javascript:return notSpecialChar(event);*/">
											</div>
											<div id="field_value_t_<%=cf.id%>trans" style="display:none;"><%
												foreach (Language l in languages){
													if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
													<input type="text" style="display:none;" name="field_value_t_<%=cf.id%>_<%=l.label%>" id="field_value_t_<%=cf.id%>_<%=l.label%>" value="" onblur="showHideTransProdField('field_value_t_<%=cf.id%>trans', 'field_value_t_<%=cf.id%>container', 'field_value_t_<%=cf.id%>', '',0,0);" class="formFieldTXTLong">
													<%}
												}%>
											</div>
											<div><%
											foreach (Language l in languages){
												if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
												<a title="<%=l.label%>" href="javascript:showHideTransProdField('field_value_t_<%=cf.id%>container', 'field_value_t_<%=cf.id%>trans', 'field_value_t_<%=cf.id%>_<%=l.label%>', '<%=l.label%>',1,0);"><img id="ml_field_value_t_<%=cf.id%>trans_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
												<%}
											}%>
											</div>
										</div>		
										<div id="baseFieldTextarea_ta_<%=cf.id%>" style="<%if(cf.type!=2){%>display:none;<%}%>">
											<div id="field_value_ta_<%=cf.id%>container" align="left">
											<textarea name="field_value_<%=cf.id%>" id="field_value_ta_<%=cf.id%>" class="formFieldTXTAREAAbstract"></textarea>
											</div>
											<div id="field_value_ta_<%=cf.id%>trans" style="display:none;"><%
												foreach (Language l in languages){
													if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
													<textarea style="display:none;" name="field_value_ta_<%=cf.id%>_<%=l.label%>" id="field_value_ta_<%=cf.id%>_<%=l.label%>" onblur="showHideTransProdField('field_value_ta_<%=cf.id%>trans', 'field_value_ta_<%=cf.id%>container', 'field_value_ta_<%=cf.id%>', '',0,0);" class="formFieldTXTAREAAbstract"></textarea>
													<%}
												}%>
											</div>
											<div><%
											foreach (Language l in languages){
												if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
												<a title="<%=l.label%>" href="javascript:showHideTransProdField('field_value_ta_<%=cf.id%>container', 'field_value_ta_<%=cf.id%>trans', 'field_value_ta_<%=cf.id%>_<%=l.label%>', '<%=l.label%>',1,0);"><img id="ml_field_value_ta_<%=cf.id%>trans_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
												<%}
											}%>
											</div>
										</div>								
										<div id="baseFieldPassword_p_<%=cf.id%>" style="<%if(cf.type!=10){%>display:none;<%}%>">
											<input type="password" name="field_value_<%=cf.id%>" id="field_value_p_<%=cf.id%>" value="<%=cf.value%>" class="formFieldTXTLong" onkeypress="/*javascript:return notSpecialChar(event);*/">			
										</div>										
										<div id="baseFieldHtmlEditor_e_<%=cf.id%>" style="<%if(cf.type!=9){%>display:none;<%}%>">
											<div id="field_value_e_<%=cf.id%>container" align="left">
											<textarea name="field_value_<%=cf.id%>" id="field_value_e_<%=cf.id%>" class="formFieldTXTAREAAbstract"></textarea>
											</div>
											
											<div id="field_value_e_<%=cf.id%>trans" style="display:none;">
												<div id="trans_value_e_<%=cf.id%>_txtarea">
												<textarea style="display:none;" name="field_value_e_<%=cf.id%>_ml" id="field_value_e_<%=cf.id%>_ml" class="formFieldTXTAREAAbstract"></textarea>
												</div>
												<%
												foreach (Language l in languages){
													if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
													<input type="hidden" name="field_value_e_<%=cf.id%>_<%=l.label%>" id="field_value_e_<%=cf.id%>_<%=l.label%>" value="">
													<%}
												}%>
												<input type="button" class="buttonForm" id="save_value_e_<%=cf.id%>_ml" hspace="2" vspace="0" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.prodotti.detail.button.inserisci.label")%>" />
												<input type="button" class="buttonForm" id="canc_value_e_<%=cf.id%>_ml" hspace="2" vspace="0" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.prodotti.detail.button.annulla.label")%>" />										
											</div>
											<div><%
											foreach (Language l in languages){
												if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
												<a title="<%=l.label%>" href="javascript:showEbuttons(<%=cf.id%>);showHideTransProdField('field_value_e_<%=cf.id%>container', 'field_value_e_<%=cf.id%>trans', 'field_value_e_<%=cf.id%>_<%=l.label%>', '<%=l.label%>',1,1);"><img id="ml_field_value_e_<%=cf.id%>trans_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
												<%}
											}%>
											</div>										
										</div>
										<script>										
										$( "#save_value_e_<%=cf.id%>_ml").click( function(){
											$("#field_value_e_<%=cf.id%>trans_button").hide();
											showHideTransProdField('field_value_e_<%=cf.id%>trans', 'field_value_e_<%=cf.id%>container', 'field_value_e_<%=cf.id%>', '',0,1);
										});
										$( "#canc_value_e_<%=cf.id%>_ml").click( function(){
											$("#field_value_e_<%=cf.id%>trans_button").hide();
											showHideTransProdField('field_value_e_<%=cf.id%>trans', 'field_value_e_<%=cf.id%>container', 'field_value_e_<%=cf.id%>', '',0,1);
										});
												
										$.cleditor.defaultOptions.width = 600;
										$.cleditor.defaultOptions.height = 200;
										$.cleditor.defaultOptions.controls = "bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image";		
										
										$(document).ready(function(){										
											$("#field_value_e_<%=cf.id%>").cleditor();
											$("#field_value_e_<%=cf.id%>_ml").cleditor();
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
										
										$('#product_field_editable_<%=cf.id%>').attr('readonly',true);
										$('#product_field_editable_<%=cf.id%>').attr('disabled',true);
										$('#product_field_editable_<%=cf.id%>').attr('style', "background:#E5E5E5;color:#9B8787;");										
										

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
										$("#descgmultilang_<%=cf.id%>").hide();										
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

					<!-- *******************************************END COMMON FIELDS BOX************************************************ -->
					
					<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divProductFields');showHideDivArrow('divProductFields','arrowFields');"><img src="<%if (hasProductFields){Response.Write("/backoffice/img/div_freccia.gif"); }else{ Response.Write("/backoffice/img/div_freccia2.gif");}%>" vspace="0" hspace="0" border="0" align="right" id="arrowFields"><%=lang.getTranslated("backend.prodotti.detail.table.label.product_fields")%></div>
					<div id="divProductFields" <%if (hasProductFields) { Response.Write("style=\"visibility:visible;display:block;padding-top:2px;\""); }else{ Response.Write("style=\"visibility:hidden;display:none;padding-top:2px;\"");}%> align="left">

					<!-- *******************************************START NEW FIELDS BOX************************************************ -->
					
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
						<img onclick="javascipt:saveField(0,'#tr_product_field_edit_0','tr_product_field_',0,0);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/application_add.png" title="<%=lang.getTranslated("backend.contenuti.lista.button.inserisci_field.label")%>" hspace="2" vspace="0" border="0">
					</td>												  
					<td id="new_field_container0">
						<input type="hidden" value="-1" name="id_field" id="id_field_0">
						 <div style="float:left;padding-right:20px;padding-top:5px;min-width:395px;">	
							 <div style="float:left;padding-right:10px; height:30px;min-width:155px;" >
								<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_group")%></span>
								<img onclick="javascipt:changeFieldGroupDesc(0);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.field_reload")%>" hspace="2" vspace="0" border="0"><br/>
								<input type="text" name="group_value" id="group_value_0"  value="" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialCharButUnderscore(event);">
								<select name="group_value_c" id="group_value_c_0" style="display:none;min-width:150px;">
								<option></option>
								<%foreach(string x in fieldGroupNames){%>
								<option value="<%=x%>"><%=x%></option>
								<%}%>
								</select>									
								<a href="javascript:showHideDiv('group_value_0_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
								<br/>
								<div style="visibility:hidden;position:absolute;width:240px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="group_value_0_ml">
								<%foreach (Language x in languages){%>
									<input type="text" hspace="2" vspace="2" name="group_value_0_<%=x.label%>" id="group_value_0_<%=x.label%>" value="" class="formFieldTXTInternationalization">
									&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
								<%}%>									
								</div>
							 </div>
							 <div style="float:left;padding-right:10px; height:40px;min-width:185px;display:block;" >
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
								<div style="visibility:hidden;position:absolute;width:240px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_description_0_ml">
								<%foreach (Language x in languages){%>
									<input type="text" hspace="2" vspace="2" name="field_description_0_<%=x.label%>" id="field_description_0_<%=x.label%>" value="" class="formFieldTXTInternationalization">
									&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
								<%}%>									
								</div>
							 </div>						 
							 <div style="float:left;padding-right:10px;padding-top:5px;clear:left;" >
								 <input type="checkbox" value="1" id="product_field_active_0" name="product_field_active">
								 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_attivo")%></span>
							 </div>
							 <div style="float:left;padding-right:10px;padding-top:5px;" >
								 <input type="checkbox" value="1" id="product_field_mandatory_0" name="product_field_mandatory">
								 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_mandatory")%></span>
							 </div>
							 <div style="float:left;padding-right:10px;padding-top:5px;" >
								 <input type="checkbox" value="1" id="product_field_editable_0" onclick="javascript:onClickFieldEditable(0);" name="product_field_editable">
								 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_editable")%></span>
							 </div>	
							 <div style="float:left;padding-right:10px;padding-top:5px;clear:left;" >
								<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_sort")%></span><br/>
								<input type="text" name="sorting" id="sorting_0" value="0" class="formFieldTXTShort" maxlength="3" onkeypress="javascript:return isInteger(event);">
							 </div>
							 <div style="float:left;padding-right:10px;padding-top:5px;" >
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
									if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.product_field.type.label."+x.description))){
										stypeLabel = lang.getTranslated("portal.commons.product_field.type.label."+x.description);
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
									if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.product_field.type_content.label."+x.description))){
										stypecLabel = lang.getTranslated("portal.commons.product_field.type_content.label."+x.description);
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
								<input type="text" name="field_values0_0" id="field_values0_0" value="" class="formFieldTXT" onkeypress="javascript:return notSpecialCharButUnderscore(event);">
								<a href="javascript:showHideDiv('field_values0_0_ml');" class="labelForm"><img id="imgdelfieldvalue_0_0_ml" width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:top;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
								<a href="javascript:delFieldValues('0','0',' ','field_values_container0_0',0);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
								<div style="visibility:hidden;position:absolute;margin-left: 24px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_values0_0_ml">
								<%foreach (Language x in languages){%>
								<input type="text" hspace="2" vspace="2" name="field_values_ml_0_0_<%=x.label%>" id="field_values_ml_0_0_<%=x.label%>" value="" class="formFieldTXTInternationalization">
								&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
								<%}%>					
								</div>								
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
								<div id="field_value_t_0container" align="left">
								<input type="text" name="field_value_0" id="field_value_t_0" value="" class="formFieldTXTLong">
								</div>
								<div id="field_value_t_0trans" style="display:none;"><%
									foreach (Language l in languages){
										if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
										<input type="text" style="display:none;" name="field_value_t_0_<%=l.label%>" id="field_value_t_0_<%=l.label%>" value="" onblur="showHideTransProdField('field_value_t_0trans', 'field_value_t_0container', 'field_value_t_0', '',0,0);" class="formFieldTXTLong">
										<%}
									}%>
								</div>
								<div><%
								foreach (Language l in languages){
									if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
									<a title="<%=l.label%>" href="javascript:showHideTransProdField('field_value_t_0container', 'field_value_t_0trans', 'field_value_t_0_<%=l.label%>', '<%=l.label%>',1,0);"><img id="ml_field_value_t_0trans_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
									<%}
								}%>
								</div>
							</div>		
							<div id="baseFieldTextarea_ta_0" style="display:none;">								
								<div id="field_value_ta_0container" align="left">
								<textarea name="field_value_0" id="field_value_ta_0" class="formFieldTXTAREAAbstract"></textarea>
								</div>
								<div id="field_value_ta_0trans" style="display:none;"><%
									foreach (Language l in languages){
										if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
										<textarea style="display:none;" name="field_value_ta_0_<%=l.label%>" id="field_value_ta_0_<%=l.label%>" onblur="showHideTransProdField('field_value_ta_0trans', 'field_value_ta_0container', 'field_value_ta_0', '',0,0);" class="formFieldTXTAREAAbstract"></textarea>
										<%}
									}%>
								</div>
								<div><%
								foreach (Language l in languages){
									if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
									<a title="<%=l.label%>" href="javascript:showHideTransProdField('field_value_ta_0container', 'field_value_ta_0trans', 'field_value_ta_0_<%=l.label%>', '<%=l.label%>',1,0);"><img id="ml_field_value_ta_0trans_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
									<%}
								}%>
								</div>									
							</div>								
							<div id="baseFieldPassword_p_0" style="display:none;">
								<input type="password" name="field_value_0" id="field_value_p_0" value="" class="formFieldTXTLong">			
							</div>	
							<div id="baseFieldHtmlEditor_e_0" style="display:none;">
								<div id="field_value_e_0container" align="left">
								<textarea name="field_value_0" id="field_value_e_0" class="formFieldTXTAREAAbstract"></textarea>
								</div>
								
								<div id="field_value_e_0trans" style="display:none;">
									<div id="trans_value_e_0_txtarea">
									<textarea style="display:none;" name="field_value_e_0_ml" id="field_value_e_0_ml" class="formFieldTXTAREAAbstract"></textarea>
									</div>
									<%
									foreach (Language l in languages){
										if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
										<input type="hidden" name="field_value_e_0_<%=l.label%>" id="field_value_e_0_<%=l.label%>" value="">
										<%}
									}%>
									<input type="button" class="buttonForm" id="save_value_e_0_ml" hspace="2" vspace="0" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.prodotti.detail.button.inserisci.label")%>" />
									<input type="button" class="buttonForm" id="canc_value_e_0_ml" hspace="2" vspace="0" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.prodotti.detail.button.annulla.label")%>" />
								</div>
								<div><%
								foreach (Language l in languages){
									if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
									<a title="<%=l.label%>" href="javascript:showEbuttons(0);showHideTransProdField('field_value_e_0container', 'field_value_e_0trans', 'field_value_e_0_<%=l.label%>', '<%=l.label%>',1,1);"><img id="ml_field_value_e_0trans_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
									<%}
								}%>
								</div>
							</div>							
							<script>							
							$( "#save_value_e_0_ml").click( function(){
								$("#field_value_e_0trans_button").hide();
								showHideTransProdField('field_value_e_0trans', 'field_value_e_0container', 'field_value_e_0', '',0,1);
							});
							$( "#canc_value_e_0_ml").click( function(){
								$("#field_value_e_0trans_button").hide();
								showHideTransProdField('field_value_e_0trans', 'field_value_e_0container', 'field_value_e_0', '',0,1);
							});
									
							$.cleditor.defaultOptions.width = 600;
							$.cleditor.defaultOptions.height = 200;
							$.cleditor.defaultOptions.controls = "bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image";		
							
							$(document).ready(function(){										
								$("#field_value_e_0").cleditor();
								$("#field_value_e_0_ml").cleditor();
							});	
							</script>								
							
							<div id="baseFieldHidden_h_0" style="display:none;">
								<input type="hidden" name="field_value_0" id="field_value_h_0" value="">			
							</div>								
						</div>					
					</td>					
					<td id="td_product_field_value_0" style="display:none;">		
						<table width="100%" cellpadding="0" cellspacing="0" border="0" id="inner-table-rel-field_0" name="inner-table-rel-field_0" class="inner-table-rel-field" style="display:none;">
							<tr class="tr_inner_rel_field_0" id="tr_inner_rel_field_0_">
							<td width="16" valign="top"><img onclick="javascript:fieldValueSlideToggle('0_');" src="/backoffice/img/arrow_join.png" class="img_field_value" id="img_field_value_0_" border="0" hspace="0" vspace="0" style="cursor:pointer;display:none;" align="left"></td>
							<td width="43%" align="left"><input type="text" name="qta_field_value_0_" id="qta_field_value_0_" value="0" class="" style="width:30px;height:13px;font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px;" onchange="javascript:checkQtaFieldValue('0',this);" onkeypress="javascript:return isInteger(event);">&nbsp;<span class="sp_qta_field_value_0_"></span><br/>
							<div class="prodotto-choose-field-correlation" id="div_field_value_0_" style="display:none;">
							<select id="select_field_value_0_" name="select_field_value_0_">								
							</select>&nbsp;
							<input type="text" id="qta_field_rel_value_0_" name="qta_field_rel_value_0_" value="0" class="" style="width:30px;height:13px;font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px;" onkeypress="javascript:return isInteger(event);" >&nbsp;
							<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="apply" onclick="javascript:updateRelatedFieldProd('select_field_value_0_','qta_field_rel_value_0_','result_container_0_');" />
							</div>
							</td>
							<td width="63%" align="left">
							<div class="rel_qta_sum" id="rel_qta_sum_check_0_"></div>
							<div style="float:left;" id="result_container_0_"></div>
							</td>
							</tr>						
						</table>	
					</td>					
					</tr>
					</table>						
					 
					<!-- *******************************************END NEW FIELDS BOX************************************************ -->
		
		
					<!-- *******************************************START PRODUCT FIELDS BOX************************************************ -->
					<input type="hidden" value="" name="list_prod_fields_values_qty">
					  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table" id="inner-table-product-field-list">
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
					foreach(ProductField cf in product.fields){
						if(!cf.common){
							string fieldCssClass="";

							bool hasFieldValue= false;
							int totalCounter = 0;
							IList<ProductFieldsValue> objListValues = null;
							dictProdFieldValues.TryGetValue(cf.id, out objListValues);
							if(objListValues != null && objListValues.Count>0){
								hasFieldValue= true;
								totalCounter = objListValues.Count;
							}
												
							string labelForm = cf.description;
							//if not(lang.getTranslated("backend.contenuti.detail.table.label."&objField.getDescription())="") then labelForm = lang.getTranslated("backend.contenuti.detail.table.label."&objField.getDescription())%>	
							<input type="hidden" value="<%=cf.id%>" name="id_field" id="id_field_<%=cf.id%>">	  
							<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_product_field_<%=cf.id%>">
							<td style="padding:0px; "><a href="javascript:deleteField(<%=cf.id%>,'tr_product_field_<%=cf.id%>','tr_product_field_');"><img vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" src="/backoffice/img/delete.png"></a></td>
							<td style="padding:0px; "><a href="javascript:modifyField('#tr_product_field_edit_<%=cf.id%>','#tr_product_field_<%=cf.id%>');"><img vspace="0" hspace="4" style="padding-top:0px;" border="0" align="left" title="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" alt="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" src="/backoffice/img/pencil.png"></a></td>
							<td style="text-align:center;" id="td_product_field_active_<%=cf.id%>"><%if(cf.enabled){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="text-align:center;" id="td_product_field_mandatory_<%=cf.id%>"><%if(cf.required){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="text-align:center;" id="td_product_field_editable_<%=cf.id%>"><%if(cf.editable){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="text-align:center;" id="td_product_field_sort_<%=cf.id%>"><%=cf.sorting%></td>
							<td id="td_product_field_group_<%=cf.id%>"><%=cf.groupDescription%></td>
							<td id="td_product_field_name_<%=cf.id%>"><%=labelForm%></td>
							<td id="td_product_field_type_<%=cf.id%>">
							<%string currtype = "";
							foreach(SystemFieldsType x in systemFieldsType){
								if(cf.type==x.id){
									currtype=x.description;
									break;
								}
							}
							Response.Write(currtype);%>
							</td>
							<td id="td_product_field_value_<%=cf.id%>">
								<%if(cf.type==3 || cf.type==4 || cf.type==5 || cf.type==6){
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
									}/*else{
										Response.Write(cf.value);
									}*/

									
									if(hasFieldValue) {%>		
										<table width="100%" cellpadding="0" cellspacing="0" border="0" id="inner-table-rel-field_<%=cf.id%>" name="inner-table-rel-field_<%=cf.id%>" class="inner-table-rel-field" style="display:none;">
										<%foreach(ProductFieldsValue j in objListValues){
											int rel_qta_sum_check = 0;
											bool hasListRelField = false;
											IList<ProductFieldsRelValue> objListValuesRel = prodrep.getProductFieldRelValues(product.id,cf.id,j.value);
											if(objListValuesRel != null && objListValuesRel.Count>0){
												hasListRelField= true;
											}%>
											<tr class="tr_inner_rel_field_<%=cf.id%>" id="tr_inner_rel_field_<%=cf.id%>_<%=j.value%>">
											<td width="16" valign="top"><img onclick="javascript:fieldValueSlideToggle('<%=cf.id%>_<%=j.value%>');" src="/backoffice/img/arrow_join.png" class="img_field_value" id="img_field_value_<%=cf.id%>_<%=j.value%>" border="0" hspace="0" vspace="0" style="cursor:pointer;display:none;" align="left"></td>
											<td width="43%" align="left"><input type="text" name="qta_field_value_<%=cf.id%>_<%=j.value%>" id="qta_field_value_<%=cf.id%>_<%=j.value%>" value="<%=j.quantity%>" class="" style="width:30px;height:13px;font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px;" onchange="javascript:checkQtaFieldValue('<%=cf.id%>',this);" onkeypress="javascript:return isInteger(event);">&nbsp;<span class="sp_qta_field_value_<%=cf.id%>_<%=j.value%>"><%=j.value%></span><br/>
											<%if(j.quantity>0){%>
											<script>
											$('#img_field_value_<%=cf.id%>_<%=j.value%>').show();
											</script>	
											<%}%>								
											<div class="prodotto-choose-field-correlation" id="div_field_value_<%=cf.id%>_<%=j.value%>" style="display:none;">
											<select id="select_field_value_<%=cf.id%>_<%=j.value%>" name="select_field_value_<%=cf.id%>_<%=j.value%>">
											<%foreach(IDictionary<string,string> relFieldsVal in correlableFieldValues){
												if(!relFieldsVal["idfield"].Equals(cf.id.ToString())){
													if (!hasListRelField) {%>
														<option value="<%=relFieldsVal["prodid"]%>|<%=relFieldsVal["idfield"]%>|<%=relFieldsVal["fvalue"]%>|<%=cf.id%>|<%=j.value%>|<%=relFieldsVal["fielddesc"]%>"><%=relFieldsVal["value"]%></option>
													<%}else{
														foreach(ProductFieldsRelValue pfrv in objListValuesRel){
															if(Convert.ToInt32(relFieldsVal["prodid"])==pfrv.idProduct &&
															   Convert.ToInt32(relFieldsVal["idfield"])==pfrv.idParentRelField &&
															   relFieldsVal["fielddesc"]==pfrv.fieldRelName
															){%>
																<option value="<%=relFieldsVal["prodid"]%>|<%=relFieldsVal["idfield"]%>|<%=relFieldsVal["fvalue"]%>|<%=cf.id%>|<%=j.value%>|<%=relFieldsVal["fielddesc"]%>"><%=relFieldsVal["value"]%></option>
																<%break;
															}else{%>
																<option value="<%=relFieldsVal["prodid"]%>|<%=relFieldsVal["idfield"]%>|<%=relFieldsVal["fvalue"]%>|<%=cf.id%>|<%=j.value%>|<%=relFieldsVal["fielddesc"]%>" disabled="disabled"><%=relFieldsVal["value"]%></option>
																<%break;
															}
														}
													}
												}
											}%>
											</select>&nbsp;
											<input type="text" id="qta_field_rel_value_<%=cf.id%>_<%=j.value%>" name="qta_field_rel_value_<%=cf.id%>_<%=j.value%>" value="0" class="" style="width:30px;height:13px;font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px;" onkeypress="javascript:return isInteger(event);" >&nbsp;
											<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="apply" onclick="javascript:updateRelatedFieldProd('select_field_value_<%=cf.id%>_<%=j.value%>','qta_field_rel_value_<%=cf.id%>_<%=j.value%>','result_container_<%=cf.id%>_<%=j.value%>');" />
											</div>
											</td>
											<td width="63%" align="left">
											<div class="rel_qta_sum" id="rel_qta_sum_check_<%=cf.id%>_<%=j.value%>"></div>
											<div style="float:left;" id="result_container_<%=cf.id%>_<%=j.value%>">
											<%
											if(hasListRelField) {
												foreach(ProductFieldsRelValue frv in objListValuesRel){
													bool isStillRelated = false;
													foreach(IDictionary<string,string> rpfv in correlableFieldValues){
														if(Convert.ToInt32(rpfv["prodid"])==frv.idProduct &&
														   Convert.ToInt32(rpfv["idfield"])==frv.idParentField &&
														   rpfv["fvalue"]==frv.fieldValue
														){
															isStillRelated = true;
															break;
														}
													}
													
													if (!isStillRelated) {
														Response.Write("deleted");
														prodrep.deleteProductFieldRelValue(frv.idProduct, frv.idParentField, frv.fieldValue, frv.idParentRelField, frv.fieldRelValue);
													}else{%>
														<div id="container_del_field_rel_value_<%=cf.id%>_<%=j.value%>_<%=frv.fieldRelName%>_<%=frv.fieldRelValue%>"><img src="/backoffice/img/bullet_delete.png" id="img_del_field_rel_value_<%=cf.id%>_<%=j.value%>" align="absmiddle" border="0" hspace="0" vspace="0" style="cursor:pointer;" onclick="javascript:deleteRelatedFieldProd('<%=frv.idProduct%>','<%=frv.idParentField%>','<%=frv.fieldValue%>','<%=frv.idParentRelField%>','<%=frv.fieldRelValue%>','result_container_<%=cf.id%>_<%=j.value%>','<%=frv.fieldRelName%>','<%=frv.quantity%>');"><span class="rel_qta_check_<%=frv.idParentRelField%>_<%=frv.fieldRelValue%>"><%=frv.quantity%></span>:&nbsp;<%=frv.fieldRelName+"("+frv.fieldRelValue+")"%></div>
													<%}
													rel_qta_sum_check+=frv.quantity;
												}
											}
											%>
											</div></td>
											</tr>
											<script>
											<%if(hasListRelField) {%>													
												$('#rel_qta_sum_check_<%=cf.id%>_<%=j.value%>').append("[<%=rel_qta_sum_check%>]");											
											<%}%>
											</script>
										<%}%>
										</table>	
										<script>
										<%if(product.quantity>-1){%>
											$("#inner-table-rel-field_<%=cf.id%>").show();
										<%}%>
										</script>
									<%}								
								}/*else{
									Response.Write(cf.value);
								}*/%>								
							</td>					
							 </tr>

							<script>
							checkAllQtys();
							</script>
								
							 <tr style="display:none;" id="tr_product_field_edit_<%=cf.id%>">
								 <td style="padding:0px;vertical-align:top;padding-top:5px;">
								 <a href="javascript:backField('#tr_product_field_edit_<%=cf.id%>','#tr_product_field_<%=cf.id%>');"><img style="cursor:pointer;" align="left" src="/backoffice/img/arrow_left.png" title="<%=lang.getTranslated("backend.commons.back")%>" hspace="4" vspace="0" border="0"></a>
								 </td>
								 <td style="padding:0px;vertical-align:top;padding-top:5px;">
								 <a href="javascript:saveField(<%=cf.id%>,'#tr_product_field_edit_<%=cf.id%>','tr_product_field_',1,<%=valuesCounter%>);"><img style="cursor:pointer;" align="left" src="/backoffice/img/disk.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.save_field")%>" hspace="4" vspace="0" border="0"></a>
								 </td>
								 <td colspan="8" style="padding-bottom:10px;">	<!-- <%if(counter<product.fields.Count-1){%>border-bottom:1px solid #000;<%}%> -->						 
								 <div style="float:left;padding-right:20px;padding-top:5px;min-width:395px;">	
									 <div style="float:left;padding-right:10px; height:30px;min-width:155px;" >
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_group")%></span>
										<img onclick="javascipt:changeFieldGroupDesc(<%=cf.id%>);" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.field_reload")%>" hspace="2" vspace="0" border="0"><br/>
										<input type="text" name="group_value" id="group_value_<%=cf.id%>"  value="<%=cf.groupDescription%>" class="formFieldTXTMedium2" onkeypress="javascript:return notSpecialCharButUnderscore(event);">
										<select name="group_value_c" id="group_value_c_<%=cf.id%>" style="display:none;min-width:150px;">
										<option></option>
										<%foreach(string x in fieldGroupNames){%>
										<option value="<%=x%>"><%=x%></option>
										<%}%>
										</select>										
										<a href="javascript:showHideDiv('group_value_<%=cf.id%>_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
										<br/>
										<div style="visibility:hidden;position:absolute;width:240px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="group_value_<%=cf.id%>_ml">
										<%foreach (Language x in languages){%>
											<input type="text" hspace="2" vspace="2" name="group_value_<%=cf.id%>_<%=x.label%>" id="group_value_<%=cf.id%>_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.id_group_"+cf.description+"_"+product.keyword, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
											&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
										<%}%>									
										</div>										
									 </div>
									 <div style="float:left;padding-right:10px; height:40px;min-width:185px;display:block;" >
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
										<div style="visibility:hidden;position:absolute;width:240px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_description_<%=cf.id%>_ml">
										<%foreach (Language x in languages){%>
											<input type="text" hspace="2" vspace="2" name="field_description_<%=cf.id%>_<%=x.label%>" id="field_description_<%=cf.id%>_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.field_description_"+cf.description+"_"+product.keyword, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
											&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
										<%}%>									
										</div>
									 </div>						 
									 <div style="float:left;padding-right:10px;padding-top:5px;clear:left;" >
										 <input type="checkbox" value="1" id="product_field_active_<%=cf.id%>" name="product_field_active" <%if(cf.enabled){Response.Write("checked='checked'");}%>>
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_attivo")%></span>
									 </div>
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
										 <input type="checkbox" value="1" id="product_field_mandatory_<%=cf.id%>" name="product_field_mandatory" <%if(cf.required){Response.Write("checked='checked'");}%>>
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_mandatory")%></span>
									 </div>
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
										 <input type="checkbox" value="1" id="product_field_editable_<%=cf.id%>" onclick="javascript:onClickFieldEditable(<%=cf.id%>);" name="product_field_editable" <%if(cf.editable){Response.Write("checked='checked'");}%>>
										 &nbsp;<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_editable")%></span>
									 </div>	
									 <div style="float:left;padding-right:10px;padding-top:5px;clear:left;" >
										<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_sort")%></span><br/>
										<input type="text" name="sorting" id="sorting_<%=cf.id%>" value="<%=cf.sorting%>" class="formFieldTXTShort" maxlength="3" onkeypress="javascript:return isInteger(event);">
									 </div>
									 <div style="float:left;padding-right:10px;padding-top:5px;" >
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
											if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.product_field.type.label."+x.description))){
												stypeLabel = lang.getTranslated("portal.commons.product_field.type.label."+x.description);
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
											if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.product_field.type_content.label."+x.description))){
												stypecLabel = lang.getTranslated("portal.commons.product_field.type_content.label."+x.description);
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
												if(totalCounter > 0) {
													string[] savedValues = null;
													if (!String.IsNullOrEmpty(cf.value)){
														savedValues = cf.value.Split(',');
													}
													
													foreach(ProductFieldsValue j in objListValues){
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
														<input type="text" id="field_values<%=cf.id+"_"+valuesCounter%>" name="field_values<%=cf.id+"_"+valuesCounter%>" value="<%=j.value%>" class="formFieldTXT" onkeypress="javascript:return notSpecialCharButUnderscore(event);">
														<a href="javascript:showHideDiv('field_values<%=cf.id+"_"+valuesCounter%>_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:top;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
														<a href="javascript:delFieldValues('<%=cf.id+"_"+valuesCounter%>','<%=cf.id%>','<%=j.value%>','field_values_container<%=cf.id+"_"+valuesCounter%>',1);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
														<div style="visibility:hidden;position:absolute;margin-left: 24px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_values<%=cf.id+"_"+valuesCounter%>_ml">
														<%foreach (Language x in languages){%>
														<input type="text" hspace="2" vspace="2" name="field_values_ml_<%=cf.id+"_"+valuesCounter%>_<%=x.label%>" id="field_values_ml_<%=cf.id+"_"+valuesCounter%>_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+j.value+"_"+product.keyword, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
														&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
														<%}%>					
														</div>														
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
													<input type="text" id="field_values<%=cf.id+"_"+valuesCounter%>" name="field_values<%=cf.id+"_"+valuesCounter%>" value="" class="formFieldTXT" onkeypress="javascript:return notSpecialCharButUnderscore(event);">
													<a href="javascript:showHideDiv('field_values<%=cf.id+"_"+valuesCounter%>_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:top;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
													<a href="javascript:delFieldValues('<%=cf.id+"_"+valuesCounter%>','<%=cf.id%>','','field_values_container<%=cf.id+"_"+valuesCounter%>',0);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
													<div style="visibility:hidden;position:absolute;margin-left: 24px;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="field_values<%=cf.id+"_"+valuesCounter%>_ml">
													<%foreach (Language x in languages){%>
													<input type="text" hspace="2" vspace="2" name="field_values_ml_<%=cf.id+"_"+valuesCounter%>_<%=x.label%>" id="field_values_ml_<%=cf.id+"_"+valuesCounter%>_<%=x.label%>" value="" class="formFieldTXTInternationalization">
													&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
													<%}%>					
													</div>													
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
											<div id="field_value_t_<%=cf.id%>container" align="left">
											<input type="text" name="field_value_<%=cf.id%>" id="field_value_t_<%=cf.id%>" value="<%=HttpUtility.HtmlEncode(cf.value)%>" class="formFieldTXTLong" onkeypress="/*javascript:return notSpecialChar(event);*/">
											</div>
											<div id="field_value_t_<%=cf.id%>trans" style="display:none;"><%
												foreach (Language l in languages){
													if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
													<input type="text" style="display:none;" name="field_value_t_<%=cf.id%>_<%=l.label%>" id="field_value_t_<%=cf.id%>_<%=l.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.field_value_t_"+cf.description+"_"+product.keyword, l.label, lang.defaultLangCode)%>" onblur="showHideTransProdField('field_value_t_<%=cf.id%>trans', 'field_value_t_<%=cf.id%>container', 'field_value_t_<%=cf.id%>', '',0,0);" class="formFieldTXTLong">
													<%}
												}%>
											</div>
											<div><%
											foreach (Language l in languages){
												if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
												<a title="<%=l.label%>" href="javascript:showHideTransProdField('field_value_t_<%=cf.id%>container', 'field_value_t_<%=cf.id%>trans', 'field_value_t_<%=cf.id%>_<%=l.label%>', '<%=l.label%>',1,0);"><img id="ml_field_value_t_<%=cf.id%>trans_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
												<%}
											}%>
											</div>
										</div>										
										<div id="baseFieldTextarea_ta_<%=cf.id%>" style="<%if(cf.type!=2){%>display:none;<%}%>">
											<div id="field_value_ta_<%=cf.id%>container" align="left">
											<textarea name="field_value_<%=cf.id%>" id="field_value_ta_<%=cf.id%>" class="formFieldTXTAREAAbstract"><%=HttpUtility.HtmlEncode(cf.value)%></textarea>
											</div>
											<div id="field_value_ta_<%=cf.id%>trans" style="display:none;"><%
												foreach (Language l in languages){
													if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
													<textarea style="display:none;" name="field_value_ta_<%=cf.id%>_<%=l.label%>" id="field_value_ta_<%=cf.id%>_<%=l.label%>" onblur="showHideTransProdField('field_value_ta_<%=cf.id%>trans', 'field_value_ta_<%=cf.id%>container', 'field_value_ta_<%=cf.id%>', '',0,0);" class="formFieldTXTAREAAbstract"><%=HttpUtility.HtmlEncode(mlangrep.translate("backend.prodotti.detail.table.label.field_value_ta_"+cf.description+"_"+product.keyword, l.label, lang.defaultLangCode))%></textarea>
													<%}
												}%>
											</div>
											<div><%
											foreach (Language l in languages){
												if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
												<a title="<%=l.label%>" href="javascript:showHideTransProdField('field_value_ta_<%=cf.id%>container', 'field_value_ta_<%=cf.id%>trans', 'field_value_ta_<%=cf.id%>_<%=l.label%>', '<%=l.label%>',1,0);"><img id="ml_field_value_ta_<%=cf.id%>trans_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
												<%}
											}%>
											</div>											
										</div>								
										<div id="baseFieldPassword_p_<%=cf.id%>" style="<%if(cf.type!=10){%>display:none;<%}%>">
											<input type="password" name="field_value_<%=cf.id%>" id="field_value_p_<%=cf.id%>" value="<%=cf.value%>" class="formFieldTXTLong" onkeypress="/*javascript:return notSpecialChar(event);*/">			
										</div>	
										<div id="baseFieldHtmlEditor_e_<%=cf.id%>" style="<%if(cf.type!=9){%>display:none;<%}%>">
											<div id="field_value_e_<%=cf.id%>container" align="left">
											<textarea name="field_value_<%=cf.id%>" id="field_value_e_<%=cf.id%>" class="formFieldTXTAREAAbstract"><%=HttpUtility.HtmlEncode(cf.value)%></textarea>
											</div>
											
											<div id="field_value_e_<%=cf.id%>trans" style="display:none;">
												<div id="trans_value_e_<%=cf.id%>_txtarea">
												<textarea style="display:none;" name="field_value_e_<%=cf.id%>_ml" id="field_value_e_<%=cf.id%>_ml" class="formFieldTXTAREAAbstract"></textarea>
												</div>
												<%
												foreach (Language l in languages){
													if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
													<input type="hidden" name="field_value_e_<%=cf.id%>_<%=l.label%>" id="field_value_e_<%=cf.id%>_<%=l.label%>" value="">
													<%}
												}%>
												<input type="button" class="buttonForm" id="save_value_e_<%=cf.id%>_ml" hspace="2" vspace="0" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.prodotti.detail.button.inserisci.label")%>" />
												<input type="button" class="buttonForm" id="canc_value_e_<%=cf.id%>_ml" hspace="2" vspace="0" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.prodotti.detail.button.annulla.label")%>" />										
											</div>
											<div><%
											foreach (Language l in languages){
												if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
												<a title="<%=l.label%>" href="javascript:showEbuttons(<%=cf.id%>);showHideTransProdField('field_value_e_<%=cf.id%>container', 'field_value_e_<%=cf.id%>trans', 'field_value_e_<%=cf.id%>_<%=l.label%>', '<%=l.label%>',1,1);"><img id="ml_field_value_e_<%=cf.id%>trans_<%=l.label%>" src="<%="/backoffice/img/flag/flag-"+l.label+".png"%>" alt="<%=l.label%>" width="16" height="11" border="0" /></a>
												<%}
											}%>
											</div>										
										</div>
										<script>
										$( "#save_value_e_<%=cf.id%>_ml").click( function(){
											$("#field_value_e_<%=cf.id%>trans_button").hide();
											showHideTransProdField('field_value_e_<%=cf.id%>trans', 'field_value_e_<%=cf.id%>container', 'field_value_e_<%=cf.id%>', '',0,1);
										});
										$( "#canc_value_e_<%=cf.id%>_ml").click( function(){
											$("#field_value_e_<%=cf.id%>trans_button").hide();
											showHideTransProdField('field_value_e_<%=cf.id%>trans', 'field_value_e_<%=cf.id%>container', 'field_value_e_<%=cf.id%>', '',0,1);
										});
												
										$.cleditor.defaultOptions.width = 600;
										$.cleditor.defaultOptions.height = 200;
										$.cleditor.defaultOptions.controls = "bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image";		
										
										$(document).ready(function(){										
											$("#field_value_e_<%=cf.id%>").cleditor();
											$("#field_value_e_<%=cf.id%>_ml").cleditor();
											<%
											foreach (Language l in languages){
												if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
												$("#field_value_e_<%=cf.id%>_<%=l.label%>").val('<%=mlangrep.translate("backend.prodotti.detail.table.label.field_value_e_"+cf.description+"_"+product.keyword, l.label, lang.defaultLangCode)%>');
												<%}
											}%>
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
					  
					<!-- *******************************************END PRODUCT FIELDS BOX************************************************ -->
					  </div>
					 <br/><br/>
					
					<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divAttachments');showHideDivArrow('divAttachments','arrowAttach');"><img src="<%if (product.attachments != null && product.attachments.Count>0){Response.Write("/backoffice/img/div_freccia.gif");}else{Response.Write("/backoffice/img/div_freccia2.gif");}%>" vspace="0" hspace="0" border="0" align="right" id="arrowAttach"><%=lang.getTranslated("backend.news.view.table.label.attached_files")%></div>
					<div id="divAttachments" <%if (product.attachments != null && product.attachments.Count>0){Response.Write("style=visibility:visible;display:block;");}else{Response.Write("style=visibility:hidden;display:none;");}%> align="left">
					<%if(product.attachments != null && product.attachments.Count>0){%>		
						<table border="0" cellspacing="0" cellpadding="0" class="principal" id="modify_attach_table">
						  <tr>
							<td width="250"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_to_del")%></span></td>
							<td width="170"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_type_label")%></span></td>
							<td><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.file_dida")%></span></td>
						  </tr>
						<%
						int attachCounter = 1;
						foreach(ProductAttachment ca in product.attachments){%>
						  <tr id="filemodifyrow<%=attachCounter%>">
							<td><%=ca.fileName%>
							<input type="hidden" value="<%=ca.id%>" name="filemodify_id<%=attachCounter%>">
							</td>
							<td>
							<select name="filemodify_label<%=attachCounter%>" class="formFieldSelectTypeFile">
							<%foreach(ProductAttachmentLabel xType in productAttachmentLabel){%>
							<option value="<%=xType.id%>" <%if(xType.id==ca.fileLabel){Response.Write("selected");}%>><%=xType.description%></option>
							<%}%>
							</select>
							</td>
							<td>
								<input type="text" name="filemodify_dida<%=attachCounter%>" value="<%=ca.fileDida%>" class="formFieldTXT">
								<a href="javascript:showHideDiv('filemodify_dida<%=attachCounter%>_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>&nbsp;<a href="javascript:deleteAttach(<%=ca.id%>,'filemodifyrow<%=attachCounter%>','<%=ca.filePath+ca.fileName%>',0);"><img hspace="5" vspace="0" border="0" style="padding-top:5px;vertical-align:top;" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" src="/backoffice/img/delete.png"></a><br/>
								<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="filemodify_dida<%=attachCounter%>_ml">
								<%foreach (Language x in languages){%>
								<input type="text" hspace="2" vspace="2" name="filemodify_dida<%=attachCounter%>_<%=x.label%>" id="filemodify_dida<%=attachCounter%>_<%=x.label%>" value="<%=mlangrep.translate("backend.prodotti.detail.table.label.filemodify_dida_"+ca.fileDida+product.keyword, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
								&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
								<%}%>						
								</div>
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
						</td>
						<td>
						<%if(i==1){%><div id="text_label_new<%=i%>" style="display:none;"><input type="text" name="fileupload_label_new<%=i%>" id="fileupload_label_new<%=i%>" onblur="javascript:prepareInsertAttachLabel(this,'<%=i%>');" class="formFieldSelectTypeFile"></div><%}%>
						<div id="select_label_new<%=i%>"><select id="fileupload_label<%=i%>" name="fileupload_label<%=i%>" class="formFieldSelectTypeFile">
						<%foreach(ProductAttachmentLabel xType in productAttachmentLabel){%>
						<option value="<%=xType.id%>"><%=xType.description%></option>
						<%}%>
						</select><%if(i==1){%><a href="javascript:addAttachLabel('<%=i%>');"><img vspace="0" hspace="4" border="0" align="top" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.add_type")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.label.add_type")%>" src="/backoffice/img/add.png"></a><a href="javascript:delAttachLabel('#fileupload_label<%=i%>');"><img vspace="0" hspace="4" border="0" align="top" title="<%=lang.getTranslated("backend.contenuti.detail.table.label.del_type")%>" alt="<%=lang.getTranslated("backend.contenuti.detail.table.label.del_type")%>" src="/backoffice/img/delete.png"></a><%}%>
						</div></td>
						<td>
							<input type="text" name="fileupload_dida<%=i%>" class="formFieldTXT">
							<a href="javascript:showHideDiv('fileupload_dida<%=i%>_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a><br/>
							<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="fileupload_dida<%=i%>_ml">
							<%foreach (Language x in languages){%>
							<input type="text" hspace="2" vspace="2" name="fileupload_dida<%=i%>_<%=x.label%>" id="fileupload_dida<%=i%>_<%=x.label%>" value="" class="formFieldTXTInternationalization">
							&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
							<%}%>						
							</div>
						</td>
						<td><%if(i==1){%><input type="text" value="<%=numMaxAttachs%>" name="numMaxImgs" id="numMaxImgs" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);"><a href="javascript:changeNumMaxImgs('');"><img src=<%="/common/img/refresh.gif"%> vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.change_num_imgs")%>"></a><%}%>&nbsp;</td>
					  </tr>
					 <%}%>	 
					</table>			
					</div>					
					 <br/><br/>

					 
					<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divProdRelations');showHideDivArrow('divProdRelations','arrowRelations');"><img src="<%if (product.relations != null && product.relations.Count>0){Response.Write("/backoffice/img/div_freccia.gif");}else{Response.Write("/backoffice/img/div_freccia2.gif");}%>" vspace="0" hspace="0" border="0" align="right" id="arrowRelations"><%=lang.getTranslated("backend.prodotti.detail.table.label.product_relations")%></div>
					<div id="divProdRelations" <%if (product.relations != null && product.relations.Count>0){Response.Write("style=\"visibility:visible;display:block;padding-top:2px;border:1px solid #C9C9C9;\"");}else{Response.Write("style=\"visibility:hidden;display:none;padding-top:2px;border:1px solid #C9C9C9;\"");}%> align="center">
					<div style="display:block " align="left">
					<%
					if (product.relations != null && product.relations.Count>0){
						int prcounter = 1;
						foreach(ProductRelation k in product.relations){
							//Set objRelProd = objRelationsProd(k)
							Product rel = prodrep.getById(k.idProductRel);
							bool hasNotSmallImg = true;%>

							<%if(prcounter % 4 == 0){%><div id="clear"></div><%}%>
							<div id="prodotto-immagine">
							<%if (rel.attachments != null && rel.attachments.Count>0) {		
								foreach(ProductAttachment attach in rel.attachments){	
									foreach(ProductAttachmentLabel cal in productAttachmentLabel){
										if(cal.id==attach.fileLabel){
											if(cal.description.Equals("img small")){%>	
												<img src="/public/upload/files/products/<%=attach.filePath+attach.fileName%>" alt="<%=rel.name%>" width="100" height="100" />
												<%hasNotSmallImg = false;
												break;
											}
										}
									}	
								}		
								if(hasNotSmallImg) {%>
									<img width="100" height="100" src="/common/img/spacer.gif" hspace="0" vspace="0" border="0">
								<%}
							}else{%>
								<img width="100" height="100" src="/common/img/spacer.gif" hspace="0" vspace="0" border="0">
							<%}%>
							</div>
							<div id="prodotto-testo">
							<p><%=rel.name%></p>
							<strong><%=lang.getTranslated("backend.prodotti.detail.table.label.cod_rel_prod")%>:</strong>&nbsp;<%=rel.keyword%>
							</div>
							<%prcounter++;
						}
					}%>
					</div>
					<div id="clear"></div>

					<div align="center" style="width:417px; overflow:auto; height:200px">
					  <input type="hidden" value="" name="list_prod_relations">
					  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table-rel-prod">
					  <tr>
					  <th><span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.list_prod_rel")%></span></th>
					  </tr>
					  <tr><td>
						<%
						if(hasRelations) {
							string desc_cat = "";
							IList<int> excludedProd = new List<int>();
							if(categories != null && categories.Count>0){%>
								<ul style="list-style-type: none;">
								<%foreach(Category c in categories){
									bool categorySeen = false;	
									int offset = c.getLevel() >1 ? c.getLevel()*8 : 0;
									foreach(Product p in productRelations){								
										if(p.id != product.id){
											if(p.categories != null && p.categories.Count>0){
												bool catMatch = false;
												foreach(ProductCategory pc in p.categories){
													if(c.id==pc.idCategory){
														catMatch = true;
														break;
													}
												}
												
												if(catMatch && !excludedProd.Contains(p.id)){
													string ischecked = "";
													if(product.relations != null && product.relations.Count>0){
														foreach(ProductRelation prt in product.relations){
															if(prt.idProductRel==p.id){
																ischecked = "checked='checked'";
																break;
															}
														}
													}%>
													<%if(!categorySeen){Response.Write("<li style='padding-left:"+offset+"px'><strong>"+c.description+"</strong></li>");categorySeen=true;}%>
													<li style="padding-left:<%=offset%>px"><input type="checkbox" value="<%=p.id%>" name="id_prod_rel" <%=ischecked%>>&nbsp;<%=p.name%>&nbsp;(<%=p.keyword%>)</li>
												<%excludedProd.Add(p.id);
												}
											}
										}
									}
								}%>
								</ul>
							<%}
						}%>
						</td></tr>
						  </table>
						</div><br/>
					  </div>
					<br/><br/>
						
					 
					<CommonGeolocalization:insert runat="server" elemType="2" ID="gl1" />
					
					<div style="float:left;"> 
						<!-- ******** RENDER CATEGORY BOX AND LANGUAGE BOX ************ -->
						<%=CategoryService.renderCategoryBox(lang.getTranslated("backend.utenti.detail.table.label.categories"), categories, lang.currentLangCode, lang.defaultLangCode, login.userLogged, "product_categories", true, productcategories)%>
						<br><br>
						<input type="hidden" value="" name="product_languages">	
						<%=LanguageService.renderLanguageBox("listLanguages", "langbox_sx", "langbox_dx", lang.getTranslated("backend.prodotti.detail.table.label.language_x_prodotti"), lang.getTranslated("backend.contenuti.detail.table.label.language_disp"), productlanguages, languages, true, true, lang.currentLangCode, lang.defaultLangCode, login.userLogged)%>					
						<br/>
					</div>
					
					<div style="float:left; width:400px;padding-left:90px;">
							<div style="float:top;padding-right:40px;padding-top:5px;">
						  	<!-- ********************************** CAMPI PER DATA PUBBLICAZIONE ************************* -->
							<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.data_pub")%></span><br>
							<input type="text" class="formFieldTXTMedium2" id="publish_date" name="publish_date" value="<%=product.publishDate.ToString("dd/MM/yyyy HH.mm")%>">
							</div>
							<script>						
							$(function() {
								$('#publish_date').datetimepicker({
									format:'d/m/Y H.i',
									closeOnDateSelect:true
								});	
								//$('#ui-datepicker-div').hide();				
							});
							</script>	
							
							<div style="float:top;padding-top:10px;">	  
							<!-- ********************************** CAMPI PER DATA CANCELLAZIONE ************************* -->
							<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.data_del")%></span><br>
							<input type="text" class="formFieldTXTMedium2" id="delete_date" name="delete_date" value="<%=product.deleteDate.ToString("dd/MM/yyyy HH.mm")%>">
							</div>
							<script>						
							$(function() {
								$('#delete_date').datetimepicker({
									format:'d/m/Y H.i',
									closeOnDateSelect:true
								});		
								//$('#ui-datepicker-div').hide();			
							});
							</script> 
						
						<br><br>
						<div style="float:top;"><span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.table.label.stato_prodotto")%></span><br>
						<select name="status" class="formFieldTXT">
						<option value="0" <%if (product.status == 0) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.lista.label.status_inactive")%></option>
						<option value="1" <%if (product.status == 1) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.lista.label.status_active")%></option>
						</select>&nbsp;&nbsp;
						</div>
						
						<div style="padding-top:5px; ">
						<span class="labelForm"><%=lang.getTranslated("backend.prodotti.detail.button.label.preview_prodotti")%></span><br>
						<%if(product.id != -1) {%>
							<select name="choose_preview_cat" id="choose_preview_cat" class="formFieldTXT" onChange="changeTemplatePreviewProductGer(this.value);">
							<option value=""></option>		
							</select>	
							<a href="javascript:previewProduct('<%=product.id%>')"><%=lang.getTranslated("backend.prodotti.detail.button.label.preview_prodotti")%></a>
							<br>
							<script>
							var tmpKey;
							var tmpValue;
							var orderedPreview = new Hashtable();
							var arrKeys = listPreviewGerProduct.keys();
							for(var z=0; z<arrKeys.length; z++){
								tmpKey = arrKeys[z];
								tmpValue = listPreviewGerProduct.get(tmpKey);
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
						</div><br><br>	
	
						<%if(product.id != -1) {%>
							<br><br>
							<span class="labelForm"><%=lang.getTranslated("backend.news.view.table.label.comments")%></span><br>
							<%if(hasComments) {%>
								<a href="javascript:previewComments();" title="<%=lang.getTranslated("backend.news.view.table.label.comments")%>"><img src="/common/img/comment_add.png" hspace="0" vspace="0" border="0"></a>
								<div id="commentsWrapper" style="position:relative;">
									<div id="commentsContainer" style="z-index:10000;position:absolute;top:-275px;left:-520px;width:500px;height:400px;border:1px solid #000;padding:5px;display:none; overflow:auto; background-color:#FFFFFF;"></div>
								</div>
							<%}else{
								Response.Write("<div align='left'>"+lang.getTranslated("backend.news.detail.table.label.no_comments")+"</div>");
							}%><br/>
						<%}%>
				  	</div>					
					</form>
				</td>
			</tr>
			</table>
			<div id="loading" style="visibility:hidden;display:none;padding-top:10px;" align="center"><img src="/backoffice/img/loading.gif" vspace="0" hspace="0" border="0" alt="Loading..." width="200" height="50"></div>
			<br/>
			<div style="display:none;" class="loading_autosave_prod">
				<img src="/common/img/loading_icon3.gif" alt="" width="16" height="16" hspace="2" vspace="0" border="0" align="left">
			</div>
			<input type="button" class="buttonForm" id="ins_esc_but" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.inserisci_esci.label")%>" onclick="javascript:sendForm(1);" />&nbsp;&nbsp;<input type="button" class="buttonForm" id="ins_but" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.inserisci.label")%>" onclick="javascript:sendForm(0);" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%="/backoffice/products/productlist.aspx?cssClass=LP"%>';" />
			<br/><br/>
			
			<%if(product.id != -1) {%>		
				<form action="/backoffice/products/insertproduct.aspx" method="post" name="form_cancella_news">
				<input type="hidden" value="<%=product.id%>" name="id">
				<input type="hidden" value="delete" name="operation">
				<input type="button" class="buttonForm" id="del_but" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.elimina.label")%>" onclick="javascript:confirmDelete();" />
				</form>
			<%}%>	
			
			<form action="/backoffice/products/insertproduct.aspx" method="get" name="form_reload_page">
			<input type="hidden" name="id" value="<%=product.id%>">
			</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>