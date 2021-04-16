using System;
using System.Web;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;
using System.Web.Caching;
using System.Xml;
using System.IO;
using System.Net;
using com.nemesys.model;

namespace com.nemesys.services
{
	public class CaptchaService
	{
		private static ConfigurationService confservice = new ConfigurationService();

		public static string renderRecaptcha()
		{
			string recaptcha = "";
			
			if(!String.IsNullOrEmpty(confservice.get("recaptcha_pub_key").value)){		
				StringBuilder builder = new StringBuilder()
				.Append("<script type=\"text/javascript\">") 
					.Append("var RecaptchaOptions = {") 
						.Append(" theme : 'white',") 
						.Append(" tabindex : 0") 
					.Append("};") 
				.Append("</script>") 
				.Append("<script type=\"text/javascript\" src=\"http://www.google.com/recaptcha/api/challenge?k=" + confservice.get("recaptcha_pub_key").value + "\"></script>") 
				.Append("<noscript>") 
					.Append("<iframe height=\"300\" width=\"500\" frameborder=\"0\" src=\"http://www.google.com/recaptcha/api/noscript?k=" + confservice.get("recaptcha_pub_key").value + "\"></iframe><br>") 
					.Append("<textarea name=\"recaptcha_challenge_field\" rows=\"3\" cols=\"40\"></textarea>") 
					.Append("<input type=\"hidden\" name=\"recaptcha_response_field\" value=\"manual_challenge\">") 
				.Append("</noscript>"); 
							
				 recaptcha = builder.ToString();
			 }
			 
			return recaptcha;			
		}


		public static bool verifyRecaptcha(string remoteAddr, string challenge, string response)
		{
			bool verified = true;			

			StringBuilder veryfyUrl = new StringBuilder("http://www.google.com/recaptcha/api/verify?")
			.Append("privatekey=").Append(confservice.get("recaptcha_priv_key").value) 
			.Append("&remoteip=").Append(remoteAddr)
			.Append("&challenge=").Append(challenge) 
			.Append("&response=").Append(response);						
			
			string urlTest = veryfyUrl.ToString();	
			try
			{	
				HttpWebRequest myHttpWebRequest = (HttpWebRequest)WebRequest.Create(urlTest);	
				using (WebResponse myWebResponse = myHttpWebRequest.GetResponse())
				{			
					// Obtain a 'Stream' object associated with the response object.
					Stream ReceiveStream = myWebResponse.GetResponseStream();							
					Encoding encode = System.Text.Encoding.GetEncoding("utf-8");						
					// Pipe the stream to a higher level stream reader with the required encoding format. 
					StreamReader readStream = new StreamReader( ReceiveStream, encode );					
					string text = readStream.ReadToEnd();		
					string[] values = Regex.Split(text, "\n"); 
					if(values != null && values[0] == "true"){
						verified = true;
					}else{
						verified = false;		
					}	
				}
			}catch(Exception ex)
			{
				verified = false;
			}
			 
			return verified;		
		}
	}
}