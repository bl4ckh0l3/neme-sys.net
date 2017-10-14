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

  var doc = new jsPDF('p', 'pt');

  var res = doc.autoTableHtmlToJson(document.getElementById("invoice-table"));
  doc.autoTable(res.columns, res.data, {margin: {top: 80}});
  

  /*
  var header = function(data) {
    doc.setFontSize(18);
    doc.setTextColor(40);
    doc.setFontStyle('normal');
    //doc.addImage(headerImgData, 'JPEG', data.settings.margin.left, 20, 50, 50);
    doc.text("Testing Report", data.settings.margin.left, 50);
  };

  var options = {
    beforePageContent: header,
    margin: {
      top: 80
    },
    startY: doc.autoTableEndPosY() + 20
  };

  doc.autoTable(res.columns, res.data, options);
  */

  doc.save("table.pdf");
}
</script>
</head>
<body>

<button onclick="generate()">Generate PDF</button>



				<table border="0" cellpadding="0" cellspacing="0" id="invoice-table">
				<tr>
				<td style="width:40%;">
				
				<img src="/public/upload/files/billing_data/logo.png" border="0" align="top" style="margin-bottom:15px;display:block;"/>
				
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
				<td style="width:60%;" colspan="2">
				nome:&nbsp;Gino<br/>cognome:&nbsp;Pino<br/>sesso:&nbsp;M<br/>
				
				mail:&nbsp;blackhole01@gmail.com<br/>
				
				<br/><b>Indirizzo di spedizione:</b><br/>gino pino (Privato)<br/>via di qua<br/>12345&nbsp;-&nbsp;roma&nbsp;&nbsp;Italia - (Liguria)<br/>Cod fisc. - PIVA:&nbsp;12345678901<br/><br/><b>Dati fatturazione:</b><br/>gino pino<br/>via di qua<br/>12345&nbsp;-&nbsp;roma&nbsp;&nbsp;Italia - <br/>Cod fisc. - PIVA:&nbsp;1234567890<br/>				
				</td>
				</tr>

				<tr>
				<th style="width:40%">Tipo documento</th>
				<th style="width:30%">Data documento</th>
				<th style="width:30%">Numero documento</th>
				</tr>
				<tr>
				<td>Fattura</td>
				<td>02/10/2017 17:01</td>
				<td>5/2017</td>
				</tr>				
				<tr>
				<th>ID ordine</th>
				<th>Data inserimento</th>
				<th>Stato ordine</th>
				</tr>
				<tr>
				<td>199</td>
				<td>28/09/2017 21:03</td>
				<td>
				inserito</td>	
				</tr>
				<tr>
				<th>GUID ordine</th>
				<th>Tipo pagamento</th>
				<th>Pagamento effettuato</th>
				</tr>
				<tr>
				<td>ba6cff8f-711d-4ca5-9112-a7fc015b08ed</td>
				<td>preventivo</td>
				<td>Si</td>
				</tr>
				<tr>
				<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
				<td colspan="3">
					<table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table">							
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
							
					</table><br/>
				</td>
				</tr>
				<tr>
				<th>Spese accessorie</th>
				<th>Commissioni</th>
				<th>&nbsp;</th>
				</tr>
				<tr>
				<td>bartolino corriere&nbsp;&nbsp;&nbsp;&euro;&nbsp;0,00<br/>confezione&nbsp;&nbsp;&nbsp;&euro;&nbsp;0,50<br/>imballaggio&nbsp;&nbsp;&nbsp;&euro;&nbsp;4,80<br/></td>
				<td >&euro;&nbsp;0,00</td>
				<td>&nbsp;</td>
				</tr>
				<tr>
				<th>Totale imponibile</th>
				<th>Totale imposta</th>
				<th>Totale ordine</th>
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