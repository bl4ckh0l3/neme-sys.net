<%@ Page Language="C#" %>
<%@ Register Assembly="FredCK.FCKeditorV2" Namespace="FredCK.FCKeditorV2" TagPrefix="FCKeditorV2" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<script runat="server">
	protected void Page_Load( object sender, EventArgs e )
	{
		// Set the base path. This is the URL path for the FCKeditor
		// installations. By default "/fckeditor/".
		//mail_body.BasePath = "/fckeditor/";

		// Set the startup editor value.
		//mail_body.Value = "<p>This is some <strong>sample text</strong>. You are using <a href=\"http://www.fckeditor.net/\">FCKeditor</a>.</p>";
	}
</script>
<FCKeditorV2:FCKeditor ID="mail_body" ImageBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" LinkBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" Width="600px" Height="300px" runat="server"></FCKeditorV2:FCKeditor><!-- ImageBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=connectors/aspx/connector.aspx" LinkBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=connectors/aspx/connector.aspx"  -->
