using System;
using System.IO;
using System.Net;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Net.Security;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

public sealed class Certificates
{
    private static Certificates instance = null;
    private static readonly object padlock = new object();

    Certificates()
    {
    }

    public static Certificates Instance
    {
        get
        {
            lock (padlock)
            {
                if (instance == null)
                {
                    instance = new Certificates();
                }
                return instance;
            }
        }
    }
    public void GetCertificatesAutomatically()
    {
    	//System.Web.HttpContext.Current.Response.Write("<br>calling GetCertificatesAutomatically<br>");
    	
        //ServicePointManager.ServerCertificateValidationCallback += new RemoteCertificateValidationCallback((sender, certificate, chain, policyErrors)=> { return true; });
        RemoteCertificateValidationCallback rcvc = new RemoteCertificateValidationCallback((sender, certificate, chain, policyErrors)=> 
        	{
        	bool isOk = RemoteCertificateValidationCallback(sender, certificate, chain, policyErrors);
        	System.Web.HttpContext.Current.Response.Write("<br><b>isOk: </b>"+isOk+"<br>");
        	return isOk; }
        );
        
        //System.Web.HttpContext.Current.Response.Write("<br><b>rcvc.ToString(): </b>"+rcvc.ToString()+"<br>");
        
        ServicePointManager.ServerCertificateValidationCallback += rcvc;
    }

    private static bool RemoteCertificateValidationCallback(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
    {
    	//System.Web.HttpContext.Current.Response.Write("<br><b>(sslPolicyErrors == SslPolicyErrors.None): </b>"+(sslPolicyErrors == SslPolicyErrors.None)+"<br>");
    	
        //Return true if the server certificate is ok
        if (sslPolicyErrors == SslPolicyErrors.None)
            return true;

        bool acceptCertificate = true;
        string msg = "The server could not be validated for the following reason(s):\r\n";

        //The server did not present a certificate
        if ((sslPolicyErrors &
            SslPolicyErrors.RemoteCertificateNotAvailable) == SslPolicyErrors.RemoteCertificateNotAvailable)
        {
            msg = msg + "\r\n    -The server did not present a certificate.\r\n";
            acceptCertificate = false;
        }
        else
        {
            //The certificate does not match the server name
            if ((sslPolicyErrors &
                SslPolicyErrors.RemoteCertificateNameMismatch) == SslPolicyErrors.RemoteCertificateNameMismatch)
            {
                msg = msg + "\r\n    -The certificate name does not match the authenticated name.\r\n";
                acceptCertificate = false;
            }

            //There is some other problem with the certificate
            if ((sslPolicyErrors &
                SslPolicyErrors.RemoteCertificateChainErrors) == SslPolicyErrors.RemoteCertificateChainErrors)
            {
                foreach (X509ChainStatus item in chain.ChainStatus)
                {
                    if (item.Status != X509ChainStatusFlags.RevocationStatusUnknown &&
                        item.Status != X509ChainStatusFlags.OfflineRevocation)
                        break;

                    if (item.Status != X509ChainStatusFlags.NoError)
                    {
                        msg = msg + "\r\n    -" + item.StatusInformation;
                        acceptCertificate = false;
                    }
                }
            }
        }

        //If Validation failed, present message box
        if (acceptCertificate == false)
        {
            msg = msg + "\r\nDo you wish to override the security check?";
            //          if (MessageBox.Show(msg, "Security Alert: Server could not be validated",
            //                       MessageBoxButtons.YesNo, MessageBoxIcon.Exclamation, MessageBoxDefaultButton.Button1) == DialogResult.Yes)
            acceptCertificate = true;
        }
        
    	//System.Web.HttpContext.Current.Response.Write("<br><b>acceptCertificate: </b>"+acceptCertificate+"<br>");
    	//System.Web.HttpContext.Current.Response.Write("<br><b>msg: </b>"+msg+"<br>");

        return acceptCertificate;
    }

}