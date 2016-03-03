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

public partial class _StrategyList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundUGroup = false;	
	protected bool bolFoundRules = false;
	protected int itemsXpageUGroup, numPageUGroup, itemsXpageRule, numPageRule;
	protected string cssClass, showTab;
	
	protected IList<UserGroup> userGroups;	
	protected IList<BusinessRule> businessRules;
	protected IList<SupplementGroup> supplements;
	protected int fromUGroups, toUGroups;	
	protected int fromBrules, toBrules;	
	
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
		cssClass="LM";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		ISupplementGroupRepository suprep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
		IUserRepository userrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		IBusinessRuleRepository brulerep = RepositoryFactory.getInstance<IBusinessRuleRepository>("IBusinessRuleRepository");
		
		Logger log = new Logger();
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		itemsXpageUGroup = 20;
		itemsXpageRule = 20;
		
		showTab="ugrouplist";
		if(!String.IsNullOrEmpty(Request["showtab"])){
			showTab=Request["showtab"];
		}	
		
		if (!String.IsNullOrEmpty(Request["itemsUGroup"])) {
			Session["listItemsug"] = Convert.ToInt32(Request["itemsUGroup"]);
			itemsXpageUGroup = (int)Session["listItemsug"];
		}else{
			if (Session["listItemsug"] != null) {
				itemsXpageUGroup = (int)Session["listItemsug"];
			}else{
				Session["listItemsug"] = 20;
				itemsXpageUGroup = (int)Session["listItemsug"];
			}
		}

		//***************** RECUPERO DATI PER LISTA FIELDS
		if (!String.IsNullOrEmpty(Request["itemsRule"])) {
			Session["listItemsbr"] = Convert.ToInt32(Request["itemsRule"]);
			itemsXpageRule = (int)Session["listItemsbr"];
		}else{
			if (Session["listItemsbr"] != null) {
				itemsXpageRule = (int)Session["listItemsbr"];
			}else{
				Session["listItemsbr"] = 20;
				itemsXpageRule = (int)Session["listItemsbr"];
			}
		}
		
		//************* START: CONTENT FILTERS SETUP
	
		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["userGroupsPagec"] = Convert.ToInt32(Request["page"]);
			numPageUGroup = (int)Session["userGroupsPagec"];
		}else{
			if (Session["userGroupsPagec"] != null) {
				numPageUGroup = (int)Session["userGroupsPagec"];
			}else{
				Session["userGroupsPagec"]= 1;
				numPageUGroup = (int)Session["userGroupsPagec"];
			}
		}

		if (showTab=="businessrulelist" && !String.IsNullOrEmpty(Request["page"])) {
			Session["BusinessRulesPagec"] = Convert.ToInt32(Request["page"]);
			numPageRule = (int)Session["BusinessRulesPagec"];
		}else{
			if (Session["BusinessRulesPagec"] != null) {
				numPageRule = (int)Session["BusinessRulesPagec"];
			}else{
				Session["BusinessRulesPagec"]= 1;
				numPageRule = (int)Session["BusinessRulesPagec"];
			}
		}
		//************* END: CONTENT FILTERS SETUP

		// recupero elementi della pagina necessari
		try{			
			supplements = suprep.getSupplementGroups();	
			if(supplements == null){				
				supplements = new List<SupplementGroup>();						
			}
		}catch (Exception ex){
			supplements = new List<SupplementGroup>();
		}

		//***** RECUPERO USER GROUPS	
		try
		{
			//check su userid: se administrator mostro tutti i contenuti
			userGroups = userrep.getAllUserGroup();			
			if(userGroups != null && userGroups.Count>0){				
				bolFoundUGroup = true;		
			}			    	
		}
		catch (Exception ex)
		{
			userGroups = new List<UserGroup>();
			bolFoundUGroup = false;
		}
		
		//***************** RECUPERO BUSINESS RULES 
		try
		{
			businessRules = brulerep.find(null, null);
			if(businessRules != null && businessRules.Count>0)
			{				
				bolFoundRules = true;				
			}    	
		}
		catch (Exception ex)
		{
			businessRules = new List<BusinessRule>();
			bolFoundRules = false;
		}
		
		
		int iugIndex = userGroups.Count;
		fromUGroups = ((this.numPageUGroup * itemsXpageUGroup) - itemsXpageUGroup);
		int ugdiff = (iugIndex - ((this.numPageUGroup * itemsXpageUGroup)-1));
		if(ugdiff < 1) {
			ugdiff = 1;
		}
		
		toUGroups = iugIndex - ugdiff;		
	
		if(itemsXpageUGroup>0){_totalPages = iugIndex/itemsXpageUGroup;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(userGroups.Count % itemsXpageUGroup != 0 &&  (_totalPages * itemsXpageUGroup) < iugIndex) {
			_totalPages = _totalPages +1;	
		}
		
		
		int ibrIndex = businessRules.Count;
		fromBrules = ((this.numPageRule * itemsXpageRule) - itemsXpageRule);
		int brdiff = (ibrIndex - ((this.numPageRule * itemsXpageRule)-1));
		if(brdiff < 1) {
			brdiff = 1;
		}
		
		toBrules = ibrIndex - brdiff;
			
		if(itemsXpageRule>0){_totalfPages = ibrIndex/itemsXpageRule;}
		if(_totalfPages < 1) {
			_totalfPages = 1;
		}else if(businessRules.Count % itemsXpageRule != 0 &&  (_totalfPages * itemsXpageRule) < ibrIndex) {
			_totalfPages = _totalfPages +1;	
		}
		
			
		this.pg1.totalPages = this.totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPageUGroup;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "showtab=ugrouplist&itemsRule="+itemsXpageRule+"&itemsUGroup="+itemsXpageUGroup;	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPageUGroup;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = "showtab=ugrouplist&itemsRule="+itemsXpageRule+"&itemsUGroup="+itemsXpageUGroup;		
		
		this.pg3.totalPages = this.totalfPages;
		this.pg3.defaultLangCode = lang.defaultLangCode;
		this.pg3.currentPage = this.numPageRule;
		this.pg3.pageForward = Request.Url.AbsolutePath;
		this.pg3.parameters = "showtab=businessrulelist&itemsRule="+itemsXpageRule+"&itemsUGroup="+itemsXpageUGroup;	
			
		this.pg4.totalPages = this.totalfPages;
		this.pg4.defaultLangCode = lang.defaultLangCode;
		this.pg4.currentPage = this.numPageRule;
		this.pg4.pageForward = Request.Url.AbsolutePath;
		this.pg4.parameters = "showtab=businessrulelist&itemsRule="+itemsXpageRule+"&itemsUGroup="+itemsXpageUGroup;	
	}
}