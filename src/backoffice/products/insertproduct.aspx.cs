using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;
using System.Runtime.Remoting;
using System.Reflection;
using System.Net.Mail;
using System.Net.Mime;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using NHibernate;
using NHibernate.Criterion;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.database.repository;
using com.nemesys.services;
using Newtonsoft.Json;

public partial class _Product : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected IList<Category> categories;
	protected IList<Language> productlanguages;	
	protected IList<IElementCategory> productcategories;	
	protected IList<Language> languages;
	protected IList<User> users;
	protected IList<ProductAttachmentLabel> productAttachmentLabel;
	protected IList<Comment> comments;
	protected IList<SystemFieldsType> systemFieldsType;
	protected IList<SystemFieldsTypeContent> systemFieldsTypeContent;
	protected IList<string> fieldNames;
	protected IList<string> fieldGroupNames;
	protected IList<string> daysOfWeek;
	protected ProductRotation pr;
	protected IDictionary<string, IList<string>> previewUrls;
	protected Product product;
	protected IList<Product> productRelations;
	protected IMultiLanguageRepository mlangrep;
	protected IGeolocalizationRepository georep;
	protected IProductRepository prodrep;
	protected ICountryRepository countryrep;
	protected ISupplementRepository suprep;
	protected ISupplementGroupRepository supgrep;
	protected string pre_el_id;
	protected string pre_el_id_transfield;
	protected int numMaxAttachs = 2;
	protected UriBuilder ubuilder = null;
	protected bool hasProductFields,hasFieldsList,hasComments,hasCommonProductFields,hasSupplements,hasSupplementsg,hasRelations;
	protected string country_opt_text;
	protected string state_region_opt_text;
	protected IList<Country> countries;
	protected IList<Country> stateRegions;
	protected IList<ProductField> commonfields;
	protected IList<Supplement> supplements;
	protected IList<SupplementGroup> supplementsg;
	protected IDictionary<int, IList<ProductFieldsValue>> dictProdFieldValues;
	protected IList<IDictionary<string,string>> correlableFieldValues;
	protected string rotation_mode_tmp_d;
	protected string rotation_mode_tmp_w;
	protected string rotation_mode_tmp_h;
	protected string calendarEvents;
	
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
		cssClass="LP";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
		countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
		ICommentRepository commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
		ICommonRepository commonrep = RepositoryFactory.getInstance<ICommonRepository>("ICommonRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		IMailRepository mailrep = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		IUserRepository urep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		georep = RepositoryFactory.getInstance<IGeolocalizationRepository>("IGeolocalizationRepository");
		suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
		supgrep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
		ConfigurationService configService = new ConfigurationService();
		productlanguages = new List<Language>();
		productcategories = null;
		productRelations = new List<Product>();
		hasRelations = false;
		hasProductFields = false;
		hasCommonProductFields = false;	
		commonfields =  new List<ProductField>();
		hasFieldsList = false;	
		hasComments = false;
		comments = new List<Comment>();
		systemFieldsType = new List<SystemFieldsType>();
		systemFieldsTypeContent = new List<SystemFieldsTypeContent>();
		dictProdFieldValues = new Dictionary<int, IList<ProductFieldsValue>>();
		correlableFieldValues = new List<IDictionary<string,string>>();
		fieldNames = new List<string>();
		fieldGroupNames = new List<string>();
		daysOfWeek = new List<string>();
		pr = null;
		
		rotation_mode_tmp_d = "";
		rotation_mode_tmp_w = "";
		rotation_mode_tmp_h = "";
		
		calendarEvents = "";

		product = new Product();		
		product.id = -1;
		product.publishDate = DateTime.Now;		
		product.deleteDate = DateTime.Parse("9999-12-31 23:59:59");
		product.languages = new List<ProductLanguage>();
		product.categories = new List<ProductCategory>();
		product.attachments = new List<ProductAttachment>();
		product.fields = new List<ProductField>();
		product.relations = new List<ProductRelation>();
		product.quantity = -1;
		pre_el_id="";
		pre_el_id_transfield="";
		if(!String.IsNullOrEmpty(configService.get("num_max_attachments").value))
		{
			numMaxAttachs = Convert.ToInt32(configService.get("num_max_attachments").value);
		}
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();
		
		// recupero elementi della pagina necessari
		ubuilder = new UriBuilder(Request.Url);
		ubuilder.Scheme = "http";
		ubuilder.Port = -1;
		ubuilder.Path="";
		ubuilder.Query = "";

		country_opt_text = "country";
		state_region_opt_text = "state/region";		
		if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.user_field.type_content.label.country"))){
			country_opt_text = lang.getTranslated("portal.commons.user_field.type_content.label.country");
		}
		if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.user_field.type_content.label.state_region"))){
			state_region_opt_text = lang.getTranslated("portal.commons.user_field.type_content.label.state_region");
		}
		
		try{				
			categories = catrep.findActive();
			if(categories == null){				
				categories = new List<Category>();						
			}
		}catch (Exception ex){
			categories = new List<Category>();
		}
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}
		try{				
			users = usrrep.find(null, "3", true, null, false, 1, false, false, false, false, true, false);		
			if(users == null){				
				users = new List<User>();						
			}
		}catch (Exception ex){
			users = new List<User>();
		}
		try{				
			productAttachmentLabel = prodrep.getProductAttachmentLabel();		
			if(productAttachmentLabel == null){				
				productAttachmentLabel = new List<ProductAttachmentLabel>();						
			}
		}catch (Exception ex){
			productAttachmentLabel = new List<ProductAttachmentLabel>();
		}
		try{				
			systemFieldsType = commonrep.getSystemFieldsType();		
			if(systemFieldsType == null){				
				systemFieldsType = new List<SystemFieldsType>();						
			}
		}catch (Exception ex){
			systemFieldsType = new List<SystemFieldsType>();
		}
		try{				
			systemFieldsTypeContent = commonrep.getSystemFieldsTypeContent();		
			if(systemFieldsTypeContent == null){				
				systemFieldsTypeContent = new List<SystemFieldsTypeContent>();						
			}
		}catch (Exception ex){
			systemFieldsTypeContent = new List<SystemFieldsTypeContent>();
		}
		try{				
			fieldNames = prodrep.findFieldNames();		
			if(fieldNames == null){				
				fieldNames = new List<string>();						
			}
		}catch (Exception ex){
			fieldNames = new List<string>();
		}
		try{				
			fieldGroupNames = prodrep.findFieldGroupNames();		
			if(fieldGroupNames == null){				
				fieldGroupNames = new List<string>();						
			}
		}catch (Exception ex){
			fieldGroupNames = new List<string>();
		}
		try{				
			countries = countryrep.findAllCountries("1");		
			if(countries == null){				
				countries = new List<Country>();						
			}
		}catch (Exception ex){
			countries = new List<Country>();
		}
		try{				
			stateRegions = countryrep.findStateRegionByCountry(null,"1,3");	
			if(stateRegions == null){				
				stateRegions = new List<Country>();						
			}
		}catch (Exception ex){
			stateRegions = new List<Country>();
		}
		try{				
			commonfields = prodrep.getProductFields(-1, true, true);
			hasCommonProductFields = true;				
			if(commonfields == null){				
				commonfields = new List<ProductField>();	
				hasCommonProductFields = false;						
			}
		}catch (Exception ex){
			commonfields = new List<ProductField>();
		}
		try{				
			supplements = suprep.find("", -1, true);
			hasSupplements = true;				
			if(supplements == null){				
				supplements = new List<Supplement>();	
				hasSupplements = false;						
			}
		}catch (Exception ex){
			supplements = new List<Supplement>();
		}
		try{				
			supplementsg = supgrep.find("",true);
			hasSupplementsg = true;				
			if(supplementsg == null){				
				supplementsg = new List<SupplementGroup>();	
				hasSupplementsg = false;						
			}
		}catch (Exception ex){
			supplementsg = new List<SupplementGroup>();
		}
		try{				
			productRelations = prodrep.find("","","",-1,"","",null,null,-1,null,null,false,false,true,false,false,false,false);
			hasRelations = true;				
			if(productRelations == null){				
				productRelations = new List<Product>();	
				hasRelations = false;						
			}
		}catch (Exception ex){
			productRelations = new List<Product>();
		}	
			
		daysOfWeek.Add("sunday");
		daysOfWeek.Add("monday");
		daysOfWeek.Add("tuesday");
		daysOfWeek.Add("wednesday");
		daysOfWeek.Add("thursday");
		daysOfWeek.Add("friday");
		daysOfWeek.Add("saturday");


		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				product = prodrep.getById(Convert.ToInt32(Request["id"]));
				summaryp.Value = product.summary;
				descriptionp.Value = product.description;
				
				if(product.languages != null)
				{
					foreach(ProductLanguage cl in product.languages)
					{
						foreach(Language l in languages)
						{						
							if(l.id==cl.idLanguage){
								productlanguages.Add(l);
								break;
							}
						}
					}
				}
				
				if(product.categories != null)
				{
					productcategories = new List<IElementCategory>();
					foreach(ProductCategory cc in product.categories)
					{
						productcategories.Add(cc);
					}
				}
								
				//Response.Write("product.fields check<br>");
				if(product.fields != null && product.fields.Count>0){
					//Response.Write("product.fields.Count:"+product.fields.Count+"<br>");
					hasProductFields = true;
					
					foreach(ProductField cf in product.fields){
						if(!cf.common){
							IList<ProductFieldsValue> objListValues = prodrep.getProductFieldValues(cf.id);
							if(objListValues != null && objListValues.Count>0){
								dictProdFieldValues.Add(cf.id,objListValues);
							
								if(cf.type==3 || cf.type==4 || cf.type==5 || cf.type==6){
									foreach(ProductFieldsValue pfv in objListValues){
										IDictionary<string,string> rpfv = new Dictionary<string,string>();
										rpfv.Add("prodid",product.id.ToString());
										rpfv.Add("idfield",cf.id.ToString());
										rpfv.Add("fielddesc",cf.description);
										rpfv.Add("fvalue",pfv.value);
										rpfv.Add("value",cf.description+": "+pfv.value);
										correlableFieldValues.Add(rpfv);
									}
								}
							}
						}
					}
				}
				
				//check for calendar events (only for booking products)
				if(product.calendar != null){
					foreach(ProductCalendar pc in product.calendar){
						calendarEvents+=pc.content+",";
					}
					
					if(calendarEvents.Length>0){
						calendarEvents.Substring(0,calendarEvents.Length-1);
					}
				}
				
				//check for comments
				comments = commentrep.find(0,product.id,2,null);
				if(comments != null && comments.Count>0){
					hasComments = true;
				}
				
				pre_el_id_transfield = Request["id"];
				
				string rotation_mode_value = product.rotationModeValue;
				if(!String.IsNullOrEmpty(rotation_mode_value)){
					string[] values = rotation_mode_value.Split('|');
					if(values != null && values.Length==3){
						rotation_mode_tmp_d = values[0];
						rotation_mode_tmp_w = values[1];
						rotation_mode_tmp_h = values[2];
					}					
				}
				pr = prodrep.getProductRotation(product.id, product.quantityRotationMode);
			}catch (Exception ex){
				product = new Product();		
				product.id = -1;
				productcategories = new List<IElementCategory>();
			}	
		}else{
			// Gestione caso inserimento field su nuovo contenuto
			productcategories = new List<IElementCategory>();
			if(!String.IsNullOrEmpty(Request["pre_el_id"]))
			{
				pre_el_id = Request["pre_el_id"];	
				//Response.Write("pre_el_id:"+pre_el_id+"<br>");	
				try{				
					IList<ProductField> tmpProductFields = prodrep.getProductFields(Convert.ToInt32(pre_el_id), null, false);			
					if(tmpProductFields != null){	
						//Response.Write("before starting save - product.fields.Count:"+product.fields.Count+"<br>");
						//Response.Write("before starting save - tmpProductFields.Count:"+tmpProductFields.Count+"<br>");		
						product.fields.Clear();
						foreach(ProductField cf in tmpProductFields){						
							//product.fields = tmpProductFields;
							product.fields.Add(cf);
						}
						hasProductFields = true;			
	
						//Response.Write("before starting save - product.fields.Count:"+product.fields.Count+"<br>");							
					}
				}catch (Exception ex){}			
			}
			else
			{
				pre_el_id=Convert.ToString(Guids.createGuidMax18Len(7)*(-1));
			}
		}
		if(!String.IsNullOrEmpty(pre_el_id))
		{
			this.gl1.idElem=Convert.ToInt32(pre_el_id);	
			pre_el_id_transfield = pre_el_id;
		}


		// CLEAR PHANTOMS FIELDS AND GEOLOCALIZATIONS (based on insert date)
		
		
		// TODO gestione preview contenuti
		previewUrls = new Dictionary<string, IList<string>>();
		string hrefGer = "";
		string newCatId = "";
		foreach(Category ct in categories)
		{
			//Response.Write("category:"+ct.ToString()+"<br>");	
			if(CategoryService.checkUserCategory(login.userLogged, ct)){
				string strHref = MenuService.resolveMenuItemUrl(ct, lang.currentLangCode, Request.Url.Scheme+"://", 1, out hrefGer, out newCatId);
				string catdesc = "-&nbsp;"+ct.description;
				string[] level = ct.hierarchy.Split('.');
				if(level != null){
					for(int l=1;l<level.Length;l++){
						catdesc = "&nbsp;&nbsp;&nbsp;"+catdesc;
					}
				}						
				IList<string> elems = new List<string>();
				elems.Add(hrefGer);
				elems.Add(newCatId);
				elems.Add(strHref);
				elems.Add(catdesc);
				//Response.Write("ct.description:"+ct.description+" -ct.hierarchy:"+ct.hierarchy+" -hrefGer:"+hrefGer+" -newCatId:"+newCatId+" -strHref:"+strHref+"<br>");
				previewUrls[ct.hierarchy]=elems;		
				//Response.Write("previewUrls["+hrefGer+"]:"+previewUrls[hrefGer]+"<br>");	
			}
		}
		
		bool carryOn;							
		//******** INSERISCO NUOVO CONTENUTO / MODIFICO ESISTENTE	
		int savesc = Convert.ToInt32(Request["savesc"]);				
		if("insert".Equals(Request["operation"]))
		{	
			carryOn = true;	
			try
			{				
				IList<Geolocalization> listOfPoints = new List<Geolocalization>();	
				IList<ProductMainFieldTranslation> mainFieldsTrans = new List<ProductMainFieldTranslation>();	
				IDictionary<string, string> qtyFieldValues = new Dictionary<string, string>();
				string bookingCalendar = "";
				string prodName = Request["name"];
				
				string summary = Request["summaryp"];					
				summary = summary.Replace("<br type=&quot;_moz&quot; />","")
				.Replace("<br type=\"_moz\" />","")
				.Replace("&lt;br type=&quot;_moz&quot; /&gt;","")
				.Replace("&lt;br /&gt;","<br />");
				if(summary=="<br />"){summary="";}	
				summary = HttpUtility.HtmlDecode(summary);
					
				string description = Request["descriptionp"];					
				description = description.Replace("<br type=&quot;_moz&quot; />","")
				.Replace("<br type=\"_moz\" />","")
				.Replace("&lt;br type=&quot;_moz&quot; /&gt;","")
				.Replace("&lt;br /&gt;","<br />");	
				if(description=="<br />"){description="";}	
				description = HttpUtility.HtmlDecode(description);
				
				string keyword = Request["keyword"];	
				string pageTitle = Request["page_title"];	
				string metaDescription = Request["meta_description"];	
				string metaKeyword = Request["meta_keyword"];				
				string publishDate = Request["publish_date"];				
				string deleteDate = Request["delete_date"];
				int status = Convert.ToInt32(Request["status"]);				

				int prodType = Convert.ToInt32(Request["prod_type"]);
				int maxDownload = Convert.ToInt32(Request["max_download"]);
				int maxDownloadTime = Convert.ToInt32(Request["max_download_time"]);
				decimal price = 0;
				if(!String.IsNullOrEmpty(Request["price"])){
					price = Convert.ToDecimal(Request["price"]);
				}
				decimal discount = 0;
				if(!String.IsNullOrEmpty(Request["discount"])){
					discount = Convert.ToDecimal(Request["discount"]);
				}				
				int idSupplement = Convert.ToInt32(Request["id_supplement"]);
				int idSupplementGroup = Convert.ToInt32(Request["id_supplement_group"]);
				int quantity = -1;
				if(!String.IsNullOrEmpty(Request["quantity"])){
					quantity = Convert.ToInt32(Request["quantity"]);
				}	
				bool setBuyQta = Convert.ToBoolean(Convert.ToInt32(Request["edit_buy_qty"]));
				int quantityRotationMode = Convert.ToInt32(Request["rotation_mode"]);
				string rotationModeValue = Request["rotation_mode_value"];
				int reloadQuantity = 0;
				if(!String.IsNullOrEmpty(Request["rotation_quantity"])){
					reloadQuantity = Convert.ToInt32(Request["rotation_quantity"]);
				}
				string listProdFieldsValuesQty = Request["list_prod_fields_values_qty"];
				//Response.Write("listProdFieldsValuesQty:"+listProdFieldsValuesQty+"<br>");
				
				//Response.Write("publishDate by request:"+publishDate+"<br>");
				//Response.Write("deleteDate by request:"+publishDate+"<br>");	
				
				if(prodType==3){
					bookingCalendar = Request["booking_calendar"];
				}
				//Response.Write("bookingCalendar:"+bookingCalendar+"<br>");
				
				product.name = prodName;
				product.summary = summary;
				product.description = description;
				product.keyword = keyword;
				product.metaDescription = metaDescription;	
				product.metaKeyword = metaKeyword;	
				product.pageTitle = pageTitle;					
				product.publishDate = DateTime.ParseExact(publishDate, "dd/MM/yyyy HH.mm", null);		
				product.deleteDate = DateTime.ParseExact(deleteDate, "dd/MM/yyyy HH.mm", null);
				product.status = status;				
				product.prodType = prodType;
				product.maxDownload = maxDownload;
				product.maxDownloadTime = maxDownloadTime;
				product.price = price;
				product.discount = discount;
				product.idSupplement = idSupplement;
				product.idSupplementGroup = idSupplementGroup;
				product.quantity = quantity;
				product.setBuyQta = setBuyQta;				
				product.quantityRotationMode = quantityRotationMode;
				/*Response.Write(
				"- quantityRotationMode:"+product.quantityRotationMode+
				"<br>- rotationModeValue:"+rotationModeValue+"<br>"
				);*/	
				if(!String.IsNullOrEmpty(rotationModeValue)){
					Dictionary<string, string> rotateVal = JsonConvert.DeserializeObject<Dictionary<string, string>>(rotationModeValue);
					StringBuilder tmpRotationValue = new StringBuilder();
					string tmpval = "";
					rotateVal.TryGetValue("d", out tmpval);	
					//Response.Write("tmpval d:"+tmpval+"<br>");						
					if(!String.IsNullOrEmpty(tmpval) && product.quantityRotationMode==3){
						tmpRotationValue.Append(tmpval);
					}
					tmpRotationValue.Append("|");
					rotateVal.TryGetValue("w", out tmpval);	
					//Response.Write("tmpval w:"+tmpval+"<br>");						
					if(!String.IsNullOrEmpty(tmpval) && product.quantityRotationMode==2){
						tmpRotationValue.Append(tmpval);
					}
					tmpRotationValue.Append("|");
					rotateVal.TryGetValue("h", out tmpval);	
					//Response.Write("tmpval h:"+tmpval+"<br>");						
					if(!String.IsNullOrEmpty(tmpval) && product.quantityRotationMode>0){
						tmpRotationValue.Append(tmpval);
					}
					//Response.Write("tmpRotationValue:"+tmpRotationValue.ToString()+"<br>");	
					product.rotationModeValue = tmpRotationValue.ToString();					
				}
				product.reloadQuantity = reloadQuantity;
				
				if(product.id == -1) {
					product.userId = login.userLogged.id;
				}

				// update product fields and fields value quantity
				//if(hasProductFields){						
					if(!String.IsNullOrEmpty(listProdFieldsValuesQty)){
						qtyFieldValues = JsonConvert.DeserializeObject<Dictionary<string, string>>(listProdFieldsValuesQty);
					}
				//}
					
				// update product languages
				product.languages.Clear();
				if(!String.IsNullOrEmpty(Request["product_languages"])){
					string[] productLanguages = Request["product_languages"].Split('|');
					if(productLanguages!=null){
						foreach(string x in productLanguages){
							ProductLanguage cl = new ProductLanguage();
							cl.idParentProduct = product.id;
							cl.idLanguage = Convert.ToInt32(x);
							product.languages.Add(cl);
						}
					}
				}
				
				// update product categories
				product.categories.Clear();
				if(!String.IsNullOrEmpty(Request["product_categories"])){
					string[] productCategories = Request["product_categories"].Split(',');
					if(productCategories!=null){
						foreach(string x in productCategories){
							ProductCategory cc = new ProductCategory();
							cc.idParent = product.id;
							cc.idCategory = Convert.ToInt32(x);
							product.categories.Add(cc);
						}
					}
				}
				
				// update list prod relations
				product.relations.Clear();
				if(!String.IsNullOrEmpty(Request["list_prod_relations"])){
					string[] prodRelations = Request["list_prod_relations"].Split('|');
					if(prodRelations!=null){
						foreach(string x in prodRelations){
							ProductRelation cc = new ProductRelation();
							cc.idParentProduct = product.id;
							cc.idProductRel = Convert.ToInt32(x);
							product.relations.Add(cc);
						}
					}
				}				

				// update product attachments
				for(int ac=1; ac<=Convert.ToInt32(Request["attach_counter"]);ac++)
				{				
					string fattachId = Request["filemodify_id"+ac];
					if(!String.IsNullOrEmpty(fattachId)){
						int aid = Convert.ToInt32(Request["filemodify_id"+ac]);
						int label = Convert.ToInt32(Request["filemodify_label"+ac]);
						string dida = Request["filemodify_dida"+ac];
						
						foreach(ProductAttachment ca in product.attachments)
						{
							if(ca.id==aid)
							{
								ca.fileLabel=label;
								ca.fileDida=dida;
								ca.idParentProduct = product.id;
								break;
							}
						}
					}
				}

				// update product attachments download
				for(int ac=1; ac<=Convert.ToInt32(Request["attach_counterd"]);ac++)
				{				
					string fattachId = Request["filemodify_id"+ac+"d"];
					if(!String.IsNullOrEmpty(fattachId)){
						int aid = Convert.ToInt32(Request["filemodify_id"+ac+"d"]);
						int label = Convert.ToInt32(Request["filemodify_label"+ac+"d"]);
						string dida = Request["filemodify_dida"+ac+"d"];
						
						foreach(ProductAttachmentDownload ca in product.dattachments)
						{
							if(ca.id==aid)
							{
								ca.fileLabel=label;
								ca.fileDida=dida;
								ca.idParentProduct = product.id;
								break;
							}
						}
					}
				}
				
				product.calendar.Clear();
				// check if product is booking for calendar event
				if(prodType==3 && !String.IsNullOrEmpty(bookingCalendar)){
					//Response.Write("prodType:"+prodType+"<br>");
					bookingCalendar="["+bookingCalendar+"]";
					
					List<ProductCalendarEventData> test = JsonConvert.DeserializeObject<List<ProductCalendarEventData>>(bookingCalendar);
					foreach(ProductCalendarEventData p in test)
					{
						//Response.Write(p.ToString()+"<br>");
						ProductCalendar pc = new ProductCalendar();
						pc.idParentProduct = product.id;
						pc.startDate=p.start;
						pc.availability=p.availability;
						pc.unit=p.unit;
						pc.content=JsonConvert.SerializeObject(p, Formatting.Indented);
						product.calendar.Add(pc);
					}
					
				}

				HttpFileCollection MyFileCollection;			
				MyFileCollection = Request.Files;
				//*************** save product attachment to show on page site
				for(int ac=1; ac<=Convert.ToInt32(Request["numMaxImgs"]);ac++)
				{					
					string fileName = Path.GetFileName(Request["fileupload_name"+ac]);
					int label = Convert.ToInt32(Request["fileupload_label"+ac]);
					string dida = Request["fileupload_dida"+ac];
					//Response.Write("first: fileName:"+fileName+" - label:"+label+" - dida:"+dida+"<br>");
					for(int k = 0; k<MyFileCollection.Keys.Count;k++)
					{	
						HttpPostedFile tmp = MyFileCollection[k];
						string name = Path.GetFileName(tmp.FileName);
						if(!String.IsNullOrEmpty(name) && name==fileName)
						{							
							if(Utils.isValidExtension(Path.GetExtension(name))){
								//Response.Write("found: fileName: "+name+" - productType: "+tmp.ContentType+" - label: "+label+" - dida: "+dida+"<br>");
								ProductAttachment ca = new ProductAttachment();
								ca.id=-1;
								ca.fileName=name;
								ca.contentType=tmp.ContentType;
								ca.fileLabel=label;
								ca.fileDida=dida;
								ca.idParentProduct=product.id;
								ca.filePath=product.id+"/";
								product.attachments.Add(ca);							
								break;
							}else{
								throw new Exception("022");
							}
						}
					}
				}
				//*************** save product attachment downloads to sell by ecommerce
				IList<ProductAttachmentDownload> newProductAttachmentDownload = new List<ProductAttachmentDownload>();
				for(int ac=1; ac<=Convert.ToInt32(Request["numMaxImgsd"]);ac++)
				{					
					string fileName = Path.GetFileName(Request["fileupload_name"+ac+"d"]);
					int label = Convert.ToInt32(Request["fileupload_label"+ac+"d"]);
					string dida = Request["fileupload_dida"+ac+"d"];
					//Response.Write("down: fileName:"+fileName+" - label:"+label+" - dida:"+dida+"<br>");
					for(int k = 0; k<MyFileCollection.Keys.Count;k++)
					{	
						HttpPostedFile tmp = MyFileCollection[k];
						string name = Path.GetFileName(tmp.FileName);
						if(!String.IsNullOrEmpty(name) && name==fileName)
						{
							if(Utils.isValidExtension(Path.GetExtension(name))){
								//Response.Write("found: fileName: "+name+" - productType: "+tmp.ContentType+" - label: "+label+" - dida: "+dida+"<br>");
								ProductAttachmentDownload ca = new ProductAttachmentDownload();
								ca.id=-1;
								ca.fileName=name;
								ca.contentType=tmp.ContentType;
								ca.fileLabel=label;
								ca.fileDida=dida;
								ca.idParentProduct=product.id;
								ca.filePath=product.id+"/";
								ca.fileSize=tmp.ContentLength;
								product.dattachments.Add(ca);
								newProductAttachmentDownload.Add(ca);
								break;
							}else{
								throw new Exception("022");
							}
						}
					}
				}
			
				if(!String.IsNullOrEmpty(Request["pre_el_id"]) && Convert.ToInt32(Request["pre_el_id"])!=product.id)
				{
					listOfPoints = georep.findByElement(Convert.ToInt32(Request["pre_el_id"]), 2);
					mainFieldsTrans = prodrep.getProductMainFieldsTranslation(Convert.ToInt32(Request["pre_el_id"]), -1, null);
				}

				// PREPARO LE LISTE DI CHIAVI MULTILINGUA DA INSERIRE/AGGIORNARE IN TRANSAZIONE
				IList<MultiLanguage> newtranslactions = new List<MultiLanguage>();
				IList<MultiLanguage> updtranslactions = new List<MultiLanguage>();
				IList<MultiLanguage> deltranslactions = new List<MultiLanguage>();
				MultiLanguage ml;
				if(languages!=null){
					foreach (Language x in languages){
						//*** insert page_title
						ml = mlangrep.find("backend.prodotti.detail.table.label.page_title_"+product.keyword, x.label);
						if(ml != null){
							ml.value = Request["page_title_"+x.label];	
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);	
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.prodotti.detail.table.label.page_title_"+product.keyword;
							ml.langCode = x.label;
							ml.value = Request["page_title_"+x.label];	
							if(!String.IsNullOrEmpty(ml.value)){				
								newtranslactions.Add(ml);
							}
						}
						//*** insert meta description
						ml = mlangrep.find("backend.prodotti.detail.table.label.meta_description_"+product.keyword, x.label);
						if(ml != null){
							ml.value = Request["meta_description_"+x.label];	
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.prodotti.detail.table.label.meta_description_"+product.keyword;
							ml.langCode = x.label;
							ml.value = Request["meta_description_"+x.label];
							if(!String.IsNullOrEmpty(ml.value)){
								newtranslactions.Add(ml);
							}
						}
						//*** insert meta keyword
						ml = mlangrep.find("backend.prodotti.detail.table.label.meta_keyword_"+product.keyword, x.label);
						if(ml != null){
							ml.value = Request["meta_keyword_"+x.label];	
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.prodotti.detail.table.label.meta_keyword_"+product.keyword;
							ml.langCode = x.label;
							ml.value = Request["meta_keyword_"+x.label];		
							if(!String.IsNullOrEmpty(ml.value)){
								newtranslactions.Add(ml);
							}
						}
						
						//*** insert attachment dida
						//******** new dida
						for(int ac=1; ac<=Convert.ToInt32(Request["numMaxImgs"]);ac++)
						{					
							string dida = Request["fileupload_dida"+ac];
							//Response.Write("first: fileName:"+fileName+" - label:"+label+" - dida:"+dida+"<br>");
							ml = mlangrep.find("backend.prodotti.detail.table.label.filemodify_dida_"+dida+product.keyword, x.label);
							if(ml != null){
								ml.value = Request["fileupload_dida"+ac+"_"+x.label];	
								if(!String.IsNullOrEmpty(ml.value)){
									updtranslactions.Add(ml);
								}else{
									deltranslactions.Add(ml);									
								}
							}else{
								ml = new MultiLanguage();
								ml.keyword = "backend.prodotti.detail.table.label.filemodify_dida_"+dida+product.keyword;
								ml.langCode = x.label;
								ml.value = Request["fileupload_dida"+ac+"_"+x.label];		
								if(!String.IsNullOrEmpty(ml.value)){
									newtranslactions.Add(ml);
								}
							}	
						}
						//******** exists dida
						for(int ac=1; ac<=Convert.ToInt32(Request["attach_counter"]);ac++)
						{					
							string dida = Request["filemodify_dida"+ac];
							//Response.Write("first: fileName:"+fileName+" - label:"+label+" - dida:"+dida+"<br>");
							ml = mlangrep.find("backend.prodotti.detail.table.label.filemodify_dida_"+dida+product.keyword, x.label);
							if(ml != null){
								ml.value = Request["filemodify_dida"+ac+"_"+x.label];	
								if(!String.IsNullOrEmpty(ml.value)){
									updtranslactions.Add(ml);
								}else{
									deltranslactions.Add(ml);									
								}
							}else{
								ml = new MultiLanguage();
								ml.keyword = "backend.prodotti.detail.table.label.filemodify_dida_"+dida+product.keyword;
								ml.langCode = x.label;
								ml.value = Request["filemodify_dida"+ac+"_"+x.label];		
								if(!String.IsNullOrEmpty(ml.value)){
									newtranslactions.Add(ml);
								}
							}	
						}
						
						//*** insert attachment download dida
						if(product.prodType==1){
							//******** new dida
							for(int ac=1; ac<=Convert.ToInt32(Request["numMaxImgsd"]);ac++)
							{					
								string dida = Request["fileupload_dida"+ac+"d"];
								//Response.Write("first: fileName:"+fileName+" - label:"+label+" - dida:"+dida+"<br>");
								ml = mlangrep.find("backend.prodotti.detail.table.label.filemodify_dida_d_"+dida+product.keyword, x.label);
								if(ml != null){
									ml.value = Request["fileupload_dida"+ac+"d_"+x.label];	
									if(!String.IsNullOrEmpty(ml.value)){
										updtranslactions.Add(ml);
									}else{
										deltranslactions.Add(ml);									
									}
								}else{
									ml = new MultiLanguage();
									ml.keyword = "backend.prodotti.detail.table.label.filemodify_dida_d_"+dida+product.keyword;
									ml.langCode = x.label;
									ml.value = Request["fileupload_dida"+ac+"d_"+x.label];		
									if(!String.IsNullOrEmpty(ml.value)){
										newtranslactions.Add(ml);
									}
								}	
							}
							//******** exists dida
							for(int ac=1; ac<=Convert.ToInt32(Request["attach_counterd"]);ac++)
							{					
								string dida = Request["filemodify_dida"+ac+"d"];
								//Response.Write("first: fileName:"+fileName+" - label:"+label+" - dida:"+dida+"<br>");
								ml = mlangrep.find("backend.prodotti.detail.table.label.filemodify_dida_d_"+dida+product.keyword, x.label);
								if(ml != null){
									ml.value = Request["filemodify_dida"+ac+"d_"+x.label];	
									if(!String.IsNullOrEmpty(ml.value)){
										updtranslactions.Add(ml);
									}else{
										deltranslactions.Add(ml);									
									}
								}else{
									ml = new MultiLanguage();
									ml.keyword = "backend.prodotti.detail.table.label.filemodify_dida_d_"+dida+product.keyword;
									ml.langCode = x.label;
									ml.value = Request["filemodify_dida"+ac+"d_"+x.label];		
									if(!String.IsNullOrEmpty(ml.value)){
										newtranslactions.Add(ml);
									}
								}	
							}						
						}
						
						if(hasProductFields){
							IList<ProductField> tmpPFs = product.fields;
							foreach(ProductField cf in tmpPFs){						

								//******************  START: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/
								
								//*** insert fields description
								ml = mlangrep.find("backend.prodotti.detail.table.label.field_description_"+cf.description+"_"+product.keyword, x.label);
								if(ml != null){	
									if(!String.IsNullOrEmpty(Request["field_description_"+cf.id+"_"+x.label])){
										ml.value = Request["field_description_"+cf.id+"_"+x.label].Replace("&quot;","\"");
										updtranslactions.Add(ml);
									}else{
										deltranslactions.Add(ml);
									}
								}else{
									ml = new MultiLanguage();
									ml.keyword = "backend.prodotti.detail.table.label.field_description_"+cf.description+"_"+product.keyword;
									ml.langCode = x.label;
									ml.value = Request["field_description_"+cf.id+"_"+x.label];		
									if(!String.IsNullOrEmpty(ml.value)){	
										ml.value = ml.value.Replace("&quot;","\"");
										newtranslactions.Add(ml);
									}
								}
								
								//*** insert group description
								ml = mlangrep.find("backend.prodotti.detail.table.label.id_group_"+cf.description+"_"+product.keyword, x.label);
								if(ml != null){	
									if(!String.IsNullOrEmpty(Request["group_value_"+cf.id+"_"+x.label])){
										ml.value = Request["group_value_"+cf.id+"_"+x.label].Replace("&quot;","\"");
										updtranslactions.Add(ml);
									}else{
										deltranslactions.Add(ml);
									}
								}else{
									ml = new MultiLanguage();
									ml.keyword = "backend.prodotti.detail.table.label.id_group_"+cf.description+"_"+product.keyword;
									ml.langCode = x.label;
									ml.value = Request["group_value_"+cf.id+"_"+x.label];
									if(!String.IsNullOrEmpty(ml.value)){
										ml.value = ml.value.Replace("&quot;","\"");	
										newtranslactions.Add(ml);
									}
								}	
								
								
								if((cf.type==3 || cf.type==4 || cf.type==5 || cf.type==6) && (cf.typeContent != 7) && (cf.typeContent != 8))
								{								
									IList<ProductFieldsValue> tmpPFVs = prodrep.getProductFieldValues(cf.id);
									
									if(tmpPFVs != null){
										foreach(ProductFieldsValue cfv in tmpPFVs){
											//*** insert product fields values
											/*
											Response.Write("<br>- cf.id: "+cf.id+"<br>");
											Response.Write("- cfv.idParentField: "+cfv.idParentField+"<br>");
											Response.Write("- cfv.value: "+cfv.value+"<br>");
											Response.Write("- cfv.sorting: "+cfv.sorting+"<br>");
											Response.Write("- cf.description: "+cf.description+"<br>");
											Response.Write("- product.keyword: "+product.keyword+"<br>");
											Response.Write("- x.label: "+x.label+"<br>");
											Response.Write("- Request[]: field_values_ml_"+cf.id+"_"+(cfv.sorting-1)+"_"+x.label+"<br>");
											Response.Write("- ml.keyword: backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+cfv.value+"_"+product.keyword+"<br><br>");
											*/
											
											ml = mlangrep.find("backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+cfv.value+"_"+product.keyword, x.label);
											if(ml != null){	
												if(!String.IsNullOrEmpty(Request["field_values_ml_"+cf.id+"_"+(cfv.sorting-1)+"_"+x.label])){	
													ml.value = Request["field_values_ml_"+cf.id+"_"+(cfv.sorting-1)+"_"+x.label].Replace("&quot;","\"");
													updtranslactions.Add(ml);
												}else{
													//Response.Write("- del ml.value: "+ml.value+"<br>");
													deltranslactions.Add(ml);									
												}
											}else{
												ml = new MultiLanguage();
												ml.keyword = "backend.prodotti.detail.table.label.field_values_"+cf.description+"_"+cfv.value+"_"+product.keyword;
												ml.langCode = x.label;
												ml.value = Request["field_values_ml_"+cf.id+"_"+(cfv.sorting-1)+"_"+x.label];
												//Response.Write("- ins ml.value: "+ml.value+"<br>");
												if(!String.IsNullOrEmpty(ml.value)){
													ml.value = ml.value.Replace("&quot;","\"");	
													newtranslactions.Add(ml);
												}
											}
										}											
									}
								}					

								if((cf.type==1 || cf.type==2 || cf.type==9) && (cf.typeContent != 7) && (cf.typeContent != 8))
								{								
									//*** insert field value t
									ml = mlangrep.find("backend.prodotti.detail.table.label.field_value_t_"+cf.description+"_"+product.keyword, x.label);
									if(ml != null){	
										if(!String.IsNullOrEmpty(Request["field_value_t_"+cf.id+"_"+x.label])){
											ml.value = Request["field_value_t_"+cf.id+"_"+x.label].Replace("&quot;","\"");
											updtranslactions.Add(ml);
										}else{
											deltranslactions.Add(ml);
										}
									}else{
										ml = new MultiLanguage();
										ml.keyword = "backend.prodotti.detail.table.label.field_value_t_"+cf.description+"_"+product.keyword;
										ml.langCode = x.label;
										ml.value = Request["field_value_t_"+cf.id+"_"+x.label];		
										if(!String.IsNullOrEmpty(ml.value)){	
											ml.value = ml.value.Replace("&quot;","\"");
											newtranslactions.Add(ml);
										}
									}								
									//*** insert field value ta
									ml = mlangrep.find("backend.prodotti.detail.table.label.field_value_ta_"+cf.description+"_"+product.keyword, x.label);
									if(ml != null){	
										if(!String.IsNullOrEmpty(Request["field_value_ta_"+cf.id+"_"+x.label])){
											ml.value = Request["field_value_ta_"+cf.id+"_"+x.label].Replace("&quot;","\"");
											updtranslactions.Add(ml);
										}else{
											deltranslactions.Add(ml);
										}
									}else{
										ml = new MultiLanguage();
										ml.keyword = "backend.prodotti.detail.table.label.field_value_ta_"+cf.description+"_"+product.keyword;
										ml.langCode = x.label;
										ml.value = Request["field_value_ta_"+cf.id+"_"+x.label];		
										if(!String.IsNullOrEmpty(ml.value)){	
											ml.value = ml.value.Replace("&quot;","\"");
											newtranslactions.Add(ml);
										}
									}							
									//*** insert field value e
									ml = mlangrep.find("backend.prodotti.detail.table.label.field_value_e_"+cf.description+"_"+product.keyword, x.label);
									if(ml != null){	
										if(!String.IsNullOrEmpty(Request["field_value_e_"+cf.id+"_"+x.label])){
											ml.value = Request["field_value_e_"+cf.id+"_"+x.label].Replace("&quot;","\"");
											updtranslactions.Add(ml);
										}else{
											deltranslactions.Add(ml);
										}
									}else{
										ml = new MultiLanguage();
										ml.keyword = "backend.prodotti.detail.table.label.field_value_e_"+cf.description+"_"+product.keyword;
										ml.langCode = x.label;
										ml.value = Request["field_value_e_"+cf.id+"_"+x.label];		
										if(!String.IsNullOrEmpty(ml.value)){	
											ml.value = ml.value.Replace("&quot;","\"");
											newtranslactions.Add(ml);
										}
									}
								}
								
								//TODO: MFT
								// completare con gli altri campi dei fields: 
								// - description: DONE
								// - group: DONE
								// - select/radio/checkbox: DONE
								// - text/textarea: DOING
								// - html-editor: DOING
								
								//******************  END: MULTILANGUAGE FIELDS TRANSLATIONS MANAGER ***************************/
							}
						}
					}
				}				


				//Response.Write("closing...<br>");
				//Response.Write("publishDate:"+product.publishDate+"<br>");
				//Response.Write("deleteDate:"+product.deleteDate+"<br>");
				//Response.End();				
				
				try
				{
					// TEST
					/*
					foreach(MultiLanguage value in updtranslactions){
						Response.Write("upd MultiLanguage:"+value.ToString()+"<br>");
					}		
					foreach(MultiLanguage value in deltranslactions){
						Response.Write("del MultiLanguage:"+value.ToString()+"<br>");
					}		
					foreach(MultiLanguage value in newtranslactions){
						Response.Write("ins MultiLanguage:"+value.ToString()+"<br>");
					}
					*/
					// FINE TEST
					
					
					//Response.Write("qtyFieldValues.Count:"+qtyFieldValues.Count+"<br>");

					prodrep.saveCompleteProduct(product, listOfPoints, mainFieldsTrans, qtyFieldValues, newtranslactions, updtranslactions, deltranslactions);
					
					foreach(MultiLanguage value in updtranslactions){
						MultiLanguageRepository.cleanCache(value);
					}		
					foreach(MultiLanguage value in deltranslactions){
						MultiLanguageRepository.cleanCache(value);
					}		
					foreach(MultiLanguage value in newtranslactions){
						MultiLanguageRepository.cleanCache(value);
					}
						
					pre_el_id=product.id.ToString();
					this.gl1.idElem=Convert.ToInt32(pre_el_id);				
					string dirName = HttpContext.Current.Server.MapPath("~/public/upload/files/products/"+product.id); 
					if (!Directory.Exists(dirName))
					{
						Directory.CreateDirectory(dirName);
					}
					string dirDownName = HttpContext.Current.Server.MapPath("~/app_data/products/"+product.id); 
					if (!Directory.Exists(dirDownName))
					{
						Directory.CreateDirectory(dirDownName);
					}
	
					for(int k = 0; k<MyFileCollection.Keys.Count;k++)
					{
						HttpPostedFile tmp = MyFileCollection[k];	
						string fileName = Path.GetFileName(tmp.FileName);
						if(!String.IsNullOrEmpty(fileName))
						{
							if(Utils.isValidExtension(Path.GetExtension(fileName)))
							{
								if(newProductAttachmentDownload != null && newProductAttachmentDownload.Count >0){
									foreach(ProductAttachmentDownload pad in newProductAttachmentDownload){
										if(product.prodType == 1 && pad.fileName.Equals(fileName)){
											TemplateService.SaveStreamToFile(tmp.InputStream, HttpContext.Current.Server.MapPath("~/app_data/products/"+product.id+"/"+tmp.FileName));
										}
									}
								}else{
									TemplateService.SaveStreamToFile(tmp.InputStream, HttpContext.Current.Server.MapPath("~/public/upload/files/products/"+product.id+"/"+tmp.FileName));
								}
							}else{
								throw new Exception("022");
							}
						}
					}
					
					log.usr= login.userLogged.username;
					log.msg = "save product: "+product.ToString();
					log.type = "info";
					log.date = DateTime.Now;
					lrep.write(log);	
				}
				catch(Exception ex)
				{
					//Response.Write("inner try/catch - An error occured: " + ex.Message);
					throw;	
				}						
			}
			catch (Exception ex)
			{
				//Response.Write("An error occured: " + ex.Message);		
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));					
				//Response.Redirect(url.ToString(),false);	
				//HttpContext.Current.ApplicationInstance.CompleteRequest();
				carryOn = false;
			}
			
			if(carryOn){
				if(savesc==0){
					Response.Redirect("/backoffice/products/insertproduct.aspx?cssClass="+Request["cssClass"]+"&id="+product.id);
				}else if(savesc==2){
					Response.Write("<prodid id='prod_id'>"+product.id.ToString()+"</prodid>");
				}else{					
					Response.Redirect("/backoffice/products/productlist.aspx?cssClass="+Request["cssClass"]);
				}
			}else{
				Response.Redirect(url.ToString());
			}								
		}
		
		if("delete".Equals(Request["operation"]))
		{
			carryOn = true;
			try
			{
				prodrep.delete(product);
				
				log.usr= login.userLogged.username;
				log.msg = "delete product: "+product.ToString();
				log.type = "info";
				log.date = DateTime.Now;
				lrep.write(log);	
			}
			catch(Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				carryOn = false;
			}
				
			if(carryOn){
				Response.Redirect("/backoffice/products/productlist.aspx?cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}			
		}		
	}
}