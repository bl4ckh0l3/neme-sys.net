<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Register Assembly="FredCK.FCKeditorV2" Namespace="FredCK.FCKeditorV2" TagPrefix="FCKeditorV2" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<script runat="server">
protected int id_objref;
protected int mainField;
protected string langCode;
protected string optype;
protected string fieldShow;
protected string fieldHide;

public ASP.BoMultiLanguageControl lang;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
		
	IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log;
	StringBuilder builder;
	ProductMainFieldTranslation pmft;
	Product product;

	try
	{
		id_objref = Convert.ToInt32(Request["id_objref"]);
		mainField = Convert.ToInt32(Request["main_field"]);
		langCode = Request["plang_code"];
		optype = Request["optype"];
		fieldShow = Request["field_show"];
		fieldHide = Request["field_hide"];
		string useDef = Request["use_def"];	
		string defValue = Request["def_val"];
		string fieldValue = Request["field_val"];
	
		/*
		Response.Write("id_objref: "+id_objref+"<br>");
		Response.Write("mainField: "+mainField+"<br>");
		Response.Write("langCode: "+langCode+"<br>");
		Response.Write("optype: "+optype+"<br>");
		Response.Write("fieldShow: "+fieldShow+"<br>");
		Response.Write("fieldHide: "+fieldHide+"<br>");
		Response.Write("useDef: "+useDef+"<br>");
		Response.Write("fieldValue: "+fieldValue+"<br>");
		*/
		
		switch (optype)
		{
		case "find":	
			pmft = prodrep.getMainFieldTranslation(id_objref, mainField, langCode, Convert.ToBoolean(Convert.ToInt32(useDef)), defValue);	
			if(pmft != null && !String.IsNullOrEmpty(pmft.value)){
				Response.Write(pmft.value.Trim());
			}
			break;
		case "show":
			pmft = prodrep.getMainFieldTranslation(id_objref, mainField , langCode, Convert.ToBoolean(Convert.ToInt32(useDef)), defValue);	
			if(pmft != null && !String.IsNullOrEmpty(pmft.value)){
				field_val.Value = pmft.value.Trim();
			}
			
			if(mainField==2){
				field_val.Height = 200;
			}else if(mainField==3){
				field_val.Height = 400;			
			}
			break;
		default:		
			fieldValue = fieldValue.Trim();
			fieldValue = fieldValue.Replace("<br type=&quot;_moz&quot; />","")
			.Replace("<br type=\"_moz\" />","")
			.Replace("&lt;br type=&quot;_moz&quot; /&gt;","")
			.Replace("&lt;br /&gt;","<br />");
			if(fieldValue=="<br />"){fieldValue="";}	
			fieldValue = HttpUtility.HtmlDecode(fieldValue);
	
			pmft = new ProductMainFieldTranslation();
			pmft.idParentProduct = id_objref;
			pmft.mainField = mainField;
			pmft.langCode = langCode;
			pmft.value = fieldValue;
			prodrep.saveMainFieldTranslation(pmft, id_objref, mainField, langCode);
			break;
		}
	}
	catch(Exception ex)
	{
		builder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		Response.StatusCode = 400;
	}
}
</script>
<%if(optype=="show"){%>
<HTML>
<head>
<style>
body {       
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	color: #000000;
	text-decoration: none;
	background-color: #FFFFFF;
	margin: 0px;
	padding: 0px;
}
</style>
<script>
function showHideTransField(fieldHide, fieldShow){
	parent.top.$("#"+fieldShow).hide();
	parent.top.$('#loading_zoom_'+fieldShow).show();
	parent.top.$("[id*='ml_"+fieldShow+"_']").attr('style', "border:none;");
	parent.top.$('#loading_zoom_'+fieldShow).hide();
	parent.top.$("#"+fieldHide).show();	
}
</script>
</head>
<BODY>
<div id="base_prod_fck">
	<form method="post" name="fckprodtransupdate" action="/backoffice/products/ajaxprodtransupdate.aspx" accept-charset="UTF-8" border="0">					
		<input type="hidden" name="id_objref" value="<%=id_objref%>">
		<input type="hidden" name="main_field" value="<%=mainField%>">		
		<input type="hidden" name="plang_code" value="<%=langCode%>">					
		<input type="hidden" name="optype" value="write">
		<FCKeditorV2:FCKeditor ID="field_val" ImageBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" LinkBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" Height="200px" runat="server"></FCKeditorV2:FCKeditor>
		<div align="right">
			<input type="button" class="buttonForm" hspace="2" vspace="0" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.prodotti.detail.button.inserisci.label")%>" onclick="javascript:document.fckprodtransupdate.submit();showHideTransField('<%=fieldHide%>', '<%=fieldShow%>');" />
			<input type="button" class="buttonForm" hspace="2" vspace="0" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.prodotti.detail.button.annulla.label")%>" onclick="javascript:showHideTransField('<%=fieldHide%>', '<%=fieldShow%>');" />
		</div>
	</form>
</div>
</BODY>
</HTML>
<%}%>