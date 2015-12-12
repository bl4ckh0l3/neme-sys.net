<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<%
if not(isEmpty(Session("objCMSUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
	Set objUserLoggedTmp = nothing
	Dim strRuoloLogged
	strRuoloLogged = objUserLogged.getRuolo()
	if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) AND not(strComp(Cint(strRuoloLogged), Application("editor_role"), 1) = 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if

	Dim id_prod, id_field, field_val, id_field_rel, field_rel_val, qta_rel, optype
	id_prod = request("id_prod")
	id_field = request("id_field")
	field_val = request("field_val")
	id_field_rel = request("id_field_rel")
	field_rel_val = request("field_rel_val")
	qta_rel = request("qta_rel")
	optype = request("optype")
	
	'response.write("id_prod: "&id_prod&"<br>")
	'response.write("id_field: "&id_field&"<br>")
	'response.write("field_val: "&field_val&"<br>")
	'response.write("id_field_rel: "&id_field_rel&"<br>")
	'response.write("field_rel_val: "&field_rel_val&"<br>")
	'response.write("qta_rel: "&qta_rel&"<br>")
	'response.write("optype: "&optype&"<br>")

	Dim objRef
	Set objRef = New ProductFieldClass
	
	Select Case optype
		Case "update"
			Set objDB = New DBManagerClass
			Set objConn = objDB.openConnection()
			objConn.BeginTrans
			call objRef.deleteFieldRelValueMatch(id_prod, id_field, field_val, id_field_rel, field_rel_val, objConn)
			call objRef.insertFieldRelValueMatch(id_prod, id_field, field_val, id_field_rel, field_rel_val, qta_rel, objConn)
			
			if objConn.Errors.Count = 0 AND Err.Number = 0 then
				objConn.CommitTrans
			else		
				objConn.RollBackTrans	
				'response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
			end if			
		Case "delete"
			call objRef.deleteFieldRelValueMatchNoTransaction(id_prod, id_field, field_val, id_field_rel, field_rel_val)
	End Select	
			
	On Error Resume Next
	Set objListActiveField4Correlation = objRef.getListProductField4ProdActiveByType(id_prod,"3,4,5,6")
	Set objFilteredListActiveField4Corr = Server.CreateObject("Scripting.Dictionary")

	for each m in objListActiveField4Correlation
		On Error Resume next		
		Set objListValuesAF4C = objRef.getListProductFieldValues(m)		
		'response.write("objListValuesAF4C.Count: "&objListValuesAF4C.Count&"<br>")		
		if(objListValuesAF4C.Count > 0)then
			for each f in objListValuesAF4C
				labelFormAF4C = objListActiveField4Correlation(m).getDescription()
				if not(langEditor.getTranslated("backend.prodotti.detail.table.label."&objListActiveField4Correlation(m).getDescription())="") then labelFormAF4C = langEditor.getTranslated("backend.prodotti.detail.table.label."&objListActiveField4Correlation(m).getDescription())
				objFilteredListActiveField4Corr.add id_prod&"|"&objListActiveField4Correlation(m).getID()&"|"&Server.HTMLEncode(f),labelFormAF4C&": "&Server.HTMLEncode(f)
				'response.Write("id field= "&id_prod&"|"&objListActiveField4Correlation(m).getID()&"|"&Server.HTMLEncode(f)&" - label= "&labelFormAF4C&": "&Server.HTMLEncode(f)&"<br/>")
			next
		end if
		Set objListValuesAF4C = nothing	
		if(Err.number<>0) then
		'response.write(Err.description)
		end if			
	next
	
	'response.write("typename(objListActiveField4Correlation): "&typename(objListActiveField4Correlation)&"<br>")

	hasListRelField = false						
	On Error Resume Next
	Set listRelField = objRef.findListFieldRelValueMatch(id_prod, id_field, field_val)
	if(Instr(1, typename(listRelField), "Dictionary", 1) > 0) then
		hasListRelField = true
	end if
	if(Err.number <> 0) then
		hasListRelField = false
	end if
	
	rel_qta_sum_check = 0	

	if(hasListRelField) then
		relcounter = 1	
		for each j in listRelField
			Set objTmp = listRelField(j)
			if not(objFilteredListActiveField4Corr.exists(id_prod&"|"&objTmp("id_field")&"|"&objTmp("field_val"))) then
				call objRef.deleteFieldRelValueMatchNoTransaction(id_prod, objTmp("id_field"), objTmp("field_val"), objTmp("id_field_rel"), objTmp("field_rel_val"))
			else%>
			<img src="<%=Application("baseroot")&"/editor/img/bullet_delete.png"%>" id="img_del_field_rel_value_<%=objTmp("id_field")%>_<%=objTmp("field_val")%>" align="absmiddle" border="0" hspace="0" vspace="0" style="cursor:pointer;" onclick="javascript:deleteRelatedFieldProd('<%=objTmp("id_prod")%>','<%=objTmp("id_field")%>','<%=objTmp("field_val")%>','<%=objTmp("id_field_rel")%>','<%=objTmp("field_rel_val")%>','result_container_<%=objTmp("id_field")%>_<%=objTmp("field_val")%>');"><%=objTmp("field_rel_desc")&"("&objTmp("field_rel_val")&"): <span class=""rel_qta_check_"&objTmp("id_field_rel")&"_"&objTmp("field_rel_val")&""">"&objTmp("qta_rel")&"</span>&nbsp;"%><%if(relcounter MOD 2 = 0) then response.write("<br/>") end if%>
			<%end if
			rel_qta_sum_check=rel_qta_sum_check+Clng(objTmp("qta_rel"))
			Set objTmp = nothing
			relcounter=relcounter+1
		next
	end if%>

	<script>
	<%if(hasListRelField) then%>
	$('#rel_qta_sum_check_<%=id_field%>_<%=field_val%>').html("[<%=rel_qta_sum_check%>]");
	<%else%>
		$('#rel_qta_sum_check_<%=id_field%>_<%=field_val%>').empty();
	<%end if

	if(objFilteredListActiveField4Corr.count>0) then
		arrKeyO = "["
		arrValO = "["
		for each l in objFilteredListActiveField4Corr
			arrKeyO = arrKeyO & "'"&l&"'," 
			arrValO = arrValO & "'"&objFilteredListActiveField4Corr(l)&"'," 
		next
		arrKeyO = arrKeyO & "]"
		arrValO = arrValO & "]"
		arrKeyO = Replace(arrKeyO, ",]", "]", 1, -1, 1)
		arrValO = Replace(arrValO, ",]", "]", 1, -1, 1)
		%>
		
		var arrKey = <%=arrKeyO%>;
		var arrVal = <%=arrValO%>;
		
		$("select[name*='select_field_value_']").each( function(){
			var id_sel_field = $(this).attr("name").substring($(this).attr("name").indexOf("select_field_value_")+19, $(this).attr("name").lastIndexOf("_"));
			var val_sel_field = $(this).attr("name").substring($(this).attr("name").lastIndexOf("_")+1, $(this).attr("name").length);
			var suffix = "|"+id_sel_field+"|"+val_sel_field;
			$(this).empty();
		
			for (var i = 0; i < arrKey.length; i++){
				var match_id = arrKey[i].substring(arrKey[i].indexOf("|")+1, arrKey[i].lastIndexOf("|"));
				//alert("key: "+arrKey[i]+" - suffix: "+suffix+" - value: "+arrVal[i]);
				if(match_id!=id_sel_field){
					$(this).append('<option value="'+arrKey[i]+suffix+'">'+arrVal[i]+'</option>');
				}	
			}
		});
	
		$("table[name*='inner-table-rel-field_']").each( function(){
			var this_field_id = $(this).attr("name").substring($(this).attr("name").lastIndexOf("_")+1, $(this).attr("name").length);
			$(this).find("span[class*='rel_qta_check_']:first").each( function(){
				var this_field_rel_id = $(this).attr("class");
				this_field_rel_id = this_field_rel_id.substring(this_field_rel_id.indexOf("rel_qta_check_")+14, this_field_rel_id.lastIndexOf("_"));
				
				$("select[name*='select_field_value_']").each( function(){		
					var this_select_name = $(this).attr("name");
					this_select_name = this_select_name.substring(this_select_name.indexOf("select_field_value_")+19, this_select_name.lastIndexOf("_"));					
					
					if(this_select_name==this_field_id){
						$(this).children().each( function(){
							var tmpsval = $(this).val();
							if(tmpsval.indexOf("<%=id_prod%>|"+this_field_rel_id)!=0){
								$(this).remove();
							}
						});
					}else if(this_select_name==this_field_rel_id){
						$(this).children().each( function(){
							var tmpsval = $(this).val();
							if(tmpsval.indexOf("<%=id_prod%>|"+this_field_id)==0){
								$(this).remove();
							}
						});						
					}else{
						$(this).children().each( function(){
							var tmpsval = $(this).val();
							if(tmpsval.indexOf("<%=id_prod%>|"+this_field_id)==0 && $("span[class*='rel_qta_check_"+this_field_id+"']").size()==0){
								$(this).remove();
							}
						});							
					}
				});		
			});	
		});
	
	
	
	
		//$('#select_field_value_<%=id_field%>_<%=field_val%>').empty();
		////$('select').children().remove(); $('select').append('<option id="foo">foo</option>'); $('#foo').focus();
		<%'for each l in objFilteredListActiveField4Corr
			'if(Left(l,InStrRev(l,"|",-1,1)-1) <> id_prod&"|"&id_field) then
				'if not(hasListRelField) then%>
				//$('#select_field_value_<%'=id_field%>_<%'=field_val%>').append('<option value="<%'=l%>|<%'=id_field%>|<%'=field_val%>"><%'=objFilteredListActiveField4Corr(l)%></option>');
				<%'else
					'for each j in listRelField
					'instring=InStr(1,l,"|",1)+1
					'instringrev=InStrRev(l,"|",-1,1)
					'shift=instringrev-instring
	
						'if(Instr(1, j, (id_prod&"|"&id_field&"|"&field_val&"|"&Mid(l,InStr(1,l,"|",1)+1,shift)), 1) > 0)then%>
						//$('#select_field_value_<%'=id_field%>_<%'=field_val%>').append('<option value="<%'=l%>|<%'=id_field%>|<%'=field_val%>"><%'=objFilteredListActiveField4Corr(l)%></option>');
						<%'Exit For
						'end if
					'next
				'end if
			'end if
		'next
	end if%>
	</script>
	
	<%Set listRelField = nothing
	Set objFilteredListActiveField4Corr = nothing	
	Set objListActiveField4Correlation = nothing
	
	if(Err.number <> 0) then 
		'response.write(Err.description)
	end if
	
	Set objRef = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>
