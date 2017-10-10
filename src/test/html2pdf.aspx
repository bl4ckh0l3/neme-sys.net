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
	/*
	try
	{
		string labelBase64 = "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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADUw7IwAAAgxSURBVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/P/24JAAAAAAQND/194wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMBVb2NgPA5XuSUAAAAASUVORK5CYII=";
		
		Response.Write("labelBase64: "+labelBase64+"<br><br>");
		
		string basePath = "~/public/upload/files/billings";	
		string filePath = HttpContext.Current.Server.MapPath(basePath+"/billing.png");
		
		if(File.Exists(@filePath)){
			File.Delete(@filePath);
		}
		
		Response.Write("filePath: "+filePath+"<br><br>");
	
		CommonService.SaveFileFrom64(labelBase64, filePath);
	}
	catch(Exception ex)
	{
		Response.Write("An error occured: "+ex.Message+"<br><br><br>"+ex.StackTrace+"<br><br><br>"+ex.ToString());
	}
	*/
}
</script>
<html>
<head>
<script type="text/javascript" src="/common/js/jquery-latest.min.js"></script>
<script type="text/javascript" src="/common/js/html2canvas.min.js"></script>
<script type="text/javascript" src="/common/js/jspdf.min.js"></script>
</head>
<body>
<div id="content">
	<h1>test</h1>
	<button id="show_button">Show Image</button>
	<img src="/backoffice/img/email_go.png" title="test" hspace="2" vspace="0" border="0">
	//this is a problem
	<a onclick="downloadPNG()" href="">download</a>
	
	<a class="button" href="javascript:demoFromHTML()">Generate PDF</a>
	
	<a class="button" href="javascript:testPdf()">Generate TEST PDF</a>
	<div id="show_img"></div>
</div>

<script>
/*
$(function () {
  $("#show_button").click(function () {
    html2canvas(document.body, {
      onrendered: function (canvas) {
        $("<img/>", {
          id: "image",
          src: canvas.toDataURL("image/png"),
          width: '95%',
          height: '95%'
        }).appendTo($("#show_img").empty());
      }
    });
  });
});
*/

$("#show_button").on('click', function () {
   html2canvas(document.body, {
      onrendered: function (canvas) {
      	//data:image/png;base64,
      	
      	var imgageData = canvas.toDataURL("image/png");
      	
      	//var newData = imgageData.replace(/^data:image\/png/, "data:application/octet-stream");
      	var newData = imgageData.replace(/^data:image\/png;base64,/, "");
      	
      	$("#show_img").append(imgageData+"<br>"+newData);
      }
    });    
});

/*
downloadPNG = function () {
  html2canvas(document.body, {
    onrendered: function (canvas) {
      Canvas2Image.saveAsPNG(canvas);
    }
  });
}
*/
</script>

 <script>
function testPdf(){
	/*
	var doc = new jsPDF();
	doc.text(20, 20, 'Hello world!');
	doc.text(20, 30, 'This is client-side Javascript, pumping out a PDF.');
	doc.addPage();
	doc.text(20, 20, 'Do you like that?');
	
	doc.save('Test.pdf');
	*/
	
	var doc = new jsPDF();
	/*var specialElementHandlers = {
	'DIV to be rendered out': function(element, renderer){
	return true;
	}
	};*/
	
	
	var html=$('#content').html();
	doc.fromHTML(html,200,200, {
	'width': 500
	});
	doc.save("Test.pdf");
} 
 




	/*
    function demoFromHTML() {
        var pdf = new jsPDF('p', 'pt', 'letter');
        // source can be HTML-formatted string, or a reference
        // to an actual DOM element from which the text will be scraped.
        //source = $('#content')[0];
        source = $('body').get(0);
        
        //alert(source);

        // we support special element handlers. Register them with jQuery-style 
        // ID selector for either ID or node name. ("#iAmID", "div", "span" etc.)
        // There is no support for any other type of selectors 
        // (class, of compound) at this time.
        specialElementHandlers = {
            // element with id of "bypass" - jQuery style selector
            '#bypassme': function (element, renderer) {
                // true = "handled elsewhere, bypass text extraction"
                return true
            }
        };
        margins = {
            top: 80,
            bottom: 60,
            left: 40,
            width: 522
        };
        // all coords and widths are in jsPDF instance's declared units
        // 'inches' in this case
        pdf.fromHTML(
        source, // HTML string or DOM elem ref.
        margins.left, // x coord
        margins.top, { // y coord
            'width': margins.width, // max width of content on PDF
            'elementHandlers': specialElementHandlers
        },

        function (dispose) {
            // dispose: object with X, Y of the last line add to the PDF 
            //          this allow the insertion of new lines after html
            pdf.save('Test.pdf');
        }, margins);
    }
    */
 </script>
 
    <script type="text/javascript">
    /*
        $(document).ready(function() {
                var getImageFromUrl = function(url, callback) {
                var img = new Image();
                img.onError = function() {
                alert('Cannot load image: "'+url+'"');
                };
                img.onload = function() {
                callback(img);
                };
                img.src = url;
                }
                var createPDF = function(imgData) {
                var doc = new jsPDF('p', 'pt', 'a4');
                var width = doc.internal.pageSize.width;    
                var height = doc.internal.pageSize.height;
                var options = {
                     pagesplit: true
                };
                doc.text(10, 20, 'Crazy Monkey');
                var h1=50;
                var aspectwidth1= (height-h1)*(9/16);
                doc.addImage(imgData, 'png', 10, h1, aspectwidth1, (height-h1), 'monkey');
                doc.addPage();
                doc.text(10, 20, 'Hello World');
                var h2=30;
                var aspectwidth2= (height-h2)*(9/16);
                doc.addImage(imgData, 'png', 10, h2, aspectwidth2, (height-h2), 'monkey');
                doc.output('datauri');
            }
                getImageFromUrl('/backoffice/img/email_go.png', createPDF);
                });
    */
    </script> 

    
    
<a href="javascript:demoFromHTML()" class="button">

<div id="testcase">

<h1>
We support special element handlers. Register them with jQuery-style.
</h1>

</div>    
<script>
function demoFromHTML() {
var doc = new jsPDF('p', 'in', 'letter');
var source = $('#testcase').first();
var specialElementHandlers = {
'#bypassme': function(element, renderer) {
return true;
}
};

doc.fromHTML(
source, // HTML string or DOM elem ref.
0.5, // x coord
0.5, // y coord
{
'width': 7.5, // max width of content on PDF
'elementHandlers': specialElementHandlers
});

doc.output('dataurl');
}
</script>
</body>
</html>