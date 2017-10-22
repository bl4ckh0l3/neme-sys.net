<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Text.RegularExpressions" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;

protected ICountryRepository countryrep;
protected IList<Country> stateRegions;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;		
	login.acceptedRoles = "1";
	bool logged = login.checkedUser();		

	countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
	StringBuilder url = new StringBuilder("/error.aspx?error_code=");

	if(!login.checkedUser()){
		stateRegions = new List<Country>();
	}else{
		try{				
			stateRegions = countryrep.findStateRegionByCountry(Request["field_val"],"2,3");	
			if(stateRegions == null){				
				stateRegions = new List<Country>();						
			}
		}catch (Exception ex){
			stateRegions = new List<Country>();
		}
	}
}
</script>

<%if(stateRegions!=null && stateRegions.Count>0){
	foreach(Country sr in stateRegions){%>
		<option value="<%=sr.stateRegionCode%>"><%=lang.getTranslated("portal.commons.select.option.country."+sr.countryCode)+" "+lang.getTranslated("portal.commons.select.option.country."+sr.stateRegionCode)%></option> 
	<%}
}%>