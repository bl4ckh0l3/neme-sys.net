using System;
using System.Web;
using System.Reflection;
using NHibernate;
using NHibernate.Cfg;
using System.IO;
using com.nemesys.model;
using com.nemesys.services;
using log4net;

namespace com.nemesys.database
{
    public sealed class NHibernateHelper
    {
		private static readonly object _Padlock = new object();
		private static readonly ILog log = LogManager.GetLogger(typeof(NHibernateHelper));
        private const string CurrentSessionKey = "nhibernate.current_session";
        private static ISessionFactory sessionFactory;

        private static void createSessionFactory()
        {
			//System.Web.HttpContext.Current.Response.Write("Entrato in static createSessionFactory<br>");
			try
			{
				Configuration cfg = new Configuration(); // Get a new NHibernate Configuration
				ConfigurationService confservice = new ConfigurationService();
				cfg.SetProperty("connection.connection_string", confservice.get("dbconn").value); // Alter the property
				
				// Add class mappings to configuration object
				//cfg.AddAssembly("com.nemesys.model");
				//cfg.AddAssembly("App_Code");
				//cfg.AddAssembly(Assembly.GetExecutingAssembly());
				//cfg.AddClass(typeof(Logger));
				//cfg.AddFile("Logger.hbm.xml");
				//cfg.AddXmlFile(System.Web.HttpContext.Current.Server.MapPath("~/App_code")+"\\Logger.hbm.xml");
				cfg.AddDirectory(new  DirectoryInfo(System.Web.HttpContext.Current.Server.MapPath("~/App_code/hbm")));
				
				//System.Web.HttpContext.Current.Response.Write("file map: "+System.Web.HttpContext.Current.Server.MapPath("App_code")+"\\Logger.hbm.xml"+"<br>");		
				lock (_Padlock)
            	{
					sessionFactory = cfg.Configure().BuildSessionFactory(); // Get a new ISessionFactory
				}
			}
			catch(System.NullReferenceException nre)
			{
				throw;
			}
        }

        public static ISession getCurrentSession()
        {
			ISession currentSession = null;
			//System.Web.HttpContext.Current.Response.Write("Entrato in GetCurrentSession<br>");
			try
			{
				if(sessionFactory == null)
				{
					createSessionFactory();
				}
			
				HttpContext context = HttpContext.Current;
				currentSession = context.Items[CurrentSessionKey] as ISession;
	
				//System.Web.HttpContext.Current.Response.Write("currentSession==null: "+ (currentSession==null) +"<br>");
			
				if (currentSession == null)
				{
					currentSession = sessionFactory.OpenSession();
					context.Items[CurrentSessionKey] = currentSession;
				}
			}
			catch(System.NullReferenceException nre)
			{
				log.Error("An error occured ISession null: " + nre.Message+"<br><br><br>"+nre.StackTrace,nre);
				currentSession = null;				
			}

            return currentSession;
        }

        public static void closeSession()
        {
            HttpContext context = HttpContext.Current;
            ISession currentSession = context.Items[CurrentSessionKey] as ISession;

            if (currentSession == null)
            {
                // No current session
                return;
            }

            currentSession.Close();
            context.Items.Remove(CurrentSessionKey);
        }

        public static void closeSessionFactory()
        {
			//System.Web.HttpContext.Current.Response.Write("Entrato in static closeSessionFactory<br>");
            if (sessionFactory != null)
            {
                sessionFactory.Close();
            }
        }
    }
}