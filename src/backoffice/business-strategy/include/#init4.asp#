<%
if (isEmpty(Session("objCMSUtenteLogged"))) then
	response.Redirect(Application("baseroot")&"/login.asp")
end if

Dim objUserLogged, objUserLoggedTmp
Set objUserLoggedTmp = new UserClass
Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
Set objUserLoggedTmp = nothing
Dim strRuoloLogged
strRuoloLogged = objUserLogged.getRuolo()
if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
end if
Set objUserLogged = nothing

Dim id_rule

id_rule = request("id_rule")
rule_type = 0
label = ""
description = ""
activate = 0
voucher_id = ""

Set objRule = New BusinessRulesClass
Set objVoucherClass =  new VoucherClass
	
if (Cint(id_rule) <> -1) then
	Dim objRule, objSelRule
	Set objSelRule = objRule.findRuleByID(id_rule)	
	id_rule = objSelRule.getID()
	rule_type = objSelRule.getRuleType()
	label = objSelRule.getLabel()		
	description = objSelRule.getDescrizione()	
	activate = objSelRule.getActivate()	
	voucher_id = objSelRule.getVoucherID()
	Set objSelRule = Nothing		
end if

Dim bolHasListRules, objListRules
bolHasListRules = false
On Error Resume Next
Set objListRules = objRule.getListaRules("1,2,4,5", null)
Set objDict = Server.CreateObject("Scripting.Dictionary")
for each k in objListRules
	objDict.add objListRules(k).getRuleType(), k
next
Set objListRules = nothing
bolHasListRules = true
if(Err.number <> 0)then
	bolHasListRules = false
	'response.write(Err.description)
end if

On Error Resume Next
hasVoucherCampaign = false
Set objListVoucherCampaign = objVoucherClass.getCampaignList(null, 1)
if(objListVoucherCampaign.count>0)then
	hasVoucherCampaign = true
end if
if(Err.number <> 0)then
	hasVoucherCampaign = false
end if

Dim objProd, bolHasListProd
Set objProd = New ProductsClass

bolHasListProd=false

On Error Resume Next
Set objListRefProd = objProd.getListaProdotti4Relation()
if not(isNull(objListRefProd)) then
	bolHasListProd=true
end if

if(Err.number <> 0)then
	bolHasListProd=false
	'response.write(Err.description)
end if
Set objProd = Nothing
%>