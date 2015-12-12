<%	
Set objSelMargin = nothing
Set objShip = nothing              
Set orderBills = nothing
Set objProdField = nothing
Set objProdFieldGroup = nothing
Set currClass = nothing
Set objVoucherClass =  nothing
Set objRule = nothing
Set objOrder = nothing
Set objTasse = nothing
Set carrello = nothing
Set Prodotto = Nothing

if(Err.number <> 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
end if
%>