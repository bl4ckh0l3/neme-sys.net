<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/common/include/Objects/CommentsClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include file="include/init2.asp" -->
		<table border="0" cellpadding="0" cellspacing="0" class="secondary">
		<tr>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.id_prodotto")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.cod_prod")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.nome_prod")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.prod_attivo")%></th>		
		</tr>
		<tr>
		<td><%=id_prod%></td>
		<td class="separator">&nbsp;</td>
		<td><%=Server.HTMLEncode(strCodProd)%></td>
		<td class="separator">&nbsp;</td>
		<td><%=Server.HTMLEncode(strNomeProd)%></td>
		<td class="separator">&nbsp;</td>
		<td><%
		Select Case stato_prod
		Case 0
			response.write(langEditor.getTranslated("backend.commons.no"))
		Case 1
			response.write(langEditor.getTranslated("backend.commons.yes"))
		Case Else
		End Select
		%></td>		
		</tr>
		<tr>
		<th colspan="7"><%=langEditor.getTranslated("backend.prodotti.view.table.label.sommario_prod")%></th>
		</tr>
		<tr>
		<td colspan="7"><%=strSommarioProd%></td>
		</tr>
		<tr>
		<th colspan="7"><%=langEditor.getTranslated("backend.prodotti.view.table.label.desc_prod")%></th>
		</tr>
		<tr>
		<td colspan="7"><%=strDescProd%></td>
		</tr>

		<tr>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.page_title")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.meta_description")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.meta_keyword")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.edit_buy_qta")%></th>
		</tr>
		<tr>
		<td><%=page_title%></td>
		<td class="separator">&nbsp;</td>
		<td><%=meta_description%></td>
		<td class="separator">&nbsp;</td>
		<td><%=meta_keyword%></td>
		<td class="separator">&nbsp;</td>
		<td><%if(edit_buy_qta = 0)then%><%=langEditor.getTranslated("backend.commons.no")%><%else%><%=langEditor.getTranslated("backend.commons.yes")%><%end if%></td>
		</tr>	

		<tr>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.prezzo_prod")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.tassa_applicata")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.taxs_group")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.sconto_prod")%></th>		
		</tr>
		<tr>
		<td>&euro;&nbsp;<%=FormatNumber(numPrezzo,2,-1,-2,0)%></td>
		<td class="separator">&nbsp;</td>
		<td><%Dim objTasse, objTassa
		Set objTasse = new TaxsClass
		On Error Resume next
		Set objTassa = objTasse.findTassaByID(id_tassa_applicata)
		response.write(objTassa.getDescrizioneTassa())
		Set objTassa = nothing	
		if(Err.number<>0) then
			'response.write(Err.description)
		end if
		Set objTasse = nothing%></td>
		<td class="separator">&nbsp;</td>
		<td><%
		Dim taxsG, objTaxGroup
		Set objTaxGroup = new TaxsGroupClass
		On Error resume Next
		Set taxsG = objTaxGroup.getGroupByID(taxs_group)
		response.Write(taxsG.getGroupDescription())
		Set taxsG = nothing
		if(Err.number <> 0)then
		end if
		%></td>
		<td class="separator">&nbsp;</td>
		<td><%=sconto_prod%>%</td>		
		</tr>
		<tr>		  
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.target_x_prod")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.attached_files")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.qta_prod")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.detail.table.label.prod_type")%></th>
		</tr>
		<tr>		  
		<td><%
		if (Instr(1, typename(objTarget), "dictionary", 1) > 0) then
			for each y in objTarget.Keys
				if (objTarget(y).getTargetType() = 3) then		
					if not(langEditor.getTranslated("portal.header.label.desc_lang."&Replace(objTarget(y).getTargetDescrizione(), "lang_", "", 1, -1, 1)) = "") then response.write (langEditor.getTranslated("portal.header.label.desc_lang."&Replace(objTarget(y).getTargetDescrizione(), "lang_", "", 1, -1, 1)) & "<br>") else response.write(objTarget(y).getTargetDescrizione()& "<br>") end if									
				end if		
			next		
			
			Dim CategoriatmpClass, objCategorieXProd
			Set CategoriatmpClass = new CategoryClass
			for each y in objTarget.Keys
				if (objTarget(y).getTargetType() = 2) then
					Set objCategorieXProd = CategoriatmpClass.findCategorieByTargetID(y)
					if not (isNull(objCategorieXProd)) then
						for each z in objCategorieXProd.Keys
							response.write (objCategorieXProd(z).getCatDescrizione() & "<br>")
						next
					end if
					Set objCategorieXProd = nothing
				end if									
			next	
			Set CategoriatmpClass = Nothing	
			Set objTarget = nothing
		end if%></td>
		<td class="separator">&nbsp;</td>
		<td><%
		if not(isNull(objProd)) then
			Dim objFileInProd
			for each z in objProd.Keys
				Set objFileInProd = objProd(z)
				response.write objFileInProd.getFileName() & "<br>"
				Set objFileInProd = nothing	
			next
			Set objProd = nothing
		end if
		
		Set objSelProdotti = nothing
		%></td>		
		<td class="separator">&nbsp;</td>
		<td><%if(numQta = Application("unlimited_key"))then%><%=langEditor.getTranslated("backend.prodotti.detail.table.label.qta_unlimited")%><%else%><%=numQta%><%end if%></td>	
		<td class="separator">&nbsp;</td>
		<td>
		<%if(prod_type = 0)then%>
			<%=langEditor.getTranslated("backend.prodotti.detail.table.label.type_portable")%>
		<%elseif(prod_type = 1)then%>
			<%=langEditor.getTranslated("backend.prodotti.detail.table.label.type_download")%>
		<%elseif(prod_type = 2)then%>
			<%=langEditor.getTranslated("backend.prodotti.detail.table.label.type_ads")%>
		<%end if%></td>
		</tr>
		<tr>		  
		<th><%=langEditor.getTranslated("backend.prodotti.detail.table.label.max_download")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.detail.table.label.max_download_time")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.prod_download")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.detail.table.label.see_comments")%></th>
		</tr>
		<tr>		  
		<td><%
			Select Case max_download
			Case -1
				response.Write(langEditor.getTranslated("backend.prodotti.detail.table.label.unlimited"))		
			Case Else
				response.Write(max_download)
			End Select%></td>
		<td class="separator">&nbsp;</td>
		<td><%
			Select Case max_download_time
			Case -1
				response.Write(langEditor.getTranslated("backend.prodotti.detail.table.label.unlimited"))	
			Case 1
				response.Write("1 "&langEditor.getTranslated("backend.prodotti.detail.table.label.minute"))	
			Case 720
				response.Write("12 "&langEditor.getTranslated("backend.prodotti.detail.table.label.hours"))	
			Case 1440
				response.Write("24 "&langEditor.getTranslated("backend.prodotti.detail.table.label.hours"))		
			Case Else
				response.Write(max_download_time&" "&langEditor.getTranslated("backend.prodotti.detail.table.label.minutes"))		
			End Select%></td>		
		<td class="separator">&nbsp;</td>
		<td><%
		Dim objListDownProd
		Set objDownloadedProdUpload = new DownloadableProductClass
		if (Instr(1, typename(objDownloadedProdUpload.getFilePerProdotto(id_prod)), "Dictionary", 1) > 0) then
			Set objListDownProd = objDownloadedProdUpload.getFilePerProdotto(id_prod)
			Dim objFilesDownProd
			for each key in objListDownProd
				Set objFilesDownProd = objListDownProd(key)
			  	response.Write(objFilesDownProd.getFileName()&"<br/>")
				Set objFilesDownProd = nothing	
			next
		end if
		Set objListDownProd = nothing
		Set objDownloadedProdUpload = Nothing
		%></td>	
		<td class="separator">&nbsp;</td>
		<td><%
		Set objCommento = New CommentsClass
		if(not(isNull(objCommento.findCommentiByIDElement(id_prod,2,1)))) then%>
			<a href="javascript:openWin('<%=Application("baseroot")&"/public/layout/include/popupComments.asp?id_element="&id_prod&"&element_type=2&active=1"%>','popupallegati',420,400,100,100);" title="<%=langEditor.getTranslated("backend.news.view.table.label.comments")%>"><img src="<%=Application("baseroot")&"/editor/img/comments.png"%>" hspace="0" vspace="0" border="0"></a>
		<%else
			response.Write("<div align='left'>"&langEditor.getTranslated("backend.prodotti.detail.table.label.no_comments")&"</div><br>")
		end if
		Set objCommento = nothing
		%>		
		</td>
		</tr>

		<tr>		  
		<th colspan="3"><%=langEditor.getTranslated("backend.commons.label.localization")%></th>
		<td class="separator">&nbsp;</td>
		<th>&nbsp;</th>
		<td class="separator">&nbsp;</td>
		<th>&nbsp;</th>
		</tr>
		<tr>		  
		<td colspan="3"><%=strGeolocal%></td>
		<td class="separator">&nbsp;</td>
		<td>&nbsp;</td>
		<td class="separator">&nbsp;</td>
		<td>&nbsp;</td>
		</tr>

		<tr>
		<th colspan="7"><%=langEditor.getTranslated("backend.prodotti.view.table.label.extra_fields")%></th>
		</tr>
		<tr>
		<td colspan="7">
		<%
		On Error Resume next
		if(hasProdFields) then
			for each k in objListProdField
				Set objField  = objListProdField(k)
				
				labelForm = objField.getDescription()
				if not(langEditor.getTranslated("backend.prodotti.detail.table.label."&labelForm)="") then labelForm = langEditor.getTranslated("backend.prodotti.detail.table.label."&labelForm)
				%>
				<span class="labelForm"><%=labelForm%></span>:&nbsp;<%
					select Case objField.getTypeField()
					Case 3,4,5,6
						Dim valueList
						valueList = ""
						Set objListValues = objProdField.getListProductFieldValues(k)
						for each g in objListValues
							valueList = valueList & Server.HTMLEncode(g) & ","
						next
						
						valueList = Left(valueList,InStrRev(valueList,",",-1,1)-1)						
						response.write(valueList)
						
						Set objListValues = nothing
					Case else						
						response.write(Server.HTMLEncode(objField.getSelValue()))
					end select%><br>
				<%Set objField  = nothing
			next
		end if

		Set objListProdField = nothing
		Set objProdField = nothing

		if(Err.number<>0) then
		'response.write(Err.description)
		end if
		%>
		</td>
		</tr>

		<tr>
		<th colspan="7"><%=langEditor.getTranslated("backend.prodotti.view.table.label.related_prod")%></th>
		</tr>
		<tr>
		<td colspan="7">
		<%
		On Error Resume next
		if not(isNull(objRelationsProd)) then
			counter = 1
			for each k in objRelationsProd
				Set objRelProd = objRelationsProd(k)

				On Error Resume Next
					Set objFilesRelProd = objRelProd.getFileXProdotto()	
				If(Err.number <> 0) then
					objFilesRelProd = null
				end if%>

				<%if(counter MOD 4 = 0)then%><div id="clear"></div><%end if%>
				<div id="prodotto-immagine">
				<%if not(isNull(objFilesRelProd)) then%>
					<%Dim hasNotSmallImg
					hasNotSmallImg = true			
					for each xObjFile in objFilesRelProd
						Set objFileXProdotto = objFilesRelProd(xObjFile)
						iTypeFile = objFileXProdotto.getFileTypeLabel()
						if(Cint(iTypeFile) = 1) then%>	
							<img src="<%=Application("dir_upload_prod")&objFileXProdotto.getFilePath()%>" alt="<%=objRelProd.getNomeProdotto()%>" width="100" height="100" />
							<%hasNotSmallImg = false
							Exit for
						end if
						Set objFileXProdotto = nothing	
					next		
					if(hasNotSmallImg) then%>
					<img width="100" height="100" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0">
					<%end if
					Set objFilesRelProd = nothing
					else%>
					<img width="100" height="100" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0">
					<%end if%>
				</div>
				<div id="prodotto-testo">
				<p><%=objRelProd.getNomeProdotto()%></p>
				<strong><%=langEditor.getTranslated("backend.prodotti.detail.table.label.cod_rel_prod")%>:</strong>&nbsp;<%=objRelProd.getCodiceProd()%>
				</div>
				<%Set objRelProd = nothing				
				counter = counter +1
			next
		end if

		Set objRelationsProd = nothing

		if(Err.number<>0) then
		'response.write(Err.description)
		end if
		%>
		</td>
		</tr>
		</table>