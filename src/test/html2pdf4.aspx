<%@ Page Language="C#" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Diagnostics" %>
<%@ import Namespace="System.Drawing" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Web.UI" %>
<%@ import Namespace="System.Web.UI.WebControls" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 

<script runat="server">		

protected void Page_Load(Object sender, EventArgs e)
{

}
</script>
<html>
<head>
<script type="text/javascript" src="/common/js/jquery-latest.min.js"></script>
<script type="text/javascript" src="/common/js/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.3.3/jspdf.min.js"></script>
<script type="text/javascript" src="/common/js/jspdf.plugin.autotable.min.js"></script>

<script>
// https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.3.3/jspdf.min.js
// https://cdn.rawgit.com/simonbengtsson/jsPDF/requirejs-fix-dist/dist/jspdf.debug.js
// https://unpkg.com/jspdf-autotable@2.3.2

function generate() {
	var doc = new jsPDF('p', 'pt', 'a4');
	
	var c = document.createElement('canvas');
	var ctx = c.getContext('2d');
	var img = document.getElementById('invoice-logo');
	//c.height = img.naturalHeight;
	//c.width = img.naturalWidth;
	c.height = img.height;
	c.width = img.width;
	ctx.drawImage(img, 0, 0);
	var base64String = c.toDataURL('png'); 
	
	var pageContent = function (data) {
		if (base64String) {
			doc.addImage(base64String, 'png', data.settings.margin.left, 15, img.width, img.height);
		}
	}; 
	
	
	
	var res = doc.autoTableHtmlToJson(document.getElementById('invoice-table'));
	doc.autoTable(res.columns, res.data, {
		addPageContent: pageContent,
		//margin: {top: 20},
		startY: img.height+20,
		theme: 'grid',
		headerStyles: {fontStyle: 'normal',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1}
	});
	var res2 = doc.autoTableHtmlToJson(document.getElementById('invoice-table2'));
	doc.autoTable(res2.columns, res2.data, {
		startY: doc.autoTableEndPosY() + 10,
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1}
	});
	var res3 = doc.autoTableHtmlToJson(document.getElementById('invoice-table3'));
	doc.autoTable(res3.columns, res3.data, {
		startY: doc.autoTableEndPosY(),
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1}
	});
	var res4 = doc.autoTableHtmlToJson(document.getElementById('invoice-table4'));
	doc.autoTable(res4.columns, res4.data, {
		startY: doc.autoTableEndPosY(),
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1}
	});
	var res5 = doc.autoTableHtmlToJson(document.getElementById('invoice-table5'));
	doc.autoTable(res5.columns, res5.data, {
		startY: doc.autoTableEndPosY() + 10,
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1}
	});
	var res6 = doc.autoTableHtmlToJson(document.getElementById('invoice-table6'));
	doc.autoTable(res6.columns, res6.data, {
		startY: doc.autoTableEndPosY() + 10,
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1}
	});
	var res7 = doc.autoTableHtmlToJson(document.getElementById('invoice-table7'));
	doc.autoTable(res7.columns, res7.data, {
		startY: doc.autoTableEndPosY(),
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1}
	});
	
	
	//doc.save("table.pdf");

	var result = doc.output("datauristring");
	result = result.replace(/^data:application\/pdf;base64,/, "");	
	
	var query_string = "id_order=999&id_billing=111&img_data="+encodeURIComponent(result);	
	//alert(query_string);
	
	$.ajax({
		async: true,
		type: "POST",
		cache: false,
		url: "/backoffice/billings/ajaxbillingimagecreate.aspx",
		data: query_string,
		success: function(response) {
			alert(response);
		},
		error: function(response) {
			//alert(response.responseText);	
			alert("errore");
		}
	});		
}
</script>
</head>
<body>

<button onclick="generate()">Generate PDF</button>


				<table border="0" cellpadding="0" cellspacing="0" id="invoice-table" style="border:1px solid #C9C9C9;">
				<tr>
				<td style="width:300px;text-align:left;vertical-align:top;">
				
				<img src="/public/upload/files/billing_data/logo.png" id="invoice-logo" border="0" align="top" style="margin-bottom:15px;display:block;"/>
				
				<strong style="margin-bottom:20px;">Blackholenet shop</strong><br/>
				Via della valle, 44<br/>
				17027&nbsp;-&nbsp;Milanello&nbsp;&nbsp;Italia - (Calabria)<br/>
				C.F.-P.IVA-R.I. CCIAA PD:&nbsp;12345654321<br/>
				Telefono:&nbsp;00390394556657<br/>
				Fax:&nbsp;00390394556644<br/>
				www.blackholenet.com<br/>
				info@blackholenet.com<br/>
				Numero REA LC - 334455<br/>
				Capitale Sociale 100.000,00 € I.V.		
				</td>
				<td style="width:500px;text-align:left;vertical-align:top;">
				nome:&nbsp;Gino<br/>cognome:&nbsp;Pino<br/>sesso:&nbsp;M<br/>
				
				mail:&nbsp;blackhole01@gmail.com<br/>
				
				<br/><b>Indirizzo di spedizione:</b><br/>gino pino (Privato)<br/>via di qua<br/>12345&nbsp;-&nbsp;roma&nbsp;&nbsp;Italia - (Liguria)<br/>Cod fisc. - PIVA:&nbsp;12345678901<br/><br/><b>Dati fatturazione:</b><br/>gino pino<br/>via di qua<br/>12345&nbsp;-&nbsp;roma&nbsp;&nbsp;Italia - <br/>Cod fisc. - PIVA:&nbsp;1234567890<br/>				
				</td>
				</tr>
				</table>

				<table border="0" cellpadding="0" cellspacing="0" id="invoice-table2" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">				
				<tr>
				<th><b>Tipo documento</b></th>
				<th><b>Data documento</b></th>
				<th><b>Numero documento</b></th>
				</tr>
				<tr>
				<td>Fattura</td>
				<td>02/10/2017 17:01</td>
				<td>5/2017</td>
				</tr>	
				</table>

				<table border="0" cellpadding="0" cellspacing="0" id="invoice-table3" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">
				<tr>
				<th style="padding-top:10px;">ID ordine</th>
				<th style="padding-top:10px;">Data inserimento</th>
				<th style="padding-top:10px;">Stato ordine</th>
				</tr>
				<tr>
				<td>199</td>
				<td>28/09/2017 21:03</td>
				<td>inserito</td>	
				</tr>
				</table>

				<table border="0" cellpadding="0" cellspacing="0" id="invoice-table4" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">
				<tr>
				<th style="padding-top:10px;">GUID ordine</th>
				<th style="padding-top:10px;">Tipo pagamento</th>
				<th style="padding-top:10px;">Pagamento effettuato</th>
				</tr>
				<tr>
				<td>ba6cff8f-711d-4ca5-9112-a7fc015b08ed</td>
				<td>preventivo</td>
				<td>Si</td>
				</tr>
				</table>

				<table border="0" cellpadding="0" cellspacing="0" id="invoice-table5" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">									
					<tr>
					<th>NOME PRODOTTO</th>
					<th class="upper">Imponibile</th>
					<th class="upper">Imposta</th>
					<th>QUANTIT&Agrave;</th>	
					<th>ATTRIBUTI PRODOTTO</th>	
					<th>TIPO PRODOTTO</th>			
					</tr>														
					<tr class="table-list-off">
						<td>maglietta stupenda</td>
						<td>&euro;&nbsp;36,00
							<ul style=padding-left:10px;padding-top:5px;margin:0px;>
							
							</ul>
						</td>
						<td>&euro;&nbsp;7,20&nbsp;(IVA 20%)</td>
						<td>4</td>	
						<td>colore:&nbsp;nero<br/>taglia:&nbsp;m<br/></td>	
						<td>
						Trasportabile</td>	
					</tr>
				</table>

				<table border="0" cellpadding="0" cellspacing="0" id="invoice-table6" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">
				<tr>
				<th style="padding-top:10px;">Spese accessorie</th>
				<th style="padding-top:10px;">Commissioni</th>
				</tr>
				<tr>
				<td>bartolino corriere&nbsp;&nbsp;&nbsp;&euro;&nbsp;0,00<br/>confezione&nbsp;&nbsp;&nbsp;&euro;&nbsp;0,50<br/>imballaggio&nbsp;&nbsp;&nbsp;&euro;&nbsp;4,80<br/></td>
				<td >&euro;&nbsp;0,00</td>
				</tr>
				</table>

				<table border="0" cellpadding="0" cellspacing="0" id="invoice-table7" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">
				<tr>
				<th style="padding-top:10px;">Totale imponibile</th>
				<th style="padding-top:10px;">Totale imposta</th>
				<th style="padding-top:10px;">Totale ordine</th>
				</tr>
				<tr>
				<td>&euro;&nbsp;36,00</td>
				<td>&euro;&nbsp;7,20</td>
				<td>&euro;&nbsp;48,50</td>
				</tr>
				</table>





<table id="basic-table" style="display: none;">
    <tr>
      <td align="right">1</td>
      <td>Donna</td>
      <td>Moore</td>
      <td>dmoore0@furl.net</td>
      <td>China</td>
      <td>211.56.242.221</td>
    </tr>
    <tr>
      <td align="right">2</td>
      <td>Janice</td>
      <td>Henry</td>
      <td>jhenry1@theatlantic.com</td>
      <td>Ukraine</td>
      <td>38.36.7.199</td>
    </tr>
    <tr>
      <td align="right">3</td>
      <td>Ruth</td>
      <td>Wells</td>
      <td>rwells2@constantcontact.com</td>
      <td>Trinidad and Tobago</td>
      <td>19.162.133.184</td>
    </tr>
    <tr>
      <td align="right">4</td>
      <td>Jason</td>
      <td>Ray</td>
      <td>jray3@psu.edu</td>
      <td>Brazil</td>
      <td>10.68.11.42</td>
    </tr>
    <tr>
      <td align="right">5</td>
      <td>Jane</td>
      <td>Stephens</td>
      <td>jstephens4@go.com</td>
      <td>United States</td>
      <td>47.32.129.71</td>
    </tr>
    <tr>
      <td align="right">6</td>
      <td>Adam</td>
      <td>Nichols</td>
      <td>anichols5@com.com</td>
      <td>Canada</td>
      <td>18.186.38.37</td>
    </tr>
</table>




</body>
</html>