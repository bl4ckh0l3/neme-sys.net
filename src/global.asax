<%@ Language="C#" %>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Web.Caching" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Timers" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<script runat=server>
	protected static ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository"); 
	protected static ConfigurationService confservice = new ConfigurationService();
	
	protected void Application_Start(object sender, EventArgs e)
	{
		/**
		this code needs to keep the session alive when bo users manage directory on web application
		read this: 
		http://stackoverflow.com/questions/2248825/asp-net-restarts-when-a-folder-is-created-renamed-or-deleted
		http://ashishgandhi.wordpress.com/2010/12/22/stop-iis-appdomain-restarts-when-a-folder-is-deleted/
		*/
		try
		{
			PropertyInfo p = typeof(System.Web.HttpRuntime).GetProperty("FileChangesMonitor", BindingFlags.NonPublic | BindingFlags.Public |  BindingFlags.Static);
			object o = p.GetValue(null, null);
			FieldInfo f = o.GetType().GetField("_dirMonSubdirs", BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.IgnoreCase);
			object monitor = f.GetValue(o);
			MethodInfo m = monitor.GetType().GetMethod("StopMonitoring", BindingFlags.Instance | BindingFlags.NonPublic);
			m.Invoke(monitor, new object[] { });
		}
		catch (Exception ex)
		{
		    //Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
		}		
	
		Application["refresh_currency_time"] = DateTime.Now;
		Application["refresh_rotation_time"] = DateTime.Now;
		Application["force_refresh_currency_time"] = true;
		Application["force_refresh_rotation_time"] = true;
	
		// web.config
		log4net.Config.XmlConfigurator.Configure();

		// set properti hostName
		log4net.GlobalContext.Properties["hostName"] = Dns.GetHostName();
		//endregion
		
		Logger log;
		
		Application["active_users"] = 0;
		try
		{
			log = new Logger();
			log.usr= "system";
			log.msg = "Application started now - active users: "+Application["active_users"];
			log.type = "info";
			log.date = DateTime.Now;
			lrep.write(log);
			
		}
		catch (Exception ex)
		{
		    //Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
		}			
	}

	protected void Application_End(object sender, EventArgs e)
	{
		//  Code that runs on application shutdown
		//Trace.WriteLine(GetAppDescription("Application_End"));
	}

	protected void Session_Start(Object sender, EventArgs e)
	{
		// setta il timeout di default 10
		Session.Timeout = 20;
		Application.Lock();
		Application["active_users"]=(int)Application["active_users"]+1;
		Application.UnLock();
	
		Logger log;
		StringBuilder builder;
		try
		{
			builder = new StringBuilder("active users: ")
			.Append(Application["active_users"])
			.Append("<br/>- ip current user: ").Append(Request.ServerVariables["REMOTE_ADDR"])
			.Append("<br/>- browser: ").Append(Request.ServerVariables["HTTP_USER_AGENT"])
			.Append("<br/>- user: ").Append(Request.ServerVariables["REMOTE_USER"])
			.Append("<br/>- Session.SessionID: ").Append(Session.SessionID)
			.Append("<br/>- url: ").Append(Request.ServerVariables["URL"])
			.Append("<br/>- host: ").Append(Request.ServerVariables["REMOTE_HOST"]);				
			log = new Logger(builder.ToString(), "system","info",DateTime.Now);
			lrep.write(log);
			
			// verifico se ci sono user online nella mappa con data inferiore a 6 ore e li cancello
			IDictionary<string, UserOnline> currentUsersOnline = UserService.getOnlineUsers();
			foreach(string key in currentUsersOnline.Keys)
			{
				DateTime entry = currentUsersOnline[key].entryDate;
				System.TimeSpan udiffResult = DateTime.Now.Subtract(entry);
				if(udiffResult.TotalHours >= 6)
				{
					UserService.removeOnlineUser(key, currentUsersOnline[key].userOnline);
				}
			}			
		}
		    catch (Exception ex)
		{
		    //Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
		}
		
		/**
		<!--nsys-globalasa2-->
		'*** per ovviare al problema dell'aggiornamento currency tramite asp.net ad ogni nuova sessione faccio un aggiornamento forzato delle valute
		'*** la soluzione non � ottimale o particolarmente pulita ma permette di avere un aggiornamento automatico delle valute abbastanza frequente, se il sito riceve parecchie visite
		'*** per evitare che l'aggiornamento avvenga ad ogni nuova sessione, metto una variabile application corrispondente alla data e ora corrente ad ogni aggiornamento, e faccio l'update
		'*** solo se sono passate almeno 1 ora dall'ultimo update delle valute
		*/		
		System.TimeSpan diffResult = DateTime.Now.Subtract((DateTime)Application["refresh_currency_time"]);

		
		if (diffResult.TotalMinutes >= 30 || (bool)Application["force_refresh_currency_time"]) {		
			UriBuilder builder0 = new UriBuilder(Request.Url);
			builder0.Scheme = "http";
			builder0.Port = -1;
			builder0.Path = "backoffice/currency/currencypoller.aspx";		
			string url = builder0.ToString();
			
			try
			{			
				HttpWebRequest myHttpWebRequest = (HttpWebRequest)WebRequest.Create(url);

				builder = new StringBuilder("diffResult.TotalMinutes: ").Append(diffResult.TotalMinutes)
				.Append("<br>diffResult.TotalSeconds: ").Append(diffResult.TotalSeconds)
				.Append("<br>url: ").Append(url).Append("<br>myHttpWebRequest: ").Append(myHttpWebRequest!=null)
				.Append("<br>getCountOnlineUsers: ").Append(UserService.getCountOnlineUsers());		
				log = new Logger(builder.ToString(),"system","debug",DateTime.Now);	
				lrep.write(log);
			
				ThreadUtil.FireAndForget(new InsertDelegate(WriteIt),new object[]{myHttpWebRequest});
			}
			catch(Exception ex){
				builder = new StringBuilder("Exception: ")
				.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
				log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
				//lrep.write(log);			
			}	
			
			Application["refresh_currency_time"] = DateTime.Now;
			Application["force_refresh_currency_time"] = false;
		}
		
		//*************** utilizzo la stessa tecnica per la rotazione quantit� dei prodotti
		System.TimeSpan diffResult2 = DateTime.Now.Subtract((DateTime)Application["refresh_rotation_time"]);
				
		if (diffResult2.TotalMinutes >= 5 || (bool)Application["force_refresh_rotation_time"]) {		
			
			UriBuilder builder1 = new UriBuilder(Request.Url);
			builder1.Scheme = "http";
			builder1.Port = -1;
			builder1.Path = "backoffice/products/qtyrotationpoller.aspx";		
			string url1 = builder1.ToString();
			
			try
			{			
				HttpWebRequest myHttpWebRequest1 = (HttpWebRequest)WebRequest.Create(url1);

				builder = new StringBuilder("product qty rotation: ")
				.Append("<br>url1: ").Append(url1).Append("<br>myHttpWebRequest1: ").Append(myHttpWebRequest1!=null);		
				log = new Logger(builder.ToString(),"system","debug",DateTime.Now);	
				lrep.write(log);
			
				ThreadUtil.FireAndForget(new InsertDelegate(WriteIt),new object[]{myHttpWebRequest1});
			}
			catch(Exception ex){
				builder = new StringBuilder("Exception qty rotation: ")
				.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
				log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
				//lrep.write(log);			
			}
			Application["refresh_rotation_time"] = DateTime.Now;	
			Application["force_refresh_rotation_time"] = false;
		}		
		/*
		<!---nsys-globalasa2-->	
		*/
	}

	protected void Session_End(Object sender, EventArgs e)
	{
		Application.Lock();
		Application["active_users"]=(int)Application["active_users"]-1;
		Application.UnLock();
		
		Logger log;
		
		//'**** elimino l'utente loggato alla lista degli utenti online	
		try{
			UserService.removeOnlineUser(Session.SessionID, (User)Session["user-online"]);
			
			/**
			<!--nsys-globalasa2-->
			'*** se previsto dalla configurazione elimino tutti i carrelli relativi all'utente in sessione
			*/	
						
			log = new Logger("del_carrello_on_exit: "+confservice.get("del_carrello_on_exit").value,"system","debug",DateTime.Now);	
			lrep.write(log);
				
			if ("0".Equals(confservice.get("del_carrello_on_exit").value))
			{	
				ShoppingCartService.delCartByIdUser(Math.Abs(Session.SessionID.GetHashCode()));
				if(Session["user-online"] != null){
					ShoppingCartService.delCartByIdUser(((User)Session["user-online"]).id);
				}
			}
			
			/*
			<!---nsys-globalasa2-->	
			*/		
		}catch(Exception ex){
				log = new Logger(ex.Message+"<br><br><br>"+ex.StackTrace,"system","error",DateTime.Now);		
				lrep.write(log);		
		}
	}

	protected void Application_Error(object sender, EventArgs e)
	{
		// Code that runs when an unhandled error occurs
		//Trace.WriteLine(GetAppDescription("Application_Error"));
		
		// Code that runs when an unhandled error occurs
		//Logging.LogException(Server.GetLastError(), "Global Error");
	}

	protected void Application_BeginRequest(object sender, EventArgs e)
	{
		//Trace.WriteLine(GetAppDescription("Application_BeginRequest"));
		
		string resolved = "";
		string forcedLangCode = "";
		string originalPath = HttpContext.Current.Request.Path.ToLower();		
		if (!File.Exists(Context.Server.MapPath(originalPath)))
		{	
			resolved = TemplateService.resolveVirtualPath(originalPath, "", out forcedLangCode);
	
			/*
			StringBuilder builder = new StringBuilder("originalPath: ")
			.Append(originalPath).Append(" -resolved: ").Append(resolved).Append(" -forcedLangCode: ").Append(forcedLangCode);	
			Logger log = new Logger(builder.ToString(), "system", "debug", DateTime.Now);	
			lrep.write(log);
			*/
				
			if(!String.IsNullOrEmpty(resolved)){
				Context.RewritePath(resolved);
				if(!String.IsNullOrEmpty(forcedLangCode)){
					HttpContext.Current.Items["lang-code"] = forcedLangCode;
				}
				
			}
		}			
	}

	protected void Application_EndRequest(object sender, EventArgs e)
	{
		//Trace.WriteLine(GetAppDescription("Application_EndRequest"));
	}

	delegate void InsertDelegate(HttpWebRequest myHttpWebRequest);
					
	static void WriteIt(HttpWebRequest myHttpWebRequest)
	{
		try
		{
			WebResponse response = myHttpWebRequest.GetResponse();
			response.Close();
		
			StringBuilder builder = new StringBuilder("WriteIt myHttpWebRequest.GetResponse(): ")
			.Append(DateTime.Now).Append("myHttpWebRequest: ").Append(myHttpWebRequest!=null);	
			Logger log = new Logger(builder.ToString(), "system", "debug", DateTime.Now);	
			lrep.write(log);
		}catch(Exception ex){
			StringBuilder builder = new StringBuilder("Exception: ")
			.Append("WriteItmthod WriteIt: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
			Logger log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
			//lrep.write(log);	
		}
	}
</SCRIPT>