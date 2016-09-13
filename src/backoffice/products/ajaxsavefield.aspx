<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="Newtonsoft.Json" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;
			
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}	

protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	string cssClass="LN";	
	login.acceptedRoles = "1,2";
	if(!login.checkedUser()){
		//Response.Redirect("~/login.aspx?error_code=002");
		Response.StatusCode = 400;
		return;
	}
		
	IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IMultiLanguageRepository mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
	Logger log = new Logger();
	StringBuilder errorMsg = new StringBuilder();
	IList<Language> languages;
	ProductField newField = new ProductField();

	//Response.Write(Environment.Version);

	try{			
		languages = langrep.getLanguageList();	
		if(languages == null){				
			languages = new List<Language>();						
		}
	}catch (Exception ex){
		languages = new List<Language>();
	}
			
	bool carryOn = true;
	try
	{	
		if("addfield"==Request["operation"]){
			newField.id=-1;
		}else if("updfield"==Request["operation"]){
			newField = prodrep.getProductFieldById(Convert.ToInt32(Request["id_field"]));
		}
		newField.idParentProduct = Convert.ToInt32(Request["id_product"]);
		if(!String.IsNullOrEmpty(Request["pre_el_id"])){
			newField.idParentProduct = Convert.ToInt32(Request["pre_el_id"]);					
		}
		newField.description = Request["field_description"];
		newField.groupDescription = Request["group_value"];
		newField.value = Request["field_value"];
		newField.type = Convert.ToInt32(Request["id_type"]);
		newField.typeContent = Convert.ToInt32(Request["id_type_content"]);
		int tmpsort = 0;
		if(!String.IsNullOrEmpty(Request["sorting"])){tmpsort = Convert.ToInt32(Request["sorting"]);}
		newField.sorting = tmpsort;
		bool tmpreq = false;
		if(!String.IsNullOrEmpty(Request["product_field_mandatory"])){tmpreq = Convert.ToBoolean(Convert.ToInt32(Request["product_field_mandatory"]));}
		newField.required = tmpreq;
		bool tmpenabled = false;
		if(!String.IsNullOrEmpty(Request["product_field_active"])){tmpenabled = Convert.ToBoolean(Convert.ToInt32(Request["product_field_active"]));}
		newField.enabled = tmpenabled;
		bool tmpedit = false;
		if(!String.IsNullOrEmpty(Request["product_field_editable"])){tmpedit = Convert.ToBoolean(Convert.ToInt32(Request["product_field_editable"]));}
		newField.editable = tmpedit;
		int tmpmlen = -1;
		if(!String.IsNullOrEmpty(Request["max_lenght"])){tmpmlen = Convert.ToInt32(Request["max_lenght"]);}
		newField.maxLenght = tmpmlen;
		
		// PREPARO LE LISTE DI CHIAVI MULTILINGUA DA INSERIRE/AGGIORNARE IN TRANSAZIONE
		IList<MultiLanguage> newtranslactions = new List<MultiLanguage>();
		IList<MultiLanguage> updtranslactions = new List<MultiLanguage>();
		IList<MultiLanguage> deltranslactions = new List<MultiLanguage>();	
		
		IList<ProductFieldTranslation> fieldsTrans = new List<ProductFieldTranslation>();
		
		//Response.Write("field_description_ml:"+Request["field_description_ml"]+"<br>");		
		//Response.Write("prod_code:"+Request["prod_code"]+"<br>");
		
		if(!String.IsNullOrEmpty(Request["prod_code"]))
		{
			string prodCode = Request["prod_code"];

			//******************  START: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/
								
			foreach (Language x in languages){				
				if(!String.IsNullOrEmpty(Request["field_description_ml"]))
				{									
					Dictionary<string, string> mlvalues = JsonConvert.DeserializeObject<Dictionary<string, string>>(Request["field_description_ml"]);
					MultiLanguage ml = null;					
					
					/*
					//*** insert description
					ml = mlangrep.find("backend.prodotti.detail.table.label.field_description_"+newField.description+"_"+prodCode, x.label);					
					if(ml != null){
						string tmpval = "";
						ml.value = "";
						mlvalues.TryGetValue(x.label, out tmpval);							
						if(!String.IsNullOrEmpty(tmpval)){
							ml.value = tmpval.Replace("&quot;","\"");
							updtranslactions.Add(ml);
						}else{
							deltranslactions.Add(ml);									
						}
					}else{
						ml = new MultiLanguage();
						ml.keyword = "backend.prodotti.detail.table.label.field_description_"+newField.description+"_"+prodCode;
						ml.langCode = x.label;
						string tmpval = "";
						ml.value = "";
						mlvalues.TryGetValue(x.label, out tmpval);
						if(!String.IsNullOrEmpty(tmpval)){	
							ml.value = tmpval.Replace("&quot;","\"");			
							newtranslactions.Add(ml);
						}
					}
					*/
					
					string tmpval = "";
					mlvalues.TryGetValue(x.label, out tmpval);							
					if(!String.IsNullOrEmpty(tmpval)){
						ProductFieldTranslation pft = new ProductFieldTranslation();
						pft.idParentProduct = newField.idParentProduct;
						pft.idField = newField.id;
						pft.type = "desc";
						pft.baseVal = "";
						pft.langCode = x.label;
						pft.value = tmpval.Replace("&quot;","\"");
						fieldsTrans.Add(pft); 
					}
				}
				
				if(!String.IsNullOrEmpty(Request["group_value_ml"]))
				{
					Dictionary<string, string> mlvalues = JsonConvert.DeserializeObject<Dictionary<string, string>>(Request["group_value_ml"]);
					MultiLanguage ml = null;
					
					/*
					//*** insert group
					ml = mlangrep.find("backend.prodotti.detail.table.label.id_group_"+newField.groupDescription+"_"+prodCode, x.label);					
					if(ml != null){
						string tmpval = "";
						ml.value = "";
						mlvalues.TryGetValue(x.label, out tmpval);							
						if(!String.IsNullOrEmpty(tmpval)){
							ml.value = tmpval.Replace("&quot;","\"");
							updtranslactions.Add(ml);
						}else{
							deltranslactions.Add(ml);									
						}
					}else{
						ml = new MultiLanguage();
						ml.keyword = "backend.prodotti.detail.table.label.id_group_"+newField.groupDescription+"_"+prodCode;
						ml.langCode = x.label;
						string tmpval = "";
						ml.value = "";
						mlvalues.TryGetValue(x.label, out tmpval);
						if(!String.IsNullOrEmpty(tmpval)){	
							ml.value = tmpval.Replace("&quot;","\"");			
							newtranslactions.Add(ml);
						}
					}	
					*/
					
					string tmpval = "";
					mlvalues.TryGetValue(x.label, out tmpval);							
					if(!String.IsNullOrEmpty(tmpval)){
						ProductFieldTranslation pft = new ProductFieldTranslation();
						pft.idParentProduct = newField.idParentProduct;
						pft.idField = newField.id;
						pft.type = "group";
						pft.baseVal = "";
						pft.langCode = x.label;
						pft.value = tmpval.Replace("&quot;","\"");
						fieldsTrans.Add(pft); 
					}
				}
				
				if((newField.type==3 || newField.type==4 || newField.type==5 || newField.type==6) && (newField.typeContent != 7) && (newField.typeContent != 8))
				{
					if(!String.IsNullOrEmpty(Request["list_product_fields_values_ml"]))
					{	
						//Response.Write("<br>- label:"+x.label+"<br>- list_product_fields_values_ml:"+Request["list_product_fields_values_ml"]+"<br><br>");

						DataSet mlvalues = JsonConvert.DeserializeObject<DataSet>(Request["list_product_fields_values_ml"]);
						MultiLanguage ml = null;
						
						foreach(DataTable table in mlvalues.Tables)
						{
							//Response.Write("table: "+table+"<br>");
								
							foreach(DataRow row in table.Rows)
							{
								//Response.Write(column+" : "+row[column]+"<br>");
								//Response.Write("column: "+column.ToString()+"<br>");
								//Response.Write("row: "+row.ToString()+"<br>");
								
								/*
								//*** insert product fields values	
								ml = mlangrep.find("backend.prodotti.detail.table.label.field_values_"+newField.description+"_"+table+"_"+prodCode, x.label);
								if(ml != null){									
									string tmpval = row[x.label].ToString();
									ml.value = "";	
									if(!String.IsNullOrEmpty(tmpval)){
										ml.value = tmpval.Replace("&quot;","\"");
										updtranslactions.Add(ml);
									}else{
										deltranslactions.Add(ml);									
									}
								}else{
									ml = new MultiLanguage();
									ml.keyword = "backend.prodotti.detail.table.label.field_values_"+newField.description+"_"+table+"_"+prodCode;
									ml.langCode = x.label;										
									string tmpval = row[x.label].ToString();
									ml.value = "";
									if(!String.IsNullOrEmpty(tmpval)){	
										ml.value = tmpval.Replace("&quot;","\"");
										newtranslactions.Add(ml);
									}
								}
								*/											
								
								string tmpval = row[x.label].ToString();
								//Response.Write("tmpval: "+tmpval+"<br>");
								if(!String.IsNullOrEmpty(tmpval)){	
									ProductFieldTranslation pft = new ProductFieldTranslation();
									pft.idParentProduct = newField.idParentProduct;
									pft.idField = newField.idParentProduct;
									pft.type = "values";
									pft.baseVal = table.ToString();
									pft.langCode = x.label;
									pft.value = tmpval.Replace("&quot;","\"");
									fieldsTrans.Add(pft); 
								}
							}
						}	
					}
				}
				
				if((newField.type==1 || newField.type==2 || newField.type==9) && (newField.typeContent != 7) && (newField.typeContent != 8))
				{
					//*** insert field_value_t
					if(!String.IsNullOrEmpty(Request["field_value_t_ml"]))
					{									
						Dictionary<string, string> mlvalues = JsonConvert.DeserializeObject<Dictionary<string, string>>(Request["field_value_t_ml"]);
						MultiLanguage ml = null;					
						
						/*
						ml = mlangrep.find("backend.prodotti.detail.table.label.field_value_t_"+newField.description+"_"+prodCode, x.label);					
						if(ml != null){
							string tmpval = "";
							ml.value = "";
							mlvalues.TryGetValue(x.label, out tmpval);							
							if(!String.IsNullOrEmpty(tmpval)){
								ml.value = tmpval.Replace("&quot;","\"");
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.prodotti.detail.table.label.field_value_t_"+newField.description+"_"+prodCode;
							ml.langCode = x.label;
							string tmpval = "";
							ml.value = "";
							mlvalues.TryGetValue(x.label, out tmpval);
							if(!String.IsNullOrEmpty(tmpval)){	
								ml.value = tmpval.Replace("&quot;","\"");			
								newtranslactions.Add(ml);
							}
						}
						*/
						
						string tmpval = "";
						mlvalues.TryGetValue(x.label, out tmpval);	
						
						if(!String.IsNullOrEmpty(tmpval)){
							ProductFieldTranslation pft = new ProductFieldTranslation();
							pft.idParentProduct = newField.idParentProduct;
							pft.idField = newField.idParentProduct;
							pft.type = "value";
							pft.baseVal = "";
							pft.langCode = x.label;
							pft.value = tmpval.Replace("&quot;","\"");
							fieldsTrans.Add(pft); 
						}						
					}
		
					//*** insert field_value_ta			
					if(!String.IsNullOrEmpty(Request["field_value_ta_ml"]))
					{									
						Dictionary<string, string> mlvalues = JsonConvert.DeserializeObject<Dictionary<string, string>>(Request["field_value_ta_ml"]);
						MultiLanguage ml = null;					
						
						/*
						ml = mlangrep.find("backend.prodotti.detail.table.label.field_value_ta_"+newField.description+"_"+prodCode, x.label);					
						if(ml != null){
							string tmpval = "";
							ml.value = "";
							mlvalues.TryGetValue(x.label, out tmpval);							
							if(!String.IsNullOrEmpty(tmpval)){
								ml.value = tmpval.Replace("&quot;","\"");
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.prodotti.detail.table.label.field_value_ta_"+newField.description+"_"+prodCode;
							ml.langCode = x.label;
							string tmpval = "";
							ml.value = "";
							mlvalues.TryGetValue(x.label, out tmpval);
							if(!String.IsNullOrEmpty(tmpval)){	
								ml.value = tmpval.Replace("&quot;","\"");			
								newtranslactions.Add(ml);
							}
						}
						*/
						
						string tmpval = "";
						mlvalues.TryGetValue(x.label, out tmpval);	
						
						if(!String.IsNullOrEmpty(tmpval)){
							ProductFieldTranslation pft = new ProductFieldTranslation();
							pft.idParentProduct = newField.idParentProduct;
							pft.idField = newField.id;
							pft.type = "value";
							pft.baseVal = "";
							pft.langCode = x.label;
							pft.value = tmpval.Replace("&quot;","\"");
							fieldsTrans.Add(pft); 
						}
					}
		
					//*** insert field_value_e			
					if(!String.IsNullOrEmpty(Request["field_value_e_ml"]))
					{									
						Dictionary<string, string> mlvalues = JsonConvert.DeserializeObject<Dictionary<string, string>>(Request["field_value_e_ml"]);
						MultiLanguage ml = null;					
						
						/*
						ml = mlangrep.find("backend.prodotti.detail.table.label.field_value_e_"+newField.description+"_"+prodCode, x.label);					
						if(ml != null){
							string tmpval = "";
							ml.value = "";
							mlvalues.TryGetValue(x.label, out tmpval);							
							if(!String.IsNullOrEmpty(tmpval)){
								ml.value = tmpval.Replace("&quot;","\"");
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.prodotti.detail.table.label.field_value_e_"+newField.description+"_"+prodCode;
							ml.langCode = x.label;
							string tmpval = "";
							ml.value = "";
							mlvalues.TryGetValue(x.label, out tmpval);
							if(!String.IsNullOrEmpty(tmpval)){	
								ml.value = tmpval.Replace("&quot;","\"");			
								newtranslactions.Add(ml);
							}
						}	
						*/
						
						
						string tmpval = "";
						mlvalues.TryGetValue(x.label, out tmpval);	
						
						if(!String.IsNullOrEmpty(tmpval)){
							ProductFieldTranslation pft = new ProductFieldTranslation();
							pft.idParentProduct = newField.idParentProduct;
							pft.idField = newField.id;
							pft.type = "value";
							pft.baseVal = "";
							pft.langCode = x.label;
							pft.value = tmpval.Replace("&quot;","\"");
							fieldsTrans.Add(pft); 
						}
					}				
				}
			}					
							
			//TODO: MFT
			// completare con gli altri campi dei fields: 
			// - description: DONE
			// - group: DONE
			// - select/radio/checkbox: DONE
			// - text/textarea: DONE
			// - html-editor: DONE
			
			//******************  END: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/
		}
		
		// RECUPERO I FIELD VALUES
		IList<ProductFieldsValue> newFieldValues = new List<ProductFieldsValue>();
		
		if(!String.IsNullOrEmpty(Request["list_product_fields_values"]))
		{
			Dictionary<string, string> fieldValues = JsonConvert.DeserializeObject<Dictionary<string, string>>(Request["list_product_fields_values"]);
			Dictionary<string, string> fieldValuesQty = new Dictionary<string, string>();
			if(!String.IsNullOrEmpty(Request["list_product_fields_values_qty"]))
			{
				fieldValuesQty = JsonConvert.DeserializeObject<Dictionary<string, string>>(Request["list_product_fields_values_qty"]);
			}
			int counter = 1;
			foreach(KeyValuePair<string, string> entry in fieldValues)
			{
				// do something with entry.Value or entry.Key
				
				ProductFieldsValue cfv = new ProductFieldsValue();
				cfv.idParentField = newField.id;
				cfv.value = entry.Value;
				cfv.sorting = counter;
				
				int tmpqty = 0;	
				string tmpval = "";
				fieldValuesQty.TryGetValue(entry.Key, out tmpval);							
				if(!String.IsNullOrEmpty(tmpval)){
					tmpqty = Convert.ToInt32(tmpval);
				}
				cfv.quantity = tmpqty;
				
				newFieldValues.Add(cfv);
				counter++;
			}
		}
						
		try
		{
			prodrep.saveCompleteProductField(newField, newFieldValues, newtranslactions, updtranslactions, deltranslactions, fieldsTrans);

			foreach(MultiLanguage value in updtranslactions){
				MultiLanguageRepository.cleanCache(value);
			}		
			foreach(MultiLanguage value in deltranslactions){
				MultiLanguageRepository.cleanCache(value);
			}		
			foreach(MultiLanguage value in newtranslactions){
				MultiLanguageRepository.cleanCache(value);
			}
			
			log.usr= login.userLogged.username;
			log.msg = "save product field: "+newField.ToString();
			log.type = "info";
			log.date = DateTime.Now;
			lrep.write(log);
		}
		catch(Exception ex)
		{
			throw;					
		}	
	}
	catch(Exception ex)
	{
		errorMsg.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
		carryOn = false;
		//Response.Write(ex.Message);
	}
		
	if(carryOn){
		////Response.Redirect("/backoffice/products/insertproduct.aspx?id="+Request["id_product"]+"&cssClass="+cssClass);		
		//Response.Write(newField.id+"<br>");	
		//Response.Write(Request["list_product_fields_values"]+"<br>");
		//Response.Write(Request["list_product_fields_values_qty"]+"<br>");
		StringBuilder resp = new StringBuilder()
		.Append("{\"newfieldid\":").Append("\""+newField.id+"\"").Append(",")
		.Append("\"newfielddesc\":").Append("\""+newField.description+"\"").Append(",")
		.Append("\"fieldsvalues\":").Append(Request["list_product_fields_values"]).Append(",")
		.Append("\"fieldsvaluesqty\":").Append(Request["list_product_fields_values_qty"]).Append("}");
		Response.Write(resp.ToString());
	}else{
		//Response.Redirect(url.ToString());
		//url = new StringBuilder("Exception: ")
		//.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		log = new Logger(errorMsg.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		Response.StatusCode = 400;
	}
}
</script>