<%@ Page Language="C#" AutoEventWireup="true" CodeFile="content.aspx.cs" Inherits="_TransferContent" Debug="false" %>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="MenuTransferFooterControl" TagName="insert" Src="~/public/layout/include/menu-transfer.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<!DOCTYPE html>
<html>
<head> 
	<title><%=pageTitle%></title>
	<META name="description" CONTENT="<%=metaDescription%>">
	<META name="keywords" CONTENT="<%=metaKeyword%>">
	<META name="autore" CONTENT="Neme-sys; email:info@shuttlegenius.com">
	<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">    
	
	<CommonCssJs:insert runat="server" />
	<script>
	function openAttach(path, fileName, idAttach, contentType){
	
		var query_string = "attach_id="+idAttach+"&attach_path="+path+"&page_url=<%=Request.Url%>&contenttype="+contentType+"&filename="+fileName;
		//alert(query_string);
		$.ajax({
			async: false,
			type: "POST",
			cache: false,
			url: "/public/layout/addson/tracking/ajaxlogdownload.aspx",
			data: query_string,
			success: function(response) {
				//alert("response: "+response);
				
			},
			error: function() {
				//alert("error");
			}
		});	
		
		window.open('/public/upload/files/contents/'+path, '_blank');
	}
	</script>

	<!--[if IE]>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<![endif]-->
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<!-- Favicon -->
	<link rel="apple-touch-icon-precomposed" sizes="144x144" href="#">
	<link rel="shortcut icon" href="#">
	<!-- CSS Global -->
	<link href="/common/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet">
	<link href="/common/plugins/bootstrap-select/css/bootstrap-select.min.css" rel="stylesheet">
	<link href="/common/plugins/fontawesome/css/font-awesome.min.css" rel="stylesheet">
	<link href="/common/plugins/owl-carousel2/assets/owl.carousel.min.css" rel="stylesheet">
	<link href="/common/plugins/owl-carousel2/assets/owl.theme.default.min.css" rel="stylesheet">
	<link href="/common/plugins/datetimepicker/css/bootstrap-datetimepicker.min.css" rel="stylesheet">
	<!-- Theme CSS -->
	<link href="/common/css/theme.css" rel="stylesheet">
	<!-- Head Libs -->
	<script src="/common/plugins/modernizr.custom.js"></script>
	<!--[if lt IE 9]>
	<script src="/common/plugins/iesupport/html5shiv.js"></script>
	<script src="/common/plugins/iesupport/respond.min.js"></script>
	<![endif]-->
	<script src="/common/plugins/bootstrap/js/bootstrap.min.js"></script>
	<script src="/common/plugins/bootstrap-select/js/bootstrap-select.min.js"></script>	
	<script src="/common/plugins/jquery.easing.min.js"></script>
	<script src="/common/plugins/jquery.smoothscroll.min.js"></script>
	<script src="/common/plugins/datetimepicker/js/moment-with-locales.min.js"></script>
	<script src="/common/plugins/datetimepicker/js/bootstrap-datetimepicker.min.js"></script>   

</head>
<body id="home" class="wide">

      <!-- PRELOADER -->
      <div id="preloader">
         <div id="preloader-status">
            <div class="spinner">
               <div class="rect1"></div>
               <div class="rect2"></div>
               <div class="rect3"></div>
               <div class="rect4"></div>
               <div class="rect5"></div>
            </div>
            <div id="preloader-title"><lang:getTranslated keyword="frontend.transfer.search.preloader.title" runat="server" /></div>
         </div>
      </div>
      <!-- /PRELOADER -->
      
      <!-- WRAPPER -->
      <div class="wrapper">
         <!-- HEADER -->
         <header class="header fixed">
            <div class="header-wrapper">
               <div class="container">
                  <!-- Logo -->
                  <!--div class="logo"-->
                     <a href="<%=mainPage%>">
                     <!--img src="/common/img/Logo.png" alt="<lang:getTranslated keyword="frontend.transfer.search.logo.alt" runat="server" />"/-->
                     <img src="/common/img/logo_tentative.png" height="62px" alt="<lang:getTranslated keyword="frontend.transfer.search.logo.alt" runat="server" />"/>
                     </a>
                  <!--/div-->
                  <!-- /Logo -->
               </div>
            </div>
         </header>
         <!-- /HEADER -->
         <!-- CONTENT AREA -->
         <div class="content-area">
       
            <!-- PAGE -->
            <%if (content != null) {%>
            <section class="page-section">
               <div class="container">
                  <div class="row">
					 <div class="caption">
						  <h4 class="caption-title"><asp:Literal id="ctitle" runat="server" /></h4>
						  <div class="caption-text"><asp:Literal id="csummary" runat="server" /></div>
						  <div class="caption-text"><asp:Literal id="cdescription" runat="server" /></div>
						  
							<%
							if(contentFields.Count>0){ 
								Response.Write(ContentService.renderField(contentFields, null, "", "", lang.currentLangCode, lang.defaultLangCode));
							}
							
							if(attachmentsDictionary.Keys.Count>0){ 
								foreach(string keyword in attachmentsDictionary.Keys){%>
									<br/><br/><strong><%=keyword%></strong><br/>
									<%foreach(ContentAttachment item in attachmentsDictionary[keyword]){%>
										<a href="javascript:openAttach('<%=item.filePath+item.fileName%>','<%=item.fileName%>','<%=item.id%>','<%=item.contentType%>')"><%=item.fileName%></a><br>
									<%}
								}
							}%>						  
					 </div>
                  </div>
               </div>
            </section>
            <%}%> 
            <!-- /PAGE -->

         </div>
         <!-- /CONTENT AREA -->
         
         <!-- FOOTER -->
         <footer class="footer">
         	<MenuTransferFooterControl:insert runat="server"/>
            
            <div class="footer-meta">
               <div class="container">
                  <div class="row">
                     <div class="col-sm-12">
                        <div class="copyright">
                        &copy; <asp:Literal id="copyr" runat="server" /> <lang:getTranslated keyword="frontend.bottom.label.copyright" runat="server" />
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </footer>
         <!-- /FOOTER -->
         <div id="to-top" class="to-top"><i class="fa fa-angle-up"></i></div>
      </div>
      <!-- /WRAPPER -->
      <!-- JS Global -->
      <script src="/common/js/theme.js"></script>
</body>
</html>