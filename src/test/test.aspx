<%@ Language="VB" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.Caching" %>
<%@ Import Namespace="System.Threading" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Io" %>
<html>
<head>
</head>

<body>
<%
Try	
	'*********************************** RECUPERO XML CON ELENCO CAMBI AGGIORNATI DAL SITO DELLA BANCA CENTRALE EUROPEA	
	Dim xml As New System.Xml.XmlDocument
	Dim mem As New System.IO.MemoryStream
	Dim myXmlString As String
	
	' Load up your xml
	xml.Load("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")
	xml.Save(mem)
	Dim bytes(mem.Length) As Byte
	bytes = mem.ToArray()
	myXmlString = System.Text.Encoding.UTF8.GetString(bytes)
	
	
	'*********************************** DALLA STRINGA XML ESTRAGGO SOLO I NODI CON I CAMBI	
	myXmlString = Mid(myXmlString,InStr(1,myXmlString,"<Cube>",1),Len(myXmlString))
	myXmlString = Mid(myXmlString,1,InStrRev(myXmlString,"</Cube>",-1,1)+7)

	'response.write(myXmlString)
	
	
	'*********************************** RICREO IL DOC XML CORRETTO E CICLO SUI SINGOLI NODI	
	Dim m_xmld As XmlDocument
	Dim m_nodelist As XmlNodeList
	Dim m_node As XmlNode
	
	'Create the XML Document
	m_xmld = New XmlDocument()
	
	'Load the Xml file
	m_xmld.Load(new StringReader(myXmlString))
	
	'Get the time of the xml file
	m_node = m_xmld.SelectSingleNode("/Cube/Cube")
	'response.write("time: "&m_node.Attributes.GetNamedItem("time").Value.toString())
	
	'Get the list of name nodes 
	m_nodelist = m_xmld.SelectNodes("/Cube/Cube/Cube")
	
	'Loop through the nodes
	For Each m_node In m_nodelist
		
		'Get the CURRENCY Attribute Value
		Dim currencyAttribute = m_node.Attributes.GetNamedItem("currency").Value
		'response.write("currencyAttribute: "&currencyAttribute.toString()&"<br/>")
		
		'Get the RATE Attribute Value
		Dim rateAttribute = m_node.Attributes.GetNamedItem("rate").Value
		'response.write("rateAttribute: "&rateAttribute.toString()&"<br/>")
	Next
	
	'response.write("<payment_confirmed>true</payment_confirmed>")
	
	


	'Dim FILENAME as String = Server.MapPath("/public/utils/nemesi_config.xml")

	'Get a StreamReader class that can be used to read the file
	'Dim objStreamReader as StreamReader
	'objStreamReader = File.OpenText(FILENAME)

	'Now, read the entire file into a string
	'Dim contents as String = objStreamReader.ReadToEnd()
	
	'response.write(String.Concat(contents,"<br><br>"))
	
	'objStreamReader.Close()

	'Create the XML Document
	'Dim m_xmld2 As XmlDocument = New XmlDocument()

	'Load the Xml file
	'm_xmld2.Load(new StringReader(contents))

	'Get the servername of the xml file
	'm_node = m_xmld2.SelectSingleNode("/config/currencysrvname")
	'response.write(String.Concat("node value: ",m_node.OuterXml))	
	
	'Application("currencysrvname") = m_node.OuterXml()

	response.write(String.Concat("<br>Application(TestCounterCurrency): ",Application("TestCounterCurrency") ,"<br>"))
	response.write(String.Concat("<br>Application(TestCounterDemo): ",Application("TestCounterDemo") ,"<br>"))
	response.write(String.Concat("<br>Application(filename): ",Application("filename") ,"<br>"))
	response.write(String.Concat("<br>Application(currencysrvname): ",Application("currencysrvname"),"<br>"))
	response.write(String.Concat("<br>Application(uriString): ",Application("uriString") ,"<br>"))
	response.write(String.Concat("<br>Application(uriString2): ",Application("uriString2") ,"<br>"))
	response.write(String.Concat("<br>Application(utils): ",Application("utils") ,"<br>"))
	response.write(String.Concat("<br>Application(error): ",Application("error") ,"<br>"))
	response.write(String.Concat("<br>Application(uriString): ",Application("uriString") ,"<br>"))
		
	


Catch errorVariable As Exception
	'Error trapping

	response.Write(errorVariable.ToString())
End Try

%>
</body>
</html>