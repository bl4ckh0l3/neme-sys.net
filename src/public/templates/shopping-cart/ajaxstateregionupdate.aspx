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
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;

protected ICountryRepository countryrep;
protected IList<Country> stateRegions;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;		
	login.acceptedRoles = "";
	bool logged = login.checkedUser();		

	countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
	StringBuilder url = new StringBuilder("/error.aspx?error_code=");

	try{				
		stateRegions = countryrep.findStateRegionByCountry(Request["field_val"],"2,3");	
		if(stateRegions == null){				
			stateRegions = new List<Country>();						
		}
	}catch (Exception ex){
		stateRegions = new List<Country>();
	}	
}
</script>

<%if(stateRegions!=null && stateRegions.Count>0){
	foreach(Country sr in stateRegions){%>
		<option value="<%=sr.stateRegionCode%>"><%=lang.getTranslated("portal.commons.select.option.country."+sr.countryCode)+" "+lang.getTranslated("portal.commons.select.option.country."+sr.stateRegionCode)%></option> 
	<%}
}%>