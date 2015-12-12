<% 
On error resume next 
Server.ScriptTimeout=3600 ' max value = 2147483647
Response.Expires=-1500
Response.Buffer = TRUE
Response.Clear
%>
<!-- #include virtual="/common/include/Objects/FileUploadClass.asp" -->
<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/CardClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductsCardClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Paginazione.inc" -->

<%
Dim id_user, numSconto, objCarrelloUser, carrello, Prodotto, hasSessionIDCard, bolHasObj
numSconto= 0

Set carrello = New CardClass
Set Prodotto = New ProductsClass
Set objProdField = new ProductFieldClass

if not(isEmpty(Session("objUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objUtenteLogged"))
	Set objUserLoggedTmp = nothing
	
	if(objUserLogged.getRuolo() <> 3) then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error=023")
	end if
	
	hasSessionIDCard = carrello.findCarrelloByIDUser(Session.SessionID)	
	id_user = objUserLogged.getUserID()
	numSconto= objUserLogged.getSconto()
	
	if(hasSessionIDCard) then	
		Set objCarrelloUser = carrello.getCarrelloByIDUser(Session.SessionID)	
		call objCarrelloUser.updateIDUtenteCarrello(objCarrelloUser.getIDCarrello(), id_user)
		Set objCarrelloUser = carrello.getCarrelloByIDUser(id_user)
	else
		Set objCarrelloUser = carrello.getCarrelloByIDUser(id_user)
	end if
	
	Set objUserLogged = nothing
else	
	Set objCarrelloUser = carrello.getCarrelloByIDUser(Session.SessionID)
end if	

Set Upload = New FileUploadClass
Upload.SaveField()

Dim objProdTmp, objListaCarrello, order_carrello_by
Dim id_prodotto, operation, qta_prod, prezzo, totale_prod, id_carrello, counter_prod, form_counter, resetQta, prod_type
order_carrello_by = 3
id_carrello = -1
id_prodotto = Upload.Form("id_prodotto")
prod_type = Upload.Form("prod_type")
operation = Upload.Form("operation")
qta_prod = Upload.Form("qta_prodotto")
counter_prod = Upload.Form("counter_prod")
form_counter = Upload.Form("form_counter")
id_ads = Upload.Form("id_ads")
resetQta = false
if(Upload.Form("reset_qta")<>"") then
	resetQta = Upload.Form("reset_qta")
end if

if(not(isNull(objCarrelloUser))) then
		Dim objProdPerCarr
		Set objProdPerCarr = New ProductsCardClass

		Dim objLogger
		Set objLogger = New LogClass
		
		'call objLogger.write("form_counter: " & form_counter, "system", "debug")
		'call objLogger.write("id_prodotto: " & id_prodotto, "system", "debug")
		'call objLogger.write("operation: " & operation, "system", "debug")
		'call objLogger.write("qta_prod: " & qta_prod, "system", "debug")
		'call objLogger.write("counter_prod: " & counter_prod, "system", "debug")
		'call objLogger.write("prod_type: " & prod_type, "system", "debug")
		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		
		Select Case operation
		   Case "add"
		   
		   	numCounterProd = 0
		   	hasFieldProdCard = false
		   	hasFieldProdCardCombination = false


				On Error Resume Next
				hasCountField = objProdField.hasListProductField4ProdActive(id_prodotto)
				if(Cint(hasCountField)>0) then
					Set objListProdField = objProdField.getListProductField4ProdActive(id_prodotto)
					'call objLogger.write("objListProdField.count: " & objListProdField.count, "system", "debug")	
	
					if (Instr(1, typename(objListProdField), "Dictionary", 1) > 0) then
						if(objListProdField.count > 0)then
							hasFieldProdCard = true
														
						end if
					end if
				end if	

		   	if(Err.number <> 0) then
		   		hasFieldProdCard = false
				end if	
								
				'call objLogger.write("hasFieldProdCard: " & hasFieldProdCard, "system", "debug")				
				
		   	'**** gestisco il recupero e l'inserimento dei field per prodotto
		   	if(hasFieldProdCard)then
					if (Instr(1, typename(objProdField.findListFieldXCardByProd(null, objCarrelloUser.getIDCarrello(), id_prodotto)), "Dictionary", 1) > 0) then
						Set fieldList4Card = objProdField.findListFieldXCardByProd(null, objCarrelloUser.getIDCarrello(), id_prodotto)			
	
						if(fieldList4Card.count > 0)then											
							for each k in fieldList4Card
								hasFieldProdCardCombination = ""
										
								'call objLogger.write("k: " & k, "system", "debug")
								
								Set objTmpField4Card = fieldList4Card(k)
								keys = objTmpField4Card.Keys
								
								for each r in keys
									Set tmpF4O = r
									'call objLogger.write("objListProdField(tmpF4O.getID()).getTypeField(): " & objListProdField(tmpF4O.getID()).getTypeField(), "system", "debug")
									if(objListProdField(tmpF4O.getID()).getTypeField()=8) then
										ks = Upload.UploadedFiles.keys
										if (UBound(ks) <> -1) then	
											if not(isEmpty(Upload.UploadedFiles("productfield"&form_counter&tmpF4O.getID())))then
												req_field = Application("dir_upload_prod")&"fields/"&id_prodotto &"/"&Session.SessionID&"/"&Upload.UploadedFiles("productfield"&form_counter&tmpF4O.getID()).FileName()
												'call objLogger.write("req_field: " & req_field, "system", "debug")
											end if
										end if
									else																		
										req_field = Upload.Form("productfield"&form_counter&tmpF4O.getID())
									end if

									'call objLogger.write("req_field: "&req_field&" - tmpF4O.getSelValue(): "&tmpF4O.getSelValue()&" - fields match: "&(req_field = tmpF4O.getSelValue()), "system", "debug")
									if (req_field <> "") AND (req_field = tmpF4O.getSelValue())then
										if(hasFieldProdCardCombination = "")then
											hasFieldProdCardCombination = true
										else
											if(hasFieldProdCardCombination)then
												hasFieldProdCardCombination = true
											else
												hasFieldProdCardCombination = false
											end if										
										end if
										'call objLogger.write("first hasFieldProdCardCombination imposto a true: " & hasFieldProdCardCombination, "system", "debug")
									else
										hasFieldProdCardCombination = false
										'call objLogger.write("first hasFieldProdCardCombination imposto a false: " & hasFieldProdCardCombination, "system", "debug")
									end if
																
									Set tmpF4O = nothing
								next
								
								'call objLogger.write("first hasFieldProdCardCombination: " & hasFieldProdCardCombination, "system", "debug")
								'call objLogger.write("(hasFieldProdCardCombination <> ''): " & (hasFieldProdCardCombination <> "") & " - (hasFieldProdCardCombination=true): " & (hasFieldProdCardCombination=true), "system", "debug")
																	
								if (hasFieldProdCardCombination <> "") AND (hasFieldProdCardCombination=true)then
									numCounterProd = k
									Exit for
								end if
								Set objTmpField4Card = nothing							
							next
						end if
						Set fieldList4Card = nothing
					end if
				end if			
		   	
				if(hasFieldProdCard) AND not(hasFieldProdCardCombination)then
					numCounterProd = objProdPerCarr.getMaxItemCounterProd(objCarrelloUser.getIDCarrello(), id_prodotto)
					numCounterProd = Cint(numCounterProd)+1
				end if
								
				'call objLogger.write("numCounterProd: "&numCounterProd, "system", "debug")
				'call objLogger.write("hasFieldProdCard: "& hasFieldProdCard, "system", "debug")
				'call objLogger.write("second hasFieldProdCardCombination: " & hasFieldProdCardCombination, "system", "debug")
					
				if (hasFieldProdCard) then
					Set objFSO = Server.CreateObject("Scripting.FileSystemObject")							
					uploadsDirVar = Application("dir_upload_prod")&"fields/"
					uploadsDirVarVal = uploadsDirVar
					uploadsDirVarVal = uploadsDirVarVal & id_prodotto &"/"&Session.SessionID&"/"
					uploadsDirVar = Server.MapPath(uploadsDirVar)
					uploadsDirVar = uploadsDirVar & "\" & id_prodotto &"\"
					'call objLogger.write("uploadsDirVar: "&uploadsDirVar, "system", "debug")
					'call objLogger.write("uploadsDirVarVal: "&uploadsDirVarVal, "system", "debug")
					'call objLogger.write("typename(objFSO): "&typename(objFSO), "system", "debug")
					'call objLogger.write("objFSO.FolderExists(uploadsDirVar): "& objFSO.FolderExists(uploadsDirVar), "system", "debug")
					on Error Resume Next
					if not(objFSO.FolderExists(uploadsDirVar)) then
						call objFSO.CreateFolder(uploadsDirVar)
						if not(objFSO.FolderExists(uploadsDirVar & Session.SessionID &"\")) then
							call objFSO.CreateFolder(uploadsDirVar & Session.SessionID &"\")
						end if
						'call objLogger.write("f.Path: "&f.Path, "system", "debug")
					end if
					if not(objFSO.FolderExists(uploadsDirVar & Session.SessionID &"\")) then
						call objFSO.CreateFolder(uploadsDirVar & Session.SessionID &"\")
					end if
					if(Err.number<>0)then
					'call objLogger.write("Err.description: "&Err.description, "system", "debug")
					end if	
					uploadsDirVar = uploadsDirVar & Session.SessionID &"\"
					Set objFSO = nothing
					call Upload.Save(uploadsDirVar)

					for each j in objListProdField
						'call objLogger.write("objListProdField(j).getTypeField(): "&objListProdField(j).getTypeField(), "system", "debug")
						if(objListProdField(j).getTypeField()=8) then
							ks = Upload.UploadedFiles.keys
							if (UBound(ks) <> -1) then	
								if not(isEmpty(Upload.UploadedFiles("productfield"&form_counter&objListProdField(j).getID())))then
									tmpFileName = Upload.UploadedFiles("productfield"&form_counter&objListProdField(j).getID()).FileName()
									prodFieldValueTmp = uploadsDirVarVal & tmpFileName
		
									if(hasFieldProdCardCombination)then
										qtaTochange = objProdField.findFieldXCard(numCounterProd, objCarrelloUser.getIDCarrello(), id_prodotto, objListProdField(j).getID()).getQtaProd()
										qtaTochange = Clng(qtaTochange)+Clng(qta_prod)
										'call objLogger.write("qtaTochange: "&qtaTochange, "system", "debug")
										call objProdField.modifyFieldXCard(numCounterProd, objCarrelloUser.getIDCarrello(), objListProdField(j).getID(), id_prodotto, qtaTochange, prodFieldValueTmp, objConn)
									else			
										'call objLogger.write("qta_prod: "&qta_prod, "system", "debug")					
										call objProdField.insertFieldXCard(numCounterProd, objCarrelloUser.getIDCarrello(), id_prodotto, objListProdField(j).getID(), qta_prod, prodFieldValueTmp, objConn)
									end if
								end if
							end if
						else
							if(Upload.Form("productfield"&form_counter&objListProdField(j).getID()) <> "")then
								'call objLogger.write("request: "&Upload.Form("productfield"&objListProdField(j).getID()), "system", "debug")
								'call objLogger.write("objListProdField(j).getTypeField(): "&objListProdField(j).getTypeField(), "system", "debug")
								prodFieldValueTmp = Upload.Form("productfield"&form_counter&objListProdField(j).getID())	
								if(hasFieldProdCardCombination)then
									qtaTochange = objProdField.findFieldXCard(numCounterProd, objCarrelloUser.getIDCarrello(), id_prodotto, objListProdField(j).getID()).getQtaProd()
									qtaTochange = Clng(qtaTochange)+Clng(qta_prod)
									'call objLogger.write("qtaTochange: "&qtaTochange, "system", "debug")
									call objProdField.modifyFieldXCard(numCounterProd, objCarrelloUser.getIDCarrello(), objListProdField(j).getID(), id_prodotto, qtaTochange, prodFieldValueTmp, objConn)
								else			
									'call objLogger.write("qta_prod: "&qta_prod, "system", "debug")					
									call objProdField.insertFieldXCard(numCounterProd, objCarrelloUser.getIDCarrello(), id_prodotto, objListProdField(j).getID(), qta_prod, prodFieldValueTmp, objConn)
								end if
							end if
						end if
					next
					
					Set objListProdField = nothing	
				end if						   	
		   
			  call objProdPerCarr.addItem(objCarrelloUser.getIDCarrello(), id_prodotto, numCounterProd, qta_prod, prod_type, resetQta, objConn)
		   Case "del"
		   	call objProdField.deleteFieldXCardByProd(counter_prod, objCarrelloUser.getIDCarrello(), id_prodotto, objConn)
			  call objProdPerCarr.delItem(objCarrelloUser.getIDCarrello(), id_prodotto, counter_prod, objConn)
		   Case Else
		End Select
		
		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
		
		Set objDB = nothing
		Set objLogger = nothing			
		Set objProdPerCarr = nothing	
		response.Redirect(Application("baseroot")&Application("dir_upload_templ")&"shopping-card/card.asp?id_carrello=" & objCarrelloUser.getIDCarrello()&"&id_ads="&id_ads&Request.ServerVariables("QUERY_STRING"))
else
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=022")
end if

Set objProdField = nothing

Set objCarrelloUser = nothing
Set carrello = nothing
Set Prodotto = nothing
%>