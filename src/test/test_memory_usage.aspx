<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Diagnostics" %>
<%@ import Namespace="System.Runtime.InteropServices" %>

<script runat="server">
protected void Page_Load(Object sender, EventArgs e)
{
	try
	{

		IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
		while (CacheEnum.MoveNext())
		{
			string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString());
			string cacheValue = HttpContext.Current.Server.HtmlEncode(CacheEnum.Value.ToString());
			
			Response.Write("cacheKey:"+cacheKey+" - ");
			Response.Write("cacheValue:"+cacheValue+"<br><br>");		
		}
		
		foreach (DictionaryEntry dEntry in HttpContext.Current.Cache)
		{
			HttpContext.Current.Cache.Remove(dEntry.Key.ToString());
		}
	
		long bytes = GC.GetTotalMemory(false);
		Response.Write("Memory Used:"+bytes.ToString()+"<br><br>");

		/*
		Processor(_Total)\% Processor Time
		Process(aspnet_wp)\% Processor Time
		Process(aspnet_wp)\Private Bytes
		Process(aspnet_wp)\Virtual Bytes
		Process(aspnet_wp)\Handle Count
		Microsoft� .NET CLR Exceptions\# Exceps thrown / sec
		ASP.NET\Application Restarts
		ASP.NET\Requests Rejected
		ASP.NET\Worker Process Restarts (not applicable to IIS 6.0)
		Memory\Available Mbytes
		Web Service\Current Connections
		Web Service\ISAPI Extension Requests/sec
		*/
		
		//PerformanceCounter oPerfCounter = new PerformanceCounter();
		//oPerfCounter.CategoryName = "Memory";
		//oPerfCounter.CounterName = "Available Mbytes";
		//oPerfCounter.InstanceName = "_Total";
		//Response.Write("Memory Usage: " + oPerfCounter.NextValue().ToString() + "<br><br>");	
	}
	catch (Exception ex)
	{
		Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
	
}
</script>