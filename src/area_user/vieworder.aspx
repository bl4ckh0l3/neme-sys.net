<%@ Page Language="C#" AutoEventWireup="true" Debug="true"%>
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
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="3" />
<script runat="server">
private ASP.MultiLanguageControl lang;

protected IOrderRepository orderep;
protected IProductRepository productrep;
protected ICommentRepository commentrep;
protected ConfigurationService confservice;
protected int orderid;
protected string paymentType;
protected bool paymentDone;
protected decimal billsAmount;
protected decimal paymentCommissions;
protected decimal orderAmount;
protected string pdone;
protected FOrder order;
protected IList<OrderFee> fees;
protected OrderShippingAddress oshipaddr;
protected ShippingAddress shipaddr;
protected OrderBillsAddress obillsaddr;
protected BillsAddress billsaddr;
protected UriBuilder builder;
protected bool hasShipAddress;
protected bool hasBillsAddress;
protected string orderStatus;
protected string orderFees;
protected string shipInfo;
protected string billsInfo;
protected string orderRulesDesc;
protected string orderProdRulesDesc;
protected IList<OrderBusinessRule> orderRules;
protected IList<OrderBusinessRule> productRules;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}

protected void Page_Load(object sender, EventArgs e)
{
	lang.set();

	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	

	IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IShippingAddressRepository shiprep = RepositoryFactory.getInstance<IShippingAddressRepository>("IShippingAddressRepository");
	IBillsAddressRepository billsrep = RepositoryFactory.getInstance<IBillsAddressRepository>("IBillsAddressRepository");
	IContentRepository contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
	IMailRepository mailrep = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
	IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
	IBusinessRuleRepository brulerep = RepositoryFactory.getInstance<IBusinessRuleRepository>("IBusinessRuleRepository");
	productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
	confservice = new ConfigurationService();
	
	orderid = -1;
	paymentType = "";
	paymentDone = false;
	billsAmount = 0.00M;
	paymentCommissions = 0.00M;
	orderAmount = 0.00M;
	pdone = "";
	order = null;
	fees = null;
	hasShipAddress = false;
	hasBillsAddress = false;
	oshipaddr = null;
	shipaddr = null;
	obillsaddr = null;
	billsaddr = null;
	orderStatus = "";
	orderFees = "";
	shipInfo = "";
	billsInfo = "";
	orderRulesDesc = "";
	orderProdRulesDesc = "";
	orderRules = null;
	productRules = null;
	IDictionary<int,string> statusOrder = OrderService.getOrderStatus();
	
	if(!String.IsNullOrEmpty(Request["orderid"])){	
		try{
			orderid = Convert.ToInt32(Request["orderid"]);
			order = orderep.getByIdExtended(orderid, true);
			
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

			//****** MANAGE ORDER FEES
			fees = orderep.findFeesByOrderId(orderid);
			if(fees != null && fees.Count>0){
				foreach(OrderFee f in fees){
					string label = f.feeDesc;
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.fee.description.label."+f.feeDesc))){
						label = lang.getTranslated("backend.fee.description.label."+f.feeDesc);
					}
					orderFees+=label+"&nbsp;&nbsp;&nbsp;&euro;&nbsp;"+f.amount.ToString("#,###0.00")+"<br/>";
				}
			}

			//****** MANAGE ORDER STATUS
			if(order.status==1){
				orderStatus = statusOrder[order.status];
				if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+orderStatus))){
					orderStatus = lang.getTranslated("backend.ordini.view.table.label."+orderStatus);
				}
			}else if(order.status==2){
				orderStatus = statusOrder[order.status];
				if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+orderStatus))){
					orderStatus = lang.getTranslated("backend.ordini.view.table.label."+orderStatus);
				}
			}else if(order.status==3){
				orderStatus = statusOrder[order.status];
				if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+orderStatus))){
					orderStatus = lang.getTranslated("backend.ordini.view.table.label."+orderStatus);
				}
			}else if(order.status==4){
				orderStatus = statusOrder[order.status];
				if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+orderStatus))){
					orderStatus = lang.getTranslated("backend.ordini.view.table.label."+orderStatus);
				}
			}
			
			//****** MANAGE SHIPPING ADDRESS
			oshipaddr = orderep.getOrderShippingAddressCached(orderid, true);
			if(oshipaddr != null){
				hasShipAddress = true;
				shipaddr = shiprep.getByIdCached(oshipaddr.idShipping, true);
			}
			
			if(hasShipAddress){
				string userLabelIsCompanyClient = "";
				if(oshipaddr.isCompanyClient){
					userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_company");
				}else{
					userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_private");
				}								
				
				shipInfo = shipaddr.name + " " + shipaddr.surname + " ("+userLabelIsCompanyClient+") - " + shipaddr.cfiscvat + " - " +oshipaddr.address +" - "+oshipaddr.city+" ("+oshipaddr.zipCode+") - "+lang.getTranslated("portal.commons.select.option.country."+oshipaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+oshipaddr.stateRegion);
			}	
			
			//****** MANAGE BILLS ADDRESS
			obillsaddr = orderep.getOrderBillsAddressCached(orderid, true);
			if(obillsaddr != null){
				hasBillsAddress = true;
				billsaddr = billsrep.getByIdCached(obillsaddr.idBills, true);
			}
			
			if(hasBillsAddress){
				billsInfo = billsaddr.name + " " + billsaddr.surname + " - " + billsaddr.cfiscvat + " - " +obillsaddr.address +" - "+obillsaddr.city+" ("+obillsaddr.zipCode+") - "+lang.getTranslated("portal.commons.select.option.country."+obillsaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+obillsaddr.stateRegion);
			}

			//****** MANAGE ORDER RULES		
			orderRules = orderep.findOrderBusinessRule(orderid, false);
			if(orderRules != null && orderRules.Count>0){
				foreach(OrderBusinessRule x in orderRules){
					string orLabel = x.label;
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.businessrule.label.label."+orLabel))){ 
						orLabel=lang.getTranslated("backend.businessrule.label.label."+orLabel);
					}
					orderRulesDesc+="<span class=\"labelForm\">"+orLabel+":</span>&nbsp;&euro;&nbsp;"+x.value.ToString("#,###0.00")+"<br/>";
				}
				orderRulesDesc+="<br/>";
			}
			
			builder = new UriBuilder(Request.Url);
			builder.Scheme = "http";
			builder.Port = -1;
			builder.Path="";
			builder.Query="";
		}catch(Exception ex){
			//Response.Write(ex.Message+"<br><br><br>"+ex.StackTrace);
			
			StringBuilder builder = new StringBuilder("Exception: ")
			.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
			Logger log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
			lrep.write(log);
		}
	}
	
	if(order != null && "insert_comment".Equals(Request["operation"])){
		int elementId = Convert.ToInt32(Request["id_element"]);
		int active = Convert.ToInt32(Request["active"]);
		int comment_type = Convert.ToInt32(Request["comment_type"]);
		string message = Request["message"];
		
		try
		{
			if(!String.IsNullOrEmpty(message)){
				Comment comment = new Comment();
				comment.message = message;
				comment.elementId = elementId;
				comment.elementType = 2;
				comment.voteType = comment_type;
				comment.userId = order.userId;
				comment.active = Convert.ToBoolean(active);
				comment.insertDate = DateTime.Now;		
				commentrep.insert(comment);
				
				if("1".Equals(confservice.get("use_comments_filter").value) && !String.IsNullOrEmpty(confservice.get("mail_comment_receiver").value)) {
					try
					{	
						FContent content = contentrep.getByIdCached(comment.elementId, true);
						User user = usrrep.getById(order.userId);
								
						MailMsg mtemplate = mailrep.getByName("confirm-comment", lang.currentLangCode, "true");
						ListDictionary replacements = new ListDictionary();
						
						StringBuilder newsContent = new StringBuilder();
						newsContent.Append("<h2>").Append(lang.getTranslated("frontend.confirm_comment.mail.label.intro")).Append("</h2>").Append("<br/><br/>");
						newsContent.Append("<div style=\"padding-bottom:15px;\"><b>").Append(lang.getTranslated("portal.commons.label.user_comment")).Append("</b>:&nbsp;<i>").Append(user.username).Append("</i></div>");
						newsContent.Append("<div style=\"padding-bottom:15px;\"><b>").Append(lang.getTranslated("portal.commons.label.comment_elem_title")).Append("</b>:&nbsp;").Append(content.title).Append("</div>");
						newsContent.Append("<p align=\"left\">");	
						newsContent.Append(comment.insertDate.ToString("dd/MM/yyyy HH:mm")).Append("<br/>");
						newsContent.Append(comment.message);
						newsContent.Append("</p>");
						newsContent.Append("<hr><br/><br/><a href=\"").Append(builder.ToString()).Append("common/include/confirmcomment.aspx?id_comment=").Append(comment.id).Append("\">").Append(lang.getTranslated("backend.confirm_comment.mail.label.confirm")).Append("</a><br/><br/>");
						
						replacements.Add("mail_receiver",confservice.get("mail_comment_receiver").value);				
						replacements.Add("<%content%>",newsContent.ToString());						
						MailService.prepareAndSend(mtemplate.name, lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, builder.ToString());				
					}catch(Exception ex){
						//Response.Write(ex.Message);
						throw;
					}
				}
			}
		}catch(Exception ex){
			//Response.Write(ex.Message);
		}
		
		Response.Redirect("/area_user/vieworder.aspx?orderid="+order.id);
	}	
}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<link rel="stylesheet" href="/public/layout/css/area_user.css" type="text/css">
<script language="JavaScript">
var commentWidgetX = 0;
var commentWidgetY = 0;

jQuery(document).ready(function(){
	$(document).mousemove(function(e){
		commentWidgetX = e.pageX;
		commentWidgetY = e.pageY;
	}); 
})

function prepareComment(elemid){		
	var divcomment = document.getElementById("send-comment");
	var offsetx   = 400;
	var offsety   = 50;	
	  
	if(ie||mac_ie){
		divcomment.style.left=commentWidgetX-offsetx;
		divcomment.style.top=commentWidgetY-offsety;
	}else{
		divcomment.style.left=commentWidgetX-offsetx+"px";
		divcomment.style.top=commentWidgetY-offsety+"px";
	}
	
	$("#send-comment").show(1000);
	divcomment.style.visibility = "visible";
	divcomment.style.display = "block";
	
	document.form_comment.id_element.value=elemid;
}

function sendForm(){    
	if(document.form_comment.comment_message.value == ""){
		alert("<%=lang.getTranslated("frontend.popup.js.alert.insert_commento")%>");
		return;
	}else{
		document.form_comment.submit();	
	}
}
  
$(function() {
	$("#send-comment").draggable();
});
  
function hideCommentform(){
	var divcomment = document.getElementById("send-comment");
	divcomment.style.visibility = "hidden";
	divcomment.style.display = "none";
	document.form_comment.id_element.value="";
}
</script>
</head>
<body>
<div id="send-comment" style="z-index:1000000;position:absolute;left:-0px;top:0px;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;">
	<form action="/area_user/vieworder.aspx" method="post" name="form_comment" accept-charset="UTF-8">		  
		<input type="hidden" name="id_element" value="">
		<input type="hidden" name="operation" value="insert_comment">
		<input type="hidden" name="orderid" value="<%=Request["orderid"]%>">
		<input type="hidden" name="active" value="<%if("1".Equals(confservice.get("use_comments_filter").value)) {Response.Write("0");}else{Response.Write("1");}%>">   
		
		<p align="right"><a href="javascript:hideCommentform();">x</a></p>
		  
		<div style="float:top;"><span class="labelForm"><%=lang.getTranslated("frontend.popup.label.insert_commento")%></span><br>
			<textarea class="formFieldTXTTextareaComment" name="message" id="comment_message" onclick="$('#comment_message').focus();"></textarea>
		</div> 
		<div><span><%=lang.getTranslated("frontend.area_user.manage.label.like")%></span><br>
			<select name="comment_type" id="comment_type">
				<OPTION VALUE="1"><%=lang.getTranslated("portal.commons.yes")%></OPTION>
				<OPTION VALUE="0"><%=lang.getTranslated("portal.commons.no")%></OPTION>
			</select>&nbsp;&nbsp;	
			<input type="button" name="send" style="margin-left:70px;" value="<%=lang.getTranslated("frontend.popup.label.insert_commento")%>" onclick="javascript:sendForm();">		
		</div>
	</form>
</div>

<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>	
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>	
		<div id="backend-content">	
			<%if(order != null){%>
				<table border="0" cellspacing="0" cellpadding="3" class="principal">							
					<tr>
					<th><%=lang.getTranslated("frontend.area_user.ordini.table.prod.header.nome_prod")%></th>
					<th><%=lang.getTranslated("frontend.area_user.ordini.table.prod.header.totale_prod")%></th>
					<th><%=lang.getTranslated("frontend.area_user.ordini.table.prod.header.tax_prod")%></th>
					<th><%=lang.getTranslated("frontend.area_user.ordini.table.prod.header.qta_prod")%></th>
					<th>&nbsp;</td>			
					</tr>
	
					<%
					int intCount = 0;
					if(order.products != null && order.products.Count>0){
						foreach(OrderProduct op in order.products.Values){
							Product prod = productrep.getByIdCached(op.idProduct, true);
							IList<OrderProductField> opfs = orderep.findItemFields(order.id, op.idProduct, op.productCounter);
							orderProdRulesDesc = "";
						
							//****** MANAGE SUPPLEMENT DESCRIPTION
							string suppdesc = op.supplementDesc;
							string suppdesctrans = lang.getTranslated("backend.supplement.description.label."+suppdesc);
							if(!String.IsNullOrEmpty(suppdesctrans)){
								suppdesc = suppdesctrans;
							}
							suppdesc = "&nbsp;("+suppdesc+")";		
							
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
			
							//****** MANAGE ORDER RULES FOR PRODUCT
							productRules = orderep.findOrderBusinessRule(orderid, true);
							if(productRules != null && productRules.Count>0){
								foreach(OrderBusinessRule w in productRules){
									int tmpIdProd = w.productId;
									int tmpCounterProd = w.productCounter;
									if(tmpIdProd==op.idProduct && tmpCounterProd==op.productCounter){
										string tmpLabel = w.label;                 
										decimal tmpAmountRule = w.value;
										orderProdRulesDesc+="<li>";
										if(!String.IsNullOrEmpty(lang.getTranslated("backend.businessrule.label.label."+tmpLabel))){
											orderProdRulesDesc+=lang.getTranslated("backend.businessrule.label.label."+tmpLabel);
										}else{
											orderProdRulesDesc+=tmpLabel;
										}
										if(tmpAmountRule!=0){
											orderProdRulesDesc+=":&nbsp;&euro;&nbsp;"+tmpAmountRule.ToString("#,###0.00");
										}
										orderProdRulesDesc+="</li>";
									}
								}
							}%>				
						
							<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=intCount%>">
								<td>
									<%=productrep.getMainFieldTranslationCached(op.idProduct, 1 , lang.currentLangCode, true,  op.productName, true).value%><br/><br/>
									<%=productFields%>
								</td>
								<td>
									&euro;&nbsp;<%=op.taxable.ToString("#,###0.00")%>
									<ul style="padding-left:10px;">
									<%string opmargin = "";
									if(op.margin > 0){%>
										<li><%=lang.getTranslated("frontend.carrello.table.label.commissioni")%>:&nbsp;&euro;&nbsp;<%=op.margin.ToString("#,###0.00")%></li>
									<%}%>
									<%if (op.discountPerc > 0) {
										decimal discountValue = 0-op.discount;%>
										<li><%=lang.getTranslated("frontend.carrello.table.label.sconto_applicato")%>&nbsp;<%=op.discountPerc.ToString("#,###0.##")%>%:&nbsp;&euro;&nbsp;<%=discountValue.ToString("#,###0.00")%></li>
									<%}%>
									<%=orderProdRulesDesc%>
									</ul>
								</td>
								<td>&euro;&nbsp;<%=op.supplement.ToString("#,###0.00")+suppdesc%></td>
								<td><%=op.productQuantity%></td>
								<td>
									<%
									bool canComment = true;
									
									if(!order.paymentDone){
										canComment = false;
									}
									
									IList<Comment> comments = commentrep.find(order.userId, op.idProduct, 2, null);	
									if (canComment && comments != null && comments.Count>0){
										DateTime orderDate = order.insertDate;
										foreach(Comment c in comments){
											DateTime commentDate = c.insertDate;
				
											if (DateTime.Compare(commentDate, orderDate)>=0) {	
												canComment = false;
												break;
											}										
										}
									}
									
									if (canComment){%>
										<a href="javascript:prepareComment('<%=op.idProduct%>');" title="<%=lang.getTranslated("frontend.area_user.ordini.table.prod.label.insert_comment")%>"><img src="/common/img/comment_add.png" hspace="0" vspace="0" border="0" alt="<%=lang.getTranslated("frontend.area_user.ordini.table.prod.label.insert_comment")%>"></a>
									<%}else{ 
										Response.Write("&nbsp;");
									}%>							
								</td>		
							</tr>
						<%intCount++;
						}
					}%>					
					
				</table>			
				
				<div style="margin-top:10px;">
					<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.id_ordine")%>:</span>&nbsp;<%=order.id%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.ordini.view.table.label.guid_ordine")%>:</span>&nbsp;<%=order.guid%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.dta_insert_order")%>:</span>&nbsp;<%=order.insertDate.ToString("dd/MM/yyyy HH:mm")%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.tipo_pagam_order")%>:</span>&nbsp;<%=paymentType%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.pagam_order_done")%>:</span>&nbsp;<%=pdone%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.stato_order")%>:</span>&nbsp;<%=orderStatus%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.spese_spediz_order")%>:</span><br/><%=orderFees%><br/>
					<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.payment_commission")%>:</span>&nbsp;&euro;&nbsp;<%=paymentCommissions.ToString("#,###0.00")%><br/><br/>
					<%=orderRulesDesc%>
					<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.totale_order")%>:</span>&nbsp;&euro;&nbsp;<%=orderAmount.ToString("#,###0.00")%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.shipping_address")%>:</span><br/><%=shipInfo%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.bills_address")%>:</span><br/><%=billsInfo%><br/><br/>	
				</div>
			<%}%>
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