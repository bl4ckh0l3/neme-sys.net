<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<%

Dim objProdField
Dim id_prod, qta_prodotto, checked
Set objProdField = New ProductFieldClass
id_prod = request("id_prod")
qta_prodotto = request("qta_prodotto")
checked = 1
message_error = ""

for each x in request.Form
	On Error Resume Next
	
	'response.write(" id_prod: "&id_prod&" - x: "&x&" - request.Form(x): "&request.Form(x)&"<br>")
	
	if(x<>"qta_prodotto" AND x<>"id_prod")then


		numOldField4ProdQta_ = objProdField.findFieldValueMatch(x, id_prod, request.Form(x))
	'response.write(" numOldField4ProdQta_: "&numOldField4ProdQta_)
		
		if(Trim(numOldField4ProdQta_) <> "" AND not(isNull(numOldField4ProdQta_)))then		
			if(CLng(qta_prodotto) <> 0 AND (CLng(numOldField4ProdQta_) - CLng(qta_prodotto) < 0)) then

				'response.write("qta_prodotto: "&qta_prodotto&" - numOldField4ProdQta_: "&numOldField4ProdQta_&"<br>")
	
				checked = 0
				message_error = message_error & " - " & request.Form(x) & ": qta= " & numOldField4ProdQta_
				exit for				
			end if

			'********* effettuo controllo sui campi correlati per verificare se la disponibilità è corretta
			On Error Resume Next	
			Set listFieldRelVal = objProdField.findListFieldRelValueMatch(id_prod, x, request.Form(x))

			'response.write("typename(listFieldRelVal): "&typename(listFieldRelVal)&" - listFieldRelVal.count: "&listFieldRelVal.count&"<br>")

			if(Instr(1, typename(listFieldRelVal), "Dictionary", 1) > 0) then
				if(listFieldRelVal.count>0)then
					bolHasField = false
					for each j in request.Form
						if(j<>"qta_prodotto" AND j<>"id_prod" AND (x&request.Form(x))<>(j&request.Form(j)))then
							'for each t in listFieldRelVal
								'Set tmpF4OR = listFieldRelVal(t)
								
								'response.write("t: "&t)
								'response.write(" - tmpF4OR(id_field): "&tmpF4OR("id_field")&" - tmpF4OR(field_val): "&tmpF4OR("field_val")&" - tmpF4OR(qta_rel): "&tmpF4OR("qta_rel")& "  ")													
								
									'response.write(" - cerco chiave: "&id_prod&"|"&x&"|"&request.Form(x)&"|"&j&"|"&request.Form(j))
									if(listFieldRelVal.exists(id_prod&"|"&x&"|"&request.Form(x)&"|"&j&"|"&request.Form(j)))then
										qtaFieldRel = listFieldRelVal(id_prod&"|"&x&"|"&request.Form(x)&"|"&j&"|"&request.Form(j))("qta_rel")
			
										'response.write(" - qtaFieldRel: "&qtaFieldRel&" - id_prod: "&id_prod&" - id field: "&x&" - val field: "&request.Form(x)&" - red field id: "&j&" - rel field value: "&request.Form(j))
		
										qtaP4CToChangeTmp_ = qta_prodotto
										if(CLng(qtaP4CToChangeTmp_) <> 0 AND (CLng(qtaFieldRel) - CLng(qtaP4CToChangeTmp_) < 0)) then		
											checked = 0
											bolHasField = false
											message_error = message_error & " - " & request.Form(j) & ": qta= " & qtaFieldRel						
											Exit for
										end if
										bolHasField = true
									else
										'checked = 0
										'response.write(" - la chiave non esiste: "&id_prod&"|"&x&"|"&request.Form(x)&"|"&j&"|"&request.Form(j))
										'exit for														
									end if
								'Set tmpF4OR = nothing
							'next
						end if
					next
					if not(bolHasField) then
						checked = 0
						exit for
					end if
				end if
			end if

			Set listFieldRelVal = nothing
			if(err.number<>0)then
				'response.write("Related field error: "&Err.description&"<br>")
				'checked = 0
				'exit for
			end if
		end if



	end if
	if(Err.number<>0)then
		'response.write("generic error: "&Err.description&"<br>")
		'checked = 0
	end if
next

Set objProdField = nothing
%>
<result>
<checked id="checked_qta"><%=checked%></checked>
<message_error id="message_error_qta"><%=message_error%></message_error>
</result>