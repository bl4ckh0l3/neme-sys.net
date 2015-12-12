<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Text.RegularExpressions" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;
protected FContent content;
protected Product product;
protected bool hasComments;
protected IContentRepository contrep;
protected IProductRepository productrep;
protected IUserRepository usrrep;
protected IUserPreferencesRepository preferencerep;
protected IList<Comment> comments;
protected string mode;
protected int elementType;
protected bool logged;
protected int elementId;
protected string elementDesc;

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
	login.acceptedRoles = "1,2";
	logged = login.checkedUser();
	ICommonRepository commonrep = RepositoryFactory.getInstance<ICommonRepository>("ICommonRepository");
	ICommentRepository commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
	preferencerep = RepositoryFactory.getInstance<IUserPreferencesRepository>("IUserPreferencesRepository");
	contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
	productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
	StringBuilder url = new StringBuilder("/error.aspx?error_code=");
	hasComments = false;
	comments = new List<Comment>();
	mode = "view";
	elementType = 0;
	content = new FContent();
	product = new Product();
	elementId = -1;
	elementDesc = "";
	
	if(logged){		
		if(!String.IsNullOrEmpty(Request["mode"])){
			mode = Request["mode"];
		}
		
		if(!String.IsNullOrEmpty(Request["element_type"])){
			elementType = Convert.ToInt32(Request["element_type"]);
		}
		
		try
		{
			if(mode=="view" || mode=="insert"){
				if(elementType==1){
					content = contrep.getById(Convert.ToInt32(Request["id_element"]));
					elementId = content.id;
					elementDesc = content.title;
				}else if(elementType==2){
					product = productrep.getById(Convert.ToInt32(Request["id_element"]));
					elementId = product.id;
					elementDesc = product.name;
				}
				
			}
					
			//check for comments
			comments = commentrep.find(0,elementId,elementType,null);
			if(comments != null && comments.Count>0){
				hasComments = true;
			}
		}
		catch(Exception ex)
		{
			Response.Write(ex.Message);
			content=null;
			product=null;
			hasComments = false;
			comments = new List<Comment>();
		}
	}	
}
</script>

<%if(logged){%>
	<script>
	function manageComments(id_element,id_comment,element_type,operation,container){	
		var query_string = "id_element="+id_element+"&id_comment="+id_comment+"&element_type="+element_type+"&operation="+operation;

		if(operation=="insert"){
			if($('#comment_message').val() == ""){
				alert("<%=lang.getTranslated("frontend.popup.js.alert.insert_commento")%>");
				return;
			}			
		
			query_string+= "&message="+encodeURIComponent($('#comment_message').val())+"&comment_type="+$('#comment_type').val()+"&active="+$('#active').val();
		}

		//alert(query_string);
		
		$.ajax({
			async: false,
			type: "POST",
			cache: false,
			url: "/backoffice/include/ajaxmanagecomments.aspx",
			data: query_string,
			success: function(response) {
				if(response==1){
					if(operation=="insert"){
						alert("<%=lang.getTranslated("frontend.popup.label.comment_posted")%>");
						$('#'+container).hide();
					}else if(operation=="unlock"){
						$('#unlock_'+id_comment).hide();						
					}else if(operation=="delete"){
						$('#comment_item_'+id_comment).hide();
					}else if(operation=="unlockvote"){
						$('#unlock_vote_'+id_comment).hide();						
					}else if(operation=="deletevote"){
						$('#vote_item_'+id_comment).hide();
					}
				}else{
					alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");
				}
			},
			error: function(response) {
				//alert(response.responseText);
				alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");				
			}
		});	
	}

	function editElement(id, elementType){
		if(elementType==1){
			location.href='/backoffice/contents/insertcontent.aspx?cssClass=LN&id='+id;
		}else if(elementType==2){
			location.href='/backoffice/products/insertproduct.aspx?cssClass=LP&id='+id;
		}
	}
	</script>	
	<%if(hasComments) {
		int elemId = -1;
		string elemDesc = "";
		if(elementId>0 && (mode=="view" || mode=="insert")){
			elemId = elementId;
			Response.Write("<b>"+elementDesc+"</b><br/><br/>");
			
			if(mode=="insert"){%>
				<div align="center" style="padding-bottom:20px;text-align:left;vertical-align:top;">
				<form action="/area_user/insertcomment.aspx" method="post" name="form_comment" accept-charset="UTF-8">		  
					<input type="hidden" id="id_element" name="id_element" value="<%=elemId%>">
					<input type="hidden" id="element_type" name="element_type" value="<%=elementType%>">
					
					<div style="float:left;padding-right:20px;"><span class="labelForm"><%=lang.getTranslated("frontend.popup.label.insert_commento")%></span><br>
						<textarea class="formFieldTXTTextareaComment" name="message" id="comment_message" onclick="$('#comment_message').focus();"></textarea>
					</div> 

					<div style="float:top;"><span class="labelForm"><%=lang.getTranslated("frontend.area_user.manage.label.like")%></span><br>
						<select name="comment_type" id="comment_type">
							<OPTION VALUE="1"><%=lang.getTranslated("portal.commons.yes")%></OPTION>
							<OPTION VALUE="0"><%=lang.getTranslated("portal.commons.no")%></OPTION>
						</select>	
					</div>

					<div style="float:top;"><span class="labelForm"><%=lang.getTranslated("frontend.area_user.manage.label.active")%></span><br>
					<select name="active" id="active">
						<OPTION VALUE="1"><%=lang.getTranslated("portal.commons.yes")%></OPTION>
						<OPTION VALUE="0"><%=lang.getTranslated("portal.commons.no")%></OPTION>
					</select>			
					</div>
					<input type="button" name="send" style="margin-left:0px;margin-top:10px;" value="<%=lang.getTranslated("frontend.popup.label.insert_commento")%>" onclick="javascript:manageComments(<%=content.id%>,'',<%=elementType%>,'insert','<%=Request["container"]%>');">	
				</form><br/>
				</div>
			<%}
		}
		
		foreach(Comment comment in comments){%>
			<div id="comment_item_<%=comment.id%>" style="margin-bottom:5px;">
			<%
			
			User user = usrrep.getById(comment.userId);
			if(mode=="manage"){
				if(comment.elementType==1){
					content = contrep.getById(comment.elementId);
					elemId = content.id;
					elemDesc = content.title;
				}else if(comment.elementType==2){
					product = productrep.getById(comment.elementId);
					elemId = product.id;
					elemDesc = product.name;					
				}
				%>
				<a href="javascript:editElement(<%=elemId%>,<%=comment.elementType%>);" style="color:#000000;"><b><%=elemDesc%></b></a><br/><br/>
			<%}%>
		
			<%=comment.insertDate.ToString("dd/MM/yyyy HH:mm")%>
			<a href="javascript:manageComments(<%=elemId%>,<%=comment.id%>,<%=comment.elementType%>,'delete','<%=Request["container"]%>');"><img src="/backoffice/img/cancel.png" vspace="0" hspace="2" border="0" align="absmiddle"></a>&nbsp;&nbsp;
			<%if(!comment.active) {%>
				<a href="javascript:manageComments(<%=elemId%>,<%=comment.id%>,<%=comment.elementType%>,'unlock','<%=Request["container"]%>');" title="<%=lang.getTranslated("portal.templates.commons.label.comment_unlock")%>"><img id="unlock_<%=comment.id%>" src="/backoffice/img/lock_open.png" vspace="0" hspace="2" border="0" align="absmiddle" alt="<%=lang.getTranslated("portal.templates.commons.label.comment_unlock")%>"></a>
			<%}%><br/>
			<%="<i>"+user.username+"</i>"%>
			<br><%=comment.message%><br>
			</div>
			
			<%
			IList<Preference> objLPC = preferencerep.find(-1, comment.userId, comment.id, comment.elementType, null, "false", "false");
			if(objLPC != null && objLPC.Count>0){
				foreach(Preference h in objLPC){
					string cusername = "";
					User committer = usrrep.getById(h.userId);
					if(committer!= null){cusername = committer.username;}%>
					<div id="vote_item_<%=h.id%>" style="background-color:#EEEEEE;border: 1px solid #E3E3E3;padding:2px;margin-bottom:5px;">
						<%=h.insertDate.ToString("dd/MM/yyyy HH:mm")%>
						<a href="javascript:manageComments(<%=elemId%>,<%=h.id%>,<%=comment.elementType%>,'deletevote','<%=Request["container"]%>');"><img src="/backoffice/img/cancel.png" vspace="0" hspace="2" border="0" align="absmiddle"></a>&nbsp;&nbsp;
						<%if(!h.active) {%>
							<a href="javascript:manageComments(<%=elemId%>,<%=h.id%>,<%=comment.elementType%>,'unlockvote','<%=Request["container"]%>');" title="<%=lang.getTranslated("portal.templates.commons.label.comment_unlock")%>"><img id="unlock_vote_<%=h.id%>" src="/backoffice/img/lock_open.png" vspace="0" hspace="2" border="0" align="absmiddle" alt="<%=lang.getTranslated("portal.templates.commons.label.comment_unlock")%>"></a>
						<%}%><br/>
						<%="<i>"+cusername+"</i>"%>
						<br><%=h.message%>				
					</div>
				<%}
			}%>	
			<hr>		
		<%}%>
		<br/>
	<%}else{
		Response.Write("<div align='center'>"+lang.getTranslated("frontend.popup.label.no_comments")+"</div><br>");
	}
}%>