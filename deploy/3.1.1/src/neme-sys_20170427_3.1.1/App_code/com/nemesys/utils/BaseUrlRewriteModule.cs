using System;
using System.Web;
using System.Data;
using System.Web.UI;
using System.Web.SessionState;
using System.IO;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.database.repository;
using com.nemesys.services;

namespace com.nemesys.utils
{	
	public abstract class BaseUrlRewriteModule : IHttpModule
	{
	   public virtual void Init(HttpApplication app)
	   {
		  // WARNING!  This does not work with Windows authentication!
		  // If you are using Windows authentication, 
		  // change to app.BeginRequest
		  app.AuthorizeRequest += new EventHandler(this.BaseModuleRewriter_AuthorizeRequest);
	   }
	
	   public virtual void Dispose() {}
	
	   protected virtual void BaseModuleRewriter_AuthorizeRequest(object sender, EventArgs e)
	   {
		  HttpApplication app = (HttpApplication) sender;
		  Rewrite(app.Request.Path, app);
	   }
	
	   protected abstract void Rewrite(string requestedPath, HttpApplication app);
	}
}