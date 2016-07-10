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

public partial class _SupplementList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected bool bolFoundGroup = false;
	protected int itemsXpageSup, numPageSup, itemsXpageSupG, numPageSupG;
	protected string cssClass, showTab;
	protected int fromSup, toSup;
	protected int fromGroup, toGroup;
	
	protected IList<Supplement> supplements;	
	protected IList<SupplementGroup> supplementGroups;
	protected IList<Country> countries;
	private int _totalPages;	
	public int totalPages {
		get { return _totalPages; }
	}	
	
	private int _totalgPages;	
	public int totalgPages {
		get { return _totalgPages; }
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
		cssClass="LTX";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		ISupplementRepository suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
		ISupplementGroupRepository supgrep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		ICountryRepository countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
		
		Logger log = new Logger();
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		itemsXpageSup = 20;
		itemsXpageSupG = 20;
		
		showTab="taxslist";
		if(!String.IsNullOrEmpty(Request["showtab"])){
			showTab=Request["showtab"];
		}	
			
		if("insGroup".Equals(Request["operation"]))
		{
			if(!String.IsNullOrEmpty(Request["description"]))
			{
				bool carryOn = true;
				try
				{	
					SupplementGroup supgins = new SupplementGroup();
					supgins.id = -1;
					supgins.description = Request["description"];
					supgrep.insert(supgins);			
					log.usr= login.userLogged.username;
					log.msg = "insert supplement group: "+supgins.ToString();
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
					Response.Redirect("/backoffice/supplements/supplementlist.aspx?showtab=taxsgroup&cssClass="+Request["cssClass"]);
				}else{
					Response.Redirect(url.ToString());
				}	
			}				
		}	
			
		if("insGroupValue".Equals(Request["operation"]))
		{
			bool carryOn = true;
			try
			{	
				SupplementGroupValue supgvins = new SupplementGroupValue();
				supgvins.id = -1;
				supgvins.idGroup = Convert.ToInt32(Request["id_group"]);
				supgvins.idFee = Convert.ToInt32(Request["id_fee"]);
				supgvins.countryCode = Request["country_code"];
				supgvins.stateRegionCode = Request["state_region_code"];
				supgvins.excludeCalculation = Convert.ToBoolean(Convert.ToInt32(Request["exclude_calculation"]));
				
				supgrep.insertGroupValue(supgvins);			
				log.usr= login.userLogged.username;
				log.msg = "insert supplement group value: "+supgvins.ToString();
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
				Response.Redirect("/backoffice/supplements/supplementlist.aspx?showtab=taxsgroup&cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}				
		}	
			
		if("deleteGroup".Equals(Request["operation"]))
		{
			if(!String.IsNullOrEmpty(Request["id_group"]) && Request["id_group"]!= "-1")
			{
				bool carryOn = true;
				try
				{	
					SupplementGroup supgdel = supgrep.getById(Convert.ToInt32(Request["id_group"]));
					supgrep.delete(supgdel);			
					log.usr= login.userLogged.username;
					log.msg = "delete supplement group: "+supgdel.ToString();
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
					Response.Redirect("/backoffice/supplements/supplementlist.aspx?showtab=taxsgroup&cssClass="+Request["cssClass"]);
				}else{
					Response.Redirect(url.ToString());
				}	
			}				
		}	
			
		if("deleteGroupValue".Equals(Request["operation"]))
		{
			bool carryOn = true;
			try
			{	
				Response.Write("Request[value_id]: "+Request["value_id"]+"<br>");
				SupplementGroupValue supgvdel = supgrep.getGroupValueById(Convert.ToInt32(Request["value_id"]));
				
				supgrep.deleteGroupValue(supgvdel);			
				log.usr= login.userLogged.username;
				log.msg = "delete supplement group value: "+supgvdel.ToString();
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
				Response.Redirect("/backoffice/supplements/supplementlist.aspx?showtab=taxsgroup&cssClass="+Request["cssClass"]+"&group_ass_match_div="+Request["group_ass_match_div"]);
			}else{
				Response.Redirect(url.ToString());
			}				
		}
		
		if (!String.IsNullOrEmpty(Request["itemsSup"])) {
			Session["listItemsup"] = Convert.ToInt32(Request["itemsSup"]);
			itemsXpageSup = (int)Session["listItemsup"];
		}else{
			if (Session["listItemsup"] != null) {
				itemsXpageSup = (int)Session["listItemsup"];
			}else{
				Session["listItemsup"] = 20;
				itemsXpageSup = (int)Session["listItemsup"];
			}
		}

		//***************** RECUPERO DATI PER LISTA FIELDS
		if (!String.IsNullOrEmpty(Request["itemsSupg"])) {
			Session["groupItems"] = Convert.ToInt32(Request["itemsSupg"]);
			itemsXpageSupG = (int)Session["groupItems"];
		}else{
			if (Session["groupItems"] != null) {
				itemsXpageSupG = (int)Session["groupItems"];
			}else{
				Session["groupItems"] = 20;
				itemsXpageSupG = (int)Session["groupItems"];
			}
		}

		if (showTab=="taxslist" && !String.IsNullOrEmpty(Request["page"])) {
			Session["supplementPagec"] = Convert.ToInt32(Request["page"]);
			numPageSup = (int)Session["supplementPagec"];
		}else{
			if (Session["supplementPagec"] != null) {
				numPageSup = (int)Session["supplementPagec"];
			}else{
				Session["supplementPagec"]= 1;
				numPageSup = (int)Session["supplementPagec"];
			}
		}

		if (showTab=="taxsgroup" && !String.IsNullOrEmpty(Request["page"])) {
			Session["groupPagec"] = Convert.ToInt32(Request["page"]);
			numPageSupG = (int)Session["groupPagec"];
		}else{
			if (Session["groupPagec"] != null) {
				numPageSupG = (int)Session["groupPagec"];
			}else{
				Session["groupPagec"]= 1;
				numPageSupG = (int)Session["groupPagec"];
			}
		}

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		long totalcount=0L;
		try{
			supplements = suprep.find(null,-1,false);			
			if(supplements != null && supplements.Count>0){				
				bolFoundLista = true;		
			}			    	
		}catch (Exception ex){
			supplements = new List<Supplement>();
			//Response.Write(ex.Message);
			bolFoundLista = false;
		}
		
		try{
			supplementGroups = supgrep.find(null, false);
			if(supplementGroups != null && supplementGroups.Count>0){				
				bolFoundGroup = true;				
			}    	
		}catch (Exception ex){
			supplementGroups = new List<SupplementGroup>();
			bolFoundGroup = false;
		}
		
		try{				
			countries = countryrep.findAllCountries("2,3");		
			if(countries == null){				
				countries = new List<Country>();						
			}
		}catch (Exception ex){
			countries = new List<Country>();
		}	
		
		int isIndex = supplements.Count;
		fromSup = ((this.numPageSup * itemsXpageSup) - itemsXpageSup);
		int sdiff = (isIndex - ((this.numPageSup * itemsXpageSup)-1));
		if(sdiff < 1) {
			sdiff = 1;
		}
		
		toSup = isIndex - sdiff;
		
		if(itemsXpageSup>0){_totalPages = (int)isIndex/itemsXpageSup;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(supplements.Count % itemsXpageSup != 0 &&  (_totalPages * itemsXpageSup) < isIndex) {
			_totalPages = _totalPages +1;	
		}
		
		int igIndex = supplementGroups.Count;
		fromGroup = ((this.numPageSupG * itemsXpageSupG) - itemsXpageSupG);
		int gdiff = (igIndex - ((this.numPageSupG * itemsXpageSupG)-1));
		if(gdiff < 1) {
			gdiff = 1;
		}
		
		toGroup = igIndex - gdiff;
			
		if(itemsXpageSupG>0){_totalgPages = igIndex/itemsXpageSupG;}
		if(_totalgPages < 1) {
			_totalgPages = 1;
		}else if(supplementGroups.Count % itemsXpageSupG != 0 &&  (_totalgPages * itemsXpageSupG) < igIndex) {
			_totalgPages = _totalgPages +1;	
		}
		
			
		this.pg1.totalPages = this.totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPageSup;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "showtab=taxslist&itemsSupg="+itemsXpageSupG+"&itemsSup="+itemsXpageSup+"&cssClass="+cssClass;	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPageSup;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = "showtab=taxslist&itemsSupg="+itemsXpageSupG+"&itemsSup="+itemsXpageSup+"&cssClass="+cssClass;		
		
		this.pg3.totalPages = this.totalgPages;
		this.pg3.defaultLangCode = lang.defaultLangCode;
		this.pg3.currentPage = this.numPageSupG;
		this.pg3.pageForward = Request.Url.AbsolutePath;
		this.pg3.parameters = "showtab=taxsgroup&itemsSupg="+itemsXpageSupG+"&itemsSup="+itemsXpageSup+"&cssClass="+cssClass;	
			
		this.pg4.totalPages = this.totalgPages;
		this.pg4.defaultLangCode = lang.defaultLangCode;
		this.pg4.currentPage = this.numPageSupG;
		this.pg4.pageForward = Request.Url.AbsolutePath;
		this.pg4.parameters = "showtab=taxsgroup&itemsSupg="+itemsXpageSupG+"&itemsSup="+itemsXpageSup+"&cssClass="+cssClass;	
	}
}