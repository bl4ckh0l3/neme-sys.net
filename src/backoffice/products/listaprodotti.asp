<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/editor/include/Paginazione.inc" -->
<!-- #include file="include/init.asp" -->
<!-- #include virtual="/editor/include/setlistatargetprod.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script>
function editProduct(idProd){
	location.href='<%=Application("baseroot") & "/editor/prodotti/InserisciProdotto.asp?cssClass=LP&id_prodotto="%>'+idProd;
}

function deleteProduct(id_objref, row,refreshrows){
	if(confirm("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.confirm_del_prod")%>")){		
		ajaxDeleteItem(id_objref,"product",row,refreshrows);
	}
}

function deleteField(id_objref,row,refreshrows){
	if(confirm("<%=langEditor.getTranslated("backend.prodotti.lista.js.alert.delete_field")%>?")){
		ajaxDeleteItem(id_objref,"product_field",row,refreshrows);
	}
}

function confirmClone(idProd){
	if(confirm('<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.confirm_clone_product")%>')){
		location.href='<%=Application("baseroot") & "/editor/prodotti/cloneproducts.asp?cssClass=LP&id_prodotto="%>'+idProd;
	}else{
		return;
	}
}

function showHideDivProdField(element){
	var elementPl = document.getElementById("prodlist");
	var elementaPl = document.getElementById("aprodlist");
	var elementPf = document.getElementById("prodfield");
	var elementaPf = document.getElementById("aprodfield");

	if(element == 'prodlist'){
		elementPf.style.visibility = 'hidden';		
		elementPf.style.display = "none";
		elementaPf.className= "";
		elementPl.style.visibility = 'visible';
		elementPl.style.display = "block";
		elementaPl.className= "active";
	}else if(element == 'prodfield'){
		elementPl.style.visibility = 'hidden';
		elementPl.style.display = "none";
		elementaPl.className= "";
		elementPf.style.visibility = 'visible';		
		elementPf.style.display = "block";
		elementaPf.className= "active";
	}
}

function ajaxViewZoom(idProd, container){
	var dataString;

	if($('#'+container).css("display")=="none"){
		dataString = 'id_prodotto='+ idProd;  
		$.ajax({  
			type: "POST",  
			url: "<%=Application("baseroot") & "/editor/prodotti/ajaxviewproduct.asp"%>",  
			data: dataString,  
			success: function(response) {  
				$('#'+container).html(response); 			
			}
		}); 
	}else{
		$('#'+container).empty();
	}
	$('#'+container).slideToggle();	

	return false; 	
}
</script>
</head>
<body onLoad="showHideDivProdField('<%=showTab%>');">
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<%cssClass="LP"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<table border="0" cellpadding="0" cellspacing="0" align="center" class="filter-table">
		<tr>
		<th align="center"><%=langEditor.getTranslated("backend.prodotti.lista.table.menu.header.txt")%></th>
		</tr>
		<%
		Dim menuFruizioneTmp, iGerLevelTmp, strGerarchiaTmp
		Set menuFruizioneTmp = new MenuClass
		if(isNull(session("strGerTmp")) OR session("strGerTmp") = "" OR (not(isNull(request("resetMenu"))) AND request("resetMenu") = "1")) then
			session("strGerTmp") = "00" 
			session("prodottiPage") = 1
			numPage = session("prodottiPage")
		end if
		if(request("strGerarchiaTmp") = "") then 
			strGerarchiaTmp = session("strGerTmp") 
		else 
			strGerarchiaTmp = request("strGerarchiaTmp")
			session("strGerTmp") = strGerarchiaTmp
		end if		
		iGerLevelTmp = menuFruizioneTmp.getLivello(strGerarchiaTmp)
		
		Set objListCatXProdTmp = CategoryClassTmp.findCategorieByTypeAndMixed(Application("strProdCat"))
		
		for each x in objListCatXProdTmp
			level = menuFruizioneTmp.getLivello(objListCatXProdTmp(x).getCatGerarchia())
			iGerDiff = level - iGerLevelTmp
				
			if(level > 1) then
				iWidth = (level-1) * 10 
				'iLenGer = (level * 2) + (level -1)
				'strSubTmpGer = Left(strGerarchiaTmp, iLenGer)
				'strSubTmpGerFiltered = Left(strSubTmpGer, iLenGer-3)
				strSubTmpGer=objListCatXProdTmp(x).getCatGerarchia()
				if(level>iGerLevelTmp)then
					numDeltaTmpGer = 0
					if(InStrRev(objListCatXProdTmp(x).getCatGerarchia(),".",-1,1)>0)then
						numDeltaTmpGer = Len(objListCatXProdTmp(x).getCatGerarchia())-(InStrRev(objListCatXProdTmp(x).getCatGerarchia(),".",-1,1)-1)
					end if
					strSubTmpGer = Left(objListCatXProdTmp(x).getCatGerarchia(), Len(objListCatXProdTmp(x).getCatGerarchia())-numDeltaTmpGer)
				end if

				numDeltaSubTmpGer = 0
				if(InStrRev(strSubTmpGer,".",-1,1)>0)then
					numDeltaSubTmpGer = Len(strSubTmpGer)-(InStrRev(strSubTmpGer,".",-1,1)-1)
				end if
				strSubTmpGerFiltered = Left(strSubTmpGer, Len(strSubTmpGer)-numDeltaSubTmpGer)
				
				if(iGerDiff <= 1) then
					if(iGerDiff<=0)then
					  strSubTmpGer = strSubTmpGerFiltered
					end if
					if (InStr(1, strGerarchiaTmp, strSubTmpGer, 1) > 0) then
						hrefGer = objListCatXProdTmp(x).getCatGerarchia()
						
						'*** checkSelectedCategory
						bolSelectedCat = false
						strSubSelCat = strGerarchiaTmp
						for a=1 to Abs(iGerDiff)
							strSubSelCat = Left(strSubSelCat,InStrRev(strSubSelCat,".",-1,1)-1)
						next

						if(strComp(objListCatXProdTmp(x).getCatGerarchia(), strSubSelCat, 1) = 0) then
							bolSelectedCat = true
						end if%>
						<tr>
							<td><img width="<%=iWidth%>" height="5" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0" align="left"><img src="<%=Application("baseroot")&"/editor/img/folder_explore.png"%>" hspace="0" vspace="0" border="0" align="left"><a href="<%=Application("baseroot") & "/editor/prodotti/ListaProdotti.asp?page=1&cssClass=LP&target_cat="&objListCatXProdTmp(x).getCatID()&"&strGerarchiaTmp="&hrefGer%>" class="filter-list<%if(bolSelectedCat) then response.Write("-active") end if%>"><%if not(isNull(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia()))) AND not(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia()) = "") then response.write(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia())) else response.Write(objListCatXProdTmp(x).getCatDescrizione()) end if%></a></td>
						</tr>			
					<%end if
				end if
			else
				numDeltaTmpGer = 0
				if(InStr(1, strGerarchiaTmp, ".", 1) > 0)then
					numDeltaTmpGer = Len(strGerarchiaTmp)-(InStr(1, strGerarchiaTmp, ".", 1)-1)
				end if
				strSubTmpGer = Left(strGerarchiaTmp, Len(strGerarchiaTmp)-numDeltaTmpGer)
				hrefGer = objListCatXProdTmp(x).getCatGerarchia()%>
				<tr>
					<td><img src="<%=Application("baseroot")&"/editor/img/folder_explore.png"%>" hspace="0" vspace="0" border="0" align="left"><a href="<%=Application("baseroot") & "/editor/prodotti/ListaProdotti.asp?page=1&cssClass=LP&target_cat="&objListCatXProdTmp(x).getCatID()&"&strGerarchiaTmp="&hrefGer%>" class="filter-list<%if(strComp(objListCatXProdTmp(x).getCatGerarchia(), strSubTmpGer, 1) = 0) then response.Write("-active")%>"><%if not(isNull(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia()))) AND not(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia()) = "") then response.write(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia())) else response.Write(objListCatXProdTmp(x).getCatDescrizione()) end if%></a></td>
				<tr>
			<%end if		
		next	

		Set menuFruizioneTmp = Nothing
		%>
		<tr> 
			<th>&nbsp;</th>
		</tr>
		</table>
		<br/>
		
		
		<div id="tab-prod-field"><a id="aprodlist" <%if(showtab="prodlist")then response.write("class=active") end if%> href="javascript:showHideDivProdField('prodlist');"><%=langEditor.getTranslated("backend.prodotti.lista.table.header.label_prod_list")%></a><a id="aprodfield" <%if(showtab="prodfield")then response.write("class=active") end if%> href="javascript:showHideDivProdField('prodfield');"><%=langEditor.getTranslated("backend.prodotti.lista.table.header.label_prod_field")%></a></div>		
		<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
		<div id="prodlist" style="visibility:visible;display:block;margin:0px;padding:0px;">			
		<table border="0" cellpadding="0" cellspacing="0" class="principal" align="top">
              <tr> 
		<th colspan="4">&nbsp;</th>
		<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.nome")%>&nbsp;<a href="<%=Application("baseroot") & "/editor/prodotti/ListaProdotti.asp?order_by=1&page="&numPage&"&strGerarchiaTmp="&request("strGerarchiaTmp")&"&target_cat="&request("target_cat")&"&itemsProd="&itemsXpageProd%>"><img src="<%=Application("baseroot")&"/editor/img/order_top.gif"%>" alt="<%=langEditor.getTranslated("backend.commons.alt.order_by_asc")%>" hspace="2" vspace="0" border="0"></a><a href="<%=Application("baseroot") & "/editor/prodotti/ListaProdotti.asp?order_by=2&page="&numPage&"&strGerarchiaTmp="&request("strGerarchiaTmp")&"&target_cat="&request("target_cat")&"&itemsProd="&itemsXpageProd%>"><img src="<%=Application("baseroot")&"/editor/img/order_bottom.gif"%>" alt="<%=langEditor.getTranslated("backend.commons.alt.order_by_desc")%>" hspace="2" vspace="0" border="0"></a></th>
		<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.prezzo")%>&nbsp;<a href="<%=Application("baseroot") & "/editor/prodotti/ListaProdotti.asp?order_by=11&page="&numPage&"&strGerarchiaTmp="&request("strGerarchiaTmp")&"&target_cat="&request("target_cat")&"&itemsProd="&itemsXpageProd%>"><img src="<%=Application("baseroot")&"/editor/img/order_top.gif"%>" alt="<%=langEditor.getTranslated("backend.commons.alt.order_by_asc")%>" hspace="2" vspace="0" border="0"></a><a href="<%=Application("baseroot") & "/editor/prodotti/ListaProdotti.asp?order_by=12&page="&numPage&"&strGerarchiaTmp="&request("strGerarchiaTmp")&"&target_cat="&request("target_cat")&"&itemsProd="&itemsXpageProd%>"><img src="<%=Application("baseroot")&"/editor/img/order_bottom.gif"%>" alt="<%=langEditor.getTranslated("backend.commons.alt.order_by_desc")%>" hspace="2" vspace="0" border="0"></a></th>
		<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.quantita")%></th>
		<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.attivo")%></th>
		<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.category")%></th>
		<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.lang")%></th>
		<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.tassa")%></th>
		<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.prod_type")%></th>
              </tr>
			  
				<%
				Dim hasProd
				hasProd = false
				on error Resume Next
					Set objListaProdotti = objProdotti.findProdotti(null, null, null, null, null, null, null, null, null, order_prod_by, objListaTargetProdTmp, objListaTargetLangTmp, 1, 0)
					
					if(objListaProdotti.Count > 0) then
						hasProd = true
					end if
					
				if Err.number <> 0 then
				end if	
				
				if(hasProd) then
									
					Dim intCount
					intCount = 0
					
					Dim prodCounter, iIndex, objTmpProd, objTmpProdKey, FromProd, ToProd, Diff, objTarget
					iIndex = objListaProdotti.Count
					FromProd = ((numPageProd * itemsXpageProd) - itemsXpageProd)
					Diff = (iIndex - ((numPageProd * itemsXpageProd)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToProd = iIndex - Diff
					
					totPages = iIndex\itemsXpageProd
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD itemsXpageProd <> 0) AND not ((totPages * itemsXpageProd) >= iIndex)) then
						totPages = totPages +1	
					end if		
							
					objTmpProd = objListaProdotti.Items
					objTmpProdKey=objListaProdotti.Keys
					objTarget = null
					
					Dim styleRow, styleRow2
					styleRow2 = "table-list-on"					
							
					for prodCounter = FromProd to ToProd
						styleRow = "table-list-off"
						if(prodCounter MOD 2 = 0) then styleRow = styleRow2 end if
						Set objFilteredProd = objTmpProd(prodCounter)
						Set objTarget = objFilteredProd.getListaTarget()
						%>		
						<tr class="<%=styleRow%>" id="tr_delete_list_<%=intCount%>">
						<td align="center" width="25"><a href="javascript:confirmClone('<%=objFilteredProd.getIDProdotto()%>');"><img src="<%=Application("baseroot")&"/editor/img/page_white_copy.png"%>" alt="<%=langEditor.getTranslated("backend.prodotti.lista.table.alt.clone")%>" hspace="2" vspace="0" border="0"></a></td>
						<td align="center" width="25"><!--<a href="<%'=Application("baseroot") & "/editor/prodotti/VisualizzaProdotto.asp?cssClass=LP&id_prodotto=" & objFilteredProd.getIDProdotto()%>">--><img style="cursor:pointer;" id="view_zoom_<%=intCount%>" src="<%=Application("baseroot")&"/editor/img/zoom.png"%>" alt="<%=langEditor.getTranslated("backend.prodotti.lista.table.alt.view")%>" hspace="2" vspace="0" border="0"><!--</a>--></td>
						<td align="center" width="25"><a href="javascript:editProduct(<%=objFilteredProd.getIDProdotto()%>);"><img src="<%=Application("baseroot")&"/editor/img/pencil.png"%>" alt="<%=langEditor.getTranslated("backend.prodotti.lista.table.alt.modify")%>" hspace="2" vspace="0" border="0"></a></td>
						<td align="center" width="25"><a href="javascript:deleteProduct(<%=objFilteredProd.getIDProdotto()%>,'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.prodotti.detail.button.elimina.label")%>" hspace="2" vspace="0" border="0"></a></td>
						<td width="25%">						
						<!--<strong><div class="ajax" id="view_nome_prod_<%'=intCount%>" onmouseover="javascript:showHide('view_nome_prod_<%'=intCount%>','edit_nome_prod_<%'=intCount%>','nome_prod_<%'=intCount%>',500, false);"><%'=Server.HTMLEncode(objFilteredProd.getNomeProdotto())%></div></strong>
						<div class="ajax" id="edit_nome_prod_<%'=intCount%>" style="position:relative;z-index:1000;"><textarea class="formfieldAjaxAreaSmall" id="nome_prod_<%'=intCount%>" name="nome_prod" onmouseout="javascript:restoreField('edit_nome_prod_<%'=intCount%>','view_nome_prod_<%'=intCount%>','nome_prod_<%'=intCount%>','product',<%'=objFilteredProd.getIDProdotto()%>,1,<%'=intCount%>);"><%'=Server.HTMLEncode(objFilteredProd.getNomeProdotto())%></textarea></div>
						<script>
						$("#edit_nome_prod_<%'=intCount%>").hide();
						</script>-->
						<strong><%=Server.HTMLEncode(objFilteredProd.getNomeProdotto())%></strong>
						</td>
						<td width="10%"><div style="float:left">&euro;&nbsp;</div>	
						<div class="ajax" id="view_prezzo_prod_<%=intCount%>" onmouseover="javascript:showHide('view_prezzo_prod_<%=intCount%>','edit_prezzo_prod_<%=intCount%>','gerarchia_<%=intCount%>',500, false);"><%=FormatNumber(objFilteredProd.getPrezzo(),2,-1,-2,0)%></div>
						<div class="ajax" id="edit_prezzo_prod_<%=intCount%>"><input type="text" class="formfieldAjaxMedium" id="prezzo_prod_<%=intCount%>" name="prezzo_prod" onmouseout="javascript:restoreField('edit_prezzo_prod_<%=intCount%>','view_prezzo_prod_<%=intCount%>','prezzo_prod_<%=intCount%>','product',<%=objFilteredProd.getIDProdotto()%>,1,<%=intCount%>);" value="<%=FormatNumber(objFilteredProd.getPrezzo(),2,-1,-2,0)%>" onkeypress="javascript:return isDouble(event);"></div>
						<script>
						$("#edit_prezzo_prod_<%=intCount%>").hide();
						</script>
						</td>
						<td><%if(objFilteredProd.getQtaDisp() = Application("unlimited_key"))then%><%=langEditor.getTranslated("backend.prodotti.detail.table.label.qta_unlimited")%><%else%><%=objFilteredProd.getQtaDisp()%><%end if%></td>
						<td>
						<div class="ajax" id="view_stato_prod_<%=intCount%>" onmouseover="javascript:showHide('view_stato_prod_<%=intCount%>','edit_stato_prod_<%=intCount%>','stato_prod_<%=intCount%>',500, true);">
						<%
						if (strComp("1", objFilteredProd.getAttivo(), 1) = 0) then 
							response.Write(langEditor.getTranslated("backend.commons.yes"))
						else 
							response.Write(langEditor.getTranslated("backend.commons.no"))
						end if
						%>
						</div>
						<div class="ajax" id="edit_stato_prod_<%=intCount%>">
						<select name="stato_prod" class="formfieldAjaxSelect" id="stato_prod_<%=intCount%>" onblur="javascript:updateField('edit_stato_prod_<%=intCount%>','view_stato_prod_<%=intCount%>','stato_prod_<%=intCount%>','product',<%=objFilteredProd.getIDProdotto()%>,2,<%=intCount%>);">
						<OPTION VALUE="0" <%if (strComp("0", objFilteredProd.getAttivo(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></OPTION>
						<OPTION VALUE="1" <%if (strComp("1", objFilteredProd.getAttivo(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_stato_prod_<%=intCount%>").hide();
						</script>
						</td>
						<td>
						<%	
						Dim CategoriatmpClass, objCategorieXProd	
						if (Instr(1, typename(objTarget), "dictionary", 1) > 0) then
							Set CategoriatmpClass = new CategoryClass
							for each y in objTarget.Keys
								if (objTarget(y).getTargetType() = 2) then
									Set objCategorieXProd = CategoriatmpClass.findCategorieByTargetID(y)
									if not (isNull(objCategorieXProd)) then
										for each z in objCategorieXProd.Keys
											response.write ("<a class=""link-change-cat"" href="""&Application("baseroot") & "/editor/prodotti/ListaProdotti.asp?page=1&cssClass=LP&target_cat="&objCategorieXProd(z).getCatID()&"&strGerarchiaTmp="&objCategorieXProd(z).getCatGerarchia()&""" title="""&langEditor.getTranslated("backend.prodotti.lista.table.alt.filter_cat")&""">" & objCategorieXProd(z).getCatDescrizione() & "</a><br>")
										next
									end if
									Set objCategorieXProd = nothing
								end if									
							next	
							Set CategoriatmpClass = Nothing
						end if%>						
						</td>
						<td nowrap>
						<%		
						if (Instr(1, typename(objTarget), "dictionary", 1) > 0) then
							tcount = 1
							for each y in objTarget.Keys
								if (objTarget(y).getTargetType() = 3) then		
									imtTitle = Replace(objTarget(y).getTargetDescrizione(), "lang_", "", 1, -1, 1)
									if not(langEditor.getTranslated("portal.header.label.desc_lang."&Replace(objTarget(y).getTargetDescrizione(), "lang_", "", 1, -1, 1)) = "") then imtTitle = langEditor.getTranslated("portal.header.label.desc_lang."&Replace(objTarget(y).getTargetDescrizione(), "lang_", "", 1, -1, 1)) end if%>
									<img width="16" height="11" border="0" style="padding-right:0px;" alt="<%=imtTitle%>" title="<%=imtTitle%>" src="/editor/img/flag/flag-<%=Replace(objTarget(y).getTargetDescrizione(), "lang_", "", 1, -1, 1)%>.png"><%if(tcount MOD 4 =0)then response.write("<br/>") end if%>
									<%tcount = tcount+1
									'intCount = intCount +1
								end if			
							next							
							Set objTarget = nothing
						end if%>
						</td>							
						<td width="13%">
						<div class="ajax" id="view_id_tassa_applicata_<%=intCount%>" onmouseover="javascript:showHide('view_id_tassa_applicata_<%=intCount%>','edit_id_tassa_applicata_<%=intCount%>','id_tassa_applicata_<%=intCount%>',500, true);">
						<%
						Dim tassa, objTassa
						Set objTassa = new TaxsClass
						On Error resume Next
						Set tassa = objTassa.findTassaByID(objFilteredProd.getIDTassaApplicata())
						response.Write(tassa.getDescrizioneTassa())
						Set tassa = nothing
						if(Err.number <> 0)then
						end if
						%>
						</div>
						<div class="ajax" id="edit_id_tassa_applicata_<%=intCount%>">
						<select name="id_tassa_applicata" class="formfieldAjaxSelect" id="id_tassa_applicata_<%=intCount%>" onblur="javascript:updateField('edit_id_tassa_applicata_<%=intCount%>','view_id_tassa_applicata_<%=intCount%>','id_tassa_applicata_<%=intCount%>','product',<%=objFilteredProd.getIDProdotto()%>,2,<%=intCount%>);">
						  <option value=""></option>
							<%
							Dim objListaTasse, objTmpTassa
							Set objListaTasse = objTassa.getListaTasse(null,null)
							if not (isNull(objListaTasse)) then
								for each y in objListaTasse.Keys
									Set objTmpTassa = objListaTasse(y)%>
									<option value="<%=y%>" <%if (objFilteredProd.getIDTassaApplicata() = y) then response.write("selected") end if%>><%=objTmpTassa.getDescrizioneTassa()%></option>	
								<%	Set objTmpTassa = nothing
								next
							end if		
							Set objListaTasse = nothing
							%>	  
						</select>
						</div>
						<script>
						$("#edit_id_tassa_applicata_<%=intCount%>").hide();
						</script>
						<%Set objTassa = nothing%>
						</td>							
						<td>
						<%if (objFilteredProd.getProdType() = 0) then response.Write(langEditor.getTranslated("backend.prodotti.detail.table.label.type_portable")) end if%>
						<%if (objFilteredProd.getProdType() = 1) then response.Write(langEditor.getTranslated("backend.prodotti.detail.table.label.type_download")) end if%>
						<%if (objFilteredProd.getProdType() = 2) then response.Write(langEditor.getTranslated("backend.prodotti.detail.table.label.type_ads")) end if%>
						</td>							
						</tr>

						<tr class="preview_row">
						<td colspan="12">
						<div id="view_product_<%=intCount%>"></div>
						<script>
						$("#view_product_<%=intCount%>").hide();
						$('#view_zoom_<%=intCount%>').click(function(){ajaxViewZoom('<%=objFilteredProd.getIDProdotto()%>', 'view_product_<%=intCount%>');});
						</script>	
						</td>
						</tr>			
						<%intCount = intCount +1
						Set objFilteredProd = nothing
					next
					Set objListaProdotti = nothing
					%>
				  
				  <tr> 
					<form action="<%=Application("baseroot") & "/editor/prodotti/ListaProdotti.asp"%>" method="post" name="item_x_page">
					<th colspan="12">
					<input type="hidden" value="<%=order_prod_by%>" name="order_by">
					<input type="hidden" value="<%=request("target_cat")%>" name="target_cat">
					<input type="hidden" value="<%=request("strGerarchiaTmp")%>" name="strGerarchiaTmp">	
					<input type="text" name="itemsProd" class="formFieldTXTNumXPage" value="<%=itemsXpageProd%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
					<%		
					'**************** richiamo paginazione
					call PaginazioneFrontend(totPages, numPageProd, strGerarchia, "/editor/prodotti/ListaProdotti.asp", "&order_by="&order_prod_by&"&itemsProd="&itemsXpageProd&"&target_cat="&request("target_cat")&"&strGerarchiaTmp="&request("strGerarchiaTmp"))%>
					</th>
					</form>
              	</tr>
             <%end if	
		Set objListCatXProdTmp = Nothing
		Set CategoryClassTmp = Nothing
		Set objProdotti = Nothing%>
		</table>
		<br/>
		<div style="float:left;">
		<form action="<%=Application("baseroot") & "/editor/prodotti/InserisciProdotto.asp"%>" method="post" name="form_crea">
		<input type="hidden" value="LP" name="cssClass">
		<input type="hidden" value="-1" name="id_prodotto">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.prodotti.lista.button.inserisci.label")%>" onclick="javascript:document.form_crea.submit();" />
		</form>
		</div>
		<div style="float:left;">
		&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.prodotti.lista.button.label.download_excel")%>" onclick="javascript:openWinExcel('<%=Application("baseroot")&"/editor/report/CreateProdExcel.asp?target_cat="&request("target_cat")%>','crea_excel',400,400,100,100);" />
		</div>
		<div>
		&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("portal.templates.commons.label.see_comments_news")%>" onclick="javascript:openWin('<%=Application("baseroot")&"/editor/include/popupCommentManager.asp?element_type=2"%>','popupallegati',400,400,100,100);" />
		</div>		
		</div>
		<div id="prodfield" style="visibility:hidden;margin:0px;padding:0px;">
			<table border="0" cellpadding="0" cellspacing="0" class="principal" align="top">
			<tr> 
				<th colspan="2">&nbsp;</th>
				<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.description")%></th>
				<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.group")%></th>
				<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.order")%></th>
				<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.type")%></th>
				<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.type_content")%></th>
				<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.required")%></th>
				<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.enabled")%></th>
				<th><%=langEditor.getTranslated("backend.prodotti.lista.table.header.editable")%></th>
			</tr>
				<%
				Dim bolHasObj
				bolHasObj = false
				intCount = 0
				iIndex = 0				

				On Error Resume Next
				Set objListaField = objProdField.getListProductField(null)
				if(objListaField.Count > 0) then		
					bolHasObj = true
				end if

				if Err.number <> 0 then
					bolHasObj = false
				end if			
				
				if(bolHasObj) then
					Dim tmpObjField				
					Dim objTmpField, objTmpFieldKey, FromField, ToField
					iIndex = objListaField.Count
					FromField = ((numPageField * itemsXpageField) - itemsXpageField)
					Diff = (iIndex - ((numPageField * itemsXpageField)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToField = iIndex - Diff
					
					totPages = iIndex\itemsXpageField
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD itemsXpageField <> 0) AND not ((totPages * itemsXpageField) >= iIndex)) then
						totPages = totPages +1	
					end if		
					
					styleRow2 = "table-list-on"
					
					objTmpField = objListaField.Items
					objTmpFieldKey=objListaField.Keys		
					for newsCounter = FromField to ToField
						styleRow = "table-list-off"
						if(newsCounter MOD 2 = 0) then styleRow = styleRow2 end if%>
						<form action="<%=Application("baseroot") & "/editor/prodotti/InserisciField.asp"%>" method="post" name="form_lista_field_<%=intCount%>">
						<input type="hidden" value="<%=objTmpFieldKey(newsCounter)%>" name="id_field">
						<input type="hidden" value="" name="delete_field"> 
						<input type="hidden" value="LP" name="cssClass">	
						</form>			
						<tr class="<%=styleRow%>" id="tr_delete_field_list_<%=intCount%>">				
							<%Set tmpObjField = objTmpField(newsCounter)%>
							<td align="center" width="25"><a href="javascript:document.form_lista_field_<%=intCount%>.submit();"><img src="<%=Application("baseroot")&"/editor/img/pencil.png"%>" alt="<%=langEditor.getTranslated("backend.prodotti.lista.table.alt.modify_field")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25"><a href="javascript:deleteField(<%=objTmpFieldKey(newsCounter)%>,'tr_delete_field_list_<%=intCount%>','tr_delete_field_list_');"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.prodotti.lista.table.alt.delete_field")%>" hspace="5" vspace="0" border="0"></a></td>										
							<td width="16%">						
							<div class="ajax" id="view_description_<%=intCount%>" onmouseover="javascript:showHide('view_description_<%=intCount%>','edit_description_<%=intCount%>','description_<%=intCount%>',500, false);"><%=tmpObjField.getDescription()%></div>
							<div class="ajax" id="edit_description_<%=intCount%>"><input type="text" class="formfieldAjax" id="description_<%=intCount%>" name="description" onmouseout="javascript:restoreField('edit_description_<%=intCount%>','view_description_<%=intCount%>','description_<%=intCount%>','product_field',<%=tmpObjField.getID()%>,1,<%=intCount%>);" value="<%=tmpObjField.getDescription()%>" onkeypress="javascript:return notSpecialChar(event);"></div>
							<script>
							$("#edit_description_<%=intCount%>").hide();
							</script>
							</td>
							<td width="18%">						
							<div class="ajax" id="view_id_group_<%=intCount%>" onmouseover="javascript:showHide('view_id_group_<%=intCount%>','edit_id_group_<%=intCount%>','id_group_<%=intCount%>',500, true);"><%=tmpObjField.getObjGroup().getDescription()%></div>
							<div class="ajax" id="edit_id_group_<%=intCount%>">
							<select name="id_group" class="formfieldAjaxSelect" id="id_group_<%=intCount%>" onblur="javascript:updateField('edit_id_group_<%=intCount%>','view_id_group_<%=intCount%>','id_group_<%=intCount%>','product_field',<%=tmpObjField.getID()%>,2,<%=intCount%>);">
							<%
							On Error resume next
							Set objFieldGroup = New ProductFieldGroupClass
							Dim objDispFGroup
							Set objDispFGroup = objFieldGroup.getListProductFieldGroup()
							Set objFieldGroup = nothing

							if (Instr(1, typename(objDispFGroup), "dictionary", 1) > 0) then
							for each x in objDispFGroup%>
							<option value="<%=x%>" <%if (tmpObjField.getIdGroup() = x) then response.Write("selected")%>><%if not(langEditor.getTranslated("backend.prodotti.detail.table.label.group."&objDispFGroup(x).getDescription()) = "") then response.write(langEditor.getTranslated("backend.prodotti.detail.table.label.group."&objDispFGroup(x).getDescription())) else response.write(objDispFGroup(x).getDescription()) end if%></option>
							<%next
							end if
							Set objDispFGroup = nothing
							if(Err.number <>0)then
							'response.write(Err.description)
							end if%>
							</select>
							</div>
							<script>
							$("#edit_id_group_<%=intCount%>").hide();
							</script>
							</td>
							<td>	
							<div class="ajax" id="view_order_<%=intCount%>" onmouseover="javascript:showHide('view_order_<%=intCount%>','edit_order_<%=intCount%>','order_<%=intCount%>',500, false);"><%=tmpObjField.getOrder()%></div>
							<div class="ajax" id="edit_order_<%=intCount%>"><input type="text" class="formfieldAjaxShort" id="order_<%=intCount%>" name="order" onmouseout="javascript:restoreField('edit_order_<%=intCount%>','view_order_<%=intCount%>','order_<%=intCount%>','product_field',<%=tmpObjField.getID()%>,1,<%=intCount%>);" value="<%=tmpObjField.getOrder()%>" maxlength="3" onkeypress="javascript:return isInteger(event);"></div>
							<script>
							$("#edit_order_<%=intCount%>").hide();
							</script>
							</td>
							<td><%=objProdField.findTypeFieldById(tmpObjField.getTypeField())%></td>
							<td><%=objProdField.findTypeContentById(tmpObjField.getTypeContent())%></td>
							<td>
							<%
							if (strComp("1", tmpObjField.getRequired(), 1) = 0) then 
								response.Write(langEditor.getTranslated("backend.commons.yes"))
							else 
								response.Write(langEditor.getTranslated("backend.commons.no"))
							end if
							%>
							</td>
							<td>
							<%
							if (strComp("1", tmpObjField.getEnabled(), 1) = 0) then 
								response.Write(langEditor.getTranslated("backend.commons.yes"))
							else 
								response.Write(langEditor.getTranslated("backend.commons.no"))
							end if
							%>
							</td>	
							<td>
							<%
							if (strComp("1", tmpObjField.getEditable(), 1) = 0) then 
								response.Write(langEditor.getTranslated("backend.commons.yes"))
							else 
								response.Write(langEditor.getTranslated("backend.commons.no"))
							end if
							%>
							</td>		
						</tr>			
						<%intCount = intCount +1
					next
					Set tmpObjField = nothing
					Set objListaField = nothing%>
		      <tr> 
			<form action="<%=Application("baseroot") & "/editor/prodotti/Listaprodotti.asp"%>" method="post" name="item_x_page_field">
			<input type="hidden" value="prodfield" name="showtab">
			<th colspan="10">
					<input type="text" name="itemsField" class="formFieldTXTNumXPage" value="<%=itemsXpageField%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
					<%						
					'**************** richiamo paginazione
					call PaginazioneFrontend(totPages, numPageField, strGerarchia, "/editor/prodotti/Listaprodotti.asp", "&itemsField="&itemsXpageField&"&showtab=prodfield")
					%>
			</th>
			</form>
		      </tr>
		      <%end if%>
		    </table>
			<br/>
			<form action="<%=Application("baseroot") & "/editor/prodotti/InserisciField.asp"%>" method="post" name="form_crea_field">
			<input type="hidden" value="-1" name="id_field">
			<input type="hidden" value="LP" name="cssClass">
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.prodotti.lista.button.inserisci_field.label")%>" onclick="javascript:document.form_crea_field.submit();" />
			</form>			
		</div>
		<%
		Set objProdField = nothing
		%>
		<br/><br/>			
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>