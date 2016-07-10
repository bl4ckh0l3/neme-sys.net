<%@Page Language="c#"%>
<%
int menu_closed = 0;
if(!String.IsNullOrEmpty(Request["menu_closed"])) {
	menu_closed = Convert.ToInt32(Request["menu_closed"]);
}
if(menu_closed==1){
	Session["menu_closed"] = true;
}else{
	Session["menu_closed"] = false;
}
%>