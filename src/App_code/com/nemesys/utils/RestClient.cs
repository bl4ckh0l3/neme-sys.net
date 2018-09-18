using System;
using System.IO;
using System.Net;
using System.Net.Security;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Security;
using System.Security.Cryptography;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

public enum HttpVerb
{
    GET,
    POST,
    PUT,
    DELETE
}

namespace com.nemesys.model
{
  public class RestClient
  {
  	  
    private string _EndPoint;
    private HttpVerb _Method;
    private string _ContentType;
    private string _PostData;	
    private BasicAuthenticator _Authenticator; 
    private IDictionary<string,string> _Headers;
  	  
	public virtual string EndPoint {
		get { return _EndPoint; }
		set { _EndPoint = value; }
	}  	  
	public virtual HttpVerb Method {
		get { return _Method; }
		set { _Method = value; }
	} 
	public virtual string ContentType {
		get { return _ContentType; }
		set { _ContentType = value; }
	} 
	public virtual string PostData {
		get { return _PostData; }
		set { _PostData = value; }
	}
	public virtual BasicAuthenticator Authenticator {
		get { return _Authenticator; }
		set { _Authenticator = value; }
	} 
	public virtual IDictionary<string,string> Headers {
		get { return _Headers; }
		set { _Headers = value; }
	} 
	
	


    public RestClient()
    {
      _EndPoint = "";
      _Method = HttpVerb.GET;
      _ContentType = "application/json;charset=utf-8";
      _PostData = "";
      _Authenticator = new BasicAuthenticator();
      _Headers = new Dictionary<string,string>();
    }
    public RestClient(string endpoint)
    {
      _EndPoint = endpoint;
      _Method = HttpVerb.GET;
      _ContentType = "application/json;charset=utf-8";
      _PostData = "";
      _Authenticator = new BasicAuthenticator();
      _Headers = new Dictionary<string,string>();
    }
    public RestClient(string endpoint, HttpVerb method)
    {
      _EndPoint = endpoint;
      _Method = method;
      _ContentType = "application/json;charset=utf-8";
      _PostData = "";
      _Authenticator = new BasicAuthenticator();
      _Headers = new Dictionary<string,string>();
    }

    public RestClient(string endpoint, HttpVerb method, string postData)
    {
      _EndPoint = endpoint;
      _Method = method;
      _ContentType = "application/json;charset=utf-8";
      _PostData = postData;
      _Authenticator = new BasicAuthenticator();
      _Headers = new Dictionary<string,string>();
    }

    public RestClient(string endpoint, HttpVerb method, string postData, BasicAuthenticator Authenticator)
    {
      _EndPoint = endpoint;
      _Method = method;
      _ContentType = "application/json;charset=utf-8";
      _PostData = postData;
      _Authenticator = Authenticator;
      _Headers = new Dictionary<string,string>();
    }

    public RestClient(string endpoint, HttpVerb method, string postData, BasicAuthenticator Authenticator, Dictionary<string,string> Headers)
    {
      _EndPoint = endpoint;
      _Method = method;
      _ContentType = "application/json;charset=utf-8";
      _PostData = postData;
      _Authenticator = Authenticator;
      _Headers = new Dictionary<string,string>();
    }

    public RestClient(string endpoint, HttpVerb method, string postData, BasicAuthenticator Authenticator, Dictionary<string,string> Headers, string contentType)
    {
      _EndPoint = endpoint;
      _Method = method;
      _ContentType = contentType;
      _PostData = postData;
      _Authenticator = Authenticator;
      _Headers = new Dictionary<string,string>();
    }


    public string[] MakeRequest()
    {
      return MakeRequest("");
    }

    public string[] MakeRequest(string parameters)
    {
      string[] results = new string[3];

      try{	
    	
    	
      HttpWebRequest request = (HttpWebRequest)WebRequest.Create(EndPoint + parameters);

      request.Method = Method.ToString();
      request.ContentLength = 0;
      request.ContentType = ContentType;
      
      if(!string.IsNullOrEmpty(_Authenticator.user) && !string.IsNullOrEmpty(_Authenticator.password)){
      	  request.Headers["Authorization"] = "Basic " + Convert.ToBase64String(Encoding.Default.GetBytes(_Authenticator.user+":"+_Authenticator.password));
      }
      
      if(_Headers.Count >0){
		/*for(int i=0; i < _Headers.Count; i++){ 
			request.Headers[_Headers.Keys[i]] = _Headers[i];
		}*/
		
		foreach( KeyValuePair<string, string> kvp in _Headers )
		{
			request.Headers[kvp.Key.ToString()] = kvp.Value.ToString();
		}		
		
      }
      
      request.PreAuthenticate = true;
      request.KeepAlive = false;
      

      //System.Web.HttpContext.Current.Response.Write("<br><b>request.Method:</b>"+request.Method+"<br>");
      //System.Web.HttpContext.Current.Response.Write("<br><b>PostData:</b>"+PostData+"<br>");
      //System.Web.HttpContext.Current.Response.Write("<br><b>request.Headers[Authorization]:</b>"+request.Headers["Authorization"]+"<br><br>");

		request.ProtocolVersion = HttpVersion.Version10; 
		ServicePointManager.Expect100Continue = true;
		//ServicePointManager.DefaultConnectionLimit = 999999;  
		//ServicePointManager.MaxServicePointIdleTime = 1000;
		//ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
		
		//ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
		//ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | (SecurityProtocolType)3072;
		
		//ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3;
		//System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;
		
		ServicePointManager.ServerCertificateValidationCallback = new System.Net.Security.RemoteCertificateValidationCallback(callback); 
		ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls | (SecurityProtocolType)3072;


      
      if (!string.IsNullOrEmpty(PostData) && Method == HttpVerb.POST)
      {
        UTF8Encoding encoding = new UTF8Encoding();
        byte[] bytes = Encoding.GetEncoding("iso-8859-1").GetBytes(PostData);
        request.ContentLength = bytes.Length;
        //System.Web.HttpContext.Current.Response.Write("<br><b>before: request.GetRequestStream()</b><br>");
        
        using (Stream writeStream = request.GetRequestStream())
        {
          writeStream.Write(bytes, 0, bytes.Length);
        }
      }

      //System.Web.HttpContext.Current.Response.Write("<br><b>before: request.GetResponse()</b><br>");
      
      //Certificates.Instance.GetCertificatesAutomatically();
      
	  using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
	  {
		string responseValue = string.Empty;

		//if (response.StatusCode != HttpStatusCode.OK && response.StatusCode != HttpStatusCode.Created)
		//{
		//  string message = String.Format("Request failed. Received HTTP {0}", response.StatusCode);
		//  throw new ApplicationException(message);
		//}
		
		//System.Web.HttpContext.Current.Response.Write("<br><b>StatusCode:</b>"+response.StatusCode+"<br>");

		// grab the response
		using (Stream responseStream = response.GetResponseStream())
		{
		  if (responseStream != null)
			using (StreamReader reader = new StreamReader(responseStream))
			{
			  responseValue = reader.ReadToEnd();
			  results[0] = responseValue;
			}
		}
		
		string headers = "{";
		for(int i=0; i < response.Headers.Count; ++i){ 
			headers+="\""+response.Headers.Keys[i]+"\":\""+response.Headers[i]+"\",";
		}
		headers=headers.Substring(0,headers.Length-1);
		headers+="}";
		
		results[1] = headers;
		results[2] = response.StatusCode.ToString();
		
		//System.Web.HttpContext.Current.Response.Write("<br><b>headers:</b>"+headers+"<br>");
		//System.Web.HttpContext.Current.Response.Write("<br><b>StatusCode:</b>"+response.StatusCode+"<br>");

	  }
		
	  return results;
	  
	}catch(Exception ex){
		//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
		throw ex;
	}
		
	  
	  /*
	  // prova di implementazione con try/catch
	  
	  string headers = string.Empty;
	  HttpWebResponse response = null;
	  try{
	  	  string responseValue = string.Empty;
	  	  
            response = (HttpWebResponse)request.GetResponse();

            Stream receiveStream = response.GetResponseStream();
            if(receiveStream != null){
            	StreamReader readStream = new StreamReader(receiveStream, Encoding.UTF8);
				  responseValue = readStream.ReadToEnd();
				  results[0] = responseValue;  
				  readStream.Close ();          
            }

			headers = "{";
			for(int i=0; i < response.Headers.Count; ++i){ 
				headers+="\"name\":\""+response.Headers.Keys[i]+"\", \"value\":\""+response.Headers[i]+"\",";
			}
			headers=headers.Substring(0,headers.Length-1);
			headers+="}";
			
			results[1] = headers;
			results[2] = response.StatusCode.ToString();
			
			System.Web.HttpContext.Current.Response.Write("<br><b>headers:</b>"+headers+"<br>");
			System.Web.HttpContext.Current.Response.Write("<br><b>StatusCode:</b>"+response.StatusCode+"<br>");

            response.Close ();	  
	  }catch(Exception ex){
	  	  System.Web.HttpContext.Current.Response.Write("<br><b>Error:</b>"+ex.Message+"<br>");
	  	  results[0] = ex.Message;
		  results[1] = headers;
	  	  results[2] = (response.StatusCode != null ? response.StatusCode.ToString() : "");
	  }
	  
	  return results;
	  */
    }  
    
	private bool callback(object obj, X509Certificate cert, X509Chain chain, SslPolicyErrors err)
	{
		return true;
	}  
	
	private bool ValidateServerCertificate(
		  object sender,
		  X509Certificate certificate,
		  X509Chain chain,
		  SslPolicyErrors sslPolicyErrors)
	{
		if (sslPolicyErrors == SslPolicyErrors.None){
			return true;
		}

		return false;
	}

  } // class

}