<%@Language=VBScript codepage=65001 %>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/CommentsClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<%
Dim objFilePerProd
Set objFilePerProd = new File4ProductsClass
Set objListFileLabel = objFilePerProd.getListaFileLabel()
Set objFilePerProd = nothing
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include file="include/init3.asp" -->
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<SCRIPT SRC="<%=Application("baseroot") & "/common/js/hashtable.js"%>"></SCRIPT>
<script language="JavaScript">
var field_value_qta = new Hashtable();

var curr_qta_val;

<%
if(hasProdFields) then		
	jsListValuesMatch = ""
	jsRenderProductField = ""
	jsCleanProductFieldQta = ""
	jsInitMapProductFieldQta = ""
	jsCheckChangeProductFieldQta = ""
	
	for each k in objListProdField
		Set objField = objListProdField(k)
		labelForm = objField.getDescription()
		if not(langEditor.getTranslated("backend.prodotti.detail.table.label."&objField.getDescription())="") then labelForm = langEditor.getTranslated("backend.prodotti.detail.table.label."&objField.getDescription())
		jsRenderProductField = jsRenderProductField & objProdField.renderProductFieldJS(objField,"form_inserisci","",langEditor,"",2)
		
		if not(numQta = Application("unlimited_key")) then

			select Case objField.getTypeField()
			Case 3,4,5,6
				On Error Resume next
				hasListValues = false
				
				Set objListValues = objProdField.getListProductFieldValues(k)
				if(objListValues.Count > 0)then
					hasListValues = true
				end if
			
				if(Err.number<>0) then
					'response.write(Err.description)
					hasListValues = false
				end if
				
				if(hasListValues)then
					On Error Resume next
					hasListValuesMatch = false
					Set objListFieldValMatch = objProdField.findListFieldValueMatch(objField.getID(), id_prod)
					if(objListFieldValMatch.Count > 0)then
						hasListValuesMatch = true
					end if
					
					if(Err.number<>0) then
						'response.write(Err.description)
						hasListValuesMatch = false
					end if								
					
					for each g in objListValues
						fieldValueMatch = ""
						if(hasListValuesMatch)then
							fieldValueMatch = objListFieldValMatch(g)
						end if									
						
						jsListValuesMatch = jsListValuesMatch & "js_list_values_match+='"&objField.getID()&"|"&id_prod&"|"&g&"|'+document.form_inserisci.qta_field_value_"&objField.getID()&"_"&g&".value+'##';"
						
						jsCleanProductFieldQta = jsCleanProductFieldQta & "document.form_inserisci.qta_field_value_"&objField.getID()&"_"&g&".value=0;"
						
						jsInitMapProductFieldQta = jsInitMapProductFieldQta & "field_value_qta.put('qta_field_value_"&objField.getID()&"_"&g&"','');"
												
					next
					Set objListFieldValMatch = nothing		
					
					Set objListValues = nothing
				end if
			Case else
			end select
			
		end if
		
		Set objField = nothing
	next

	if(jsListValuesMatch <> "")then
		jsListValuesMatch = jsListValuesMatch & "if(js_list_values_match.charAt(js_list_values_match.length -1) == ""#""){"
		jsListValuesMatch = jsListValuesMatch & "js_list_values_match = js_list_values_match.substring(0, js_list_values_match.length -2);"
		jsListValuesMatch = jsListValuesMatch & "}"
	end if	
		
	if(jsCleanProductFieldQta <> "")then
		confirmResetValues = 	"if(confirm('"&langEditor.getTranslated("backend.prodotti.detail.js.alert.confirm_reset_qta_fields_value")&"')){"		
		jsCleanProductFieldQta = confirmResetValues & jsCleanProductFieldQta
		jsCleanProductFieldQta = jsCleanProductFieldQta & "$('.img_field_value').hide();" & "}"
		jsCleanProductFieldQta = jsCleanProductFieldQta & "else{document.form_inserisci.qta_prod.value = curr_qta_val;}"
	end if	
		
	if(jsInitMapProductFieldQta <> "")then
		response.write(jsInitMapProductFieldQta)
	end if
end if
%>


	
function sendForm(saveEsc, activatefield){
	if(controllaCampiInput(activatefield)){

		<%if(Application("use_aspupload_lib") = 1) then%>
			document.form_inserisci.action="<%=Application("baseroot") & "/editor/prodotti/Processprodotto2.asp"%>";
		<%end if%>

		document.form_inserisci.save_esc.value = saveEsc;
		document.getElementById("loading").style.visibility = "visible";
		document.getElementById("loading").style.display = "block";
		document.form_inserisci.submit();
	}else{
		return;
	}
}

function confirmDelete(){
	if(confirm('<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.confirm_del_prod")%>')){
		document.form_cancella_prod.submit();
	}
}

function move(fbox, tbox){
	var arrFbox = new Array();
	var arrTbox = new Array();
	var arrLookup = new Array();
	var i;
	
	for(i = 0; i < tbox.options.length; i++){
		arrLookup[tbox.options[i].text] = tbox.options[i].value;
		arrTbox[i] = tbox.options[i].text;
	}
	
	var fLength = 0;
	var tLength = arrTbox.length;
	
	for(i = 0; i < fbox.options.length; i++){
		arrLookup[fbox.options[i].text] = fbox.options[i].value;
		if(fbox.options[i].selected && fbox.options[i].value != ""){
			arrTbox[tLength] = fbox.options[i].text;
			tLength++;
		}else{
			arrFbox[fLength] = fbox.options[i].text;
			fLength++;
		}
	}
	
	arrFbox.sort();
	arrTbox.sort();
	fbox.length = 0;
	tbox.length = 0;
	var c;
	
	for(c = 0; c < arrFbox.length; c++){
		var no = new Option();
		no.value = arrLookup[arrFbox[c]];
		no.text = arrFbox[c];
		fbox[c] = no;
	}
	
	for(c = 0; c < arrTbox.length; c++){
		var no = new Option();
		no.value = arrLookup[arrTbox[c]];
		no.text = arrTbox[c];
		tbox[c] = no;
	}
}

function controllaCampiInput(activatefield){	
	if (listTargetLang=="") {
		alert("<%=langEditor.getTranslated("backend.contenuti.detail.js.alert.insert_target")%>");
		return false;
	}	
	
	//valorizzo il campo nascosto "ListTarget" con la lista dei Target della news separati da "|"
	var strTargets = "";
	strTargets+=listTargetCat
	strTargets+=listTargetLang
	if(strTargets.charAt(strTargets.length -1) == "|"){
		strTargets = strTargets.substring(0, strTargets.length -1);
	}
	
	document.form_inserisci.ListTarget.value = strTargets;
	//alert(document.form_inserisci.ListTarget.value);
		
	if(document.form_inserisci.nome_prod.value == ""){
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.insert_prod_name")%>");
		document.form_inserisci.nome_prod.focus();
		return false;
	}
	
	if(document.form_inserisci.codice_prod.value == ""){
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.insert_cod_prod")%>");
		document.form_inserisci.codice_prod.focus();
		return false;
	}

	var thisPrezzoProd = document.form_inserisci.prezzo_prod.value;
	if(thisPrezzoProd == ""){
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.insert_prezzo_prod")%>");
		document.form_inserisci.prezzo_prod.focus();
		return false;
	}else if(thisPrezzoProd.indexOf('.') != -1){
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.use_only_comma")%>");
		document.form_inserisci.prezzo_prod.focus();
		return false;		
	}
	
	/*
	CONTROLLO SULLA QUANTITA' INSERITA:
	- ILLIMITATA = valore di Application("unlimited_key")
	- VALORE = valore del campo qta_prod
	*/
	if(document.form_inserisci.sel_qta_prod[0].checked == true){
		document.form_inserisci.qta_prod.value = "<%=Application("unlimited_key")%>";
	}else{
		if(document.form_inserisci.qta_prod.value == ""){
			alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.insert_qta_prod")%>");
			document.form_inserisci.qta_prod.focus();
			return false;
		}else if(isNaN(document.form_inserisci.qta_prod.value)){
			alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.isnan_value")%>");
			document.form_inserisci.qta_prod.focus();
			return false;		
		}
	}
	
	//recupero i valori dei checkbox con i file allegati
	//da eliminare
	var i;
	var strFiles = "";
	if(document.form_inserisci.existingFiles != null){
		if(document.form_inserisci.existingFiles.length == null){
			if(document.form_inserisci.existingFiles.checked){
				strFiles = strFiles + document.form_inserisci.existingFiles.value + "|";
			}
		}else{
			for(i=0; i<document.form_inserisci.existingFiles.length; i++){
				if(document.form_inserisci.existingFiles[i].checked){		
					strFiles = strFiles + document.form_inserisci.existingFiles[i].value + "|";
				}
			}
		}
	}
	if(strFiles.charAt(strFiles.length -1) == "|"){
		strFiles = strFiles.substring(0, strFiles.length -1);
	}	
	document.form_inserisci.ListFileDaEliminare.value = strFiles;

	//recupero i valori dei checkbox con i file downloadable allegati
	//da eliminare
	var j;
	var strFilesDown = "";
	if(document.form_inserisci.existingDownloadFiles != null){
		if(document.form_inserisci.existingDownloadFiles.length == null){
			if(document.form_inserisci.existingDownloadFiles.checked){
				strFilesDown = strFilesDown + document.form_inserisci.existingDownloadFiles.value + "|";
			}
		}else{
			for(j=0; j<document.form_inserisci.existingDownloadFiles.length; j++){
				if(document.form_inserisci.existingDownloadFiles[j].checked){		
					strFilesDown = strFilesDown + document.form_inserisci.existingDownloadFiles[j].value + "|";
				}
			}
		}
	}
	if(strFilesDown.charAt(strFilesDown.length -1) == "|"){
		strFilesDown = strFilesDown.substring(0, strFilesDown.length -1);
	}	
	document.form_inserisci.ListFileDownDaEliminare.value = strFilesDown;


	//var strNomeProdTmp = document.form_inserisci.nome_prod.value;
	//document.form_inserisci.nome_prod.value = replaceChars(strNomeProdTmp);
	
	//var strSommarioProdTmp = document.form_inserisci.sommario_prod.value;
	//document.form_inserisci.sommario_prod.value = replaceChars(strSommarioProdTmp);		

	//var strTestoTmp = document.form_inserisci.desc_prod.value;
	//document.form_inserisci.desc_prod.value = replaceChars(strTestoTmp);


	if(document.form_inserisci.sconto_prod.value != "") {
		var scontoTmp = document.form_inserisci.sconto_prod.value;
		if(!checkDoubleFormat(scontoTmp) || scontoTmp.indexOf(".")!=-1){
			alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.isnan_value")%>");
			document.form_inserisci.sconto_prod.value = "0";
			document.form_inserisci.sconto_prod.focus();
			return false;
		}
	}else{
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.insert_sconto_prod")%>");
		document.form_inserisci.sconto_prod.value = "0";
		document.form_inserisci.sconto_prod.focus();
		return false;		
	}
	
	$("#add_attach_table").find("input:text[name*='_dida']").each(function(){
		$(this).attr('value', replaceChars($(this).val()));
	});

	$("#modify_attach_table").find("input:text[name*='fileDaModificare_']").each(function(){
		$(this).attr('value', replaceChars($(this).val()));
	});	
	
	
	<%
	if(hasProdFields) then		
		response.write("var js_list_values_match = '';")		
		response.write(jsListValuesMatch)		
		response.write("document.form_inserisci.list_prod_fields_values.value = js_list_values_match;")	
		
		response.write(jsRenderProductField)	
	end if
	%>

	//recupero i valori dei checkbox con i field aggiuntivi da associare al prodotto
	var k;
	var strProdfields = "";
	if(document.form_inserisci.prod_field_active != null){
		if(document.form_inserisci.prod_field_active.length == null){
			if(document.form_inserisci.prod_field_active.checked){
				strProdfields = strProdfields + document.form_inserisci.prod_field_active.value + "|";
			}
		}else{
			for(k=0; k<document.form_inserisci.prod_field_active.length; k++){
				if(document.form_inserisci.prod_field_active[k].checked){		
					strProdfields = strProdfields + document.form_inserisci.prod_field_active[k].value + "|";
				}
			}
		}
	}
	if(strProdfields.charAt(strProdfields.length -1) == "|"){
		strProdfields = strProdfields.substring(0, strProdfields.length -1);
	}	
	document.form_inserisci.list_prod_fields.value = strProdfields;


	// faccio una controllo se la quantit√† associata ai sngoli field coincide con quella totale del prodotto
	if(!activatefield){
		var global_qta = $("input[name='qta_prod']").val();
		var send_form = true;
		$("table[name*='inner-table-rel-field_']").each( function(){
			var field_sum_qta = 0;
	
			var this_field_rel_id = $(this).attr("name");
			this_field_rel_id = this_field_rel_id.substring(this_field_rel_id.indexOf("inner-table-rel-field_")+22, this_field_rel_id.length);

			var prod_field_name = $('#td_prod_field_name_'+this_field_rel_id).text();	
			var td_prod_field_active = $('#td_prod_field_active_'+this_field_rel_id);
			var obj = $(td_prod_field_active).find('input:checkbox[name="prod_field_active"]:checked');
			if(obj.length == 0){return true;}

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
					alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.sum_rel_qta_not_match")%>\n- "+prod_field_name+": "+prod_field_val_name+"\n- <%=langEditor.getTranslated("backend.prodotti.detail.table.label.qta_fields")%>: "+$(this).val()+" --> "+ref_field_sum);
					send_form = false;	
					stopIteration = true;		
					return false;
				}	
			});
			if(stopIteration){return false;}
			
			if(field_sum_qta!=global_qta){
				alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.sum_qta_not_match")%>\n- "+prod_field_name+"\n- <%=langEditor.getTranslated("backend.prodotti.detail.table.label.qta_tot_prod")%>: "+global_qta+"\n- <%=langEditor.getTranslated("backend.prodotti.detail.table.label.qta_fields")%>: "+field_sum_qta);
				send_form = false;			
				return false;
			}
		});
		if(!send_form){return false;}
	}

	//TODO: ripeto il controllo sulla quantit√† per ogni riga, tra field value e somma field correlati
	



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

/*alert(document.form_inserisci.nome_prod.value);
alert(document.form_inserisci.codice_prod.value);*/

	return true;
}


function changeQtaStato(){
	if(document.form_inserisci.sel_qta_prod[0].checked == true){
		document.form_inserisci.qta_prod.value = "";
		document.form_inserisci.qta_prod.readOnly = true;
	}else{
		document.form_inserisci.qta_prod.readOnly = false;		
	}
}

function replaceChars(inString){
	var outString = inString;
	var pos= 0;

	// ricerca e escaping degli apici
	var quote= -1;
	do {
		quote= outString.indexOf('\'', pos);
		if (quote >= 0) {
			outString= outString.substring(0, quote) + "&#39;" + outString.substring(quote +1);
			pos= quote+2;
		}
	} while (quote >= 0);	
	
	// ricerca e escaping dei doppi apici
	pos= 0;
	var doublequote= -1;
	do {
		doublequote= outString.indexOf('\"', pos);
		if (doublequote >= 0) {
			outString= outString.substring(0, doublequote) + "&quot;" + outString.substring(doublequote +1);
			pos= doublequote+2;
		}
	} while (doublequote >= 0);

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
	
	//ricerca lettere accentate ËÈ‡Ú˘Ï
	//&egrave;&eacute;&agrave;&ograve;&ugrave;&igrave;
	pos= 0;
	var letter= -1;
	do {
		letter= outString.indexOf('Ë', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&egrave;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	letter= -1;
	do {
		letter= outString.indexOf('È', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&eacute;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	letter= -1;
	do {
		letter= outString.indexOf('‡', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&agrave;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	letter= -1;
	do {
		letter= outString.indexOf('Ú', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&ograve;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	letter= -1;
	do {
		letter= outString.indexOf('˘', pos);
		if (letter >= 0) {
			outString= outString.substring(0, letter) + "&ugrave;" + outString.substring(letter +1);
			pos= letter+2;
		}
	} while (letter >= 0);
	letter= -1;
	do {
		letter= outString.indexOf('Ï', pos);
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


function changeNumMaxImgs(){
	if(document.form_inserisci.numMaxImgs.value == ""){
		alert("<%=langEditor.getTranslated("backend.templates.detail.js.alert.insert_value")%>");
		document.form_inserisci.numMaxImgs.focus();
		return;
	}else if(isNaN(document.form_inserisci.numMaxImgs.value)){
		alert("<%=langEditor.getTranslated("backend.templates.detail.js.alert.isnan_value")%>");
		document.form_inserisci.numMaxImgs.focus();
		return;		
	}
	//location.href = "<%=Application("baseroot") & "/editor/prodotti/InserisciProdotto.asp?id_prodotto="&id_prod&"&numMaxImgs="%>"+document.form_inserisci.numMaxImgs.value+"&numMaxProds=<%=numMaxProds%>"+"&prod_type="+document.form_inserisci.prod_type.value;
	renderNumImgsAttachTable(document.form_inserisci.numMaxImgs.value);
}

function changeNumMaxProds(){
	if(document.form_inserisci.numMaxProds.value == ""){
		alert("<%=langEditor.getTranslated("backend.templates.detail.js.alert.insert_value")%>");
		document.form_inserisci.numMaxProds.focus();
		return;
	}else if(isNaN(document.form_inserisci.numMaxProds.value)){
		alert("<%=langEditor.getTranslated("backend.templates.detail.js.alert.isnan_value")%>");
		document.form_inserisci.numMaxProds.focus();
		return;		
	}
	//location.href = "<%=Application("baseroot") & "/editor/prodotti/InserisciProdotto.asp?id_prodotto="&id_prod&"&numMaxProds="%>"+document.form_inserisci.numMaxProds.value+"&numMaxImgs=<%=numMaxImgs%>"+"&prod_type=1";
	renderNumDownAttachTable(document.form_inserisci.numMaxProds.value);
}

function renderNumImgsAttachTable(counter){
	$(".imgs_attach_table_rows").remove();
	
	var render ="";
	
	for(var i=1;i<=counter;i++){
		render=render+'<tr class="imgs_attach_table_rows">';
			render=render+'<td><input type="file" name="fileupload'+i+'" class="formFieldTXT"></td>';
			render=render+'<td>';
			render=render+'<select name="fileupload'+i+'_label" class="formFieldSelectTypeFile">';
			<%for each xType in objListFileLabel%>
			<%="render=render+'<option value="""&xType&""">"&objListFileLabel(xType)&"</option>';"%>
			<%next%>
			render=render+'</select>';
			render=render+'</td>';
			render=render+'<td><input type="text" name="fileupload'+i+'_dida" class="formFieldTXT"></td>';
			render=render+'<td>';
			if(i==1){
			render=render+'<input type="text" value="'+counter+'" name="numMaxImgs" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);"><a href="javascript:changeNumMaxImgs();"><img src=<%=Application("baseroot")&"/common/img/refresh.gif"%> vspace="0" hspace="4" border="0" align="top" alt="<%=langEditor.getTranslated("backend.commons.detail.table.label.change_num_imgs")%>"></a>';
			}
			render=render+'</td>';
		render=render+'</tr>';
	}

	$("#imgs_add_attach_table").append(render);

}

function renderNumDownAttachTable(counter){
	$(".down_attach_table_rows").remove();
	
	var render ="";

	for(var i=1;i<=counter;i++){
		render=render+'<tr class="down_attach_table_rows">';
			render=render+'<td><input type="file" name="prodfileupload'+i+'" class="formFieldTXT">&nbsp;&nbsp;</td>';
			render=render+'<td>';
			if(i==1){
			render=render+'<input type="text" value="'+counter+'" name="numMaxProds" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);"><a href="javascript:changeNumMaxProds();"><img src=<%=Application("baseroot")&"/common/img/refresh.gif"%> vspace="0" hspace="4" border="0" align="top" alt="<%=langEditor.getTranslated("backend.commons.detail.table.label.change_num_prods")%>"></a>';
			}
			render=render+'</td>';
		render=render+'</tr>';
	}

	$("#down_add_attach_table").append(render);

}

function showHide(){
	if(document.form_inserisci.prod_type.options[document.form_inserisci.prod_type.selectedIndex].value == 0 || document.form_inserisci.prod_type.options[document.form_inserisci.prod_type.selectedIndex].value == 2){
		var element = document.getElementById("div_downloadable_field");
		element.style.visibility = 'hidden';
		element.style.display = "none";
	}else if(document.form_inserisci.prod_type.options[document.form_inserisci.prod_type.selectedIndex].value == 1){
		var element = document.getElementById("div_downloadable_field");
		element.style.visibility = 'visible';	
		element.style.display = "block";
	}
}

function showHideDivArrow(elemDiv,elemArrow){
	var elementDiv = document.getElementById(elemDiv);
	var elementArrow = document.getElementById(elemArrow);
	if(elementDiv.style.visibility == 'visible'){
		elementArrow.src='<%=Application("baseroot")&"/editor/img/div_freccia.gif"%>';
	}else if(elementDiv.style.visibility == 'hidden'){
		elementArrow.src='<%=Application("baseroot")&"/editor/img/div_freccia2.gif"%>';
	}
}

function reloadNumQtaType(qtaType) {
   /*$.ajax({
      type: "POST",
      async: false,
      url: "<%=Application("baseroot") & "/editor/prodotti/InserisciProdotto.asp?id_prodotto="&id_prod&"&numMaxImgs="%>"+document.form_inserisci.numMaxImgs.value+"&numMaxProds="+document.form_inserisci.numMaxProds.value+"&prod_type="+document.form_inserisci.prod_type.value+"&change_num_qta="+qtaType,
      success: function(response){
        $('html').html(response);
      }
   });*/
  

   location.href = "<%=Application("baseroot") & "/editor/prodotti/InserisciProdotto.asp?id_prodotto="&id_prod&"&numMaxImgs="%>"+document.form_inserisci.numMaxImgs.value+"&numMaxProds="+document.form_inserisci.numMaxProds.value+"&prod_type="+document.form_inserisci.prod_type.value+"&change_num_qta="+qtaType;
}

function setCurrQtaVal(currQtaVal){
	curr_qta_val = currQtaVal;
}

function cleanFieldValuesQta(){
	<%=jsCleanProductFieldQta%>
}

function checkQtaFieldValue(id, field){
	<%if(jsInitMapProductFieldQta <> "")then%>
	var max_qta = document.form_inserisci.qta_prod.value;
	var total_qta=0;
	var len_idof=id.length+1;
	total_qta+=Number(field.value);	
	var arrKeys = field_value_qta.keys();	
	
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];		
		if(tmpKey.indexOf(field.name.substring(0, field.name.indexOf('_'+id)+len_idof)) != -1){
			if(tmpKey != field.name){
				tmpValue = document.getElementById(tmpKey);
				total_qta+=Number(tmpValue.value);
			}			
		}
	}
	
	if(total_qta>max_qta){
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.wrong_max_qta_value")%>");
		field.value=0;
		return;
	}

	var idf = '#img'+field.name.substring(3,field.name.length);

	if(Number(field.value)>0){
		$(idf).show();
	}else if(Number(field.value)==0){
		$(idf).hide();	
	}
	<%end if%>
}


function sendAjaxTransCommand(id_objref, main_field , lang_code, value, use_def, operation){
	var resp = "";

	if(operation=="find"){
		var query_string = "main_field="+main_field+"&lang_code="+lang_code+"&use_def="+use_def+"&id_objref="+id_objref+"&optype="+operation;
		
		$.ajax({
			async: false,
			type: "GET",
			cache: false,
			url: "<%=Application("baseroot") & "/editor/prodotti/ajaxprodtransupdate.asp"%>",
			data: query_string,
			success: function(response) {
				resp = response;
			},
			error: function() {
				$("#ajaxresp").empty();
				$("#ajaxresp").append("<%=langEditor.getTranslated("backend.commons.fail_updated_field")%>");
				$("#ajaxresp").fadeIn(1500,"linear");
				$("#ajaxresp").fadeOut(600,"linear");
				resp = "";
			}
		});
	}else if(operation=="write"){
		var query_string = "main_field="+main_field+"&lang_code="+lang_code+"&use_def="+use_def+"&id_objref="+id_objref+"&optype="+operation+"&field_val="+encodeURIComponent(value);
		//alert("query_string: "+query_string);
	
		$.ajax({
			async: false,
			type: "GET",
			cache: false,
			url: "<%=Application("baseroot") & "/editor/prodotti/ajaxprodtransupdate.asp"%>",
			data: query_string,
			success: function(response) {
				/*$("#ajaxresp").empty();
				$("#ajaxresp").append("<%=langEditor.getTranslated("backend.commons.ok_updated_field")%>");
				$("#ajaxresp").fadeIn(1500,"linear");
				$("#ajaxresp").fadeOut(600,"linear");*/
			},
			error: function() {
				$("#ajaxresp").empty();
				$("#ajaxresp").append("<%=langEditor.getTranslated("backend.commons.fail_updated_field")%>");
				$("#ajaxresp").fadeIn(1500,"linear");
				$("#ajaxresp").fadeOut(600,"linear");
			}
		});		
	}

	return resp;
}

function showHideTransField(fieldHide, fieldShow, field, id_objref, main_field , lang_code){
	resp = sendAjaxTransCommand(id_objref, main_field , lang_code, "", 0, "find");
	$('#'+field).val(resp);
	$("#"+fieldHide).hide();
	$("#"+fieldShow).show();
	$("#"+field).attr("lang",lang_code);
	$("#"+field).focus();
}

function saveFieldTranslation(fieldHide, fieldShow, field, id_objref, main_field){
	sendAjaxTransCommand(id_objref, main_field , $("#"+field).attr("lang"), $("#"+field).val(), 0, "write");
	$("#"+fieldHide).hide();
	$("#"+fieldShow).show();	
}

function showHideTransFieldFCK(id_objref, main_field, lang_code){
	var query_string = "main_field="+main_field+"&lang_code="+lang_code+"&id_objref="+id_objref+"&optype=show";	
	openWin('<%=Application("baseroot")&"/editor/prodotti/fckprodtransupdate.asp?"%>'+query_string,'fckprodtransupdate',600,360,100,100);
}

function activateFieldProd(idProdField){
	if(confirm('<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.activate_field")%>')){
		sendForm(0,true);
	}else{
		if($('#'+idProdField+':checked').val() == undefined){
			document.getElementById(idProdField).checked=true;
		}else{	
			document.getElementById(idProdField).checked=false;
		}	
	}
}

function showAllProdField(){
	var ischecked;
	
	if($('#activate_all_prod_field:checked').val() == undefined){
		$('#inner-table-prod-field-list tbody tr').each( function(){
			var objParent = $(this).find('input:checkbox[name="prod_field_active"]');
			var obj = $(this).find('input:checkbox[name="prod_field_active"]:checked');
			//alert(objParent.length);
			if(objParent.length > 0){
				//alert(obj.length);
				if(obj.length == 0){
					$(this).hide();
				}
			}
		});	
	}else{
		$('#inner-table-prod-field-list tbody tr').each( function(){		
			$(this).show();
		});	
	}
}

function checkRelatedFieldProd(relQta){
	
}

function updateRelatedFieldProd(relField, relQta, resultContainer){
	var objRelF, objRelQ;
	var idProd, idField, fieldVal, idRelField, fieldRelVal; 

	objRelQ=$('#'+relQta).val();
	if(Number(objRelQ)<=0){
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.insert_qta_prod")%>");
		return;
	}

	objRelF=$('#'+relField).val();
	if(objRelF==null || objRelF==undefined){
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.field_not_changed")%>");
		return;
	}

	var arrFieldList = objRelF.split("|");
	idProd=arrFieldList[0];
	idRelField=arrFieldList[1];
	fieldRelVal=arrFieldList[2];
	idField=arrFieldList[3];
	fieldVal=arrFieldList[4];
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
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.field_max_exceded")%>: "+maxVal);
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
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.field_relation_exist")%>");
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
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.field_max_exceded")%>: "+maxVal);
		return;
	}
	
	var query_string = "id_prod="+idProd+"&id_field="+idField+"&field_val="+fieldVal+"&id_field_rel="+idRelField+"&field_rel_val="+fieldRelVal+"&qta_rel="+objRelQ+"&optype=update";
	//alert(query_string);
	
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "<%=Application("baseroot") & "/editor/prodotti/ajaxrelprodfieldupdate.asp"%>",
		data: query_string,
		success: function(response) {
			$("#"+resultContainer).empty();
			$("#"+resultContainer).html(response);
		},
		error: function() {
			alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.field_not_changed")%>");
		}
	});	
}

function deleteRelatedFieldProd(idProd, idField, fieldVal, idRelField, fieldRelVal, resultContainer){
	
	var query_string = "id_prod="+idProd+"&id_field="+idField+"&field_val="+fieldVal+"&id_field_rel="+idRelField+"&field_rel_val="+fieldRelVal+"&qta_rel=&optype=delete";
	//alert(query_string);
	
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "<%=Application("baseroot") & "/editor/prodotti/ajaxrelprodfieldupdate.asp"%>",
		data: query_string,
		success: function(response) {
			$("#"+resultContainer).empty();
			$("#"+resultContainer).html(response);
		},
		error: function() {
			alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.field_not_changed")%>");
		}
	});	
}
</script>
</head>
<body>
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<%cssClass="IP"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<!-- #include virtual="/fckeditor/fckeditor.asp" -->
		<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
		<%
		Dim objTmpLang, arrLangCodes
		Set objTmpLang = New LanguageClass
		On Error Resume Next	
		arrLangCodes = objTmpLang.getListaLanguageByDesc().Keys
		if(Err.number<>0)then
		end if		
		%>
		<table border="0" cellspacing="0" cellpadding="0" class="principal">
		<tr> 		  		  
			<td>
			<form action="<%=Application("baseroot") & "/editor/prodotti/ProcessProdotto.asp"%>" method="post" name="form_inserisci" enctype="multipart/form-data" accept-charset="UTF-8">
			<input type="hidden" value="<%=id_prod%>" name="id_prodotto">
			<input type="hidden" value="1" name="save_esc">
			<input type="hidden" value="<%="http://" & request.ServerVariables("SERVER_NAME") %>" name="srv_name">
			<span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.cod_prod")%></span><br/>
			<input type="text" name="codice_prod" value="<%=Server.HTMLEncode(strCodProd)%>" class="formFieldTXT" /><br/><br/>
			<span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.nome_prod")%></span><br/>
			<div id="base_prod_name"><textarea name="nome_prod" class="formFieldTXTAREAAbstract"><%=Server.HTMLEncode(strNomeProd)%></textarea></div>
			<%
			if (CInt(id_prod) <> -1) then%>			
				<div id="trans_prod_name"><textarea id="nome_prod_trans" class="formFieldTXTAREAAbstract"></textarea></div>
				<script>
				$("#trans_prod_name").hide();
				
				$("#nome_prod_trans").blur(function() {
					saveFieldTranslation('trans_prod_name','base_prod_name','nome_prod_trans', <%=id_prod%>, 1);
				});				
				</script>
				<%
			end if
			%>
			<div><%
			if (CInt(id_prod) <> -1) then
				On Error Resume Next	
				for each z in arrLangCodes%>			
				<a href="javascript:showHideTransField('base_prod_name', 'trans_prod_name', 'nome_prod_trans', <%=id_prod%>, 1 , '<%=z%>');"><img src="<%=Application("baseroot")&"/editor/img/flag/flag-"&z&".png"%>" alt="<%=z%>" width="16" height="11" border="0" /></a>
				<%next
				if(Err.number<>0)then
				end if
			end if
			%>
			</div><br/>
			<div align="left" style="float:left;padding-right: 5px;">				
				<span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.page_title")%></span><br/>
				<input type="text" name="page_title" value="<%if(Trim(page_title)<>"")then response.write(Server.HTMLEncode(Trim(page_title))) end if%>" class="formFieldTXT">
			  </div>
			  <div align="left" style="float:left;padding-right: 5px;">
			  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.meta_description")%></span><br/>
				<input type="text" name="meta_description" value="<%if(Trim(meta_description)<>"")then response.write(Server.HTMLEncode(Trim(meta_description))) end if%>" class="formFieldTXT">
			  </div>
			 <div align="left" style="padding-bottom:20px;">
			 <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.meta_keyword")%></span><br/>
				<input type="text" name="meta_keyword" value="<%if(Trim(meta_keyword)<>"")then response.write(Server.HTMLEncode(Trim(meta_keyword))) end if%>" class="formFieldTXT">
			</div>
			<br/>
			<%
			Dim oFCKeditor
			Set oFCKeditor = New FCKeditor
			'''oFCKeditor.Width = 200
			oFCKeditor.Height = 200
			oFCKeditor.BasePath = "/fckeditor/"
			%>

			<div class="divDetailHeader" onClick="javascript:showHideDiv('divSummary');showHideDivArrow('divSummary','arrowSummary');"><img src="<%if not(strSommarioProd = "")then response.Write(Application("baseroot")&"/editor/img/div_freccia.gif") else response.Write(Application("baseroot")&"/editor/img/div_freccia2.gif") end if%>" vspace="0" hspace="0" border="0" align="right" id="arrowSummary"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.sommario_prod")%></div>
			<div id="divSummary" <%if not(strSommarioProd = "")then response.Write("style=""visibility:visible;display:block;""") else response.Write("style=""visibility:hidden;display:none;""") end if%> align="left">
				<div id="base_prod_summary"><%
				oFCKeditor.Value = strSommarioProd
				oFCKeditor.Create "sommario_prod"
				%>
				</div>
				<%if (CInt(id_prod) <> -1) then%>
					<div><%
						On Error Resume Next	
						for each z in arrLangCodes%>			
						<a href="javascript:showHideTransFieldFCK(<%=id_prod%>, 2 , '<%=z%>');"><img src="<%=Application("baseroot")&"/editor/img/flag/flag-"&z&".png"%>" alt="<%=z%>" width="16" height="11" border="0" /></a>
						<%next
						if(Err.number<>0)then
						end if
					%>
					</div>
				<%end if%>
			</div><br/>
			
			<div class="divDetailHeader" onClick="javascript:showHideDiv('divText');showHideDivArrow('divText','arrowText');"><img src="<%if not(strDescProd = "")then response.Write(Application("baseroot")&"/editor/img/div_freccia.gif") else response.Write(Application("baseroot")&"/editor/img/div_freccia2.gif") end if%>" vspace="0" hspace="0" border="0" align="right" id="arrowText"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.desc_prod")%></div>
			<div id="divText" <%if not(strDescProd = "")then response.Write("style=""visibility:visible;display:block;""") else response.Write("style=""visibility:hidden;display:none;""") end if%> align="left">
			<div id="base_prod_desc"><%
			oFCKeditor.Height = 400
			oFCKeditor.Value = strDescProd
			oFCKeditor.Create "desc_prod"
			%>
			</div>
			<%if (CInt(id_prod) <> -1) then%>
				<div><%
					On Error Resume Next	
					for each z in arrLangCodes%>			
					<a href="javascript:showHideTransFieldFCK(<%=id_prod%>, 3 , '<%=z%>');"><img src="<%=Application("baseroot")&"/editor/img/flag/flag-"&z&".png"%>" alt="<%=z%>" width="16" height="11" border="0" /></a>
					<%next
					if(Err.number<>0)then
					end if
				%>
				</div>
			<%end if%>		
			</div><br/>

			<%
			'***** inizializzo gli elementi per la googlemap
			strID=id_prod
			strType=2
					
			if(Cint(strID)=-1)then
				Set objGUID = new GUIDClass
				strID=objGUID.CreateNumberGUIDRandomVarLenght(7)*(-1)
				Set objGUID = nothing%>
				<input type="hidden" value="<%=strID%>" name="pregeoloc_el_id">
			<%end if%>
			<!-- #include virtual="/editor/include/localization_widget.asp" -->


			<input type="hidden" value="" name="ListTarget"> 
			<%
			Set objT = New TargetClass
			response.write(objT.renderTargetBox("listTargetCat", "targetcatbox_sx","targetcatbox_dx",langEditor.getTranslated("backend.prodotti.detail.table.label.target_x_prodotti_prod"), langEditor.getTranslated("backend.prodotti.detail.table.label.target_disp_prodotti"), "2", objTarget, objListaTargetPerUser, false, false, langEditor))
			Set objT = Nothing
			%>
			<br/><br/>						
			<%
			Set objT = New TargetClass
			response.write(objT.renderTargetBox("listTargetLang", "targetlangbox_sx","targetlangbox_dx",langEditor.getTranslated("backend.prodotti.detail.table.label.target_x_prodotti_lang"), langEditor.getTranslated("backend.prodotti.detail.table.label.target_disp_lang"), "3", objTarget, objListaTargetPerUser, false, false, langEditor))
			Set objT = Nothing
			%>				

			<br/>
			<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divAttachments');showHideDivArrow('divAttachments','arrowAttach');"><img src="<%if (Instr(1, typename(objFilesProd), "Dictionary", 1) > 0)then response.Write(Application("baseroot")&"/editor/img/div_freccia.gif") else response.Write(Application("baseroot")&"/editor/img/div_freccia2.gif") end if%>" vspace="0" hspace="0" border="0" align="right" id="arrowAttach"><%=langEditor.getTranslated("backend.prodotti.view.table.label.attached_files")%></div>
			<div id="divAttachments" <%if (Instr(1, typename(objFilesProd), "Dictionary", 1) > 0) then response.Write("style=""visibility:visible;display:block;""") else response.Write("style=""visibility:hidden;display:none;""") end if%> align="left">
			<table border="0" cellspacing="0" cellpadding="0" class="principal" id="imgs_add_attach_table">
			  <tr>
				<td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.attachment")%></span></td>
				<td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.file_type_label")%></span></td>
				<td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.file_dida")%></span></td>
				<td><span class="labelForm"><%=langEditor.getTranslated("backend.commons.detail.table.label.change_num_imgs")%></span></td>
			  </tr>
			  <%
			  Dim fileCounter
			  for fileCounter=1 to numMaxImg%>
			  <tr class="imgs_attach_table_rows">
				<td><input type="file" name="fileupload<%=fileCounter%>" class="formFieldTXT"></td>
				<td>
				<select name="fileupload<%=fileCounter%>_label" class="formFieldSelectTypeFile">
				<%for each xType in objListFileLabel%>
				<option value="<%=xType%>"><%=objListFileLabel(xType)%></option>
				<%next%>
				</select>
				</td>
				<td><input type="text" name="fileupload<%=fileCounter%>_dida" class="formFieldTXT"></td>
				<td><%if(fileCounter=1)then%><input type="text" value="<%=numMaxImg%>" name="numMaxImgs" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);">&nbsp;<a href="javascript:changeNumMaxImgs();"><img src=<%=Application("baseroot")&"/common/img/refresh.gif"%> vspace="0" hspace="4" border="0" align="top" alt="<%=langEditor.getTranslated("backend.commons.detail.table.label.change_num_imgs")%>"></a><%end if%>&nbsp;</td>
			  </tr>
			 <%next%> 
			</table>
		  
			<%Dim listFileToModify
			listFileToModify = ""
			if not(isNull(objFilesProd)) then%>		
				<table border="0" cellspacing="0" cellpadding="0" class="principal" id="modify_attach_table">
				  <tr>
					<td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.file_to_del")%></span></td>
					<td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.file_type_label")%></span></td>
					<td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.file_dida")%></span></td>
				  </tr>
				<%Dim objFilesProdInProd
				for each z in objFilesProd.Keys
					Set objFilesProdInProd = objFilesProd(z)%>
				  <tr>
					<td><input type="checkbox" value="<%=objFilesProdInProd.getFileID()%>" name="existingFiles">&nbsp;<%=objFilesProdInProd.getFileName()%></td>
					<td>
					<select name="fileDaModificare_<%=objFilesProdInProd.getFileID()%>_label" class="formFieldSelectTypeFile">
					<%for each xType in objListFileLabel%>
					<option value="<%=xType%>" <%if(xType=objFilesProdInProd.getFileTypeLabel()) then response.write("selected") end if%>><%=objListFileLabel(xType)%></option>
					<%next%>
					</select>
					</td>
					<td><input type="text" name="fileDaModificare_<%=objFilesProdInProd.getFileID()%>" value="<%=objFilesProdInProd.getFileDida()%>" class="formFieldTXT"></td>
				  </tr>
					<%listFileToModify = listFileToModify & objFilesProdInProd.getFileID() & "|"
					Set objFilesProdInProd = nothing	
				next				
				Set objFilesProd = nothing
				listFileToModify = Mid(listFileToModify, 1, (Len(listFileToModify)-1))%>
				</table>
			<%end if%>
			<input type="hidden" value="<%=Trim(listFileToModify)%>" name="ListFileDaModificare">
			<input type="hidden" value="" name="ListFileDaEliminare">
		  </div><br/>
		  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.prod_type")%></span><br/>
		  <select name="prod_type" class="formFieldTXTSelect" onChange="javascript:showHide();">
		  <option value="0" <%if (prod_type = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.prodotti.detail.table.label.type_portable")%></option>
		  <option value="1" <%if (prod_type = 1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.prodotti.detail.table.label.type_download")%></option>
		  <option value="2" <%if (prod_type = 2) then response.Write("selected")%>><%=langEditor.getTranslated("backend.prodotti.detail.table.label.type_ads")%></option>
		  </select>

			<div id="div_downloadable_field" style="visibility:<%if(prod_type=1) then response.Write("visible") else response.Write("hidden") end if%>;display:<%if(prod_type=1) then response.Write("block") else response.Write("none") end if%>">
			<input type="hidden" value="" name="ListFileDownDaEliminare">
			<br/>
			<table border="0" cellspacing="0" cellpadding="0" class="principal" id="down_add_attach_table">
				<tr>
				<td>
				  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.max_download")%></span><br/>
				  <select name="max_download" class="formFieldTXTMedium">
				  <option value="-1" <%if (max_download = -1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.prodotti.detail.table.label.unlimited")%></option>
				  <option value="1" <%if (max_download = 1) then response.Write("selected")%>>1</option>
				  <option value="2" <%if (max_download = 2) then response.Write("selected")%>>2</option>
				  <option value="3" <%if (max_download = 3) then response.Write("selected")%>>3</option>
				  <option value="4" <%if (max_download = 4) then response.Write("selected")%>>4</option>
				  <option value="5" <%if (max_download = 5) then response.Write("selected")%>>5</option>
				  <option value="6" <%if (max_download = 6) then response.Write("selected")%>>6</option>
				  <option value="7" <%if (max_download = 7) then response.Write("selected")%>>7</option>
				  <option value="8" <%if (max_download = 8) then response.Write("selected")%>>8</option>
				  <option value="9" <%if (max_download = 9) then response.Write("selected")%>>9</option>
				  <option value="10" <%if (max_download = 10) then response.Write("selected")%>>10</option>
				  <option value="20" <%if (max_download = 20) then response.Write("selected")%>>20</option>
				  <option value="30" <%if (max_download = 30) then response.Write("selected")%>>30</option>
				  <option value="40" <%if (max_download = 40) then response.Write("selected")%>>40</option>
				  <option value="50" <%if (max_download = 50) then response.Write("selected")%>>50</option>
				  <option value="100" <%if (max_download = 100) then response.Write("selected")%>>100</option>
				  </select><br/><br/></td>
				<td>
				  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.max_download_time")%></span><br/>
				  <select name="max_download_time" class="formFieldTXTMedium">
				  <option value="-1" <%if (max_download_time = -1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.prodotti.detail.table.label.unlimited")%></option>
				  <option value="1" <%if (max_download_time = 1) then response.Write("selected")%>>1 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minute")%></option>
				  <option value="2" <%if (max_download_time = 2) then response.Write("selected")%>>2 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="3" <%if (max_download_time = 3) then response.Write("selected")%>>3 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="4" <%if (max_download_time = 4) then response.Write("selected")%>>4 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="5" <%if (max_download_time = 5) then response.Write("selected")%>>5 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="6" <%if (max_download_time = 6) then response.Write("selected")%>>6 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="7" <%if (max_download_time = 7) then response.Write("selected")%>>7 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="8" <%if (max_download_time = 8) then response.Write("selected")%>>8 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="9" <%if (max_download_time = 9) then response.Write("selected")%>>9 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="10" <%if (max_download_time = 10) then response.Write("selected")%>>10 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="30" <%if (max_download_time = 30) then response.Write("selected")%>>30 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="60" <%if (max_download_time = 60) then response.Write("selected")%>>60 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.minutes")%></option>
				  <option value="720" <%if (max_download_time = 720) then response.Write("selected")%>>12 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.hours")%></option>
				  <option value="1440" <%if (max_download_time = 1440) then response.Write("selected")%>>24 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.hours")%></option>
				  <option value="4320" <%if (max_download_time = 4320) then response.Write("selected")%>>3 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.days")%></option>
				  <option value="10080" <%if (max_download_time = 10080) then response.Write("selected")%>>7 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.days")%></option>
				  <option value="21600" <%if (max_download_time = 21600) then response.Write("selected")%>>15 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.days")%></option>
				  <option value="43200" <%if (max_download_time = 43200) then response.Write("selected")%>>30 <%=langEditor.getTranslated("backend.prodotti.detail.table.label.days")%></option>
				  </select><br/><br/></td>
				</tr>
				<tr>
				<td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.attachment")%></span></td>
				<td><span class="labelForm"><%=langEditor.getTranslated("backend.commons.detail.table.label.change_num_prods")%></span></td>
				</tr>
				<%
				for fileProdCounter=1 to numMaxProd%>
					<tr class="down_attach_table_rows">
					<td><input type="file" name="prodfileupload<%=fileProdCounter%>" class="formFieldTXT">&nbsp;&nbsp;</td>
					<td><%if(fileProdCounter=1)then%><input type="text" value="<%=numMaxProd%>" name="numMaxProds" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);">&nbsp;<a href="javascript:changeNumMaxProds();"><img src=<%=Application("baseroot")&"/common/img/refresh.gif"%> vspace="0" hspace="4" border="0" align="top" alt="<%=langEditor.getTranslated("backend.commons.detail.table.label.change_num_prods")%>"></a><%end if%>&nbsp;</td>
					</tr>
				<%next%> 
			</table>
			<%
			Dim objListDownProd
			Set objDownloadedProdUpload = new DownloadableProductClass
			if (Instr(1, typename(objDownloadedProdUpload.getFilePerProdotto(id_prod)), "Dictionary", 1) > 0) then
				Set objListDownProd = objDownloadedProdUpload.getFilePerProdotto(id_prod)%>
				<table border="0" cellspacing="0" cellpadding="0" class="principal">
				  <tr>
					<td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.file_to_del")%></span></td>
				  </tr>
				<%Dim objFilesDownProd
				for each key in objListDownProd
					Set objFilesDownProd = objListDownProd(key)%>
				  <tr>
					<td><input type="checkbox" value="<%=objFilesDownProd.getID()%>" name="existingDownloadFiles">&nbsp;<%=objFilesDownProd.getFileName()%></td>
				  </tr>
					<%Set objFilesDownProd = nothing	
				next%>
				</table>		
			<%end if
			Set objListDownProd = nothing
			Set objDownloadedProdUpload = Nothing
			%>
			</div><br/>
		  <br/>
		  
		  
		  <table border="0" cellspacing="0" cellpadding="0">
		  <tr>
		  <td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.prezzo_prod")%>&nbsp;&nbsp;&nbsp;</span><br/>
		  <input type="text" name="prezzo_prod" value="<%=numPrezzo%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);">
		  </td>	
		  <td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.tassa_applicata")%></span><br/>
		  <select name="id_tassa_applicata" class="formFieldTXT">
		  <option value=""></option>
			<%
			On Error Resume Next
			Dim objTasse, objListaTasse, objTassa
			Set objTasse = new TaxsClass
			Set objListaTasse = objTasse.getListaTasse(null,null)
			if (Instr(1, typename(objListaTasse), "Dictionary", 1) > 0) then
				for each y in objListaTasse.Keys
					Set objTassa = objListaTasse(y)%>
					<option value="<%=y%>" <%if (id_tassa_applicata = y) then response.write("selected") end if%>><%=objTassa.getDescrizioneTassa()%></option>	
				<%	Set objTassa = nothing
				next
			end if		
			Set objListaTasse = nothing
			Set objTasse = nothing
			
			if(Err.number <> 0) then
			end if
			%>	  
		  </select>
		  </td>
		  <td>
		  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.taxs_group")%></span><br>
		  <select name="taxs_group" class="formFieldTXT">
		  <option value=""></option>
			<%
			Dim objTaxGroup, objListaTaxGroup, objGroupT
			Set objTaxGroup = new TaxsGroupClass
			On Error Resume Next
			Set objListaTaxGroup = objTaxGroup.getListaTaxsGroup(null)
			if not (isNull(objListaTaxGroup)) then
				for each y in objListaTaxGroup.Keys
					Set objGroupT = objListaTaxGroup(y)%>
					<option value="<%=y%>" <%if (taxs_group = y) then response.write("selected") end if%>><%=objGroupT.getGroupDescription()%></option>	
				<%	Set objGroupT = nothing
				next
			end if		
			Set objListaTaxGroup = nothing
			if(Err.number<>0)then
			end if
			Set objTaxGroup = nothing
			%>	  
		  </select>		  
		  </td>
		  </tr>
		  <tr>
		  <td><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.qta_prod")%>&nbsp;&nbsp;&nbsp;</span><br/>		  
		  <input type="radio" onclick="javascript:reloadNumQtaType(-1111111111);" name="sel_qta_prod" value="0" <%if (numQta = Application("unlimited_key")) then response.write("checked='checked'") end if%> onclick="changeQtaStato();"> <%=langEditor.getTranslated("backend.prodotti.detail.table.label.qta_unlimited")%><br/>
		  <input type="radio" onclick="javascript:reloadNumQtaType(<%if(CInt(id_prod) <> -1 AND not(numQta = Application("unlimited_key")))then response.write("document.form_inserisci.qta_prod.value") else response.write("0") end if%>);" name="sel_qta_prod" value="1" <%if not(numQta = Application("unlimited_key")) then response.write("checked='checked'") end if%> onclick="changeQtaStato();"> <input type="text" name="qta_prod" value="<%if not(numQta = Application("unlimited_key")) then response.write(numQta) end if%>" class="formFieldTXTShort" <%if (numQta = Application("unlimited_key")) then response.write("readonly") end if%> onkeypress="javascript:return isInteger(event);" onfocus="javascript:setCurrQtaVal(document.form_inserisci.qta_prod.value);" onchange="javascript:cleanFieldValuesQta();">		
		  </td>	
		  <td valign="top"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.sconto_prod")%></span><br/>
		  <input type="test" value="<%=sconto_prod%>" name="sconto_prod" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">%
		  </td>	
		  <td valign="top"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.edit_buy_qta")%></span><br/>
		  <select name="edit_buy_qta" class="formFieldTXTShort">
		  <option value="0" <%if (edit_buy_qta = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>
		  <option value="1" <%if (edit_buy_qta = 1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>
		  </select>
		  </td>
		  </tr>
		  </table>
		  <br/><br/>
		  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.prod_attivo")%></span><br/>
		  <select name="stato_prod" class="formFieldTXTShort">
		  <option value="0" <%if (stato_prod = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>
		  <option value="1" <%if (stato_prod = 1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>
		  </select>

		<br/><br/>
		<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divProdFields');showHideDivArrow('divProdFields','arrowFields');"><img src="<%if (hasProdFields)then response.Write(Application("baseroot")&"/editor/img/div_freccia.gif") else response.Write(Application("baseroot")&"/editor/img/div_freccia2.gif") end if%>" vspace="0" hspace="0" border="0" align="right" id="arrowFields"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.product_fields")%></div>
		<div id="divProdFields" <%if (hasProdFields) then response.Write("style=""visibility:visible;display:block;padding-top:2px;""") else response.Write("style=""visibility:hidden;display:none;padding-top:2px;""") end if%> align="left">
		  <input type="hidden" value="" name="list_prod_fields">
		  <input type="hidden" value="" name="list_prod_fields_values">
		  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table" id="inner-table-prod-field-list">
			<tr>
			<th width="155"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.prod_field_attivo")%></span>&nbsp;&nbsp;<span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.prod_field_attivo_all")%></span><input type="checkbox" id="activate_all_prod_field" value="" onclick="javascript:showAllProdField();" checked></th>
			<th width="20%"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.prod_field_name")%></span></th>
			<%if (numQta = Application("unlimited_key")) then%>
			<th colspan="2"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.prod_field_values")%></span></th>
			<%else%>
			<th width="27%"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.prod_field_values")%></span></th>
			<th><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.prod_field_correlated")%></span></th>			
			<%end if%>
			</tr>
		  <tbody>
		<%
		Dim fieldCssClass
		if(hasProdFields) then
			Dim styleRow, styleRow2, counter
			styleRow2 = "table-list-on"
			counter = 0

			Set objListActiveField4Correlation = objProdField.getListProductField4ProdActiveByType(id_prod,"3,4,5,6")
			Set objFilteredListActiveField4Corr = Server.CreateObject("Scripting.Dictionary")

			for each m in objListActiveField4Correlation
				On Error Resume next
				
				Set objListValuesAF4C = objProdField.getListProductFieldValues(m)
				if(objListValuesAF4C.Count > 0)then
					for each f in objListValuesAF4C
						labelFormAF4C = objListActiveField4Correlation(m).getDescription()
						if not(langEditor.getTranslated("backend.prodotti.detail.table.label."&objListActiveField4Correlation(m).getDescription())="") then labelFormAF4C = langEditor.getTranslated("backend.prodotti.detail.table.label."&objListActiveField4Correlation(m).getDescription())
						objFilteredListActiveField4Corr.add id_prod&"|"&objListActiveField4Correlation(m).getID()&"|"&Server.HTMLEncode(f),labelFormAF4C&": "&Server.HTMLEncode(f)
					next
				end if
				Set objListValuesAF4C = nothing
			
				if(Err.number<>0) then
				end if			
			next
		
			for each k in objListProdField
				styleRow = "table-list-off"
				if(counter MOD 2 = 0) then styleRow = styleRow2 end if
				
				Set objField = objListProdField(k)
				fieldCssClass=""
				
				if(CInt(objField.getTypeField())=4) then
					fieldCssClass="formFieldMultiple"
				end if
				
				labelForm = objField.getDescription()
				if not(langEditor.getTranslated("backend.prodotti.detail.table.label."&objField.getDescription())="") then labelForm = langEditor.getTranslated("backend.prodotti.detail.table.label."&objField.getDescription())
				%>		  
				<tr class="<%=styleRow%>" id="tr_prod_field_<%=objField.getID()%>">
				<td id="td_prod_field_active_<%=objField.getID()%>">
				<%
				onclickactive=""
				if (numQta <> Application("unlimited_key")) then
					select Case objField.getTypeField()
					Case 3,4,5,6	
						onclickactive = "onclick=""javascript:activateFieldProd('prod_field_active_"&objField.getID()&"-"&objField.getTypeField()&"');"""
					end select
				end if
				%>
				<input type="checkbox" <%=onclickactive%> value="<%=objField.getID()&"-"&objField.getTypeField()%>" id="prod_field_active_<%=objField.getID()&"-"&objField.getTypeField()%>" name="prod_field_active" <%if(objField.getIdProd() <> "")then response.write("checked='checked'") end if%>>&nbsp;</td>
				<td id="td_prod_field_name_<%=objField.getID()%>"><%=labelForm%>&nbsp;</td>
				<td colspan="2"><%								
					select Case objField.getTypeField()
					Case 3,4,5,6						
						On Error Resume next
						hasListValues = false
						
						Set objListValues = objProdField.getListProductFieldValues(k)
						if(objListValues.Count > 0)then
							hasListValues = true
						end if
					
						if(Err.number<>0) then
							'response.write(Err.description)
							hasListValues = false
						end if
					
						if(hasListValues)then
							if (numQta = Application("unlimited_key")) then
								Dim valueList
								valueList = ""
								for each g in objListValues
									valueList = valueList & Server.HTMLEncode(g) & ","
								next
								
								valueList = Left(valueList,InStrRev(valueList,",",-1,1)-1)						
								response.write(valueList)
							else
								On Error Resume next
								hasListValuesMatch = false
								Set objListFieldValMatch = objProdField.findListFieldValueMatch(objField.getID(), id_prod)
								if(objListFieldValMatch.Count > 0)then
									hasListValuesMatch = true
								end if
								
								if(Err.number<>0) then
									'response.write(Err.description)
									hasListValuesMatch = false
								end if%>	
								
								<table width="100%" cellpadding="0" cellspacing="0" border="0" name="inner-table-rel-field_<%=objField.getID()%>" class="inner-table-rel-field">
								
								<%for each g in objListValues
									fieldValueMatch = ""
									if(hasListValuesMatch)then
										fieldValueMatch = objListFieldValMatch(g)
									end if
										
									rel_qta_sum_check = 0			

									hasListRelField = false						
									On Error Resume Next
									Set listRelField = objProdField.findListFieldRelValueMatch(id_prod, objField.getID(), g)
									if(Instr(1, typename(listRelField), "Dictionary", 1) > 0) then
										hasListRelField = true
									end if
									if(Err.number <> 0) then
										hasListRelField = false
									end if%>
									<tr class="tr_inner_rel_field_<%=objField.getID()%>">
									<td width="16" valign="top"><img src="<%=Application("baseroot")&"/editor/img/arrow_join.png"%>" class="img_field_value" id="img_field_value_<%=objField.getID()%>_<%=g%>" border="0" hspace="0" vspace="0" style="cursor:pointer;" align="left"></td>
									<td width="43%" align="left"><input type="text" name="qta_field_value_<%=objField.getID()%>_<%=g%>" id="qta_field_value_<%=objField.getID()%>_<%=g%>" value="<%=fieldValueMatch%>" class="formFieldTXTShort" onchange="javascript:checkQtaFieldValue('<%=objField.getID()%>',this);" onkeypress="javascript:return isInteger(event);">&nbsp;<span class="sp_qta_field_value_<%=objField.getID()%>_<%=g%>"><%=g%></span><br/>
									<%'response.write("fieldValueMatch: "&fieldValueMatch&" = 0 -> "& (Cint(fieldValueMatch)=0) &"<br>") 
									if(Cint(fieldValueMatch)=0)then%>
									<script>
									$('#img_field_value_<%=objField.getID()%>_<%=g%>').hide();
									</script>	
									<%end if%>								
									<div class="prodotto-choose-field-correlation" id="div_field_value_<%=objField.getID()%>_<%=g%>">
									<select id="select_field_value_<%=objField.getID()%>_<%=g%>" name="select_field_value_<%=objField.getID()%>_<%=g%>">
									<%for each l in objFilteredListActiveField4Corr
										if(Left(l,InStrRev(l,"|",-1,1)-1) <> id_prod&"|"&objField.getID()) then
											if not(hasListRelField) then%>
											<option value="<%=l%>|<%=objField.getID()%>|<%=g%>"><%=objFilteredListActiveField4Corr(l)%></option>
											<%else
												for each j in listRelField
													instring=InStr(1,l,"|",1)+1
													instringrev=InStrRev(l,"|",-1,1)
													shift=instringrev-instring
													if(Instr(1, j, (id_prod&"|"&objField.getID()&"|"&g&"|"&Mid(l,InStr(1,l,"|",1)+1,shift)), 1) > 0)then%>
														<option value="<%=l%>|<%=objField.getID()%>|<%=g%>"><%=objFilteredListActiveField4Corr(l)%></option>
														<%Exit For
													end if
												next
											end if
										end if
									next%>
									</select>&nbsp;
									<input type="text" id="qta_field_rel_value_<%=objField.getID()%>_<%=g%>" name="qta_field_rel_value_<%=objField.getID()%>_<%=g%>" value="0" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);" >&nbsp;
									<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="apply" onclick="javascript:updateRelatedFieldProd('select_field_value_<%=objField.getID()%>_<%=g%>','qta_field_rel_value_<%=objField.getID()%>_<%=g%>','result_container_<%=objField.getID()%>_<%=g%>');" />
									</div>
									</td>
									<td width="63%" align="left">
									<div class="rel_qta_sum" id="rel_qta_sum_check_<%=objField.getID()%>_<%=g%>"></div>
									<div style="float:left;" id="result_container_<%=objField.getID()%>_<%=g%>">
									<%
									On Error Resume Next
									if(hasListRelField) then
										relcounter = 1
										for each j in listRelField
											Set objTmp = listRelField(j)
											if not(objFilteredListActiveField4Corr.exists(id_prod&"|"&objTmp("id_field")&"|"&objTmp("field_val"))) then
												call objProdField.deleteFieldRelValueMatchNoTransaction(id_prod, objTmp("id_field"), objTmp("field_val"), objTmp("id_field_rel"), objTmp("field_rel_val"))
											else%>
												<img src="<%=Application("baseroot")&"/editor/img/bullet_delete.png"%>" id="img_del_field_rel_value_<%=objField.getID()%>_<%=g%>" align="absmiddle" border="0" hspace="0" vspace="0" style="cursor:pointer;" onclick="javascript:deleteRelatedFieldProd('<%=objTmp("id_prod")%>','<%=objTmp("id_field")%>','<%=objTmp("field_val")%>','<%=objTmp("id_field_rel")%>','<%=objTmp("field_rel_val")%>','result_container_<%=objField.getID()%>_<%=g%>');"><%=objTmp("field_rel_desc")&"("&objTmp("field_rel_val")&"): <span class=""rel_qta_check_"&objTmp("id_field_rel")&"_"&objTmp("field_rel_val")&""">"&objTmp("qta_rel")&"</span>&nbsp;"%><%if(relcounter MOD 2 = 0) then response.write("<br/>") end if%>
											<%end if
											rel_qta_sum_check=rel_qta_sum_check+Clng(objTmp("qta_rel"))
											'response.write(" ) qta_rel: "&objTmp("qta_rel")&" - rel_qta_sum_check: "&rel_qta_sum_check&"<br>")
											Set objTmp = nothing
											relcounter=relcounter+1
										next
									end if
									Set listRelField = nothing	
									if(Err.number <> 0) then
									end if
									%>
									</div></td>
									</tr>
									<script>
									<%if(hasListRelField) then%>
									$('#rel_qta_sum_check_<%=objField.getID()%>_<%=g%>').append("[<%=rel_qta_sum_check%>]");
									<%end if%>
									$('#img_field_value_<%=objField.getID()%>_<%=g%>').click(function() {
										$('#div_field_value_<%=objField.getID()%>_<%=g%>').slideToggle();
									});
									</script>
								<%next%>
								</table>
								<%Set objListFieldValMatch = nothing						
							end if
							
							Set objListValues = nothing
						end if
					case 7
						fieldValueMatch = objProdField.findFieldMatchValue(k,id_prod)
						response.write(objProdField.renderProductFieldHTML(objField,fieldCssClass, "", id_prod, fieldValueMatch,langEditor,0,objField.getEditable()))%>
						<script>
						document.getElementById('<%=objProdField.getFieldPrefix()&objField.getID()%>').setAttribute('type', 'text');
						</script>
					<%case 8
					case else
						if(Cint(objField.getTypeField())=9)then%>	
						<!--<script>
						//clfilepath = "http://<%'=request.ServerVariables("SERVER_NAME")&Application("dir_upload_prod")&"fields/"&id_prod&"/"&Session.SessionID&"/"%>";	
						//declare cleditor option array;
						//var cloptions<%'=objProdField.getFieldPrefix()&objField.getID()%> = {
							//width:280,	// width not including margins, borders or padding
							//height:200,	// height not including margins, borders or padding
							//controls:"bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image",	// controls to add to the toolbar
							/*imagesServerPath:clfilepath,	// set the server path to upload imgs
							objref_id:<%'=id_prod%>,	// set the reference to the product associated to the field
							serverURL:'<%'=Application("baseroot") & "/editor/prodotti/ajaxuploadfile.asp"%>',	// set the reference url to the server upload file page
							textarea_id:'<%'=objProdField.getFieldPrefix()&objField.getID()%>',	// id input field matched with cleditor instance
							cleditor_instance_count:<%'=objField.getID()%>	// id input field matched with cleditor instance*/
						};					
						</script>-->					
						<%end if
						fieldValueMatch = objProdField.findFieldMatchValue(k,id_prod)
						response.write(objProdField.renderProductFieldHTML(objField,fieldCssClass, "", id_prod, fieldValueMatch,langEditor,0,objField.getEditable()))						
					end select%></td>					
				 </tr>
			<%counter = counter +1
			next
		end if

		Set objListActiveField4Correlation = nothing
		Set objListProdField = nothing
		Set objProdField = nothing
		%>
		<script>
		$('.prodotto-choose-field-correlation').hide();

		$("table[name*='inner-table-rel-field_']").each( function(){
			//alert("class: "+$(this).attr("class")+"; text: "+$(this).text());
			//alert("name: "+$(this).attr("name")+"; text: "+$(this).text());

			//var inner_rel_qta_check = $(this).find("span[class*='rel_qta_check_']:first");
			//alert("inner_rel_qta_check: "+inner_rel_qta_check.attr("class")+"; text: "+inner_rel_qta_check.text());
			var this_field_id = $(this).attr("name").substring($(this).attr("name").lastIndexOf("_")+1, $(this).attr("name").length);
			//alert("this_field_id: "+this_field_id);
			$(this).find("span[class*='rel_qta_check_']:first").each( function(){
				//alert("class inn: "+$(this).attr("class")+"; text: "+$(this).text());
				var this_field_rel_id = $(this).attr("class");
				this_field_rel_id = this_field_rel_id.substring(this_field_rel_id.indexOf("rel_qta_check_")+14, this_field_rel_id.lastIndexOf("_"));
				
				$("select[name*='select_field_value_']").each( function(){		
					var this_select_name = $(this).attr("name");
					this_select_name = this_select_name.substring(this_select_name.indexOf("select_field_value_")+19, this_select_name.lastIndexOf("_"));					
					//alert("\nthis_field_id: "+this_field_id+" - this_field_rel_id: "+this_field_rel_id+" - name jq: "+$(this).attr("name")+" - this_select_name: "+this_select_name);		
					
					if(this_select_name==this_field_id){
						//var size = $(this).children.not("option[value]:contains('<%=id_prod%>|'+this_select_name+')").size();
						//var size = $(this).children().not(":contains('<%=id_prod%>|"+this_field_rel_id+"')").size();
						//var size2 = $(this).children(":contains('<%=id_prod%>|"+this_field_rel_id+"')").size();
						//alert("match: <%=id_prod%>|"+this_field_rel_id+" - size: "+size+" - size2: "+size2);

						$(this).children().each( function(){
							//alert("value: "+$(this).val());
							var tmpsval = $(this).val();
							if(tmpsval.indexOf("<%=id_prod%>|"+this_field_rel_id)!=0){
								$(this).remove();
							}
						});
					}else if(this_select_name==this_field_rel_id){
						$(this).children().each( function(){
							//alert("value: "+$(this).val());
							var tmpsval = $(this).val();
							if(tmpsval.indexOf("<%=id_prod%>|"+this_field_id)==0){
								$(this).remove();
							}
						});						
					}else{
						$(this).children().each( function(){
							//alert("value: "+$(this).val());
							var tmpsval = $(this).val();
							//alert("this_field_id: "+this_field_id+" - rel_qta_check_: "+ $("span[class*='rel_qta_check_"+this_field_id+"']").size());
							if(tmpsval.indexOf("<%=id_prod%>|"+this_field_id)==0 && $("span[class*='rel_qta_check_"+this_field_id+"']").size()==0){
								$(this).remove();
							}
						});							
					}
				});		
			});	
		});		

		</script>
			</tbody>
		  </table>
		  </div>


		<br/><br/>
		<div class="divDetailHeader" align="left" onClick="javascript:showHideDiv('divProdRelations');showHideDivArrow('divProdRelations','arrowRelations');"><img src="<%if not(isNull(objRelationsProd))then response.Write(Application("baseroot")&"/editor/img/div_freccia.gif") else response.Write(Application("baseroot")&"/editor/img/div_freccia2.gif") end if%>" vspace="0" hspace="0" border="0" align="right" id="arrowRelations"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.product_relations")%></div>
		<div id="divProdRelations" <%if not(isNull(objRelationsProd)) then response.Write("style=""visibility:visible;display:block;padding-top:2px;border:1px solid #C9C9C9;""") else response.Write("style=""visibility:hidden;display:none;padding-top:2px;""") end if%> align="center">
		<div style="display:block " align="left">
		<%
		if not(isNull(objRelationsProd)) then
			counter = 1
			for each k in objRelationsProd
				Set objRelProd = objRelationsProd(k)

				On Error Resume Next
					Set objFilesRelProd = objRelProd.getFileXProdotto()	
				If(Err.number <> 0) then
					objFilesRelProd = null
				end if%>

				<%if(counter MOD 4 = 0)then%><div id="clear"></div><%end if%>
				<div id="prodotto-immagine">
				<%if not(isNull(objFilesRelProd)) then%>
					<%Dim hasNotSmallImg
					hasNotSmallImg = true			
					for each xObjFile in objFilesRelProd
						Set objFileXProdotto = objFilesRelProd(xObjFile)
						iTypeFile = objFileXProdotto.getFileTypeLabel()
						if(Cint(iTypeFile) = 1) then%>	
							<img src="<%=Application("dir_upload_prod")&objFileXProdotto.getFilePath()%>" alt="<%=objRelProd.getNomeProdotto()%>" width="100" height="100" />
							<%hasNotSmallImg = false
							Exit for
						end if
						Set objFileXProdotto = nothing	
					next		
					if(hasNotSmallImg) then%>
					<img width="100" height="100" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0">
					<%end if
					Set objFilesRelProd = nothing
					else%>
					<img width="100" height="100" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0">
					<%end if%>
				</div>
				<div id="prodotto-testo">
				<p><%=objRelProd.getNomeProdotto()%></p>
				<strong><%=langEditor.getTranslated("backend.prodotti.detail.table.label.cod_rel_prod")%>:</strong>&nbsp;<%=objRelProd.getCodiceProd()%>
				</div>
				<%Set objRelProd = nothing				
				counter = counter +1
			next
		end if
		%>
		</div>
		<div id="clear"></div>

		<div align="center" style="width:417px; overflow:auto; height:200px">
		  <input type="hidden" value="" name="list_prod_relations">
		  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table-rel-prod">
		  <tr>
		  <th><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.list_prod_rel")%></span></th>
		  </tr>
			<%
			On Error Resume Next
			Set objListRefProd = objProd.getListaProdotti4Relation()
			if not(isNull(objListRefProd)) then
				counter = 0
				desc_cat = ""

				for each k in objListRefProd					
					Set objTmp = objListRefProd(k)

					checked = ""

					if not(isNull(objRelationsProd))then
						if(objRelationsProd.Exists(k))then
							checked = "checked='checked'"
						end if
					end if
					
					if(objTmp.getIDProdotto() <> id_prod)then%>		  
					<tr class="table-list-off">
					<td><%if(desc_cat <>objTmp.getDescCatRelProd())then response.write("<strong>"&objTmp.getDescCatRelProd()&"</strong><br/>") end if%><input type="checkbox" value="<%=objTmp.getIDProdotto()%>" name="id_prod_rel" <%=checked%>>&nbsp;<%=objTmp.getNomeProdotto()%>&nbsp;(<%=objTmp.getCodiceProd()%>)</td>
					 </tr>
					<%
					desc_cat = objTmp.getDescCatRelProd()
					end if
					Set objTmp = nothing
					counter = counter +1
				next
			end if
	
			Set objListRefProd = nothing
			if(Err.number <> 0)then
				'response.write(Err.description)
			end if
			%>
			  </table>
			</div><br/>
		  </div>
		  <%Set objRelationsProd = nothing%>



		  <%if (Cint(id_prod) <> -1) then%>
			  <br/><br/><br/>
			  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.comments")%></span><br/>
			 <%
				Set objCommento = New CommentsClass
				if(not(isNull(objCommento.findCommentiByIDElement(id_prod,2,null)))) then%>
				<a href="javascript:openWin('<%=Application("baseroot")&"/public/layout/include/popupInsertComments.asp?id_element="&id_prod&"&element_type=2"%>','popupallegati',400,400,100,100);" title="<%=langEditor.getTranslated("backend.prodotti.detail.table.label.comments")%>"><img src="<%=Application("baseroot")&"/common/img/comment_add.png"%>" hspace="0" vspace="0" border="0"></a>
				<%else
					response.Write("<div align='left'>"&langEditor.getTranslated("backend.prodotti.detail.table.label.no_comments")&"</div><br/>")
				end if
				Set objCommento = nothing
			 %>
		  <%end if%>
		  
		<div id="loading" style="visibility:hidden;display:none;" align="center"><img src="/editor/img/loading.gif" vspace="0" hspace="0" border="0" alt="Loading..." width="200" height="50"></div>
		</form>
		</td>
	</tr>
	</table><br/>
	  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.prodotti.detail.button.inserisci_esci.label")%>" onclick="javascript:sendForm(1,false);" />&nbsp;&nbsp;<%if (Cint(id_prod) <> -1) then%><input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.prodotti.detail.button.inserisci.label")%>" onclick="javascript:sendForm(0,false);" />&nbsp;&nbsp;<%end if%><input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.prodotti.detail.button.annulla.label")%>" onclick="javascript:reset();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/prodotti/ListaProdotti.asp?cssClass=LP"%>';" />
	  <br/>
			
			<%if (Cint(id_prod) <> -1) then%>		
			<form action="<%=Application("baseroot") & "/editor/prodotti/DeleteProd.asp"%>" method="post" name="form_cancella_prod">
			<input type="hidden" value="<%=id_prod%>" name="id_prod_to_delete">
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.prodotti.detail.button.elimina.label")%>" onclick="javascript:confirmDelete();" />
			</form>
			<%end if%>
			
		    <form action="<%=Application("baseroot") & "/editor/prodotti/Inserisciprodotto.asp"%>" method="get" name="form_reload_page">
		    <input type="hidden" name="id_prodotto" value="<%=id_prod%>">
		    </form>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>
<%
Set objTmpLang = nothing
Set objProd = nothing%>