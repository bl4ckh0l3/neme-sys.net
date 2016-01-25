using System;
using System.Text;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;
using System.Web.Caching;
using System.Xml;
using System.IO;
using com.nemesys.model;
using com.nemesys.database.repository;

namespace com.nemesys.services
{
	public class UserService
	{
		private static readonly object _Padlock = new object();
		private static IDictionary<string, UserOnline> userOnline = new  Dictionary<string, UserOnline>();
		protected static IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		protected static ICountryRepository countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
		
		public static UserAttachment getUserAvatar(User user)
		{
			if(user.attachments != null && user.attachments.Count>0)
			{
				foreach(UserAttachment attachment in user.attachments)
				{
					if(attachment.isAvatar) return attachment;	
				}
			}			
			return null;		
		}
		
		public static bool deleteUserAttachment(string filePath)
		{
			bool deleted = false;
			//cancello la directory fisica del template
			try{
				string tpath = HttpContext.Current.Server.MapPath("~/public/upload/files/user/"+filePath);
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
		
		public static  IDictionary<string, UserOnline> getOnlineUsers()
		{
			lock (_Padlock)
			{
				return new Dictionary<string, UserOnline>(userOnline);
			}
		}
		
		public static int getCountOnlineUsers()
		{
			lock (_Padlock)
			{
				return userOnline.Count;
			}
		}
		
		public static  void addOnlineUser(string usrkey, User user)
		{
			try
			{
				lock (_Padlock)
				{
					foreach (string k in userOnline.Keys)
					{
						if(userOnline[k].userOnline.id==user.id)
						{
							userOnline.Remove(k);
							break;
						}
					}					
					userOnline.Remove(usrkey);
					
					UserOnline usro = new UserOnline();
					usro.userOnline = user;
					usro.entryDate = DateTime.Now;
					userOnline[usrkey] = usro;
				}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				// DO NOTHING
			}			
		}
		
		public static  void removeOnlineUser(string usrkey, User user)
		{
			try
			{			
				lock (_Padlock)
				{
					foreach (string k in userOnline.Keys)
					{
						if(userOnline[k].userOnline.id==user.id)
						{
							userOnline.Remove(k);
						}
					}	
					userOnline.Remove(usrkey);
				}			
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				// DO NOTHING
			}	
		}
		
		public static void removeAllOnlineUser()
		{
			try
			{			
				lock (_Padlock)
				{					
					userOnline.Clear();
				}			
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				// DO NOTHING
			}	
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

		public static string renderField(IList<UserField> fieldList, User user, IDictionary<int,string> jsFunctions, string style, string cssClass, string langcode, string defLangCode, string useFor)
		{
			string renderField="";
			string jsFunction = "";

			try
			{
				string currentGroup = "";
				foreach(UserField cf in fieldList)
				{
					if(cf.enabled)
					{
						IList<UserFieldsValue> values = null;						
						string ufvalue = "";
						if(user != null && user.fields != null && user.fields.Count>0){
							foreach(UserFieldsMatch ufm in user.fields){
								if(ufm.idParentField==cf.id && ufm.idParentUser==user.id){
									ufvalue = ufm.value;
									break;
								}								
							}
						}
						
						string isrequired = "";
						if(cf.required){
							isrequired = "&nbsp;*";
						}
						
						string maxLenght = "";	
						if (cf.maxLenght>0) {
							maxLenght = " maxlength='"+cf.maxLenght+"'";
						}
								
						string keyPress = "";
						if(cf.typeContent==3){
							keyPress = " onkeypress='javascript:return isInteger(event);'";
						}else if(cf.typeContent==4){		
							keyPress = " onkeypress='javascript:return isDouble(event);'";
						}							

						string tmpGroup = cf.groupDescription;
						tmpGroup = translate("backend.utenti.detail.table.label.id_group_"+tmpGroup, tmpGroup, langcode, defLangCode);
						if(currentGroup!=tmpGroup)
						{
							renderField+="<h2>"+tmpGroup+"</h2>";
							currentGroup = tmpGroup;
						}
						
						renderField+="<div id='fe_container_user_field_"+cf.id+"' style='"+style+"' class='"+cssClass+"'>";
						
						string tmpDescription = cf.description;
						tmpDescription = translate("backend.utenti.detail.table.label.description_"+tmpDescription, tmpDescription, langcode, defLangCode);

						renderField+="<span>"+tmpDescription+isrequired+"</span>";
						
						switch (cf.type)
						{
							case 1:
								if(jsFunctions != null){
									jsFunctions.TryGetValue(cf.id, out jsFunction);
								}				
								renderField+="<input type='text' name='user_field_"+cf.id+"' id='tuser_field_"+cf.id+"' value='"+ufvalue+"' "+jsFunction+" "+keyPress+" "+maxLenght+">";
								if(cf.typeContent==5)
								{
									renderField+="<script>";
									renderField+="$(function() {";										
										renderField+="$('#tuser_field_"+cf.id+"').datepicker({";
											string hourMinutes = "";
											if(cf.typeContent==6){hourMinutes = " hh:mm";}											
											renderField+="dateFormat: 'dd/mm/yy"+hourMinutes+"',";
											renderField+="changeMonth: true,";
											renderField+="changeYear: true";
											//renderField+=",yearRange: '1900:"+DateTime.Now.GetYear()+"'";
										renderField+="});";											
									renderField+="});";										
									renderField+="</script>";
								}
								else if(cf.typeContent==6)
								{
									renderField+="<script>";
									renderField+="$(function() {";	
										renderField+="$('#tuser_field_"+cf.id+"').datetimepicker({";
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
								break;
							case 2:
								if(jsFunctions != null){
									jsFunctions.TryGetValue(cf.id, out jsFunction);
								}
								renderField+="<textarea name='user_field_"+cf.id+"' id='auser_field_"+cf.id+"' "+jsFunction+" "+maxLenght+">"+ufvalue+"</textarea>";
								break;
							case 3:
								if(jsFunctions != null){
									jsFunctions.TryGetValue(cf.id, out jsFunction);
								}
								renderField+="<select name='user_field_"+cf.id+"' id='suser_field_"+cf.id+"' "+jsFunction+">";
								if(!cf.required)
								{
									renderField+="<option></option>";
								}
								
								if(cf.typeContent==7)
								{
									IList<Country> countries = countryrep.findAllCountries(useFor);
									if(countries != null && countries.Count>0)
									{
										foreach(Country c in countries)
										{
											string selected = "";
											if(c.countryCode==ufvalue)
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
									IList<Country> stateRegions = countryrep.findAllStateRegion(useFor);
									if(stateRegions != null && stateRegions.Count>0)
									{
										foreach(Country c in stateRegions)
										{
											string selected = "";
											if(c.stateRegionCode==ufvalue)
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
									values = usrrep.getUserFieldValues(cf.id);
									if(values != null && values.Count>0)
									{
										foreach(UserFieldsValue cfv in values)
										{
											string selected = "";
											if(cfv.value==ufvalue)
											{
												selected = " selected='selected'";
											}						
											string tmpdefdesc = cfv.value;
											tmpdefdesc = translate("backend.utenti.detail.table.label.field_values_"+cf.description+"_"+tmpdefdesc, tmpdefdesc, langcode, defLangCode);
											renderField+="<option value='"+cfv.value+"' "+selected+">"+tmpdefdesc+"</option>";
										}
									}
								}
								renderField+="</select>";
								break;
							case 4:
								int tmpMaxL = 3;
								if(cf.maxLenght>tmpMaxL){
									tmpMaxL = cf.maxLenght;
								}
								if(jsFunctions != null){
									jsFunctions.TryGetValue(cf.id, out jsFunction);
								}
								renderField+="<select multiple size='"+tmpMaxL+"' name='user_field_"+cf.id+"' id='muser_field_"+cf.id+"' "+jsFunction+">";
								if(!cf.required)
								{
									renderField+="<option></option>";
								}
							
								values = usrrep.getUserFieldValues(cf.id);
								if(values != null && values.Count>0)
								{
									foreach(UserFieldsValue cfv in values)
									{
										string selected = "";
										string[] splittedValues = ufvalue.Split(',');
										
										if(splittedValues!=null){
											foreach(string s in splittedValues){												
												if(s.Trim()==cfv.value){
													selected = " selected='selected'";	
													break;
												}
											}
										}else if(cfv.value==ufvalue){
											selected = " selected='selected'";
										}
										
										string tmpdefmdesc = cfv.value;
										tmpdefmdesc = translate("backend.utenti.detail.table.label.field_values_"+cf.description+"_"+tmpdefmdesc, tmpdefmdesc, langcode, defLangCode);
										renderField+="<option value='"+cfv.value+"' "+selected+">"+tmpdefmdesc+"</option>";
									}
								}
								renderField+="</select>";	
								break;
							case 5:
								values = usrrep.getUserFieldValues(cf.id);
								if(values != null && values.Count>0)
								{
									if(jsFunctions != null){
										jsFunctions.TryGetValue(cf.id, out jsFunction);
									}
									renderField+="<div class='user_field_xcontainer'>";
									int tmpCounter=1;
									foreach(UserFieldsValue cfv in values)
									{
										string vchecked = "";
										string[] splittedValues = ufvalue.Split(',');
										
										//System.Web.HttpContext.Current.Response.Write("cfv.value: " + cfv.value+" -ufvalue: "+ufvalue+"<br>");

										if(splittedValues!=null){
											foreach(string s in splittedValues){
												//System.Web.HttpContext.Current.Response.Write("s: " + s+"<br>");												
												if(s.Trim()==cfv.value){
													vchecked = " checked='checked'";	
													break;
												}
											}
										}else if(cfv.value==ufvalue){
											vchecked = " checked='checked'";
										}
										
										string tmpckdesc = cfv.value;
										tmpckdesc = translate("backend.utenti.detail.table.label.field_values_"+cf.description+"_"+tmpckdesc, tmpckdesc, langcode, defLangCode);
										renderField+="<input type='checkbox' "+vchecked+" name='user_field_"+cf.id+"' id='xuser_field_"+cf.id+"' value='"+cfv.value+"' "+jsFunction+">&nbsp;<span>"+tmpckdesc+"</span>";
										if(tmpCounter % 3 == 0){
											renderField+="<br/>";
										}
										tmpCounter++;
									}
									renderField+="</div><div style='clear:left;'></div>";
								}
								break;
							case 6:
								values = usrrep.getUserFieldValues(cf.id);
								if(values != null && values.Count>0)
								{
									if(jsFunctions != null){
										jsFunctions.TryGetValue(cf.id, out jsFunction);
									}
									renderField+="<div class='user_field_rcontainer'>";
									int tmpCounter=1;
									foreach(UserFieldsValue cfv in values)
									{
										string vchecked = "";
										string[] splittedValues = ufvalue.Split(',');

										if(splittedValues!=null){
											foreach(string s in splittedValues){												
												if(s.Trim()==cfv.value){
													vchecked = " checked='checked'";	
													break;
												}
											}
										}else if(cfv.value==ufvalue){
											vchecked = " checked='checked'";
										}
										
										string tmprddesc = cfv.value;
										tmprddesc = translate("backend.utenti.detail.table.label.field_values_"+cf.description+"_"+tmprddesc, tmprddesc, langcode, defLangCode);
										renderField+="<input type='radio' "+vchecked+" name='user_field_"+cf.id+"' id='ruser_field_"+cf.id+"' value='"+cfv.value+"' "+jsFunction+">&nbsp;<span>"+tmprddesc+"</span>";
										if(tmpCounter % 3 == 0){
											renderField+="<br/>";
										}
										tmpCounter++;
									}
									renderField+="</div>";
								}
								break;
							case 7:
								renderField+="<input type='hidden' value='"+ufvalue+"' name='user_field_"+cf.id+"' id='huser_field_"+cf.id+"'>";
								break;
							case 8:							
								renderField+="<input type='file' name='user_field_"+cf.id+"' id='fuser_field_"+cf.id+"'>";
								break;
							case 9:
								renderField+="<textarea name='user_field_"+cf.id+"' id='euser_field_"+cf.id+"' class='formFieldTXTAREAAbstract' "+maxLenght+">"+ufvalue+"</textarea>";
								renderField+="<script>";
								renderField+="$.cleditor.defaultOptions.width = 600;";
								renderField+="$.cleditor.defaultOptions.height = 200;";
								renderField+="$.cleditor.defaultOptions.controls = \"bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image\";";		
								renderField+="$(document).ready(function(){";
									renderField+="$('#euser_field_"+cf.id+"').cleditor();";
								renderField+="});";
								renderField+="</script>";	
								break;
							case 10:
								if(jsFunctions != null){
									jsFunctions.TryGetValue(cf.id, out jsFunction);
								}	
								renderField+="<input type='password' name='user_field_"+cf.id+"' id='puser_field_"+cf.id+"' value='"+ufvalue+"' class='formFieldTXTMedium2' "+jsFunction+" "+keyPress+" "+maxLenght+">";
								break;
							default:
								break;
						}
					}	
					
					renderField+="</div><div style='clear:left;'></div>";				
				}
			}
			catch(Exception ex)
			{
				renderField = "";
			}
						
			return renderField;				
		}

		public static string renderFieldJsFormValidation(IList<UserField> fieldList, User user, string langcode, string defLangCode)
		{
			StringBuilder renderFieldJs= new StringBuilder();

			try
			{
				foreach(UserField cf in fieldList)
				{
					if(cf.enabled)
					{				
						switch (cf.type)
						{
							case 1: case 2: case 9: case 10:
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
									renderFieldJs.Append("if($('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').val()==''){")
										.Append("alert('")
										.Append(translate("portal.commons.content_field.js.alert.insert_value", "insert value for:", langcode, defLangCode))
										.Append(" ")
										.Append(translate("backend.utenti.detail.table.label.description_"+cf.description, cf.description, langcode, defLangCode))
										.Append("');")										
										.Append("$('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').focus();")
										.Append("return;")
									.Append("}");
								}
								
								if(cf.typeContent==2){
									renderFieldJs.Append("var tmpmail = ").Append("$('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').val();")
									.Append("if(tmpmail != ''){")
										.Append("if(tmpmail.indexOf('@')<2 || tmpmail.indexOf('.')==-1 || tmpmail.indexOf(' ')!=-1 || tmpmail.length<6){")
											.Append("alert('")
											.Append(translate("portal.commons.content_field.js.alert.wrong_mail", "insert right mail format for:", langcode, defLangCode))
											.Append(" ")
											.Append(translate("backend.utenti.detail.table.label.description_"+cf.description, cf.description, langcode, defLangCode))
											.Append("');")										
											.Append("$('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').focus();")
											.Append("return;")
										.Append("}")
									.Append("}else if(strMail == ''){")
										.Append("alert('")
										.Append(translate("portal.commons.content_field.js.alert.wrong_mail", "insert mail for:", langcode, defLangCode))
										.Append(" ")
										.Append(translate("backend.utenti.detail.table.label.description_"+cf.description, cf.description, langcode, defLangCode))
										.Append("');")										
										.Append("$('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').focus();")
										.Append("return;")
									.Append("}");											
								}else if(cf.typeContent==3){
									renderFieldJs.Append("if(isNaN($('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').val())){")
										.Append("alert('")
										.Append(translate("portal.commons.content_field.js.alert.isnan_value", "insert integer value:", langcode, defLangCode))
										.Append(" ")
										.Append(translate("backend.utenti.detail.table.label.description_"+cf.description, cf.description, langcode, defLangCode))
										.Append("');")
										.Append("$('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').focus();")
										.Append("return;")
									.Append("}");	
								}else if(cf.typeContent==4){	
									renderFieldJs.Append("if($('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').val().length > 0 && (!checkDoubleFormatExt($('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').val()) || $('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').val().indexOf('.')!=-1)){")	
									//renderFieldJs.Append("if(!isDouble($('#").Append(prefixfield).Append("content_field_").Append(cf.id).Append("').val())){")
										.Append("alert('")
										.Append(translate("portal.commons.content_field.js.alert.isnan_value", "insert double value:", langcode, defLangCode))
										.Append(" ")
										.Append(translate("backend.utenti.detail.table.label.description_"+cf.description, cf.description, langcode, defLangCode))
										.Append("');")
										.Append("$('#").Append(prefixfield).Append("user_field_").Append(cf.id).Append("').focus();")
										.Append("return;")
									.Append("}");	
								}
								break;
							case 5:
								if(cf.required){
									renderFieldJs.Append("var hasElem = false;")
									.Append("$('input:checkbox[id*=\"xuser_field_").Append(cf.id).Append("\"]').each( function(){")
										.Append("if($(this).val() != ''){")
											.Append("hasElem = true;")											 
										.Append("}")									
									.Append("});")
									.Append("if(!hasElem){")
										.Append("alert('")
										.Append(translate("portal.commons.content_field.js.alert.insert_value", "insert value for:", langcode, defLangCode))
										.Append(" ")
										.Append(translate("backend.utenti.detail.table.label.description_"+cf.description, cf.description, langcode, defLangCode))
										.Append("');")										
										.Append("return;")								 
									.Append("}");																	
								}
								break;
							case 6:
								if(cf.required){
									renderFieldJs.Append("var hasElem = false;")
									.Append("$('input:radio[id*=\"ruser_field_").Append(cf.id).Append("\"]').each( function(){")
										.Append("if($(this).val() != ''){")
											.Append("hasElem = true;")											 
										.Append("}")									
									.Append("});")
									.Append("if(!hasElem){")
										.Append("alert('")
										.Append(translate("portal.commons.content_field.js.alert.insert_value", "insert value for:", langcode, defLangCode))
										.Append(" ")
										.Append(translate("backend.utenti.detail.table.label.description_"+cf.description, cf.description, langcode, defLangCode))
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
		
		public static IList<User> sortUserByField(IList<User> users, int idField)
		{
			IList<User> result = new List<User>();
			IDictionary<string,User> dusers = new Dictionary<string,User>();
			//perform load of dictionary with users data
			foreach(User u in users)
			{
				if(u.fields != null && u.fields.Count>0)
				{
					foreach(UserFieldsMatch ufm in u.fields)
					{
						if(ufm.idParentField==idField)
						{
							dusers.Add(ufm.value+"_"+u.id,u);
							break;
						}
					}
				}
				else
				{
					dusers.Add("_"+u.id,u);
				}
			}
			
			// Store keys in a List
			List<string> list = new List<string>(dusers.Keys);
			list.Sort();
			
			// Loop through list
			foreach (string k in list)
			{
				User usr = null;
				dusers.TryGetValue(k, out usr);
				if(usr != null)
				{
					result.Add(usr);
				}
			}			
			
			return result;
		}
		
		public static void SaveStreamToFile(Stream stream, string filename)
		{  
		   using(Stream destination = File.Create(filename))
			  Write(stream, destination);
		}
		
		//Typically I implement this Write method as a Stream extension method. 
		//The framework handles buffering.		
		static void Write(Stream from, Stream to)
		{
		   for(int a = from.ReadByte(); a != -1; a = from.ReadByte())
			  to.WriteByte( (byte) a );
		}
	}
}