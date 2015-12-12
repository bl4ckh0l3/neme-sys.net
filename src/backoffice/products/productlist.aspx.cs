using System;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using System.Web.Caching;

public partial class _ProductList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected bool bolFoundField = false;
	protected int itemsXpageProd, numPageProd, itemsXpageField, numPageField;
	protected string cssClass, showTab;
	protected int fromFields, toFields;
	protected IList<string> fieldNames;
	protected IList<string> fieldGroupNames;
	protected IList<SystemFieldsType> systemFieldsType;
	protected IList<SystemFieldsTypeContent> systemFieldsTypeContent;
	
	protected int order_by;
	protected string titlef;
	protected string typef;
	protected string qtyrtypef;
	protected string keywordf;
	protected string statusf;
	protected int languagef;
	protected int categoryf;
	protected int userf;
	
	protected IList<Product> products;	
	protected IList<ProductField> productfields;
	protected IList<Language> languages;	
	protected IList<Category> categories;
	protected IList<Supplement> supplements;
	private int _totalPages;	
	public int totalPages {
		get { return _totalPages; }
	}	
	
	private int _totalfPages;	
	public int totalfPages {
		get { return _totalfPages; }
	}
	
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
		IProductRepository productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
		ISupplementRepository suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		IUserRepository userrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		ICommonRepository commonrep = RepositoryFactory.getInstance<ICommonRepository>("ICommonRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		
		Logger log = new Logger();
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");	
		IList<int> matchCategories = null;
		IList<int> matchLanguages = null;	
		order_by = -1;
		titlef = "";
		keywordf = "";
		statusf = "";
		languagef = 0;
		categoryf = 0;
		typef = "";
		qtyrtypef = "";
		userf = -1;		
		itemsXpageProd = 20;
		itemsXpageField = 20;
		
		showTab="productlist";
		if(!String.IsNullOrEmpty(Request["showtab"])){
			showTab=Request["showtab"];
		}	
			
		if("deleteField".Equals(Request["operation"]))
		{
			if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
			{
				bool carryOn = true;
				try
				{	
					ProductField productfdel = productrep.getProductFieldById(Convert.ToInt32(Request["id"]));
					productrep.deleteProductField(productfdel.id);			
					log.usr= login.userLogged.username;
					log.msg = "delete field: "+productfdel.ToString();
					log.type = "info";
					log.date = DateTime.Now;
					lrep.write(log);
				}
				catch (Exception ex)
				{
					url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
					carryOn = false;
				}
				
				if(carryOn){
					Response.Redirect("/backoffice/products/productlist.aspx?showtab=productfield&cssClass="+Request["cssClass"]);
				}else{
					Response.Redirect(url.ToString());
				}	
			}				
		}
		
		if (!String.IsNullOrEmpty(Request["itemsProd"])) {
			Session["listItemsp"] = Convert.ToInt32(Request["itemsProd"]);
			itemsXpageProd = (int)Session["listItemsp"];
		}else{
			if (Session["listItemsp"] != null) {
				itemsXpageProd = (int)Session["listItemsp"];
			}else{
				Session["listItemsp"] = 20;
				itemsXpageProd = (int)Session["listItemsp"];
			}
		}

		//***************** RECUPERO DATI PER LISTA FIELDS
		if (!String.IsNullOrEmpty(Request["itemsField"])) {
			Session["fieldItemsp"] = Convert.ToInt32(Request["itemsField"]);
			itemsXpageField = (int)Session["fieldItemsp"];
		}else{
			if (Session["fieldItemsp"] != null) {
				itemsXpageField = (int)Session["fieldItemsp"];
			}else{
				Session["fieldItemsp"] = 20;
				itemsXpageField = (int)Session["fieldItemsp"];
			}
		}
		
		//************* START: CONTENT FILTERS SETUP
		if("1" == Request["resetMenu"]) 
		{
			Session["productsPagec"] = 1;
			numPageProd = (int)Session["productsPagec"];
			Session["fieldPagec"]= 1;
			numPageField = (int)Session["fieldPagec"];
			Session["order_by"] = -1;
			order_by = (int)Session["order_by"];
			Session["titlef"] = "";
			titlef = (string)Session["titlef"];
			Session["typef"] = "";
			typef = (string)Session["typef"];
			Session["keywordf"] = "";
			keywordf = (string)Session["keywordf"];
			Session["statusf"] = "";
			statusf = (string)Session["statusf"];
			Session["categoryf"] = null;
			categoryf = 0;
			Session["languagef"] = null;
			languagef = 0;
		}
		else
		{		
			if (!String.IsNullOrEmpty(Request["page"])) {
				Session["productsPagec"] = Convert.ToInt32(Request["page"]);
				numPageProd = (int)Session["productsPagec"];
			}else{
				if (Session["productsPagec"] != null) {
					numPageProd = (int)Session["productsPagec"];
				}else{
					Session["productsPagec"]= 1;
					numPageProd = (int)Session["productsPagec"];
				}
			}

			if (showTab=="productfield" && !String.IsNullOrEmpty(Request["page"])) {
				Session["fieldPagec"] = Convert.ToInt32(Request["page"]);
				numPageField = (int)Session["fieldPagec"];
			}else{
				if (Session["fieldPagec"] != null) {
					numPageField = (int)Session["fieldPagec"];
				}else{
					Session["fieldPagec"]= 1;
					numPageField = (int)Session["fieldPagec"];
				}
			}
			
			if (!String.IsNullOrEmpty(Request["order_by"]) && Request["order_by"]!="-1") {
				Session["order_by"] = Convert.ToInt32(Request["order_by"]);
				order_by = (int)Session["order_by"];
			}else{
				if (Session["order_by"] != null) {
					order_by = (int)Session["order_by"];
				}else{
					Session["order_by"]= -1;
					order_by = (int)Session["order_by"];
				}
			}

			if (!String.IsNullOrEmpty(Request["titlef"])) {
				Session["titlef"] = Request["titlef"];
				titlef = (string)Session["titlef"];
			}else{
				if (Session["titlef"] != null) {
					titlef = (string)Session["titlef"];
				}else{
					Session["titlef"] = "";
					titlef = (string)Session["titlef"];
				}
			}

			if (!String.IsNullOrEmpty(Request["typef"])) {
				Session["typef"] = Request["typef"];
				typef = (string)Session["typef"];
			}else{
				if (Session["typef"] != null) {
					typef = (string)Session["typef"];
				}else{
					Session["typef"] = "";
					typef = (string)Session["typef"];
				}
			}
			
			if (!String.IsNullOrEmpty(Request["keywordf"])) {
				Session["keywordf"] = Request["keywordf"];
				keywordf = (string)Session["keywordf"];
			}else{
				if (Session["keywordf"] != null) {
					keywordf = (string)Session["keywordf"];
				}else{
					Session["keywordf"] = "";
					keywordf = (string)Session["keywordf"];
				}
			}
			
			if (!String.IsNullOrEmpty(Request["statusf"])) {
				Session["statusf"] = Request["statusf"];
				statusf = (string)Session["statusf"];
			}else{
				if (Session["statusf"] != null) {
					statusf = (string)Session["statusf"];
				}else{
					Session["statusf"] = "";
					statusf = (string)Session["statusf"];
				}
			}
			
			if (!String.IsNullOrEmpty(Request["categoryf"]) && Request["categoryf"]!="0") {
				Session["categoryf"] = Convert.ToInt32(Request["categoryf"]);
				categoryf = (int)Session["categoryf"];
				//Response.Write("categoryf:"+categoryf+" -Session[categoryf]:"+Session["categoryf"]+"<br>");
				matchCategories = new List<int>();
				matchCategories.Add(categoryf);
			}else{
				if (Session["categoryf"] != null) {
					categoryf = (int)Session["categoryf"];
					//Response.Write("categoryf by session:"+categoryf+" -Session[categoryf]:"+Session["categoryf"]+"<br>");
					matchCategories = new List<int>();
					matchCategories.Add(categoryf);
				}else{
					Session["categoryf"] = null;
					categoryf = 0;
					//Response.Write("categoryf empty:"+categoryf+" -Session[categoryf]:"+Session["categoryf"]+"<br>");
				}
			}
			
			if (!String.IsNullOrEmpty(Request["languagef"]) && Request["languagef"]!="0") {
				Session["languagef"] = Convert.ToInt32(Request["languagef"]);
				languagef = (int)Session["languagef"];
				//Response.Write("languagef:"+languagef+" -Session[languagef]:"+Session["languagef"]+"<br>");
				matchLanguages = new List<int>();
				matchLanguages.Add(languagef);
			}else{
				if (Session["languagef"] != null) {
					languagef = (int)Session["languagef"];
					//Response.Write("languagef by session:"+languagef+" -Session[languagef]:"+Session["languagef"]+"<br>");
					matchLanguages = new List<int>();
					matchLanguages.Add(languagef);
				}else{
					Session["languagef"] = null;
					languagef = 0;
				}
			}
		}
		//************* END: CONTENT FILTERS SETUP

		//Response.Write("titlef:"+titlef+" -Session[titlef]:"+Session["titlef"]+"<br>");
		//Response.Write("keywordf:"+keywordf+" -Session[keywordf]:"+Session["keywordf"]+"<br>");
		//Response.Write("statusf:"+statusf+" -Session[statusf]:"+Session["statusf"]+"<br>");
		//Response.Write("categoryf:"+categoryf+" -Session[categoryf]:"+Session["categoryf"]+"<br>");
		//Response.Write("languagef:"+languagef+" -Session[languagef]:"+Session["languagef"]+"<br>");
		//Response.Write("resetMenu:"+Request["resetMenu"]+" -Request[resetMenu] == 1:"+(Request["resetMenu"] == "1")+"<br>");

		// recupero elementi della pagina necessari
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}
		try{			
			categories = catrep.getCategoryList();	
			if(categories == null){				
				categories = new List<Category>();						
			}
		}catch (Exception ex){
			categories = new List<Category>();
		}
		try{			
			supplements = suprep.find(null,-1,false);	
			if(supplements == null){				
				supplements = new List<Supplement>();						
			}
		}catch (Exception ex){
			supplements = new List<Supplement>();
		}
		
		try{				
			fieldNames = productrep.findFieldNames();		
			if(fieldNames == null){				
				fieldNames = new List<string>();						
			}
		}catch (Exception ex){
			fieldNames = new List<string>();
		}
		try{				
			fieldGroupNames = productrep.findFieldGroupNames();		
			if(fieldGroupNames == null){				
				fieldGroupNames = new List<string>();						
			}
		}catch (Exception ex){
			fieldGroupNames = new List<string>();
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

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		long totalcount=0L;
		try
		{
			//check su userid: se administrator mostro tutti i contenuti
			if(!login.userLogged.role.isAdmin()){userf=login.userLogged.id;}
			products = productrep.find(titlef,keywordf,statusf,userf,typef,qtyrtypef,null,null,order_by,matchCategories,matchLanguages,false,true,true,false,false,numPageProd,itemsXpageProd,out totalcount);
			
			if(products != null && products.Count>0){				
				bolFoundLista = true;		
				
				//if(products[0].attachments!=null){Response.Write("products attachments != null "+products[0].attachments.GetType());}	
			}			    	
		}
		catch (Exception ex)
		{
			products = new List<Product>();
			Response.Write(ex.Message);
			bolFoundLista = false;
		}
		
		//***************** RECUPERO LISTA COMMON CONTENT FIELDS 
		try
		{
			productfields = productrep.getProductFields(-1, null, "true");
			if(productfields != null && productfields.Count>0)
			{				
				bolFoundField = true;				
			}    	
		}
		catch (Exception ex)
		{
			productfields = new List<ProductField>();
			bolFoundField = false;
		}		
	
		if(itemsXpageProd>0){_totalPages = (int)totalcount/itemsXpageProd;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(totalcount % itemsXpageProd != 0 &&  (_totalPages * itemsXpageProd) < totalcount) {
			_totalPages = _totalPages +1;	
		}
		
		
		int ifIndex = productfields.Count;
		fromFields = ((this.numPageField * itemsXpageField) - itemsXpageField);
		int fdiff = (ifIndex - ((this.numPageField * itemsXpageField)-1));
		if(fdiff < 1) {
			fdiff = 1;
		}
		
		toFields = ifIndex - fdiff;
			
		if(itemsXpageField>0){_totalfPages = ifIndex/itemsXpageField;}
		if(_totalfPages < 1) {
			_totalfPages = 1;
		}else if(productfields.Count % itemsXpageField != 0 &&  (_totalfPages * itemsXpageField) < ifIndex) {
			_totalfPages = _totalfPages +1;	
		}
		
			
		this.pg1.totalPages = this.totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPageProd;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "showtab=productlist&itemsField="+itemsXpageField+"&itemsProd="+itemsXpageProd+"&cssClass="+cssClass+"&order_by="+order_by+"&titlef="+titlef+"&typef="+typef+"&keywordf="+keywordf+"&categoryf="+categoryf+"&statusf="+statusf+"&languagef="+languagef;	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPageProd;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = "showtab=productlist&itemsField="+itemsXpageField+"&itemsProd="+itemsXpageProd+"&cssClass="+cssClass+"&order_by="+order_by+"&titlef="+titlef+"&typef="+typef+"&keywordf="+keywordf+"&categoryf="+categoryf+"&statusf="+statusf+"&languagef="+languagef;		
		
		this.pg3.totalPages = this.totalfPages;
		this.pg3.defaultLangCode = lang.defaultLangCode;
		this.pg3.currentPage = this.numPageField;
		this.pg3.pageForward = Request.Url.AbsolutePath;
		this.pg3.parameters = "showtab=productfield&itemsField="+itemsXpageField+"&itemsProd="+itemsXpageProd+"&cssClass="+cssClass+"&order_by="+order_by+"&titlef="+titlef+"&typef="+typef+"&keywordf="+keywordf+"&categoryf="+categoryf+"&statusf="+statusf+"&languagef="+languagef;	
			
		this.pg4.totalPages = this.totalfPages;
		this.pg4.defaultLangCode = lang.defaultLangCode;
		this.pg4.currentPage = this.numPageField;
		this.pg4.pageForward = Request.Url.AbsolutePath;
		this.pg4.parameters = "showtab=productfield&itemsField="+itemsXpageField+"&itemsProd="+itemsXpageProd+"&cssClass="+cssClass+"&order_by="+order_by+"&titlef="+titlef+"&typef="+typef+"&keywordf="+keywordf+"&categoryf="+categoryf+"&statusf="+statusf+"&languagef="+languagef;	
	}
}