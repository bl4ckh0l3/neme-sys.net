using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _FeeList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected bool bolFoundSup = false;	
	protected bool bolFoundSupG = false;	
	protected int itemsXpage, numPage;
	protected int fromFee, toFee;
	protected string cssClass;	
	protected IList<Fee> fees;
	protected IList<Supplement> supplements;	
	protected IList<SupplementGroup> supplementGroups;
	private int _totalPages;	
	public int totalPages {
		get { return _totalPages; }
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
		cssClass="LSP";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
	
		IFeeRepository feerep = RepositoryFactory.getInstance<IFeeRepository>("IFeeRepository");
		ISupplementRepository suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
		ISupplementGroupRepository supgrep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["feeItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["feeItems"];
		}else{
			if (Session["feeItems"] != null) {
				itemsXpage = (int)Session["feeItems"];
			}else{
				Session["feeItems"] = 20;
				itemsXpage = (int)Session["feeItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["feePage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["feePage"];
		}else{
			if (Session["feePage"] != null) {
				numPage = (int)Session["feePage"];
			}else{
				Session["feePage"]= 1;
				numPage = (int)Session["feePage"];
			}
		}

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		try{
			fees = feerep.find(null, -1, null, false);
			if(fees != null){				
				bolFoundLista = true;			
			}	    	
		}catch (Exception ex){
			//Response.Write("bolFoundLista Exception:"+ex.Message+"<br>");
			fees = new List<Fee>();
			bolFoundLista = false;
		}
		try{
			supplements = suprep.find(null,-1,false);			
			if(supplements != null && supplements.Count>0){				
				bolFoundSup = true;		
			}			    	
		}catch (Exception ex){
			//Response.Write("bolFoundSup Exception:"+ex.Message+"<br>");
			supplements = new List<Supplement>();
			//Response.Write(ex.Message);
			bolFoundSup = false;
		}
		
		try{
			supplementGroups = supgrep.find(null, false);
			if(supplementGroups != null && supplementGroups.Count>0){				
				bolFoundSupG = true;				
			}    	
		}catch (Exception ex){
			//Response.Write("bolFoundSupG Exception:"+ex.Message+"<br>");
			supplementGroups = new List<SupplementGroup>();
			bolFoundSupG = false;
		}
	
		int iIndex = fees.Count;
		fromFee = ((this.numPage * itemsXpage) - itemsXpage);
		int diff = (iIndex - ((this.numPage * itemsXpage)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toFee = iIndex - diff;
			
		if(itemsXpage>0){_totalPages = iIndex/itemsXpage;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(fees.Count % itemsXpage != 0 &&  (_totalPages * itemsXpage) < iIndex) {
			_totalPages = _totalPages +1;	
		}
			
		this.pg1.totalPages = this.totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPage;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "items="+itemsXpage+"&cssClass="+cssClass;	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPage;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = "items="+itemsXpage+"&cssClass="+cssClass;			
	}
}