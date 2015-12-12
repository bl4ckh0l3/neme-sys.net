<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/Paginazione.inc" -->
<!-- #include virtual="/common/include/Objects/SendMailClass.asp" -->
<!-- #include virtual="/common/include/captcha/adovbs.asp"-->
<!-- #include virtual="/common/include/captcha/iasutil.asp"-->
<!-- #include virtual="/common/include/captcha/functions.asp"--> 
<!-- #include file="include/init2.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=pageTemplateTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<%if not(isNull(strCSS)) ANd not(strCSS = "") then%>
<link rel="stylesheet" href="<%=Application("baseroot") & strCSS%>" type="text/css">
<%end if%>
</head>
<body>
<!-- inizio container -->
<div id="container">
	<!-- header -->
	<!-- #include virtual="/public/layout/include/header.inc" -->	
	<!-- header fine -->
	<!-- main -->
	<div id="main">		
		<!-- content -->	
		<div class="content">
			<!-- include virtual="/public/layout/include/Menutips.inc" -->
			<!--
			<%'if bolHasObj then%>
				<h2><%'=objCurrentNews.getTitolo()%></h2>
				<%'if (Len(objCurrentNews.getAbstract1()) > 0) then response.Write("<cite class=box_home>"&objCurrentNews.getAbstract1()&"</cite>") end if
				'if (Len(objCurrentNews.getAbstract2()) > 0) then response.Write("<cite class=box_home>"&objCurrentNews.getAbstract2()&"</cite>") end if
				'if (Len(objCurrentNews.getAbstract3()) > 0) then response.Write("<cite class=box_home>"&objCurrentNews.getAbstract3()&"</cite>") end if
				'response.Write(objCurrentNews.getTesto())
				
				'if(bolHasAttach) then 
				'	for each key in attachMap
				'		if(attachMap(key).count > 0)then%>
							<br/><br/><strong><%'=lang.getTranslated(attachMultiLangKey(key))%></strong><br/>
							<%'for each item in attachMap(key)%>
								<a href="javascript:openWin('<%'=Application("baseroot")&"/public/layout/include/popup.asp?id_allegato="&item.getFileID()&"&parent_type=1"%>','popupallegati',400,400,100,100)"><%'=item.getFileName()%></a><br>
							<%'next
				'		end if
				'	next
				'end if
				'Set objCurrentNews = nothing
			'else
				'response.Write("<br/><br/><div align=""center""><strong>"& lang.getTranslated("portal.commons.templates.label.page_in_progress")&"</strong></div>")
			'end if%>
			-->
			<%response.write(lang.getTranslated("frontend.template_form.label.mail_sent")) %>
		</div>
		<!-- content fine -->		
	</div>
	<!-- main fine -->	
</div>
<!-- fine container -->
<!-- #include virtual="/public/layout/include/bottom.inc" -->
</body>
</html>
<%
Set objListaTargetCat = nothing
Set objListaTargetLang = nothing
Set objListaNews = nothing
Set News = Nothing
%>