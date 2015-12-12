        <script language="Javascript">  
        function changeActiveLang(strAction, strLangCode){
            document.form_change_lang.action=strAction;
            document.form_change_lang.langCode.value=strLangCode;
            document.form_change_lang.submit();
        }
        </script>
				<ul>
				<li><%
				  Dim objSelLanguage, objTmpSelLanguage, objSelListaLanguage, strActiveLang
				  Set objSelLanguage = New LanguageClass
				  On error Resume Next
				  Set objSelListaLanguage = objSelLanguage.getListaLanguage()
				  for each z in objSelListaLanguage
					Set objTmpSelLanguage = objSelListaLanguage(z)
          
          if(objTmpSelLanguage.isLangActive()) then
            url = Application("baseroot") & "/default.asp"
            
            bolSubActive = objTmpSelLanguage.isSubDomainActive()
            if(bolSubActive)then
              url = base_url&objTmpSelLanguage.getURLSubDomain()&url				
            else
              url = base_url&Application("srt_default_server_name")&url							
            end if
            
            strActiveLang = ""
            if(strComp(objTmpSelLanguage.getLanguageDescrizione(), lang.getLangCode(), 1) = 0) then
              strActiveLang = "lang-widget-active"
            end if%>                
            <a href="javascript:changeActiveLang('<%=url%>', '<%=objTmpSelLanguage.getLanguageDescrizione()%>');" title="<%=lang.getTranslated("portal.header.label.desc_lang."&objTmpSelLanguage.getLanguageDescrizione())%>" class="<%=strActiveLang%>"><img src="<%=Application("baseroot")&"/common/img/flag/flag-"&objTmpSelLanguage.getLanguageDescrizione()&".png"%>" alt="<%=objTmpSelLanguage.getLanguageDescrizione()%>" border="0" align="absmiddle" /></a>
				  <%end if
          Set objTmpSelLanguage = nothing
				  next
				  Set objSelListaLanguage = nothing	
				  if(Err.number <> 0)then
				  end if
				  Set objSelLanguage = nothing
				  %></li>
				</ul>
			<form action="" method="post" name="form_change_lang">	
			<input type="hidden" value="<%=strGerarchia%>" name="gerarchia">	
			<input type="hidden" value="" name="langCode">          
			</form>