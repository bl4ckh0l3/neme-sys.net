using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _VoucherList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected int fromVoucher, toVoucher;
	protected string cssClass;	
	protected IList<VoucherCampaign> campaigns;
	
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
		cssClass="LVC";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
	
		IVoucherRepository voucherep = RepositoryFactory.getInstance<IVoucherRepository>("IVoucherRepository");

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["voucherItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["voucherItems"];
		}else{
			if (Session["voucherItems"] != null) {
				itemsXpage = (int)Session["voucherItems"];
			}else{
				Session["voucherItems"] = 20;
				itemsXpage = (int)Session["voucherItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["voucherPage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["voucherPage"];
		}else{
			if (Session["voucherPage"] != null) {
				numPage = (int)Session["voucherPage"];
			}else{
				Session["voucherPage"]= 1;
				numPage = (int)Session["voucherPage"];
			}
		}

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		try{
			campaigns = voucherep.find(null, null);
			if(campaigns != null){				
				bolFoundLista = true;			
			}	    	
		}catch (Exception ex){
			Response.Write("bolFoundLista Exception:"+ex.Message+"<br>");
			campaigns = new List<VoucherCampaign>();
			bolFoundLista = false;
		}
	
		int iIndex = campaigns.Count;
		fromVoucher = ((this.numPage * itemsXpage) - itemsXpage);
		int diff = (iIndex - ((this.numPage * itemsXpage)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toVoucher = iIndex - diff;
			
		if(itemsXpage>0){_totalPages = iIndex/itemsXpage;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(campaigns.Count % itemsXpage != 0 &&  (_totalPages * itemsXpage) < iIndex) {
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