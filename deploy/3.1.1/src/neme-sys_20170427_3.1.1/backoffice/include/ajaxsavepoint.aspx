<%@ Page Language="C#" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
private ASP.UserLoginControl login;
IGeolocalizationRepository georep;

protected void Page_Init(Object sender, EventArgs e)
{
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	login.acceptedRoles = "1,2";
	if(!login.checkedUser()){
		return;
	}
	
	georep = RepositoryFactory.getInstance<IGeolocalizationRepository>("IGeolocalizationRepository");
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;

	int id = Convert.ToInt32(Request["idp"]);
	string operation = Request["operation"];	
	Geolocalization point = new Geolocalization();
	point.id=id;	

	if(operation=="delete"){
		try
		{
			point = georep.getById(id);
			if(point.id>0){
				georep.delete(point);
			}
		}
		catch(Exception ex)
		{
			//Response.Write("An inner error occured: " + ex.Message);
		}
	}else{
		int idElement = Convert.ToInt32(Request["id_element"]);
		int type = Convert.ToInt32(Request["type"]);
		decimal latitude = Convert.ToDecimal(Request["latitude"].Replace(".",","));
		decimal longitude = Convert.ToDecimal(Request["longitude"].Replace(".",","));
		string txtInfo = Request["txtinfo"];
		//Response.Write("id:"+id+" - operation:"+operation+" - idElement:"+idElement+" - type:"+type+" - latitude:"+latitude+" - longitude:"+longitude+" - txtInfo:"+txtInfo);
		try
		{
			if(point.id>0){
				point = georep.getById(point.id);
				georep.delete(point);
			}
		}
		catch(Exception ex)
		{
			//Response.Write("An inner error occured: " + ex.Message);
		}
		point.idElement = idElement;
		point.type = type;
		point.latitude = latitude;
		point.longitude = longitude;
		point.txtInfo = txtInfo;
		georep.insert(point);
		Response.Write(point.id);
	}

}
</script>