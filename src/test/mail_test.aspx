<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.database" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="System.Net.Mail" %>
<%@ import Namespace="System.Net.Mime" %>

<script runat="server">
IMailRepository mailrepository = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
//MailService mailservice = new MailService();
protected MailMsg mail;
protected MailMessage msg;
protected void Page_Load(Object sender, EventArgs e)
{
	try
	{
		//mail = mailrepository.getByName("test-body-text");
		
		ListDictionary replacements = new ListDictionary();
		replacements.Add("<%marker1%>","bella li funziona");
		replacements.Add("mail_sender","admin@blackholenet.com");
		msg = MailService.prepareMessage("test-body-text", null, replacements, null);
		//Response.Write("msg: "+msg.ToString()+"<br><br>");
		MailService.send(msg);
		
		/*msg = MailService.prepareMessage("test-body-html", replacements);
		Response.Write("msg: "+msg.ToString()+"<br><br>");
		MailService.send(msg);*/
		Attachment attach1 = new Attachment(System.Web.HttpContext.Current.Server.MapPath("/common/img/body-bg.jpg"), "image/jpeg");
		IList<Attachment> attachments = new List<Attachment>();
		attachments.Add(attach1);
		MailService.prepareAndSend("test-body-html", null, replacements, attachments);	
		
		// inserisco nuovo massage template:
		MailMsg newmmsg = new MailMsg();
		newmmsg.name = "test-inner-body";
		newmmsg.description = "test-inner-body desc";
		newmmsg.sender = "info@test.it";
		newmmsg.receiver = "inforec@test.it";
		newmmsg.modifyDate = DateTime.Now;
		mailrepository.insert(newmmsg);
	}
	    catch (Exception ex)
	{
	     Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
	
}
</script>
<html>
<head>
</head>
<body>
    <h2>Mail Report </h2>
    
    <%	
		/*if(mail != null)
		{
			Response.Write("mail: "+mail.ToString()+"<br><br>");
			Response.Write("mail != null: "+(mail != null)+"<br><br>");
			Response.Write("mail typeof: "+mail.GetType()+"<br><br>");
		}else{
			Response.Write("mail == null<br>");
		}
		if(msg != null)
		{
			Response.Write("msg: "+msg.ToString()+"<br><br>");
			Response.Write("msg != null: "+(msg != null)+"<br><br>");
			Response.Write("msg typeof: "+msg.GetType()+"<br><br>");
		}else{
			Response.Write("msg == null<br>");
		}*/	
	%>
</body>
</html>