<%@ Page Language="C#" AutoEventWireup="true" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="MenuFrontendControl" TagName="insert" Src="~/public/layout/include/menu-frontend.ascx" %>
<%@ Register TagPrefix="UserMaskWidget" TagName="render" Src="~/public/layout/addson/user/user-mask-widget.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;

protected int orderid;
protected string paymentType;
protected bool paymentDone;
protected decimal billsAmount;
protected decimal paymentCommissions;
protected decimal orderAmount;
protected bool hasOrderRule;
protected bool hasProductRule;
protected IList<OrderBusinessRule> orderRules;
protected IList<OrderBusinessRule> productRules;
protected string pdone;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}

protected void Page_Load(object sender, EventArgs e)
{
	lang.set();

	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	


	IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");	
	IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IShippingAddressRepository shiprep = RepositoryFactory.getInstance<IShippingAddressRepository>("IShippingAddressRepository");
	IBillsAddressRepository billsrep = RepositoryFactory.getInstance<IBillsAddressRepository>("IBillsAddressRepository");
	IProductRepository productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	IContentRepository contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
	IAdsRepository adsrep = RepositoryFactory.getInstance<IAdsRepository>("IAdsRepository"); 
	ConfigurationService confservice = new ConfigurationService();
	
	orderid = -1;
	paymentType = "";
	paymentDone = false;
	billsAmount = 0.00M;
	paymentCommissions = 0.00M;
	orderAmount = 0.00M;
	bool hasShipAddress = false;
	bool hasBillsAddress = false;
	hasOrderRule = false;
	hasProductRule = false;
	pdone = "";
	orderRules = null;
	productRules = null;
	
	if(!String.IsNullOrEmpty(Request["orderid"])){
		IList<UserField> usrfields;
			
		try{	
			List<string> usesFor = new List<string>();
			usesFor.Add("2");
			usesFor.Add("3");			
			usrfields = usrrep.getUserFields("true",usesFor);
		}catch (Exception ex){
			usrfields = new List<UserField>();
		}	
	
		try{
			orderid = Convert.ToInt32(Request["orderid"]);
			FOrder order = orderep.getById(orderid, true);
			
			User user = usrrep.getById(order.userId);
			
			paymentDone = order.paymentDone;
			paymentCommissions = order.paymentCommission;
			orderAmount = order.amount;

			pdone = lang.getTranslated("portal.commons.no");
			if(paymentDone){
				pdone = lang.getTranslated("portal.commons.yes");
			}			
			
			int paymentId = order.paymentId;
			Payment payment = payrep.getByIdCached(paymentId, true);
			if(payment != null){
				paymentType = payment.description;
				if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+payment.description))){
					paymentType = lang.getTranslated("backend.payment.description.label."+payment.description);
				}
			}
			
			IList<OrderFee> fees = orderep.findFeesByOrderId(orderid);
			if(fees != null && fees.Count>0){
				foreach(OrderFee f in fees){
					billsAmount+=f.amount;
				}
			}
			
			OrderShippingAddress oshipaddr = orderep.getOrderShippingAddressCached(orderid, true);
			ShippingAddress shipaddr = null;
			if(oshipaddr != null){
				hasShipAddress = true;
				shipaddr = shiprep.getByIdCached(oshipaddr.idShipping, true);
			}
			
			OrderBillsAddress obillsaddr = orderep.getOrderBillsAddressCached(orderid, true);
			BillsAddress billsaddr = null;
			if(obillsaddr != null){
				hasBillsAddress = true;
				billsaddr = billsrep.getByIdCached(obillsaddr.idBills, true);
			}
			
			orderRules = orderep.findOrderBusinessRule(orderid, false);
			if(orderRules != null && orderRules.Count>0){
				hasOrderRule = true;
			}
			
			productRules = orderep.findOrderBusinessRule(orderid, true);
			if(productRules != null && productRules.Count>0){
				hasProductRule = true;
			}

			UriBuilder builder = new UriBuilder(Request.Url);
			builder.Scheme = "http";
			builder.Port = -1;
			builder.Path="";
			builder.Query="";
			
			ListDictionary replacementsUser = new ListDictionary();
			ListDictionary replacementsAdmin = new ListDictionary();
			StringBuilder userMessage = new StringBuilder();
			StringBuilder adminMessage = new StringBuilder();	
			replacementsUser.Add("mail_receiver",user.email);	
			
			//start user message
			userMessage.Append(lang.getTranslated("backend.ordini.view.table.label.id_ordine")).Append(":&nbsp;<b>").Append(order.id).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.guid_ordine")).Append(":&nbsp;<b>").Append(order.guid).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.order_client")).Append("&nbsp;-&nbsp;ID:&nbsp;<b>").Append(user.username).Append("</b>&nbsp;-&nbsp;")
			.Append(lang.getTranslated("frontend.registration.manage.label.email")).Append(":&nbsp;<b>").Append(user.email).Append("</b><br/><br/>");		
			
			//start admin message
			adminMessage.Append(lang.getTranslated("backend.ordini.view.table.label.id_ordine")).Append(":&nbsp;<b>").Append(order.id).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.guid_ordine")).Append(":&nbsp;<b>").Append(order.guid).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.order_client")).Append("&nbsp;-&nbsp;ID:&nbsp;<b>").Append(user.username).Append("</b>&nbsp;-&nbsp;")
			.Append(lang.getTranslated("frontend.registration.manage.label.email")).Append(":&nbsp;<b>").Append(user.email).Append("</b><br/><br/>");								
				
			if(order.noRegistration && "1".Equals(confservice.get("show_user_field_on_direct_buy").value) && user.fields != null && user.fields.Count>0 && usrfields != null && usrfields.Count>0){							
				foreach(UserFieldsMatch f in user.fields){
					string label = "";
					string value = "";
					foreach(UserField uf in usrfields){
						if(uf.id==f.idParentField){
							label = uf.description;
							value = f.value;
							if(uf.typeContent==7 || uf.typeContent==8){
								if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.select.option.country."+f.value))){
									value = lang.getTranslated("portal.commons.select.option.country."+f.value);
								}
							}
							if(!String.IsNullOrEmpty(lang.getTranslated("backend.utenti.detail.table.label.field_values_"+uf.description+"_"+f.value))){
								label = lang.getTranslated("backend.utenti.detail.table.label.field_values_"+uf.description+"_"+f.value);
							}
							break;
						}										
					}
					userMessage.Append(label).Append(":&nbsp;<b>").Append(value).Append("</b><br/><br/>");
					adminMessage.Append(label).Append(":&nbsp;<b>").Append(value).Append("</b><br/><br/>");								
				}
			}
			
			//****** MANAGE SHIPPING ADDRESS
			if(hasShipAddress){
				string shipInfo = "";
				string userLabelIsCompanyClient = "";
				if(oshipaddr.isCompanyClient){
					userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_company");
				}else{
					userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_private");
				}								
				
				shipInfo = shipaddr.name + " " + shipaddr.surname + " ("+userLabelIsCompanyClient+") - " + shipaddr.cfiscvat + " - " +oshipaddr.address +" - "+oshipaddr.city+" ("+oshipaddr.zipCode+") - "+lang.getTranslated("portal.commons.select.option.country."+oshipaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+oshipaddr.stateRegion);
					
				userMessage.Append(lang.getTranslated("backend.ordini.view.table.label.shipping_address")).Append(":&nbsp;<b>").Append(shipInfo).Append("</b><br/><br/>");
				adminMessage.Append(lang.getTranslated("backend.ordini.view.table.label.shipping_address")).Append(":&nbsp;<b>").Append(shipInfo).Append("</b><br/><br/>");	
			}	
			
			//****** MANAGE BILLS ADDRESS
			if(hasBillsAddress){
				string billsInfo = billsaddr.name + " " + billsaddr.surname + " - " + billsaddr.cfiscvat + " - " +obillsaddr.address +" - "+obillsaddr.city+" ("+obillsaddr.zipCode+") - "+lang.getTranslated("portal.commons.select.option.country."+obillsaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+obillsaddr.stateRegion);
								
				userMessage.Append(lang.getTranslated("backend.ordini.view.table.label.bills_address")).Append(":&nbsp;<b>").Append(billsInfo).Append("</b><br/><br/>");
				adminMessage.Append(lang.getTranslated("backend.ordini.view.table.label.bills_address")).Append(":&nbsp;<b>").Append(billsInfo).Append("</b><br/><br/>");					
			}

			userMessage.Append(lang.getTranslated("backend.ordini.view.table.label.dta_insert_order")).Append(":&nbsp;<b>").Append(order.insertDate.ToString("dd/MM/yyyy HH:mm")).Append("</b><br/><br/>");
			adminMessage.Append(lang.getTranslated("backend.ordini.view.table.label.dta_insert_order")).Append(":&nbsp;<b>").Append(order.insertDate.ToString("dd/MM/yyyy HH:mm")).Append("</b><br/><br/>");				

			userMessage.Append(lang.getTranslated("backend.ordini.view.table.label.attached_prods")).Append("<br/>");		
			adminMessage.Append(lang.getTranslated("backend.ordini.view.table.label.attached_prods")).Append("<br/>");			
			
			StringBuilder orderProducts = new StringBuilder();
			orderProducts.Append("<table border=0 align=top cellpadding=3 cellspacing=0 style=\"border:1px solid #C9C9C9;\">")						
			.Append("<tr>")
			.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(lang.getTranslated("backend.ordini.view.table.header.nome_prod")).Append("</th>")
			.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(lang.getTranslated("backend.ordini.view.table.header.sommario_prod")).Append("</th>")
			.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(lang.getTranslated("backend.ordini.view.table.header.totale_prod")).Append("</th>")
			.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(lang.getTranslated("backend.ordini.view.table.header.totale_tax")).Append("</th>")
			.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(lang.getTranslated("backend.ordini.view.table.header.qta_prod")).Append("</th>")	
			.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(lang.getTranslated("backend.ordini.detail.table.label.fields_prod")).Append("</th>")				
			.Append("</tr>");
			
			if(order.products != null && order.products.Count>0){
				foreach(OrderProduct op in order.products.Values){
					Product prod = productrep.getByIdCached(op.idProduct, true);
					IList<OrderProductField> opfs = orderep.findItemFields(order.id, op.idProduct, op.productCounter);
				
					string adsRefTitle = "";
					if(op.idAds != null && op.idAds>-1){
						Ads a = adsrep.getById(op.idAds);
						if(a != null){
							FContent f = contrep.getByIdCached(a.elementId, true);
							if(f != null){
								adsRefTitle = "<br/><b>"+lang.getTranslated("frontend.carrello.table.label.ads_title")+"</b>&nbsp;"+f.title;
							}
						}
					}
					
					//****** MANAGE SUPPLEMENT DESCRIPTION
					string suppdesc = op.supplementDesc;
					string suppdesctrans = lang.getTranslated("backend.supplement.description.label."+suppdesc);
					if(!String.IsNullOrEmpty(suppdesctrans)){
						suppdesc = suppdesctrans;
					}
					suppdesc = "&nbsp;("+suppdesc+")";	

					string opmargin = "";
					if(op.margin > 0){
						opmargin = "<li>"+lang.getTranslated("frontend.carrello.table.label.commissioni")+":&nbsp;&euro;&nbsp;"+op.margin.ToString("#,###0.00")+"</li>";
					}
					
					string opdiscPerc = "";
					if (op.discountPerc > 0) {
						decimal discountValue = 0-op.discount;
						opdiscPerc ="<li>"+lang.getTranslated("frontend.carrello.table.label.sconto_applicato")+"&nbsp;"+op.discountPerc.ToString("#,###0.##")+"%:&nbsp;&euro;&nbsp;"+discountValue.ToString("#,###0.00")+"</li>";
					}					
					
					//****** MANAGE ORDER RULES FOR PRODUCT
					string orderProdRules = "";
					if (hasProductRule){
						foreach(OrderBusinessRule w in productRules){
							int tmpIdProd = w.productId;
							int tmpCounterProd = w.productCounter;
							if(tmpIdProd==op.idProduct && tmpCounterProd==op.productCounter){
								string tmpLabel = w.label;                 
								decimal tmpAmountRule = w.value;
								orderProdRules+="<li>";
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.businessrule.label.label."+tmpLabel))){
									orderProdRules+=lang.getTranslated("backend.businessrule.label.label."+tmpLabel);
								}else{
									orderProdRules+=tmpLabel;
								}
								if(tmpAmountRule!=0){
									orderProdRules+=":&nbsp;&euro;&nbsp;"+tmpAmountRule.ToString("#,###0.00");
								}
								orderProdRules+="</li>";
							}
						}
					}	
					
					//****** MANAGE FIELDS FOR PRODUCT
					string productFields = "";
					if(opfs != null && opfs.Count>0){
						foreach(OrderProductField opf in opfs){
							string flabel = lang.getTranslated("backend.prodotti.detail.table.label.field_description_"+opf.description+"_"+prod.keyword);
							if(String.IsNullOrEmpty(flabel)){
								flabel = opf.description;
							}
							
							if(opf.fieldType==8){
								productFields+=flabel+":&nbsp;<a target='_blank' href='"+builder.ToString()+"public/upload/files/orders/"+opf.idOrder+"/"+opf.value+"'>"+opf.value+"</a><br/>";
							}else{
								productFields+=flabel+":&nbsp;"+opf.value+"<br/>";
							}
						}
					}				
				
					orderProducts.Append("<tr>")
					.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">")
						.Append(productrep.getMainFieldTranslationCached(op.idProduct, 1 , lang.currentLangCode, true,  op.productName, true).value)
						.Append(adsRefTitle)
					.Append("</td>")
					.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">").Append(productrep.getMainFieldTranslationCached(op.idProduct, 2 , lang.currentLangCode, true,  prod.summary, true).value).Append("</td>")
					.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">")
						.Append("&euro;&nbsp;")
						.Append(op.taxable.ToString("#,###0.00"))
						.Append("<ul style=padding:0px;>")
						.Append(opmargin)
						.Append(opdiscPerc)
						.Append(orderProdRules)
						.Append("</ul>")
					.Append("</td>")
					.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">")
						.Append("&euro;&nbsp;")
						.Append(op.supplement.ToString("#,###0.00"))
						.Append(suppdesc)
					.Append("</td>")
					.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">").Append(op.productQuantity).Append("</td>")	
					.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">")
						.Append(productFields)
					.Append("</td>")					
					.Append("</tr>");
				}  
			}
			orderProducts.Append("</table>");


			userMessage.Append(orderProducts.ToString()).Append("<br/><br/>");		
			adminMessage.Append(orderProducts.ToString()).Append("<br/><br/>");	
			
			userMessage.Append(lang.getTranslated("backend.ordini.view.table.label.tipo_pagam_order")).Append(":&nbsp;<b>").Append(paymentType).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.pagam_order_done")).Append(":&nbsp;<b>").Append(pdone).Append("</b><br/><br/>");

			//****** MANAGE PAYMENT TRANSACTION (ONLY FOR ADMIN EMAIL)
			string paymentTrans = "";
			/*
			Dim objPaymentTrans, objTmpPaymentTransList
			Set objPaymentTrans = new PaymentTransactionClass
			Set objTmpPaymentTransList = objPaymentTrans.getListaOrderPaymentTransaction(id_order)
			for each q in objTmpPaymentTransList
				paymentTrans+="<strong>ID:</strong> "&objTmpPaymentTransList(q).getIdTransaction()&";&nbsp;";
				paymentTrans+="<strong>STATUS:</strong> "&objTmpPaymentTransList(q).getPaymentStatus()&";&nbsp;";
				Select Case objTmpPaymentTransList(q).isNotified()
				Case 0
					paymentTrans+="<strong>NOTIFIED:</strong> "&langEditor.getTranslated("backend.commons.no")&";<br/>";
				Case 1
					paymentTrans+="<strong>NOTIFIED:</strong> "&langEditor.getTranslated("backend.commons.yes")&";<br/>";
				Case Else
				End Select
			next	
			*/
			
			adminMessage.Append(lang.getTranslated("backend.ordini.view.table.label.tipo_pagam_order")).Append(":&nbsp;<b>").Append(paymentType).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.pagam_order_done")).Append(":&nbsp;<b>").Append(pdone).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.list_transaction_order")).Append(":&nbsp;<b>")
				.Append(paymentTrans)
			.Append("</b><br/><br/>");			

			//****** MANAGE ORDER STATUS
			string orderStatus = "";
			if(order.status==1){
				orderStatus = lang.getTranslated("backend.ordini.view.table.label.ord_inserting");
			}else if(order.status==2){
				orderStatus = lang.getTranslated("backend.ordini.view.table.label.ord_executing");
			}else if(order.status==3){
				orderStatus = lang.getTranslated("backend.ordini.view.table.label.ord_executed");
			}else if(order.status==4){
				orderStatus = lang.getTranslated("backend.ordini.view.table.label.ord_sca");
			}		

			//****** MANAGE ORDER FEES
			string orderFees = "";
			if(fees != null && fees.Count>0){
				foreach(OrderFee f in fees){
					string label = f.feeDesc;
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.fee.description.label."+f.feeDesc))){
						label = lang.getTranslated("backend.fee.description.label."+f.feeDesc);
					}
					orderFees+=label+"&nbsp;&nbsp;&nbsp;&euro;&nbsp;"+f.amount.ToString("#,###0.00")+"<br/>";
				}
			}			
			
			userMessage.Append(lang.getTranslated("backend.ordini.view.table.label.stato_order")).Append(":&nbsp;<b>").Append(orderStatus).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.spese_spediz_order")).Append(":&nbsp;<br/><b>").Append(orderFees).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.payment_commission")).Append(":&nbsp;<b>&euro;&nbsp;").Append(paymentCommissions.ToString("#,###0.00")).Append("</b><br/><br/>");
			
			adminMessage.Append(lang.getTranslated("backend.ordini.view.table.label.stato_order")).Append(":&nbsp;<b>").Append(orderStatus).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.spese_spediz_order")).Append(":&nbsp;<br/><b>").Append(orderFees).Append("</b><br/><br/>")
			.Append(lang.getTranslated("backend.ordini.view.table.label.payment_commission")).Append(":&nbsp;<b>&euro;&nbsp;").Append(paymentCommissions.ToString("#,###0.00")).Append("</b><br/><br/>");	

			//****** MANAGE ORDER RULES
			string orderRulesDesc = "";
			if(hasOrderRule){
				foreach(OrderBusinessRule x in orderRules){
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.businessrule.label.label."+x.label))){ 
						orderRulesDesc+=lang.getTranslated("backend.businessrule.label.label."+x.label);
					}else{
						orderRulesDesc+=x.label;
					}
					orderRulesDesc+="&nbsp;&nbsp;&nbsp;<b>&euro;&nbsp;"+x.value.ToString("#,###0.00")+"</b><br/>";
				}
				orderRulesDesc+="<br/>";
				
				userMessage.Append(orderRulesDesc);
				adminMessage.Append("<b>").Append(lang.getTranslated("backend.ordini.view.table.label.business_rules")).Append(":</b><br/>").Append(orderRulesDesc);
			}
			
			userMessage.Append(lang.getTranslated("backend.ordini.view.table.label.totale_order")).Append(":&nbsp;<b>&euro;&nbsp;").Append(orderAmount.ToString("#,###0.00")).Append("</b><br/><br/>");
			adminMessage.Append(lang.getTranslated("backend.ordini.view.table.label.totale_order")).Append(":&nbsp;<b>&euro;&nbsp;").Append(orderAmount.ToString("#,###0.00")).Append("</b><br/><br/>");
			
		
			replacementsUser.Add("<%content%>",Server.HtmlDecode(userMessage.ToString()));
			replacementsAdmin.Add("<%content%>",Server.HtmlDecode(adminMessage.ToString()));
			
			MailService.prepareAndSend("order-confirmed", lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacementsUser, null, builder.ToString());
			MailService.prepareAndSend("order-confirmed", lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacementsAdmin, null, builder.ToString());				

			
		}catch(Exception ex){
			StringBuilder builder = new StringBuilder("Exception: ")
			.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
			Logger log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
			lrep.write(log);			
		}
	}
}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<META name="description" CONTENT="">
<META name="keywords" CONTENT="">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>
		<div id="content-center">
			<div id="carrello-lista">   
				<div id="prodotto-conto">
					<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_id_ordine")%>: <strong><%=orderid%></strong></div>
					<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_to_do_1")%>: <strong><%=paymentType%></strong></div>
					<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_pagam_done")%>: <strong><%=pdone%></strong></div>
					<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_spese_sped")%>: <strong>&euro; <%=billsAmount.ToString("#,###0.00")%></strong></div>
					<%if(hasOrderRule){
						foreach(OrderBusinessRule x in orderRules){
							string orLabel = x.label;
							if(!String.IsNullOrEmpty(lang.getTranslated("backend.businessrule.label.label."+orLabel))){ 
								orLabel = lang.getTranslated("backend.businessrule.label.label."+orLabel);
							}%>
							<div class="spese-div"><%=orLabel%>:&nbsp;<strong>&euro;&nbsp;<%=x.value.ToString("#,###0.00")%></strong></div>
						<%}
					}%>
					<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_payment_commission")%>: <strong>&euro;  <%=paymentCommissions.ToString("#,###0.00")%></strong></div>
					<div id="spese-totale"><%=lang.getTranslated("frontend.carrello.table.label.confirm_tot_ord")%>: <strong>&euro;  <%=orderAmount.ToString("#,###0.00")%></strong></div>
					
					<%if(paymentDone){%>					
						<h2><%=lang.getTranslated("frontend.carrello.table.label.ordine_complete")%></h2>
						<p><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_complete")%></p>
					<%}else{%>
						<h2><%=lang.getTranslated("frontend.carrello.table.label.ordine_complete")%></h2>
						<p><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_to_do_2")%></p>
					<%}%>
				</div>
			</div>	
		</div>
		<br style="clear: left" />
		<div>
		<MenuFrontendControl:insert runat="server" ID="mf5" index="5" model="horizontal"/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>
