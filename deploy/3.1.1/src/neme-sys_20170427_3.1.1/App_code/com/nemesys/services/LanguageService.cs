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
	public class LanguageService
	{
		protected static ILanguageRepository langtrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");

		public static string renderLanguageBox(string resJsVar, string idBoxSx, string idBoxDx, string labelSx, string labelDx, IList<Language> arrSx, IList<Language> arrDx, bool bolCheckAutoT, bool bolAddDescTrans, string langcode, string defLangCode, User user)
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
				renderTargetBox+="<div style='float: left;display:block;'>";
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
								if(checkUserLanguage(user, y)){
									renderTargetBox+="<li class='ui-state-default' style='margin: 2px; padding: 2px; font-size: 11px; width: 200px; cursor:move;' id='"+y.id+"'>"+ttype+"</li>"	;					
								} 
							}
						}				
					}else{
						foreach(Language y in arrDx)
						{			
							imgLang="<img src='/backoffice/img/flag/flag-"+y.label+".png' border=0 hspace=2 vspace=0 align=top>";						
							ttype=imgLang+MultiLanguageService.translate("portal.header.label.desc_lang."+y.label, langcode, defLangCode);
							if(checkUserLanguage(user, y)){
								renderTargetBox+="<li class='ui-state-default' style='margin: 2px; padding: 2px; font-size: 11px; width: 200px; cursor:move;' id='"+y.id+"'>"+ttype+"</li>";
							}
						}
					}	
				}else{
					return null;
				}	
					
				renderTargetBox+="</ul>";
				renderTargetBox+="</div>";
				renderTargetBox+="<br clear='both'/>";
		
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
		
		public static bool checkUserLanguage(User user, Language language)
		{
			try
			{
				//System.Web.HttpContext.Current.Response.Write("<b>language: </b>"+language.ToString()+"<br>");
				//System.Web.HttpContext.Current.Response.Write("<b>user == null: </b>"+(user == null)+"<br>");
				//System.Web.HttpContext.Current.Response.Write("<b>user.languages == null: </b>"+(user.languages == null)+"<br>");
				//System.Web.HttpContext.Current.Response.Write("<b>user.languages.Count == 0: </b>"+(user.languages.Count == 0)+"<br>");
				
				// eseguo prima i controlli base
				if(user == null){return true;}
				if(user.languages == null){return false;}
				if(user.languages.Count == 0){return false;}
				
				foreach(UserLanguage ull in user.languages)
				{
					if(ull.idLanguage==language.id)
					{
						return true;
					}
				}
				}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("<b>Exception: </b>"+ex.Message+"<br>");
				return false;
			}
				
			return false;
		}
		
		public static bool isLanguageNull(Language language)
		{
			return (language == null || language.id==-1);	
		}
	}
}