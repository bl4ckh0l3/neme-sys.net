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
	/*	
	public class UrlRewriteHandle : IHttpHandler, IRequiresSessionState
	{	
		const string ORIGINAL_PATHINFO = "UrlRewriterOriginalPathInfo";
		const string ORIGINAL_QUERIES = "UrlRewriterOriginalQueries";
	
		public void ProcessRequest(HttpContext context)
		{
			// Check to see if the specified file actual exists and serve it if so..
			String strReqPath = context.Server.MapPath(context.Request.AppRelativeCurrentExecutionFilePath);
			if (File.Exists(strReqPath))
			{				
				Page aspxHandler = (Page)PageParser.GetCompiledPageInstance(context.Request.AppRelativeCurrentExecutionFilePath, strReqPath, context);
				// Execute the handler..
				aspxHandler.PreRenderComplete +=new EventHandler(AspxPage_PreRenderComplete);
				aspxHandler.ProcessRequest(context);
				return;
			}
	
			// Record the original request PathInfo and
			// QueryString information to handle graceful postbacks
			context.Items[ORIGINAL_PATHINFO] = context.Request.PathInfo;
			context.Items[ORIGINAL_QUERIES] = context.Request.QueryString.ToString();
	
			// Map the friendly URL to the back-end one..
			String strVirtualPath = "";
			String strQueryString = "";
			MapFriendlyUrl(context, out strVirtualPath, out strQueryString);
	
			if(strVirtualPath.Length>0)
			{
				foreach (string strOriginalQuery in context.Request.QueryString.Keys)
				{
					// To ensure that any query strings passed in the original request are preserved, we append these
					// to the new query string now, taking care not to add any keys
			   		// which have been rewritten during the handler..
					if (strQueryString.ToLower().IndexOf(strOriginalQuery.ToLower()+ "=") < 0)
					{
						strQueryString += string.Format("{0}{1}={2}",((strQueryString.Length > 0) ? "&" : ""),strOriginalQuery,context.Request.QueryString[strOriginalQuery]);
					}
				}
	
				// Apply the required query strings to the request
				context.RewritePath(context.Request.Path, string.Empty, strQueryString);
	
				// Now get a page handler for the ASPX page required, using this context.
				Page aspxHandler = (Page)PageParser.GetCompiledPageInstance(strVirtualPath, context.Server.MapPath(strVirtualPath), context);
	
				// Execute the handler..
				aspxHandler.PreRenderComplete +=new EventHandler(AspxPage_PreRenderComplete);
				aspxHandler.ProcessRequest(context);
			}
			else
			{
				// No mapping was found - emit a 404 response.	
				context.Response.StatusCode = 404;
				context.Response.ContentType = "text/plain";
				context.Response.Write("Page Not Found");
				context.Response.End();
			}
		}
	
		void MapFriendlyUrl(HttpContext context, out String strVirtualPath, out String strQueryString)
		{
			strVirtualPath = ""; strQueryString = "";
			string forcedLangCode = "";
	
			// TODO 
			// chiamare il TemplateService.resolveVirtualPath(strVirtualPath, out forcedLangCode)
		}
	
		void AspxPage_PreRenderComplete(object sender, EventArgs e)
		{
			// We need to rewrite the path replacing the original tail and query strings..
			// This happens AFTER the page has been loaded and setup
			// but has the effect of ensuring
			// postbacks to the page retain the original un-rewritten pages URL and queries.
	
			HttpContext.Current.RewritePath(HttpContext.Current.Request.Path,HttpContext.Current.Items[ORIGINAL_PATHINFO].ToString(),HttpContext.Current.Items[ORIGINAL_QUERIES].ToString());
		}
	
		public bool IsReusable
		{
			get
			{
				return true;
			}
		}
	}	
	*/	
	
	
	public class UrlRewriteHandle : IHttpHandlerFactory
	{	
		public IHttpHandler GetHandler(HttpContext context, string requestType, string URL, string pathTranslated)
		{
			//context.Items["fileName"] = Path.GetFileNameWithoutExtension(URL).ToLower();
			ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
			StringBuilder builder = new StringBuilder("URL: ")
			.Append(URL).Append(" -pathTranslated: ").Append(pathTranslated);	
			Logger log = new Logger(builder.ToString(), "system", "debug", DateTime.Now);	
			lrep.write(log);

			/*if (File.Exists(URL))
			{				
				context.Server.Transfer(URL);
			}*/

			
			// TODO chiamare template su db con url rewrite e comporre nuova url coretta
			string realurl = context.Server.MapPath(URL);
			string forcedLangCode = "";
			string resolved = TemplateService.resolveVirtualPath(URL, "", out forcedLangCode);
			if(resolved != null){
				realurl = context.Server.MapPath(resolved);
			}			
					
			return PageParser.GetCompiledPageInstance(URL, realurl, context);
		}
		
		public void ReleaseHandler(IHttpHandler handler){ }
	}
	
}