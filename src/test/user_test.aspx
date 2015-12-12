<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.database" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.model" %>

<%@ import Namespace="NHibernate" %>
<%@ import Namespace="NHibernate.Cfg" %>

<script runat="server">
User mario;
User gino;

IUserRepository urep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		
protected void Page_Load(Object sender, EventArgs e)
{
	try
	{
		mario = new User();
		mario.username = "mario";
		mario.password = "mario";
		mario.email = "mario@mario.it";
		mario.insertDate = DateTime.Now;
		mario.modifyDate = DateTime.Now;
		mario.role = new UserRole(3);
		mario.privacyAccept = false;
		mario.hasNewsletter = true;
		mario.isActive = false;
		mario.discount = 0.00m;
		mario.boComments = null;
		mario.isPublicProfile = true;
		mario.isAutomaticUser = false;
		mario.attachments = new List<UserAttachment>();
		mario.friends = new List<UserFriend>();

		gino = new User();
		gino.username = "gino";
		gino.password = "gino";
		gino.email = "gino@gino.it";
		gino.insertDate = DateTime.Now;
		gino.modifyDate = DateTime.Now;
		gino.role = new UserRole(3);
		gino.privacyAccept = false;
		gino.hasNewsletter = true;
		gino.isActive = false;
		gino.discount = 0.00m;
		gino.boComments = null;
		gino.isPublicProfile = true;
		gino.isAutomaticUser = false;

		//adding attach
		UserAttachment attach1 = new UserAttachment();
		attach1.filename = "myfile.jsp";
		attach1.contentType = "img-jpg";
		attach1.path = "/public/upload/user/";
		attach1.fileLabel = "img-medium";
		attach1.isAvatar = false;
		attach1.insertDate = DateTime.Now;

		UserAttachment attach2 = new UserAttachment();
		attach2.filename = "myfile2.jsp";
		attach2.contentType = "img-jpg";
		attach2.path = "/public/upload/user/";
		attach2.fileLabel = "img-big";
		attach2.isAvatar = false;
		attach2.insertDate = DateTime.Now;

		// aggiungo attachments a mario
		mario.attachments.Add(attach1);
		mario.attachments.Add(attach2);	

		//persisto gino
		urep.insert(gino);

		// aggiungo gino come amico di mario  dopo aver gi� persistito gino, prima di persistere mario
		UserFriend ginoFriend = new UserFriend();
		ginoFriend.friend=gino.id;
		ginoFriend.isActive = false;
		ginoFriend.idParentUser = mario.id;
		mario.friends.Add(ginoFriend);

		//persisto mario
		urep.insert(mario);

		UserConfirmation marioconfirmCode = new UserConfirmation(mario.id, "ADSFSDGFSDFFAgfsgvzdfsfsdFDS565465454fasfd");
		urep.insertConfirmationCode(marioconfirmCode);

		//urep.delete(mario);

		User logged = new User(); 
		logged.username = "mario";
		logged.password = "mario";
		Response.Write("<br><b>start logged.email: </b>"+logged.email+"<br>");

		logged = urep.login(logged);
		if(logged != null){
			Response.Write("<b>after login: logged != null - toString: </b>"+logged.ToString()+"<br>");
			//Response.Write("<b>after login: logged != null - toString: </b><br>");
		}
		//mario = urep.getById(mario.id);
		//gino = urep.getById(gino.id);
		
		Response.Write("<br><b>mario:</b> "+mario.ToString()+"<br>");	
		if(mario.attachments != null)
		{
			foreach (UserAttachment k in mario.attachments)
			{
				Response.Write(k.ToString()+"<br>");
			} 
		}else{
			Response.Write("user.attachments == null<br>");
		}	
		if(mario.friends != null)
		{
			foreach (UserFriend y in mario.friends)
			{
				Response.Write(y.ToString()+"<br>");
			} 
		}else{
			Response.Write("user.friends == null<br>");
		}

		bool matchcode = urep.matchConfirmationCode(mario, marioconfirmCode.confirmationCode);

		Response.Write("mario.confirmationCode match with: "+marioconfirmCode.confirmationCode+" - "+matchcode+"<br>");

		Response.Write("<br><b>gino:</b> "+gino.ToString()+"<br>");
		if(gino.attachments != null)
		{
			foreach (UserAttachment k in gino.attachments)
			{
				Response.Write(k.ToString()+"<br>");
			} 
		}else{
			Response.Write("user.attachments == null<br>");
		}
	
		
		//user.password="provap2";
		//user.role = new UserRole(2);
		//user.modifyDate = DateTime.Now.AddMinutes(3);
		//urep.update(user);

		//olduser = urep.getById(user.id);
		urep.delete(gino);				
		
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
    <h2>User Report </h2>
    
    <%
	
	/*Response.Write("deleted user : "+olduser.toString()+"<br>");	
		if(user.attachments != null)
		{
			foreach (UserAttachment k in olduser.attachments)
			{
				Response.Write(k.toString()+"<br>");
			} 
		}else{
			Response.Write("user.attachments == null<br>");
		}	*/
	%>
</body>
</html>