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


<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<script type="text/javascript" src="/common/js/jquery-latest.min.js"></script>
	<script type="text/javascript" src="/common/js/jspdf.min.js"></script>

  <script type="text/javascript">
  
	function generatePdf(imgData){
		var query_string = "save=1&img_data="+encodeURIComponent(imgData);	
		
		$.ajax({
			async: true,
			type: "POST",
			cache: false,
			url: "/test/html2pdf3.aspx",
			data: query_string,
			success: function(response) {
				alert(response);
			},
			error: function(response) {
				alert(response.responseText);	
			}
		});	
	}  
  
  function PDF1(){
    var doc = new jsPDF('p', 'in', 'a4');
    var elementHandler = {
      '#ignorePDF': function (element, renderer) {
        return true;
      }
    };
    var source = window.document.getElementsByTagName("body")[0];
    doc.fromHTML(
      source,
      0.5,
      0.5,
      {
        'width': 180,
        'elementHandlers': elementHandler
      });

    var result = doc.output("datauristring");
    result = result.replace(/^data:application\/pdf;base64,/, "");
    generatePdf(result);
    //alert(result);
    }

    $( document ).ready(function() {
      //console.log( "ready!" );
      PDF1();
    });
</script>

  </head>

  <body>
    ASDSADASDASDSA
    <div>
      <p id="ignorePDF">don't print this to pdf</p>

      <p><font size="3" color="red">print this to pdf</font></p>
    </div>




  </body>
  </html>