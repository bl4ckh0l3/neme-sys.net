using System;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.services;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

public partial class _UserList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected IUserRepository usrrep;
	protected bool bolFoundLista = false;	
	protected bool bolFoundField = false;
	protected bool bolHasFieldFilterActive = false;
	protected IDictionary<int,string> filteredFieldsActive;
	protected int itemsXpageList, numPageList, itemsXpageField, numPageField;
	protected string cssClass, search_key, showTab;		
	protected int order_by = 1;
	protected string rolef = "";
	protected string publicf = null;
	protected string activef = null;	
	protected IList<User> users;	
	protected IList<UserField> usrfields;
	protected IList<UserGroup> groupsu;
	protected IList<string> fieldNames;
	protected IList<string> fieldGroupNames;
	protected IList<SystemFieldsType> systemFieldsType;
	protected IList<SystemFieldsTypeContent> systemFieldsTypeContent;
	protected int fromUsers, toUsers;
	protected int fromFields, toFields;
	protected string mailAddressBCC = "";
	protected StringBuilder urlparamusrfilter;
	
	
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
		cssClass="LU";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
	
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		ICommonRepository commonrep = RepositoryFactory.getInstance<ICommonRepository>("ICommonRepository");
		usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();
		bool carryOn;
		fieldNames = new List<string>();
		fieldGroupNames = new List<string>();
		systemFieldsType = new List<SystemFieldsType>();
		systemFieldsTypeContent = new List<SystemFieldsTypeContent>();
		filteredFieldsActive = new Dictionary<int,string>();
		itemsXpageList = 20;
		itemsXpageField = 20;

		//*****************  RECUPERO ELEMENTI DELLA PAGINA NECESSARI
		try{				
			groupsu = usrrep.getAllUserGroup();
			if(groupsu == null){				
				groupsu = new List<UserGroup>();						
			}
		}catch (Exception ex){
			groupsu = new List<UserGroup>();
		}
		try{				
			fieldNames = usrrep.findFieldNames();		
			if(fieldNames == null){				
				fieldNames = new List<string>();						
			}
		}catch (Exception ex){
			fieldNames = new List<string>();
		}
		try{				
			fieldGroupNames = usrrep.findFieldGroupNames();		
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
			
		if("delete".Equals(Request["operation"]))
		{
			if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
			{
				carryOn = true;
				try
				{	
					User userdel = usrrep.getById(Convert.ToInt32(Request["id"]));
					bool executed = usrrep.delete(userdel, false);					
					string msg = "delete user: ";
					if(!executed){
						msg = "disabled user (cannot be deleted for elements association): ";
					}
					log.usr= login.userLogged.username;
					log.msg = msg+userdel.ToString();
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
					Response.Redirect("/backoffice/users/userlist.aspx?showtab=usrlist&cssClass="+Request["cssClass"]);
				}else{
					Response.Redirect(url.ToString());
				}	
			}				
		}	
			
		if("deleteField".Equals(Request["operation"]))
		{
			if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
			{
				carryOn = true;
				try
				{	
					UserField userfdel = usrrep.getUserFieldById(Convert.ToInt32(Request["id"]));
					usrrep.deleteUserField(userfdel.id);			
					log.usr= login.userLogged.username;
					log.msg = "delete field: "+userfdel.ToString();
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
					Response.Redirect("/backoffice/users/userlist.aspx?showtab=usrfield&cssClass="+Request["cssClass"]);
				}else{
					Response.Redirect(url.ToString());
				}	
			}				
		}	

		showTab="usrlist";
		if(!String.IsNullOrEmpty(Request["showtab"])){
			showTab=Request["showtab"];
		}

		if (!String.IsNullOrEmpty(Request["itemsList"])) {
			Session["listItems"] = Convert.ToInt32(Request["itemsList"]);
			itemsXpageList = (int)Session["listItems"];
		}else{
			if (Session["listItems"] != null) {
				itemsXpageList = (int)Session["listItems"];
			}else{
				Session["listItems"] = 20;
				itemsXpageList = (int)Session["listItems"];
			}
		}

		if (showTab=="usrlist" && !String.IsNullOrEmpty(Request["page"])) {
			Session["listPage"] = Convert.ToInt32(Request["page"]);
			numPageList = (int)Session["listPage"];
		}else{
			if (Session["listPage"] != null) {
				numPageList = (int)Session["listPage"];
			}else{
				Session["listPage"]= 1;
				numPageList = (int)Session["listPage"];
			}
		}

		if (!String.IsNullOrEmpty(Request["search_key"])) {
			Session["search_key"] = Request["search_key"];
			search_key = (string)Session["search_key"];
		}else{
			if (Session["search_key"] != null) {
				search_key = (string)Session["search_key"];
			}else{
				Session["search_key"]= null;
				search_key = (string)Session["search_key"];
			}
		}
		if (!String.IsNullOrEmpty(Request["rolef"])) {
			rolef = Request["rolef"];
		}
		if (!String.IsNullOrEmpty(Request["publicf"])) {
			publicf = Request["publicf"];
		}
		if (!String.IsNullOrEmpty(Request["activef"])) {
			activef = Request["activef"];
		}
		if (!String.IsNullOrEmpty(Request["order_by"])) {
			order_by = Convert.ToInt32(Request["order_by"]);
		}

		//***************** RECUPERO DATI PER LISTA FIELDS
		if (!String.IsNullOrEmpty(Request["itemsField"])) {
			Session["fieldItems"] = Convert.ToInt32(Request["itemsField"]);
			itemsXpageField = (int)Session["fieldItems"];
		}else{
			if (Session["fieldItems"] != null) {
				itemsXpageField = (int)Session["fieldItems"];
			}else{
				Session["fieldItems"] = 20;
				itemsXpageField = (int)Session["fieldItems"];
			}
		}

		if (showTab=="usrfield" && !String.IsNullOrEmpty(Request["page"])) {
			Session["fieldPage"] = Convert.ToInt32(Request["page"]);
			numPageField = (int)Session["fieldPage"];
		}else{
			if (Session["fieldPage"] != null) {
				numPageField = (int)Session["fieldPage"];
			}else{
				Session["fieldPage"]= 1;
				numPageField = (int)Session["fieldPage"];
			}
		}	

		if(!String.IsNullOrEmpty(Request["resetMenu"]) && Request["resetMenu"] == "1") 
		{
			Session["listPage"] = 1;
			numPageList = (int)Session["listPage"];
			Session["fieldPage"]= 1;
			numPageField = (int)Session["fieldPage"];
			Session["search_key"] = null;
			search_key = (string)Session["search_key"];
		}


		//***************** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		users = new List<User>();
		try
		{
			users = usrrep.find(search_key, rolef, activef, publicf, "false", order_by, false, false, false, false, false,true);
			if(users != null)
			{				
				bolFoundLista = true;					
			}    	
		}
		catch (Exception ex)
		{
			users = new List<User>();
			bolFoundLista = false;
		}

		//***************** RECUPERO LISTA USER FIELDS 
		try
		{
			List<string> usesFor = new List<string>();
			usesFor.Add("1");
			usesFor.Add("3");
			usrfields = usrrep.getUserFields(null,usesFor, null);
			if(usrfields != null)
			{				
				bolFoundField = true;

				foreach(UserField uf in usrfields){
					if((uf.type==1 || uf.type==7) && !String.IsNullOrEmpty(Request["user_field_"+uf.id])){
						filteredFieldsActive.Add(uf.id,Request["user_field_"+uf.id]);
						bolHasFieldFilterActive = true;
					}
				}				
			}    	
		}
		catch (Exception ex)
		{
			usrfields = new List<UserField>();
			bolFoundField = false;
		}

		//***************** APPLICO I FILTRI ALLA LISTA UTENTI
		if(bolHasFieldFilterActive){
			IList<User> toRemove = new List<User>();
			IList<bool> itemsRemove = null;
			foreach(User u in users){
				//Response.Write(u.ToString()+"<br>");
				itemsRemove = new List<bool>();
				foreach (int i in filteredFieldsActive.Keys){
					bool remove=true;
					string valuetmp = "";
					if(u.fields != null && u.fields.Count>0){
						foreach(UserFieldsMatch ufm in u.fields){
							//Response.Write("i:"+i+" -ufm.idParentField:"+ufm.idParentField+" -filteredFieldsActive[i]:"+filteredFieldsActive[i]+"<br>");
							if(i==ufm.idParentField){
								valuetmp = ufm.value;
								break;
							}							
						}
					}
				
					string[] arrFilteredField = filteredFieldsActive[i].Split(',');
					if(arrFilteredField != null){
						foreach(string x in arrFilteredField){
							//Response.Write("arrFilteredField x:"+x+" -valuetmp:"+valuetmp+"<br>");
							if(valuetmp==x){	
								remove=false;									
								//objDictlUsrFieldsVal.add i&"-"&k, valuetmp										
								break;
							}							
						}
					}
					//Response.Write("remove:"+remove+"<br>");
					itemsRemove.Add(remove);
				}
				bool doRemove = false;
				foreach(bool x in itemsRemove){
					//Response.Write("doRemove:"+doRemove+" -x:"+x+"<br>");
					doRemove = doRemove || x;
				}
				
				
				if(doRemove){	
					toRemove.Add(u);
				}
			}
			if(toRemove.Count>0){
				foreach(User ur in toRemove){
					users.Remove(ur);
				}
			}
		}		

		//***************** SE � STATO IMPOSTATO UN ORDINAMENTO SUI FILTRI RIORDINO LA LISTA UTENTI IN BASE AL FILTRO SELEZIONATO					
		if(!String.IsNullOrEmpty(Request["order_by_fields"])) {
			string order_by_fields = Request["order_by_fields"];	
			users = UserService.sortUserByField(users, Convert.ToInt32(order_by_fields));
		}
		
		
		int iIndex = users.Count;
		fromUsers = ((this.numPageList * itemsXpageList) - itemsXpageList);
		int diff = (iIndex - ((this.numPageList * itemsXpageList)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toUsers = iIndex - diff;
			
		if(itemsXpageList>0){_totalPages = iIndex/itemsXpageList;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(users.Count % itemsXpageList != 0 &&  (_totalPages * itemsXpageList) < iIndex) {
			_totalPages = _totalPages +1;	
		}
		
		
		int ifIndex = usrfields.Count;
		fromFields = ((this.numPageField * itemsXpageField) - itemsXpageField);
		int fdiff = (ifIndex - ((this.numPageField * itemsXpageField)-1));
		if(fdiff < 1) {
			fdiff = 1;
		}
		
		toFields = ifIndex - fdiff;
			
		if(itemsXpageField>0){_totalfPages = ifIndex/itemsXpageField;}
		if(_totalfPages < 1) {
			_totalfPages = 1;
		}else if(usrfields.Count % itemsXpageField != 0 &&  (_totalfPages * itemsXpageField) < ifIndex) {
			_totalfPages = _totalfPages +1;	
		}

		// ENTRO QUESTO PUNTO DEVONO ESSERE RECUPERATI TUTTI GLI OGGETTI E TUTTE LE LISTE GIA' PAGINATE E FILTRATE
		
		
		//RECUPERO DALLA LISTA FINALE L'ELENCO DELLE MAIL DA USARE PER IL MESSAGGIO ISTANTANEO SE NECESSARIO.		
		foreach(User u in users)
		{
			mailAddressBCC+=","+u.email;
		}
		if(mailAddressBCC.StartsWith(","))
		{
			mailAddressBCC = mailAddressBCC.Substring(1);
		}
		
		//verifico se bisogna inviare mail spot
		if(!String.IsNullOrEmpty(Request["do_send_mail"]) && Request["do_send_mail"]=="1"){
			ListDictionary replacements = new ListDictionary();
			replacements.Add("<%content%>",Server.HtmlDecode(Request["mail_body"]));
			//replacements.Add("mail_bcc","denismind@libero.it");
			replacements.Add("mail_bcc",Request["mail_bcc"]);
			replacements.Add("mail_subject",Request["mail_subject"]);			
			UriBuilder builder = new UriBuilder(Request.Url);
			builder.Scheme = "http";
			builder.Port = -1;
			builder.Path="";
			carryOn = true;
			try
			{
				MailService.prepareAndSend("user-list-mail-spot", lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, builder.ToString());
				IMultiLanguageRepository langRepository = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
				if (!String.IsNullOrEmpty(langRepository.convertMessageCode("002")))
				{
					message.Text = "<span class=error id=mailbox_error><br/>"+lang.getTranslated(langRepository.convertMessageCode("002"))+"</span>";
				}
	
			}
			catch(Exception ex){				
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				carryOn = false;
			}
			
			if(!carryOn){
				Response.Redirect(url.ToString());
			}	
		}

		urlparamusrfilter= new StringBuilder()
		.Append("itemsList=").Append(itemsXpageList)
		.Append("&itemsField=").Append(itemsXpageField)
		.Append("&cssClass=").Append(cssClass)
		.Append("&showtab=usrlist")
		.Append("&rolef=").Append(rolef)
		.Append("&publicf=").Append(publicf)
		.Append("&activef=").Append(activef)
		.Append("&order_by=").Append(order_by)
		.Append("&view_filter=").Append(Request["view_filter"])
		.Append("&view_fields=").Append(Request["view_fields"])
		.Append("&order_by_fields=").Append(Request["order_by_fields"]);
			
		StringBuilder urlparamfieldfilter= new StringBuilder()
		.Append("itemsList=").Append(itemsXpageList)
		.Append("&itemsField=").Append(itemsXpageField)
		.Append("&cssClass=").Append(cssClass)
		.Append("&showtab=usrfield")
		.Append("&rolef=").Append(rolef)
		.Append("&publicf=").Append(publicf)
		.Append("&activef=").Append(activef)
		.Append("&order_by=").Append(order_by)
		.Append("&view_filter=").Append(Request["view_filter"])
		.Append("&view_fields=").Append(Request["view_fields"])
		.Append("&order_by_fields=").Append(Request["order_by_fields"]);
			
		if(bolHasFieldFilterActive){
			foreach(int i in filteredFieldsActive.Keys){
				urlparamusrfilter.Append("&user_field_").Append(i).Append("=").Append(filteredFieldsActive[i]);
			}
		}	
			
		this.pg1.totalPages = this.totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPageList;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = urlparamusrfilter.ToString();	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPageList;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = urlparamusrfilter.ToString();		
			
		this.pg3.totalPages = this.totalfPages;
		this.pg3.defaultLangCode = lang.defaultLangCode;
		this.pg3.currentPage = this.numPageField;
		this.pg3.pageForward = Request.Url.AbsolutePath;
		this.pg3.parameters = urlparamfieldfilter.ToString();	
			
		this.pg4.totalPages = this.totalfPages;
		this.pg4.defaultLangCode = lang.defaultLangCode;
		this.pg4.currentPage = this.numPageField;
		this.pg4.pageForward = Request.Url.AbsolutePath;
		this.pg4.parameters = urlparamfieldfilter.ToString();		
	}
}