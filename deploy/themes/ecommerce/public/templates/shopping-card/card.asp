<%On Error Resume Next%>
<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/CardClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductsCardClass.asp" -->
<!-- #include virtual="/common/include/Objects/ShippingAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/BillsAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/UserFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/UserFieldClass.asp" -->
<!-- #include file="include/init2.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include file="include/initMeta2.inc" -->
<SCRIPT SRC="<%=Application("baseroot") & "/common/js/hashtable.js"%>"></SCRIPT>
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<!-- #include file="include/initStyleAndJs2.inc" -->
</head>
<body>
<div id="warp">
	<!-- #include virtual="/public/layout/include/header.inc" -->	
	<div id="container">	
		<!-- include virtual="/public/layout/include/menu_orizz.inc" -->
<!-- #include virtual="/public/layout/include/menu_vert_sx.inc" -->
		<div id="content-center">
			<!-- #include file="include/initContent2.inc" -->
		</div>
		<!-- #include virtual="/public/layout/include/menu_vert_dx.inc" -->
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>		
</body>
</html>
<!-- #include file="include/end2.inc" -->