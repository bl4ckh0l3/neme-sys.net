using System;
using System.Web;
using System.Text;
using System.Web.UI;
using System.Web.SessionState;
using System.IO;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.database.repository;
using com.nemesys.services;

namespace com.nemesys.utils
{	
	public class UrlRewriteModule : BaseUrlRewriteModule
	{	
		protected override void Rewrite(string requestedPath, System.Web.HttpApplication app)
		{
			/*ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
			StringBuilder builder = new StringBuilder("requestedPath: ").Append(requestedPath);	
			Logger log = new Logger(builder.ToString(), "system", "debug", DateTime.Now);	
			lrep.write(log);*/
					   
			if (!File.Exists(app.Context.Server.MapPath(requestedPath)))
			{
				string forcedLangCode = "";	
				string resolved = TemplateService.resolveVirtualPath(requestedPath, "", out forcedLangCode);
				if(resolved != null){				 
					/*builder = new StringBuilder("resolved: ").Append(resolved);	
					log = new Logger(builder.ToString(), "system", "debug", DateTime.Now);	
					lrep.write(log);*/
				
					app.Context.RewritePath(resolved);
				}
			}		   
		}
	}
	
}