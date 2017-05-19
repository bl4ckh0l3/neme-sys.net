<%@control Language="c#" description="common-user-logged-control" className="UserLoginControl"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<script runat="server">
protected IUserRepository userep;

private string _acceptedRoles;	
public string acceptedRoles {
	get { return _acceptedRoles; }
	set { _acceptedRoles = value; }
}

private User _userLogged;
public User userLogged {
	get { return _userLogged; }
}

public void updateUserLogged(User updated)
{
	this._userLogged = updated;
	Session["user-logged"] = this._userLogged;
}

public bool checkedUser()
{
	//Response.Write("<b>LoginControl.checkedUser</b><br>");
	HttpCookie checkCookie = new HttpCookie("CheckCookie");
	checkCookie = Request.Cookies["KeepLoggedUser"];
	if(checkCookie!=null && !String.IsNullOrEmpty(checkCookie.Value))
	{
		int usrid = Convert.ToInt32(checkCookie.Value);
		userep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		_userLogged = userep.getByParams(usrid, true, true, true, true, true, true);
	}
	if(_userLogged==null)
	{
		_userLogged = (User)Session["user-logged"];
	}
	else
	{
		Session["user-logged"] = _userLogged;
	}
	
	if(_userLogged!= null){
		if(checkedRoles()){
			return true;		
		}
	}	
	return false;
}

private bool checkedRoles()
{
	if(!String.IsNullOrEmpty(_acceptedRoles))
	{
		bool isIn = false;
		string[] roles = _acceptedRoles.Split(',');
		foreach (string role in roles)
		{
			UserRole currole = userLogged.role;
			isIn = currole.isInRole(Convert.ToInt32(role));
			if(isIn){
				return true;
			}
		}
		
		if(!isIn)
		{
			return false;
		}
	
	}	
	return true;
}

protected void Page_Load(Object sender, EventArgs e)
{
	if(!checkedUser()){
		Response.Redirect(Utils.getBaseUrl(Request.Url.ToString(),1).ToString()+"login.aspx?error_code=002");
	}
}
</script>