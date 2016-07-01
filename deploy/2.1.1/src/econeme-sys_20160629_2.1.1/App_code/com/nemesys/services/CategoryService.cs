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
	public class CategoryService
	{
		protected static ICategoryRepository cattrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");

		public static string renderCategoryBox(string label, IList<Category> arrCats, string langcode, string defLangCode, User user, string fieldName, bool filter, IList<IElementCategory> catElements)
		{			
			string renderTargetBox="";
			
			try
			{				
				renderTargetBox+="<span class='labelForm'>"+label+"</span>";
				renderTargetBox+="&nbsp;<input type='checkbox' onclick='javascript:selectAllCategories();' value='' id='check_all_categories' name='check_all_categories'>";
				renderTargetBox+="<div align='center' style='width:502px; overflow:auto; height:200px; border:1px solid #727272;z-index:1;'>";
				renderTargetBox+="<div style='z-index:10000;text-align:left;'>";
				renderTargetBox+="<ul style='text-align:left;list-style-type:none;'>";
										
				if (arrCats!=null) {
					foreach(Category y in arrCats)
					{
						
						string ischecked = "";
						string disabled = "";
						int offset = y.getLevel() >1 ? y.getLevel()*8 : 0;
						
						if(!y.hasElements)
						{
							disabled = " disabled='disabled'";
						}

						if(catElements != null)
						{
							bool isAvailable = true;
							if(filter){
								isAvailable = false;
								if(checkUserCategory(user, y)){isAvailable=true;}
							}
							if(catElements!=null && catElements.Count>0)
							{
								foreach(IElementCategory iec in catElements)
								{
									if(iec.idCategory==y.id)
									{
										ischecked = "checked='checked'";
										break;
									}
								}
							}
							if(isAvailable){			
								renderTargetBox+="<li style='padding-left:"+offset+"px'><input type='checkbox' "+disabled+" value='"+y.id+"' name='"+fieldName+"' "+ischecked+">&nbsp;"+y.description+"</li>";
							}
						}
						else if(user!=null)
						{
							if(user.categories!=null || !filter)
							{
								bool isAvailable = true;
								if(filter){
									isAvailable = false;
									if(checkUserCategory(user, y)){isAvailable=true;}
								}
								if(!filter)
								{
									foreach(UserCategory uc in user.categories)
									{
										if(uc.idCategory==y.id)
										{
											ischecked = "checked='checked'";
											break;
										}
									}
								}
								if(isAvailable){				
									renderTargetBox+="<li style='padding-left:"+offset+"px'><input type='checkbox' "+disabled+" value='"+y.id+"' name='"+fieldName+"' "+ischecked+">&nbsp;"+y.description+"</li>";
								}
							}							
						}
						else if(!filter){			
							renderTargetBox+="<li style='padding-left:"+offset+"px'><input type='checkbox' "+disabled+" value='"+y.id+"' name='"+fieldName+"' "+ischecked+">&nbsp;"+y.description+"</li>";
						}
					}
				}		
				
				renderTargetBox+="</ul></div>";
				renderTargetBox+="</div>";

				renderTargetBox+="<script>";
				renderTargetBox+="function selectAllCategories(){";
					renderTargetBox+="var ischecked;";
					//renderTargetBox+="alert(\"check_all_categories:\"+$('#check_all_categories:checked').val());";
					renderTargetBox+="if($('#check_all_categories').is(':checked')){";
						renderTargetBox+="$('input:checkbox[name=\""+fieldName+"\"]').each( function(){";
							//renderTargetBox+="alert(\"this:\"+$(this).val());";
							renderTargetBox+="if(!$(this).is(':disabled')){";	
								renderTargetBox+="$(this).attr('checked', true);";
							renderTargetBox+="}";
						renderTargetBox+="});";
					renderTargetBox+="}else{";
						renderTargetBox+="$('input:checkbox[name=\""+fieldName+"\"]').each( function(){";	
							//renderTargetBox+="alert(\"this:\"+$(this).val());";
							renderTargetBox+="$(this).attr('checked', false);";
						renderTargetBox+="});";
					renderTargetBox+="}";
				renderTargetBox+="}";
				renderTargetBox+="</script>";	 
			}
			catch(Exception ex)
			{
				System.Web.HttpContext.Current.Response.Write("<b>error: </b>"+ex.Message+"<br>");
				renderTargetBox = "";
			}
			
			return renderTargetBox;			
		}
		
		public static bool checkUserCategory(User user, Category category)
		{
			try
			{
				//System.Web.HttpContext.Current.Response.Write("<b>category: </b>"+category.ToString()+"<br>");
				//System.Web.HttpContext.Current.Response.Write("<b>user == null: </b>"+(user == null)+"<br>");
				//System.Web.HttpContext.Current.Response.Write("<b>user.categories == null: </b>"+(user.categories == null)+"<br>");
				//System.Web.HttpContext.Current.Response.Write("<b>user.categories.Count == 0: </b>"+(user.categories.Count == 0)+"<br>");
				
				// eseguo prima i controlli base
				if(user == null){return false;}
				if(user.categories == null){return false;}
				if(user.categories.Count == 0){return false;}
				
				foreach(UserCategory ucl in user.categories)
				{
					//System.Web.HttpContext.Current.Response.Write("ucl.idCategory:"+ucl.idCategory+" -category.id:"+category.id+"<br>");
					if(ucl.idCategory==category.id)
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
		
		public static bool isCategoryNull(Category category)
		{
			return (category == null || category.id==-1);	
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
		
		public static bool deleteCategoryImage(string filePath)
		{
			bool deleted = false;
			//cancello la directory fisica del template
			try{
				string tpath = HttpContext.Current.Server.MapPath("~/public/upload/files/categories/"+filePath);
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
		
		public static int getTemplateId(Category category, string currLangCode)
		{
			int templateId = category.idTemplate;
			foreach(CategoryTemplate ct in category.templates)
			{
				if(ct.langCode==currLangCode)
				{
					templateId = ct.templateId;
					break;
				}	
			}

			return templateId;
		}
	}
}