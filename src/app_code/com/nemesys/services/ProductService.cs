using System;
using System.Text;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Collections;
using System.Threading;
using System.Web.Caching;
using System.Xml;
using System.IO;
using System.Net.Mail;
using System.Net.Mime;
using com.nemesys.model;
using com.nemesys.database.repository;

namespace com.nemesys.services
{
	public class ProductService
	{
		protected static IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
		protected static ICountryRepository countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
		protected static IDictionary<string,int> daysOfWeek = new Dictionary<string,int>();

		static ProductService()
		{	
			daysOfWeek.Clear();
			daysOfWeek.Add("sunday",0);
			daysOfWeek.Add("monday",1);
			daysOfWeek.Add("tuesday",2);
			daysOfWeek.Add("wednesday",3);
			daysOfWeek.Add("thursday",4);
			daysOfWeek.Add("friday",5);
			daysOfWeek.Add("saturday",6);	
		}
		
		public static bool deleteAttachment(string filePath, int type)
		{
			bool deleted = false;
			//cancello la directory fisica del template
			try{
				string tpath = HttpContext.Current.Server.MapPath("~/public/upload/files/products/"+filePath);
				if(type==1){
					tpath = HttpContext.Current.Server.MapPath("~/app_data/products/"+filePath);
				}
				if(File.Exists(tpath)) 
				{
					File.Delete(tpath);
					deleted = true;
				}
			}catch(Exception ex)
			{
				deleted = false;
			}

			return deleted;			
		}
		
		public static IDictionary<string,ProductFieldTranslation> getMapProductFieldsTranslations(int productId){
			IDictionary<string,ProductFieldTranslation> prodFieldsTrans = new Dictionary<string,ProductFieldTranslation>();
			
			IList<ProductFieldTranslation> tmpProdFieldsTrans = prodrep.getProductFieldsTranslationCached(productId, -1, null, null, null, true);
			if(tmpProdFieldsTrans!=null && tmpProdFieldsTrans.Count>0){
				foreach(ProductFieldTranslation pft in tmpProdFieldsTrans){
					prodFieldsTrans.Add(new StringBuilder().Append(pft.idParentProduct).Append("-").Append(pft.idField).Append("-").Append(pft.type).Append("-").Append(pft.baseVal).Append("-").Append(pft.langCode).ToString(),pft);
				}
			}
			
			return prodFieldsTrans;
		}

		public static string renderTargetBox(string resJsVar, string idBoxSx, string idBoxDx, string labelSx, string labelDx, IList<Language> arrSx, IList<Language> arrDx, bool bolCheckAutoT, bool bolAddDescTrans, string langcode, string defLangCode)
		{		
			string resJsValues ="";		
			string renderTargetBox="";
			string imgLang = "";
			string ttype = "";
			
			try
			{		
				renderTargetBox+="<div style='float: left;margin-right: 10px;'>";
				renderTargetBox+="<span class='labelForm'>"+labelSx+"</span><br>";
				renderTargetBox+="<ul id='"+idBoxSx+"' style='list-style-type: none; margin: 0; float: left; margin-right: 10px; background: #fff; padding: 5px; width: 230px;height: 160px;border: 1px solid #727272;overflow: auto;'>";
				
				if (arrSx!=null) {
					foreach(Language y in arrSx)
					{						
						imgLang="<img src='/backoffice/img/flag/flag-"+y.label+".png' border=0 hspace=2 vspace=0 align=top>";						
						ttype=imgLang+MultiLanguageService.translate("portal.header.label.desc_lang."+y.label, langcode, defLangCode);

						renderTargetBox+="<li class='ui-state-highlight' style='margin: 2px; padding: 2px; font-size: 11px; width: 200px; cursor:move;' id='"+y.id+"'>"+ttype+"</li>";
						resJsValues+=y.id+"|";
					}
				}		
				
				renderTargetBox+="</ul>";
				renderTargetBox+="</div>";
				renderTargetBox+="<div>";
				renderTargetBox+="<span class='labelForm'>"+labelDx+"</span><br>";
				renderTargetBox+="<ul id='"+idBoxDx+"' style='list-style-type: none; margin: 0; float:left; background: #fff; padding: 5px; width: 230px;height: 160px;border: 1px solid #727272;overflow: auto;'>";
				
				if (arrDx!=null) {
					if (arrSx!=null) { 
						foreach(Language y in arrDx)
						{
							bool bolExistTarget = false;
							imgLang="<img src='/backoffice/img/flag/flag-"+y.label+".png' border=0 hspace=2 vspace=0 align=top>";						
							ttype=imgLang+MultiLanguageService.translate("portal.header.label.desc_lang."+y.label, langcode, defLangCode);
					
							foreach(Language x in arrSx)
							{							
								if(x.id==y.id) {
									bolExistTarget = true;
									break;
								}	
							}	
											
							if (!bolExistTarget) {
								renderTargetBox+="<li class='ui-state-default' style='margin: 2px; padding: 2px; font-size: 11px; width: 200px; cursor:move;' id='"+y.id+"'>"+ttype+"</li>"	;					
							} 
						}				
					}else{
						foreach(Language y in arrDx)
						{			
							imgLang="<img src='/backoffice/img/flag/flag-"+y.label+".png' border=0 hspace=2 vspace=0 align=top>";						
							ttype=imgLang+MultiLanguageService.translate("portal.header.label.desc_lang."+y.label, langcode, defLangCode);
							renderTargetBox+="<li class='ui-state-default' style='margin: 2px; padding: 2px; font-size: 11px; width: 200px; cursor:move;' id='"+y.id+"'>"+ttype+"</li>";
						}
					}	
				}else{
					return null;
				}	
					
				renderTargetBox+="</ul>";
				renderTargetBox+="</div><br clear='both'/>";
		
				renderTargetBox+="<script>";
				renderTargetBox+="var "+resJsVar+" = '"+resJsValues+"';";
				
				renderTargetBox+="$(function () {";
					renderTargetBox+="$('#"+idBoxSx+"').sortable({";
						renderTargetBox+="connectWith: \"ul#"+idBoxDx+"\"";
						renderTargetBox+=",receive: function(event, ui) {";					
							renderTargetBox+=resJsVar+"+=ui.item.attr('id')+'|';";	
						renderTargetBox+="}";
						renderTargetBox+=",remove: function(event, ui) {";
							renderTargetBox+=resJsVar+"="+resJsVar+".replace(ui.item.attr('id')+'|','');";
						renderTargetBox+="}";
					renderTargetBox+="}).disableSelection();";
					
					renderTargetBox+="$('#"+idBoxDx+"').sortable({";
						renderTargetBox+="connectWith: \"ul#"+idBoxSx+"\"";
					renderTargetBox+="}).disableSelection();";
				renderTargetBox+="});";
				renderTargetBox+="</script>";
	 
			}
			catch(Exception ex)
			{
				renderTargetBox = "";
			}
			
			return renderTargetBox;			
		}

		public static string renderField(IList<ProductField> fieldList, IDictionary<int,string> jsFunctions, string style, string cssClass, string langcode, string defLangCode, IDictionary<string,ProductFieldTranslation> prodFieldsTrans, bool forceViewOnly)
		{
			string renderField="";
			string jsFunction = "";

			try
			{
				string currentGroup = "";
				foreach(ProductField cf in fieldList)
				{
					if(cf.enabled)
					{
						ProductFieldTranslation pftv = null;
						bool isEditable = cf.editable;
						if(forceViewOnly){
							isEditable = true;
						}
						
						string maxLenght = "";	
						if (cf.maxLenght>0) {
							maxLenght = " maxlength='"+cf.maxLenght+"'";
						}
						
						string isrequired = "";
						if(cf.required){
							isrequired = "&nbsp;*";
						}
									
						string keyPress = "";
						if(cf.typeContent==3){
							keyPress = " onkeypress='javascript:return isInteger(event);'";
						}else if(cf.typeContent==4){		
							keyPress = " onkeypress='javascript:return isDouble(event);'";
						}
						
						if(currentGroup!=cf.groupDescription)
						{
							string tmpgroupDesc = cf.groupDescription;
							//tmpgroupDesc = translate("backend.prodotti.detail.table.label.field_description_"+cf.groupDescription+"_"+productKeyword, tmpgroupDesc, langcode, defLangCode);
							if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("group").Append("-").Append("").Append("-").Append(langcode).ToString(), out pftv)){
								tmpgroupDesc = pftv.value;
							}
							
							renderField+="<h1>"+tmpgroupDesc+"</h1>";
							currentGroup = tmpgroupDesc;
						}					
											
						renderField+="<div id='fe_container_product_field_"+cf.id+"' style='"+style+"' class='"+cssClass+"'>";
						
						string tmpDescription = cf.description;
						//tmpDescription = translate("backend.prodotti.detail.table.label.field_description_"+cf.description+"_"+productKeyword, tmpDescription, langcode, defLangCode);		
						if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("desc").Append("-").Append("").Append("-").Append(langcode).ToString(), out pftv)){
							tmpDescription = pftv.value;
						}

						string[] tmpvalues;
						
						switch (cf.type)
						{
							case 1:
								if(isEditable){
									string tmpValue = cf.value;
									//tmpValue = translate("backend.prodotti.detail.table.label.field_value_t_"+cf.description+"_"+productKeyword, tmpValue, langcode, defLangCode);
									if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("value").Append("-").Append("").Append("-").Append(langcode).ToString(), out pftv)){
										tmpValue = pftv.value;
									}
									renderField+=tmpValue;	
									
								}else{
									renderField+="<span>"+tmpDescription+isrequired+"</span>&nbsp;";
									
									if(jsFunctions != null){
										jsFunctions.TryGetValue(cf.id, out jsFunction);
									}					
									renderField+="<input type='text' name='product_field_"+cf.id+"' id='tproduct_field_"+cf.id+"' value='' "+jsFunction+" "+keyPress+" "+maxLenght+">";
									if(cf.typeContent==5)
									{
										renderField+="<script>";
										renderField+="$(function() {";										
											renderField+="$('#tproduct_field_"+cf.id+"').datepicker({";
												string hourMinutes = "";
												if(cf.typeContent==6){hourMinutes = " hh:mm";}											
												renderField+="dateFormat: 'dd/mm/yy"+hourMinutes+"',";
												renderField+="changeMonth: true,";
												renderField+="changeYear: true";
												//renderField+=",yearRange: '1900:"+DateTime.Now.GetYear()+"'";
											renderField+="});";	
											renderField+="$('#ui-datepicker-div').hide();";
										renderField+="});";										
										renderField+="</script>";
									}
									else if(cf.typeContent==6)
									{
										renderField+="<script>";
										renderField+="$(function() {";	
											renderField+="$('#tproduct_field_"+cf.id+"').datetimepicker({";
												//renderField+="showButtonPanel: false,";
												//renderField+="dateFormat: 'dd/mm/yy',";
												//renderField+="timeFormat: 'HH.mm'";
												renderField+="format:'d/m/Y H.i',";
												renderField+="closeOnDateSelect:true";
											renderField+="});";
											renderField+="$('#ui-datepicker-div').hide();";											
										renderField+="});";										
										renderField+="</script>";
									}									
								}
								break;
							case 2:
								if(isEditable){
									string tmpValue = cf.value;
									//tmpValue = translate("backend.prodotti.detail.table.label.field_value_ta_"+cf.description+"_"+productKeyword, tmpValue, langcode, defLangCode);
									if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("value").Append("-").Append("").Append("-").Append(langcode).ToString(), out pftv)){
										tmpValue = pftv.value;
									}
									renderField+=tmpValue;								
								}else{
									renderField+="<span>"+tmpDescription+isrequired+"</span>&nbsp;";
									
									if(jsFunctions != null){
										jsFunctions.TryGetValue(cf.id, out jsFunction);
									}
									renderField+="<textarea name='product_field_"+cf.id+"' id='aproduct_field_"+cf.id+"' "+jsFunction+" "+maxLenght+"></textarea>";
								}
								break;
							case 3:
								if(isEditable){
									string tmpValue = cf.value;
									if(cf.typeContent==7)
									{
										if (!String.IsNullOrEmpty(tmpValue) && tmpValue.LastIndexOf('_') > -1){
											tmpValue = tmpValue.Substring(0,tmpValue.LastIndexOf('_'));
										}
										tmpValue = translate("portal.commons.select.option.country."+tmpValue, tmpValue, langcode, defLangCode);
									}else if(cf.typeContent==8){
										tmpValue = translate("portal.commons.select.option.country."+tmpValue, tmpValue, langcode, defLangCode);
									}else{
										if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("values").Append("-").Append(cf.value).Append("-").Append(langcode).ToString(), out pftv)){
											tmpValue = pftv.value;
										}
									}
									renderField+=tmpValue;	
								}else{
									renderField+="<span>"+tmpDescription+isrequired+"</span>&nbsp;";
									
									if(jsFunctions != null){
										jsFunctions.TryGetValue(cf.id, out jsFunction);
									}
									renderField+="<select name='product_field_"+cf.id+"' id='sproduct_field_"+cf.id+"' "+jsFunction+">";
									if(!cf.required)
									{
										renderField+="<option></option>";
									}
									
									if(cf.typeContent==7)
									{
										IList<Country> countries = countryrep.findAllCountries("2,3");
										if(countries != null && countries.Count>0)
										{
											foreach(Country c in countries)
											{
												string selected = "";
												if(c.countryCode==cf.value)
												{
													selected = " selected='selected'";
												}
												string tmpcdesc = c.countryDescription;
												tmpcdesc = translate("portal.commons.select.option.country."+c.countryCode, c.countryDescription, langcode, defLangCode);
												renderField+="<option value='"+c.countryCode+"' "+selected+">"+tmpcdesc+"</option>";
											}
										}	
										
									}
									else if(cf.typeContent==8)
									{
										IList<Country> stateRegions = countryrep.findAllStateRegion("2,3");
										if(stateRegions != null && stateRegions.Count>0)
										{
											foreach(Country c in stateRegions)
											{
												string selected = "";
												if(c.stateRegionCode==cf.value)
												{
													selected = " selected='selected'";
												}
												string tmpsrdesc = c.stateRegionDescription;
												tmpsrdesc = translate("portal.commons.select.option.country."+c.stateRegionCode, c.stateRegionDescription, langcode, defLangCode);
												renderField+="<option value='"+c.stateRegionCode+"' "+selected+">"+tmpsrdesc+"</option>";
											}
										}										
									}
									else
									{
										IList<ProductFieldsValue> values = prodrep.getProductFieldValuesCached(cf.id, true);
										if(values != null && values.Count>0)
										{
											foreach(ProductFieldsValue cfv in values)
											{
												string selected = "";
												if(cfv.value==cf.value)
												{
													selected = " selected='selected'";
												}
												string tmpcfvval = cfv.value;
												//tmpcfvval = translate("backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+cfv.value+"_"+productKeyword, tmpcfvval, langcode, defLangCode);
												if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("values").Append("-").Append(tmpcfvval).Append("-").Append(langcode).ToString(), out pftv)){
													tmpcfvval = pftv.value;
												}
												
												renderField+="<option value='"+cfv.value+"' "+selected+">"+tmpcfvval+"</option>";
											}
										}
									}
									renderField+="</select>";
								}
								break;
							case 4:
								tmpvalues = cf.value.Split(',');
								
								if(isEditable){
									foreach(string r in tmpvalues){
										//renderField+=translate("backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+r+"_"+productKeyword, r, langcode, defLangCode);	
										if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("values").Append("-").Append(r).Append("-").Append(langcode).ToString(), out pftv)){
											renderField+=pftv.value+"<br/>";
										}
									}		
								}else{
									renderField+="<span>"+tmpDescription+isrequired+"</span>&nbsp;";
									
									int tmpMaxL = 3;
									if(cf.maxLenght>tmpMaxL){
										tmpMaxL = cf.maxLenght;
									}
									if(jsFunctions != null){
										jsFunctions.TryGetValue(cf.id, out jsFunction);
									}
									renderField+="<select multiple size='"+tmpMaxL+"' name='product_field_"+cf.id+"' id='mproduct_field_"+cf.id+"' "+jsFunction+">";
									if(!cf.required)
									{
										renderField+="<option></option>";
									}
								
									IList<ProductFieldsValue> values = prodrep.getProductFieldValuesCached(cf.id, true);
									if(values != null && values.Count>0)
									{
										foreach(ProductFieldsValue cfv in values)
										{
											string selected = "";
											foreach(string r in tmpvalues)
											{
												if(cfv.value==r)
												{
													selected = " selected='selected'";
													break;
												}
											}
											string tmpcfvval = cfv.value;
											//tmpcfvval = translate("backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+cfv.value+"_"+productKeyword, tmpcfvval, langcode, defLangCode);
											if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("values").Append("-").Append(tmpcfvval).Append("-").Append(langcode).ToString(), out pftv)){
												tmpcfvval = pftv.value;
											}
												
											renderField+="<option value='"+cfv.value+"' "+selected+">"+tmpcfvval+"</option>";
										}
									}
									renderField+="</select>";							
								}
								break;
							case 5:
								tmpvalues = cf.value.Split(',');
								
								if(isEditable){
									foreach(string r in tmpvalues){
										//renderField+=translate("backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+r+"_"+productKeyword, r, langcode, defLangCode);		
										if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("values").Append("-").Append(r).Append("-").Append(langcode).ToString(), out pftv)){
											renderField+=pftv.value+"<br/>";
										}
									}							
								}else{
									renderField+="<span>"+tmpDescription+isrequired+"</span>&nbsp;";
									
									IList<ProductFieldsValue> values = prodrep.getProductFieldValuesCached(cf.id, true);
									if(values != null && values.Count>0)
									{
										if(jsFunctions != null){
											jsFunctions.TryGetValue(cf.id, out jsFunction);
										}
										foreach(ProductFieldsValue cfv in values)
										{
											string vchecked = "";
											foreach(string r in tmpvalues)
											{
												if(cfv.value==r)
												{
													vchecked = " checked='checked'";
													break;
												}
											}
											string tmpcfvval = cfv.value;
											//tmpcfvval = translate("backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+cfv.value+"_"+productKeyword, tmpcfvval, langcode, defLangCode);
											if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("values").Append("-").Append(tmpcfvval).Append("-").Append(langcode).ToString(), out pftv)){
												tmpcfvval = pftv.value;
											}
											
											renderField+="<input type='checkbox' "+vchecked+" name='product_field_"+cf.id+"' id='xproduct_field_"+cf.id+"' value='"+cfv.value+"' "+jsFunction+">&nbsp;"+tmpcfvval;
										}
									}
								}
								break;
							case 6:
								tmpvalues = cf.value.Split(',');
									
								if(isEditable){
									foreach(string r in tmpvalues){
										//renderField+=translate("backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+r+"_"+productKeyword, r, langcode, defLangCode);		
										if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("values").Append("-").Append(r).Append("-").Append(langcode).ToString(), out pftv)){
											renderField+=pftv.value+"<br/>";
										}
									}							
								}else{
									renderField+="<span>"+tmpDescription+isrequired+"</span>&nbsp;";
									
									IList<ProductFieldsValue> values = prodrep.getProductFieldValuesCached(cf.id, true);
									if(values != null && values.Count>0)
									{
										if(jsFunctions != null){
											jsFunctions.TryGetValue(cf.id, out jsFunction);
										}
										foreach(ProductFieldsValue cfv in values)
										{
											string vchecked = "";
											foreach(string r in tmpvalues)
											{
												if(cfv.value==r)
												{
													vchecked = " checked='checked'";
													break;
												}
											}
											string tmpcfvval = cfv.value;
											//tmpcfvval = translate("backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+cfv.value+"_"+productKeyword, tmpcfvval, langcode, defLangCode);
											if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("values").Append("-").Append(tmpcfvval).Append("-").Append(langcode).ToString(), out pftv)){
												tmpcfvval = pftv.value;
											}
											
											renderField+="<input type='radio' "+vchecked+" name='product_field_"+cf.id+"' id='rproduct_field_"+cf.id+"' value='"+cfv.value+"' "+jsFunction+">&nbsp;"+tmpcfvval;
										}
									}
								}
								break;
							case 7:
								renderField+="<span>"+tmpDescription+isrequired+"</span>&nbsp;";
								renderField+="<input type='hidden' value='"+cf.value+"' name='product_field_"+cf.id+"' id='hproduct_field_"+cf.id+"'>";
								break;
							case 8:	
								renderField+="<span>"+tmpDescription+isrequired+"</span>&nbsp;";
								renderField+="<input type='file' name='product_field_"+cf.id+"' id='fproduct_field_"+cf.id+"'>";
								break;
							case 9:
								if(isEditable){
									string tmpValue = cf.value;
									//tmpValue = translate("backend.prodotti.detail.table.label.field_value_e_"+cf.description+"_"+productKeyword, tmpValue, langcode, defLangCode);
									if(prodFieldsTrans.TryGetValue(new StringBuilder().Append(cf.idParentProduct).Append("-").Append(cf.id).Append("-").Append("value").Append("-").Append("").Append("-").Append(langcode).ToString(), out pftv)){
										tmpValue = pftv.value;
									}
									renderField+=tmpValue;							
								}else{
									renderField+="<span>"+tmpDescription+isrequired+"</span>&nbsp;";
									
									renderField+="<textarea name='product_field_"+cf.id+"' id='eproduct_field_"+cf.id+"' class='formFieldTXTAREAAbstract' "+maxLenght+"></textarea>";
									renderField+="<script>";
									renderField+="$.cleditor.defaultOptions.width = 600;";
									renderField+="$.cleditor.defaultOptions.height = 200;";
									renderField+="$.cleditor.defaultOptions.controls = \"bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image\";";		
									renderField+="$(document).ready(function(){";
										renderField+="$('#eproduct_field_"+cf.id+"').cleditor();";
									renderField+="});";
									renderField+="</script>";						
								}
								break;
							case 10:
								if(isEditable){
									renderField+=cf.value;								
								}else{
									renderField+="<span>"+tmpDescription+isrequired+"</span>&nbsp;";
									
									if(jsFunctions != null){
										jsFunctions.TryGetValue(cf.id, out jsFunction);
									}	
									renderField+="<input type='password' name='product_field_"+cf.id+"' id='pproduct_field_"+cf.id+"' value='' class='formFieldTXTMedium2' "+jsFunction+" "+keyPress+" "+maxLenght+">";
								}
								break;
							default:
								break;
						}
					
						renderField+="</div>";	
					}				
				}
			}
			catch(Exception ex)
			{
				renderField = "";
			}
						
			return renderField;				
		}

		public static string renderFieldJsFormValidation(IList<ProductField> fieldList, string langcode, string defLangCode)
		{
			StringBuilder renderFieldJs= new StringBuilder();

			try
			{
				foreach(ProductField cf in fieldList)
				{
					if(cf.enabled)
					{				
						switch (cf.type)
						{
							case 1: case 2: case 9: case 10:
								if(!cf.editable){
									string prefixfield = "";
									if(cf.type==1){
										prefixfield = "t";
									}else if(cf.type==2){
										prefixfield = "a";
									}else if(cf.type==9){
										prefixfield = "e";
									}else if(cf.type==10){
										prefixfield = "p";
									}
									
									if(cf.required){
										renderFieldJs.Append("if($('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').val()==''){")
											.Append("alert('")
											.Append(translate("portal.commons.product_field.js.alert.insert_value", "insert value for:", langcode, defLangCode))
											.Append(" ")
											.Append(translate("backend.prodotti.detail.table.label.field_description_"+cf.description, cf.description, langcode, defLangCode))
											.Append("');")										
											.Append("$('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').focus();")
											.Append("return;")
										.Append("}");
									}
									
									if(cf.typeContent==2){
										renderFieldJs.Append("var tmpmail = ").Append("$('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').val();")
										.Append("if(tmpmail != ''){")
											.Append("if(tmpmail.indexOf('@')<2 || tmpmail.indexOf('.')==-1 || tmpmail.indexOf(' ')!=-1 || tmpmail.length<6){")
												.Append("alert('")
												.Append(translate("portal.commons.product_field.js.alert.wrong_mail", "insert right mail format for:", langcode, defLangCode))
												.Append(" ")
												.Append(translate("backend.prodotti.detail.table.label.field_description_"+cf.description, cf.description, langcode, defLangCode))
												.Append("');")										
												.Append("$('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').focus();")
												.Append("return;")
											.Append("}")
										.Append("}else if(strMail == ''){")
											.Append("alert('")
											.Append(translate("portal.commons.product_field.js.alert.wrong_mail", "insert mail for:", langcode, defLangCode))
											.Append(" ")
											.Append(translate("backend.prodotti.detail.table.label.field_description_"+cf.description, cf.description, langcode, defLangCode))
											.Append("');")										
											.Append("$('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').focus();")
											.Append("return;")
										.Append("}");											
									}else if(cf.typeContent==3){
										renderFieldJs.Append("if(isNaN($('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').val())){")
											.Append("alert('")
											.Append(translate("portal.commons.product_field.js.alert.isnan_value", "insert integer value:", langcode, defLangCode))
											.Append(" ")
											.Append(translate("backend.prodotti.detail.table.label.field_description_"+cf.description, cf.description, langcode, defLangCode))
											.Append("');")
											.Append("$('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').focus();")
											.Append("return;")
										.Append("}");	
									}else if(cf.typeContent==4){	
										renderFieldJs.Append("if($('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').val().length > 0 && (!checkDoubleFormatExt($('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').val()) || $('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').val().indexOf('.')!=-1)){")	
										//renderFieldJs.Append("if(!isDouble($('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').val())){")
											.Append("alert('")
											.Append(translate("portal.commons.product_field.js.alert.isnan_value", "insert double value:", langcode, defLangCode))
											.Append(" ")
											.Append(translate("backend.prodotti.detail.table.label.field_description_"+cf.description, cf.description, langcode, defLangCode))
											.Append("');")
											.Append("$('#").Append(prefixfield).Append("product_field_").Append(cf.id).Append("').focus();")
											.Append("return;")
										.Append("}");	
									}				
								}
								break;
							case 5:
								if(!cf.editable && cf.required){
									renderFieldJs.Append("var hasElem = false;")
									.Append("$('input:checkbox[id*=\"xproduct_field_").Append(cf.id).Append("\"]').each( function(){")
										.Append("if($(this).val() != '' && $(this).is(':checked')){")
											.Append("hasElem = true;")											 
										.Append("}")									
									.Append("});")
									.Append("if(!hasElem){")
										.Append("alert('")
										.Append(translate("portal.commons.product_field.js.alert.insert_value", "insert value for:", langcode, defLangCode))
										.Append(" ")
										.Append(translate("backend.prodotti.detail.table.label.field_description_"+cf.description, cf.description, langcode, defLangCode))
										.Append("');")										
										.Append("return;")								 
									.Append("}");																	
								}
								break;
							case 6:
								if(!cf.editable && cf.required){
									renderFieldJs.Append("var hasElem = false;")
									.Append("$('input:radio[id*=\"rproduct_field_").Append(cf.id).Append("\"]').each( function(){")
										.Append("if($(this).val() != '' && $(this).is(':checked')){")
											.Append("hasElem = true;")											 
										.Append("}")									
									.Append("});")
									.Append("if(!hasElem){")
										.Append("alert('")
										.Append(translate("portal.commons.product_field.js.alert.insert_value", "insert value for:", langcode, defLangCode))
										.Append(" ")
										.Append(translate("backend.prodotti.detail.table.label.field_description_"+cf.description, cf.description, langcode, defLangCode))
										.Append("');")										
										.Append("return;")								 
									.Append("}");								
								}
								break;
							default:
								break;
						}
					}				
				}
			}
			catch(Exception ex)
			{
				return null;
			}
			
			return renderFieldJs.ToString();				
		}
		
		public static string translate(string keyword, string defaultReturn, string langcode, string defLangCode){
			string result = MultiLanguageService.translate(keyword, langcode, defLangCode);
			if(!String.IsNullOrEmpty(result)){
				return result;
			}
			return defaultReturn;			
		}
		
		public static bool isProductNull(Product product)
		{
			return (product == null || product.id==-1);	
		}
		
		public static int getDayOfWeek(string key)
		{
			int result = -1;
			daysOfWeek.TryGetValue(key, out result);	
			//Response.Write("result:"+result+"<br>");	
			return result;
		}
		
		public static decimal getSupplementAmount(decimal price, decimal supValue, int supType)
		{
			decimal result = 0.00M;
			
			if(supType==2){
				result = price * (supValue / 100);
			}else{
				result = supValue;
			}
			
			return result;
		}	
		
		public static decimal getDiscountedAmount(decimal price, decimal discount)
		{
			decimal result = price;
			
			if(discount>0){
				result = result - (result / 100 * discount);
			}
			
			return result;
		}	
		
		public static decimal getDiscountedValue(decimal price, decimal discount)
		{
			decimal result = 0;
			
			if(discount>0){
				result = price / 100 * discount;
			}
			
			return result;
		}	
		
		public static decimal getMarginAmount(decimal price, decimal margin)
		{
			decimal result = 0;
			
			if(margin>0){
				result = price / 100 * margin;
			}
			
			return result;
		}	
		
		public static decimal getDiscountAmount(decimal price, decimal discount, decimal proddicount, decimal userdiscount, bool applyProdDiscount, bool applyUserDiscount)
		{
			decimal result = 0;

			if(applyProdDiscount){
				discount+=proddicount;
			}
			if(applyUserDiscount){
				discount+=userdiscount;
			}
			
			if(discount>0){
				result = price / 100 * discount;
			}
			
			return result;
		}		
		
		// calcolo un importo in base alla strategia impostata per UserGroup
		public static decimal getAmount(decimal price, decimal margin, decimal discount, decimal proddicount, decimal userdiscount, bool applyProdDiscount, bool applyUserDiscount)
		{
			decimal result = price;
			
			if(applyProdDiscount){
				discount+=proddicount;
			}
			if(applyUserDiscount){
				discount+=userdiscount;
			}
			
			margin = margin-discount;
			
			result += (result/100*margin); 
			
			return result;
		}
		
		// calcolo una percentuale di sconto in base alla strategia impostata per UserGroup	
		public static decimal getDiscountPercentage(decimal discount, decimal proddicount, decimal userdiscount, bool applyProdDiscount, bool applyUserDiscount)
		{
			decimal result = discount;
			
			if(applyProdDiscount){
				result+=proddicount;
			}
			if(applyUserDiscount){
				result+=userdiscount;
			}
			
			return result;
		}		
	}
}