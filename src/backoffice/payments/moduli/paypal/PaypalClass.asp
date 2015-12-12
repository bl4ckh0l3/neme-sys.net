<%
Class PaypalClass
	Private id
	Private keyword
	Private value
	Private match_field
	
	
	Public Function getID()
		getID = id
	End Function
	
	Public Sub setID(strID)
		id = strID
	End Sub
	
	Public Function getKeyword()
		getKeyword = keyword
	End Function
	
	Public Sub setKeyword(strKeyword)
		keyword = strKeyword
	End Sub
	
	Public Function getValue()
		getValue = value
	End Function
	
	Public Sub setValue(strValue)
		value = strValue
	End Sub
	
	Public Function getMatchField()
		getMatchField = match_field
	End Function
	
	Public Sub setMatchField(strMatchField)
		match_field = strMatchField
	End Sub	
		
	Public Function getListaPaypalField()
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict		
		getListaPaypalField = null		
		strSQL = "SELECT * FROM paypal_field"
				
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()		
		Set objRS = objConn.Execute(strSQL)
		if not(objRS.EOF) then			
			Set objDict = Server.CreateObject("Scripting.Dictionary")
			Dim objPaypal
			do while not objRS.EOF				
				Set objPaypal = new PaypalClass
				strID = objRS("id")
				strKeyword = objRS("keyword")
				objPaypal.setID(strID)
				objPaypal.setKeyword(strKeyword)	
				objPaypal.setValue(objRS("value"))
				objPaypal.setMatchField(objRS("match_field"))
				objDict.add strKeyword, objPaypal
				objRS.moveNext()
			loop
			Set objPaypal = nothing							
			Set getListaPaypalField = objDict			
			Set objDict = nothing				
		end if
		
		Set objRS = Nothing
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	End Function
		
	Public Function getListaPaypalFieldMatch()
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict		
		getListaPaypalFieldMatch = null		
		strSQL = "SELECT * FROM paypal_field WHERE match_field <>'' AND NOT match_field IS NULL"
				
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()		
		Set objRS = objConn.Execute(strSQL)
		if not(objRS.EOF) then			
			Set objDict = Server.CreateObject("Scripting.Dictionary")
			do while not objRS.EOF				
				strMatchField = objRS("match_field")
				strKeyword = objRS("keyword")
				objDict.add strKeyword, strMatchField
				objRS.moveNext()
			loop			
			Set getListaPaypalFieldMatch = objDict			
			Set objDict = nothing				
		end if
		
		Set objRS = Nothing
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	End Function
		
	Public Function getListaPaypalFieldNotMatch()
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict		
		getListaPaypalFieldNotMatch = null		
		strSQL = "SELECT * FROM paypal_field WHERE match_field ='' OR match_field IS NULL"
				
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()		
		Set objRS = objConn.Execute(strSQL)
		if not(objRS.EOF) then			
			Set objDict = Server.CreateObject("Scripting.Dictionary")
			do while not objRS.EOF
				strKeyword = objRS("keyword")
				strValue = objRS("value")
				objDict.add strKeyword, strValue
				objRS.moveNext()
			loop					
			Set getListaPaypalFieldNotMatch = objDict			
			Set objDict = nothing				
		end if
		
		Set objRS = Nothing
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	End Function
		
	Public Function findPaypalFieldByID(id)
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict
		findPaypalFieldByID = null		
		strSQL = "SELECT * FROM paypal_field WHERE id=?;"
		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()	
		Dim objCommand
		Set objCommand = Server.CreateObject("ADODB.Command")
		objCommand.ActiveConnection = objConn
		objCommand.CommandType=1
		objCommand.CommandText = strSQL
		objCommand.Parameters.Append objCommand.CreateParameter(,19,1,,id)
		Set objRS = objCommand.Execute()	
		
		if not(objRS.EOF) then
			Dim objPaypal
			Set objPaypal = new PaypalClass
			strID = objRS("id")
			strKeyword = objRS("keyword")
			objPaypal.setID(strID)
			objPaypal.setKeyword(strKeyword)	
			objPaypal.setValue(objRS("value"))
			objPaypal.setMatchField(objRS("match_field"))
			Set findPaypalFieldByID = objPaypal
			Set objPaypal = nothing				
		end if
		
		Set objRS = Nothing
		Set objCommand = Nothing	
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	End Function
		
	Public Function findPaypalFieldByKeyword(keyword)
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict
		findPaypalFieldByKeyword = null		
		strSQL = "SELECT * FROM paypal_field WHERE keyword=?;"
		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()		
		Dim objCommand
		Set objCommand = Server.CreateObject("ADODB.Command")
		objCommand.ActiveConnection = objConn
		objCommand.CommandType=1
		objCommand.CommandText = strSQL
		objCommand.Parameters.Append objCommand.CreateParameter(,200,1,50,keyword)
		Set objRS = objCommand.Execute()
		
		if not(objRS.EOF) then
			Dim objPaypal
			Set objPaypal = new PaypalClass
			strID = objRS("id")
			strKeyword = objRS("keyword")
			objPaypal.setID(strID)
			objPaypal.setKeyword(strKeyword)	
			objPaypal.setValue(objRS("value"))
			objPaypal.setMatchField(objRS("match_field"))	
			Set findPaypalFieldByKeyword = objPaypal
			Set objPaypal = nothing				
		end if
		
		Set objRS = Nothing
		Set objCommand = Nothing	
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	End Function	
			
	Public Sub insertPaypalField(strKeyword, strValue, strMatchField)
		on error resume next
		Dim objDB, strSQL, objRS, objConn
		
		strSQL = "INSERT INTO paypal_field(keyword, descrizione, value, match_field) VALUES("
		strSQL = strSQL & "?,?,?,?);"

		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()		
		
		Dim objCommand
		Set objCommand = Server.CreateObject("ADODB.Command")
		objCommand.ActiveConnection = objConn
		objCommand.CommandType=1
		objCommand.CommandText = strSQL
		objCommand.Parameters.Append objCommand.CreateParameter(,200,1,50,strKeyword)
		objCommand.Parameters.Append objCommand.CreateParameter(,200,1,100,strValue)
		objCommand.Parameters.Append objCommand.CreateParameter(,200,1,50,strMatchField)
		objCommand.Execute()
		
		Set objCommand = Nothing
		Set objDB = nothing
		
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
	End Sub
		
	Public Sub modifyPaypalField(id, strKeyword, strValue, strMatchField)
		on error resume next
		Dim objDB, strSQL, objRS, objConn
		strSQL = "UPDATE paypal_field SET "
		strSQL = strSQL & "keyword=?,"
		strSQL = strSQL & "value=?,"
		strSQL = strSQL & "match_field=?"	
		strSQL = strSQL & " WHERE id=?;"
		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()			
		Dim objCommand
		Set objCommand = Server.CreateObject("ADODB.Command")
		objCommand.ActiveConnection = objConn
		objCommand.CommandType=1
		objCommand.CommandText = strSQL
		objCommand.Parameters.Append objCommand.CreateParameter(,200,1,50,strKeyword)
		objCommand.Parameters.Append objCommand.CreateParameter(,200,1,100,strValue)
		objCommand.Parameters.Append objCommand.CreateParameter(,200,1,50,strMatchField)
		objCommand.Parameters.Append objCommand.CreateParameter(,19,1,,id)
		objCommand.Execute()		
		Set objCommand = Nothing
		Set objDB = nothing
		
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
	End Sub		
		
	Public Sub deletePaypalField(id)
		on error resume next
		Dim objDB, strSQLDelPaypal, objRS, objConn	
		
		strSQLDelPaypal = "DELETE FROM paypal_field WHERE id=?;"

		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		Dim objCommand
		Set objCommand = Server.CreateObject("ADODB.Command")
		objCommand.ActiveConnection = objConn
		objCommand.CommandType=1
		objCommand.CommandText = strSQLDelPaypal
		objCommand.Parameters.Append objCommand.CreateParameter(,19,1,,id)
		objCommand.Execute()
		
		Set objCommand = Nothing	
		Set objDB = Nothing
		
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
	End Sub

End Class
%>