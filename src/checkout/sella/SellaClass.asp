<%
Class SellaClass
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
		
	Public Function getListaSellaField()
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict		
		getListaSellaField = null		
		strSQL = "SELECT * FROM sella_field"
				
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()		
		Set objRS = objConn.Execute(strSQL)
		if not(objRS.EOF) then			
			Set objDict = Server.CreateObject("Scripting.Dictionary")
			Dim objSella
			do while not objRS.EOF				
				Set objSella = new SellaClass
				strID = objRS("id")
				strKeyword = objRS("keyword")
				objSella.setID(strID)
				objSella.setKeyword(strKeyword)	
				objSella.setValue(objRS("value"))
				objSella.setMatchField(objRS("match_field"))
				objDict.add strKeyword, objSella
				objRS.moveNext()
			loop
			Set objSella = nothing							
			Set getListaSellaField = objDict			
			Set objDict = nothing				
		end if
		
		Set objRS = Nothing
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	End Function
		
	Public Function getListaSellaFieldMatch()
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict		
		getListaSellaFieldMatch = null		
		strSQL = "SELECT * FROM sella_field WHERE match_field <>'' AND NOT match_field IS NULL"
				
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
			Set getListaSellaFieldMatch = objDict			
			Set objDict = nothing				
		end if
		
		Set objRS = Nothing
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	End Function
		
	Public Function getListaSellaFieldNotMatch()
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict		
		getListaSellaFieldNotMatch = null		
		strSQL = "SELECT * FROM sella_field WHERE match_field ='' OR match_field IS NULL"
				
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
			Set getListaSellaFieldNotMatch = objDict			
			Set objDict = nothing				
		end if
		
		Set objRS = Nothing
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	End Function
		
	Public Function findSellaFieldByID(id)
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict
		findSellaFieldByID = null		
		strSQL = "SELECT * FROM sella_field WHERE id=?;"
		
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
			Dim objSella
			Set objSella = new SellaClass
			strID = objRS("id")
			strKeyword = objRS("keyword")
			objSella.setID(strID)
			objSella.setKeyword(strKeyword)	
			objSella.setValue(objRS("value"))
			objSella.setMatchField(objRS("match_field"))
			Set findSellaFieldByID = objSella
			Set objSella = nothing				
		end if
		
		Set objRS = Nothing
		Set objCommand = Nothing
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	End Function
		
	Public Function findSellaFieldByKeyword(keyword)
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict
		findSellaFieldByKeyword = null		
		strSQL = "SELECT * FROM sella_field WHERE keyword=?;"
		
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
			Dim objSella
			Set objSella = new SellaClass
			strID = objRS("id")
			strKeyword = objRS("keyword")
			objSella.setID(strID)
			objSella.setKeyword(strKeyword)	
			objSella.setValue(objRS("value"))
			objSella.setMatchField(objRS("match_field"))	
			Set findSellaFieldByKeyword = objSella
			Set objSella = nothing				
		end if
		
		Set objRS = Nothing
		Set objCommand = Nothing
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	End Function	
			
	Public Sub insertSellaField(strKeyword, strValue, strMatchField)
		on error resume next
		Dim objDB, strSQL, objRS, objConn
		
		strSQL = "INSERT INTO sella_field(keyword, descrizione, value, match_field) VALUES("
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
		
	Public Sub modifySellaField(id, strKeyword, strValue, strMatchField)
		on error resume next
		Dim objDB, strSQL, objRS, objConn
		strSQL = "UPDATE sella_field SET "
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
		
	Public Sub deleteSellaField(id)
		on error resume next
		Dim objDB, strSQLDelPaypal, objRS, objConn	
		
		strSQLDelPaypal = "DELETE FROM sella_field WHERE id=?;" 

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