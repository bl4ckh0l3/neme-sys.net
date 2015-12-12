<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ShippingAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/BillsAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/UserFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/UserFieldClass.asp" -->
	

		<%Dim id_utente, objUserLogged
		id_utente = request("id_user")
		
		Set objUserLogged = new UserClass
		
		Dim objClientTmp, hasSconto, scontoCliente, hasGroup, groupCliente, groupDesc
		Dim objGroup
		Set objGroup = new UserGroupClass

		hasSconto=false
		hasGroup = false
		scontoCliente = 0
		groupCliente = ""
		groupDesc = ""
		

		if(not(id_utente = "")) then
			Set objClientTmp = objUserLogged.findUserByID(id_utente)%>	
			<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.order_client")%></span>:&nbsp;			
			<%response.write(objClientTmp.getUserName())

			groupCliente = objClientTmp.getGroup()
			if(not(groupCliente= "")) then
				hasGroup = true
				groupDesc = objGroup.findUserGroupByID(groupCliente).getShortDesc()
			end if

			scontoCliente = objClientTmp.getSconto()
			if(not(scontoCliente= "")) then
				scontoCliente = Cdbl(scontoCliente)
				if(scontoCliente > 0) then
					hasSconto = true%>
					&nbsp;(<%=langEditor.getTranslated("backend.ordini.detail.table.label.sconto_cliente")%>:&nbsp;<%=scontoCliente%>%)
				<%end if
			end if

			if(hasGroup) then
				response.write("<br/>"&langEditor.getTranslated("backend.ordini.detail.table.label.if_client_has_group")&groupDesc)
			else
				if(hasSconto AND Application("manage_sconti") = 0) then
					response.write("<br/>"&langEditor.getTranslated("backend.ordini.detail.table.label.if_client_has_sconto"))
				end if
			end if
			response.write("<br/><br/>")
			Set objClientTmp = nothing
			
			

			'********** RECUPERO LA LISTA DI FIELD UTENTE DISPONIBILI
			Dim objUserField, objListUserField, objUserFieldGroup, strPrecFieldgroup, strFieldgroup, fieldMatchValue, hasUserFields
			hasUserFields=false
			On Error Resume Next
			Set objUserField = new UserFieldClass
			Set objListUserField = objUserField.getListUserField(1,"2,3")
			if(objListUserField.count > 0)then
			  hasUserFields=true
			end if
			if(Err.number <> 0) then
			  hasUserFields=false
			end if                  
				
			strPrecFieldgroup = ""
			fieldMatchValue = ""
				
			Dim userFieldcount
			userFieldcount =1
			if(hasUserFields) then
			for each k in objListUserField
			    On Error Resume next
			    Set objField = objListUserField(k)

			      fieldMatchValue = objUserField.findFieldMatchValue(objField.getID(),id_utente)
			  
			      select Case objField.getTypeField()
			      Case 6,7
				if not(fieldMatchValue = "") AND not(isNull(fieldMatchValue)) then
				  fieldMatchValueArr = split(fieldMatchValue,",")
				  fieldMatchValue = ""
				  fieldMatchValueTmp =""
				  for j=0 to Ubound(fieldMatchValueArr)
				      if not(langEditor.getTranslated("backend.utenti.detail.table.label."&fieldMatchValueArr(j))="") then fieldMatchValueTmp = langEditor.getTranslated("backend.utenti.detail.table.label."&fieldMatchValueArr(j)) else fieldMatchValueTmp=fieldMatchValueArr(j) end if
				      fieldMatchValue = fieldMatchValue & fieldMatchValueTmp&", "
				  next
				  fieldMatchValue = Left(fieldMatchValue,InStrRev(fieldMatchValue,", ",-1,1)-1)
				end if              
			      Case Else
			      End Select 
			  
			    if(userFieldcount=1) then
			      strFieldgroup = objField.getObjGroup().getDescription()
			      strPrecFieldgroup = strFieldgroup%>
			      <b><%if not(langEditor.getTranslated("backend.utenti.detail.table.label.group."&strFieldgroup)="") then response.write(langEditor.getTranslated("backend.utenti.detail.table.label.group."&strFieldgroup)) else response.write(strFieldgroup) end if%></b><br/>
			      <span><%if not(langEditor.getTranslated("backend.utenti.detail.table.label."&objField.getDescription())="") then response.write(langEditor.getTranslated("backend.utenti.detail.table.label."&objField.getDescription())) else response.write(objField.getDescription()) end if%>:</span>&nbsp;
			      <%=fieldMatchValue%><br/>
			  <%else
				strFieldgroup = objField.getObjGroup().getDescription()
				if(strFieldgroup = strPrecFieldgroup) then%>
				  <span><%if not(langEditor.getTranslated("backend.utenti.detail.table.label."&objField.getDescription())="") then response.write(langEditor.getTranslated("backend.utenti.detail.table.label."&objField.getDescription())) else response.write(objField.getDescription()) end if%>:</span>&nbsp;
				  <%=fieldMatchValue%><br/>                
				<%else%>
				  <b><%if not(langEditor.getTranslated("backend.utenti.detail.table.label.group."&strFieldgroup)="") then response.write(langEditor.getTranslated("backend.utenti.detail.table.label.group."&strFieldgroup)) else response.write(strFieldgroup) end if%></b><br/>
				  <span><%if not(langEditor.getTranslated("backend.utenti.detail.table.label."&objField.getDescription())="") then response.write(langEditor.getTranslated("backend.utenti.detail.table.label."&objField.getDescription())) else response.write(objField.getDescription()) end if%>:</span>&nbsp;
				  <%=fieldMatchValue%><br/>                
				<%strPrecFieldgroup = strFieldgroup
				  end if              
			      end if
			      
			    userFieldcount=userFieldcount+1

			    if(Err.number<>0) then
			    response.write(Err.description)
			    end if 
			next 
			end if

		      Set objListUserField = nothing
		      Set objUserField = nothing





		else
			'response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
		end if

		Set objGroup = nothing
		  
		  Set tmpObjUsr = nothing
		  Set objUtente = nothing
		  Set objUserLogged = nothing
		  %>
		<br><br>
		<%' *****************************************************		
		  ' INIZIO: CODICE GESTIONE SHIPPING ADDRESS	
		  Dim objShip, orderShip, hasShipAddress
		  Dim userName, userSurname, userCfiscVat, userAddress, userCity, userZipCode, userCountry, userStateRegion
		  
		  userName = ""
		  userSurname = ""
		  userCfiscVat = ""
		  userAddress = ""
		  userCity = ""
		  userZipCode = ""
		  userCountry = ""
		  userStateRegion = ""
		  hasShipAddress = false
		  
		  Set objShip = new ShippingAddressClass
		  On Error Resume Next
		  
		  Set orderShip = objShip.findShippingAddressByUserID(id_utente)
		  
		  if (Instr(1, typename(orderShip), "ShippingAddressClass", 1) > 0) then
			userName = orderShip.getName()
			userSurname = orderShip.getSurname()
			userCfiscVat = orderShip.getCfiscVat()
			userAddress = orderShip.getAddress()
			userCity = orderShip.getCity()
			userZipCode = orderShip.getZipCode()
			userCountry = orderShip.getCountry()	
			if not(isNull(orderShip.getStateRegion()) AND not(orderShip.getStateRegion()="")) then
				userStateRegion = " - " & langEditor.getTranslated("portal.commons.select.option.country."&orderShip.getStateRegion())
			end if	
			hasShipAddress = true
		  end if		  
		  
		  Set orderShip = nothing
		  
		  if(Err.number <> 0) then 
			'response.write(Err.description)
		  end if
		  
		  if(hasShipAddress)then%>
			<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.shipping_address")%></span>:<br/>
			<%response.write(userName & " " & userSurname & " - " & userCfiscVat & " - " & userAddress &" - "&userCity&" ("&userZipCode&") - "&langEditor.getTranslated("portal.commons.select.option.country."&userCountry)&userStateRegion)
		  end if
		  Set objShip = nothing%>
		<br><br>
		
		<%' *****************************************************		
		  ' INIZIO: CODICE GESTIONE BILLS ADDRESS
		  Dim objBills, orderBills, hasBillsAddress
		  Dim buserName, buserSurname, buserCfiscVat, buserAddress, buserCity, buserZipCode, buserCountry, buserStateRegion
		  
		  buserName = ""
		  buserSurname = ""
		  buserCfiscVat = ""
		  buserAddress = ""
		  buserCity = ""
		  buserZipCode = ""
		  buserCountry = ""
		  buserStateRegion = ""
		  hasBillsAddress = false
		  
		  Set objBills = new BillsAddressClass
		  On Error Resume Next
		  
		  Set orderBills = objBills.findBillsAddressByUserID(id_utente)
		  
		  if (Instr(1, typename(orderBills), "BillsAddressClass", 1) > 0) then
			buserName = orderBills.getName()
			buserSurname = orderBills.getSurname()
			buserCfiscVat = orderBills.getCfiscVat()
			buserAddress = orderBills.getAddress()
			buserCity = orderBills.getCity()
			buserZipCode = orderBills.getZipCode()
			buserCountry = orderBills.getCountry()		
			if not(isNull(orderBills.getStateRegion()) AND not(orderBills.getStateRegion()="")) then
				buserStateRegion = " - " & langEditor.getTranslated("portal.commons.select.option.country."&orderBills.getStateRegion())
			end if	
			hasBillsAddress = true
		  end if		  
		  
		  Set orderBills = nothing
		  
		  if(Err.number <> 0) then 
			'response.write(Err.description)
		  end if
		  
		  if(hasBillsAddress)then%>
			<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.bills_address")%></span>:<br/>
			<%
			response.write(buserName & " " & buserSurname & " - " & buserCfiscVat & " - " & buserAddress &" - "&buserCity&" ("&buserZipCode&") - "&langEditor.getTranslated("portal.commons.select.option.country."&buserCountry)&buserStateRegion)
		  end if
		  Set objBills = nothing%>