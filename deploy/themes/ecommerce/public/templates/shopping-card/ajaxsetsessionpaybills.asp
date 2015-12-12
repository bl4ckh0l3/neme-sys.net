<%
operation = request("operation")
'response.write("operation: "&operation)

for each x in request.Form
	if(x<>"operation")then
		'response.write(" - x:"&x&"; - request.Form(x):"&request.Form(x))
		'response.write(" - Session(x) start:"&Session(x)&"; ")
		'controllo se esiste già una selezione in sessione e nel caso aggiungo il nuovo valore con la virgola
		'devo verificare anche la selezione con valore vuoto che sigifica unchecked
		if(Session(x)<>"" AND operation="del")then
			'response.write(" - Session("&x&") del start:"&Session(x)&"; ")
			sessionTmp = Session(x)
			Session(x)=""
			'response.write(" - Session(x) del start 2:"&Session(x)&"; ")
			for each q in Split(Trim(sessionTmp),",")
				'response.write(" - q:"&q&"-request.Form(x):"&request.Form(x)&"; ")
				if(Trim(q)<>request.Form(x)) then
					Session(x)=Session(x)&Trim(q)&","
				end if
			next
			'response.write(" - Session("&x&") del before end:"&Session(x)&"; ")
			if(Len(Session(x))>0)then
				Session(x)=Left(Session(x),Len(Session(x))-1)
			end if
			'response.write(" - Session("&x&") del end:"&Session(x)&"; ")
		elseif(Session(x)<>"" AND operation="add")then
			Session(x)=Session(x)&","&Trim(request.Form(x))
			'response.write(" - Session("&x&") add:"&Session(x)&"; ")	
		elseif(operation="addone")then
			Session(x)=Trim(request.Form(x))
			'response.write(" - Session("&x&") addone:"&Session(x)&"; ")
		else
			Session(x)=Trim(request.Form(x))
			'response.write(" - Session("&x&") else:"&Session(x)&"; ")		
		end if
	end if
next
%>