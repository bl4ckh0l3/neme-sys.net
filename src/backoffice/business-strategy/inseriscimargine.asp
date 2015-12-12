<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include file="include/init2.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">

function insertMargine(){
		
	//valorizzo il campo nascosto "ListGroups" con la lista dei Groups del margine
	//separati da "|"
	//questo perchè non si riesce a passare all'altra pagina la lista originale separata da ","
	var strGroups = "";
	for(i=0;i<document.form_inserisci.IDTargetGroups.length;i++){
		strGroups = strGroups + document.form_inserisci.IDTargetGroups.options[i].value + "|";
	}
	if(strGroups.charAt(strGroups.length -1) == "|"){
		strGroups = strGroups.substring(0, strGroups.length -1);
	}
	
	document.form_inserisci.ListGroups.value = strGroups;

	if(document.form_inserisci.margine.value != "") {
		var margineTmp = document.form_inserisci.margine.value;
		if(!checkDoubleFormat(margineTmp) || margineTmp.indexOf(".")!=-1){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.isnan_value")%>");
			document.form_inserisci.margine.value = "0";
			document.form_inserisci.margine.focus();
			return false;
		}
	}else{
		alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_margine")%>");
		document.form_inserisci.margine.value = "0";
		document.form_inserisci.margine.focus();
		return false;		
	}

	if(document.form_inserisci.discount.value != "") {
		var discountTmp = document.form_inserisci.discount.value;
		if(!checkDoubleFormat(discountTmp) || discountTmp.indexOf(".")!=-1){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.isnan_value")%>");
			document.form_inserisci.discount.value = "0";
			document.form_inserisci.discount.focus();
			return false;
		}
	}else{
		alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_discount")%>");
		document.form_inserisci.discount.value = "0";
		document.form_inserisci.discount.focus();
		return false;		
	}	
	document.form_inserisci.submit()
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
</script>
</head>
<body onLoad="javascript:document.form_inserisci.margine.focus();">
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
	<table class="principal" cellpadding="0" cellspacing="0">
	<tr> 
	<td>
		<form action="<%=Application("baseroot") & "/editor/margini/ProcessMargini.asp"%>" method="post" name="form_inserisci">
		  <input type="hidden" value="margindiscount" name="showtab">
		  <input type="hidden" value="<%=id_margine%>" name="id_margine">
		  <span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.margine")%></span><br>
		  <input type="text" name="margine" value="<%=FormatNumber(dblMargine,2,-1)%>" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">%
		  <br/><br/>	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.discount")%></span><br>
		  <input type="text" name="discount" value="<%=FormatNumber(dblSconto,2,-1)%>" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">%
		  </div>
		<br>		  
		  <div align="left" style="float:left;padding-right:10px;"><span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.active_disc_prod")%></span><br>
			<select name="prod_disc" class="formFieldTXTShort">
			<option value="0"<%if ("0"=bolProdDisc) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=bolProdDisc) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>&nbsp;&nbsp;	
		  </div>	 	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.active_disc_user")%></span><br>
			<select name="user_disc" class="formFieldTXTShort">
			<option value="0"<%if ("0"=bolUserdisc) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=bolUserdisc) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>
		  </div><br>	

		<input type="hidden" value="" name="ListGroups"> 
		<div style="float:left;"> 
		  <span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.group_x_margine")%></span><br>
			<select multiple size="7" name="IDTargetGroups" class="formFieldTARGET">
			<%if(Instr(1, typename(objSelGroup), "dictionary", 1) > 0) then
				for each y in objSelGroup.Keys%>
					<option value="<%=y%>"><%=objSelGroup(y).getShortDesc()%></option>	
				<%next
			end if%>
			</SELECT>
		</div>
		  <div style="float:left;padding-top:40px;">
		  <a href="javascript:move(document.form_inserisci.IDTargetGroups,document.form_inserisci.targetDisponibiliGroups)"><img src=<%=Application("baseroot")&"/editor/img/arrow_right.png"%> vspace="2" hspace="2" border="0" align="middle"></a><br>
          <a href="javascript:move(document.form_inserisci.targetDisponibiliGroups,document.form_inserisci.IDTargetGroups)"><img src=<%=Application("baseroot")&"/editor/img/arrow_left.png"%> vspace="2" hspace="2" border="0" align="middle"></a><br>
		  </div>
		  <div style="float:top;">
		  	<span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.group_disp_margine")%></span><br> 
			<select multiple size="7" name="targetDisponibiliGroups" class="formFieldTARGET">
			<%if (Instr(1, typename(objDispGroup), "dictionary", 1) > 0) AND not(isEmpty(objDispGroup)) then
				dim hasSelGroup, hasAlreadyGroup
				hasSelGroup = false
				hasAlreadyGroup = false
				if (Instr(1, typename(objSelGroup), "dictionary", 1) > 0) then
					hasSelGroup = true
				end if
				if (Instr(1, typename(objAlreadyUsedGroup), "dictionary", 1) > 0) then
					hasAlreadyGroup = true
				end if

				for each x in objDispGroup.Keys
					bolExistGroup = false

					if (hasSelGroup) then 				
						if(objSelGroup.Exists(x)) then
							bolExistGroup = true
						else
							bolExistGroup = false
						end if		
					end if

					if (hasAlreadyGroup) then		
						if(objAlreadyUsedGroup.Exists(x)) then
							bolExistGroup = true
						else
							bolExistGroup = false
						end if
					end if
							
					if not(bolExistGroup) then%>
						<option value="<%=x%>"><%=objDispGroup(x).getShortDesc()%></option>						
					<%end if		 
				next	
			end if%>
			</SELECT>
          </div>
		</form>
		</td></tr>
		</table><br/>	
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.margini.detail.button.inserisci.label")%>" onclick="javascript:insertMargine();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/margini/ListaMargini.asp?cssClass=LM&showtab=margindiscount"%>';" />
		<br/><br/>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>