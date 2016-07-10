<%@control Language="c#" description="user-profile-widget-control" className="UserProfileWidgetControl"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>

<script runat="server">  
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
private ConfigurationService configService;
private ICommentRepository commentrep;
private IUserPreferencesRepository preftrep;
bool logged;

private int _index;	
public int index {
	get { return _index; }
	set { _index = value; }
}
private string _style;	
public string style {
	get { if(_style!=null){return _style;}else{return "";} }
	set { _style = value; }
}
private string _cssClass;	
public string cssClass {
	get { if(_cssClass!=null){return _cssClass;}else{return "txtUserPreference";} }
	set { _cssClass = value; }
}
private string _model;	
public string model {
	get { if(_model!=null){return _model;}else{return "compact";} }
	set { _model = value; }
}

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
	login.acceptedRoles = "3";
	logged = login.checkedUser();
	commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
	preftrep = RepositoryFactory.getInstance<IUserPreferencesRepository>("IUserPreferencesRepository");
	configService = new ConfigurationService();
}
</script>


<%
if(logged){
  long total = 0;
  long percentual = 0;
  total = preftrep.countTotal(login.userLogged.id, true);
  percentual = preftrep.getPositivePercentage(login.userLogged.id);

  long total_comment_news = commentrep.countComments(login.userLogged.id,1,true,false);
  //<!--nsys-addsuser1-->//<!---nsys-addsuser1-->
  %>
  <br/>
  <div style="<%=style%>" class="<%=cssClass%>">
          <!--nsys-modcommunity7-->
          <%=lang.getTranslated("backend.utenti.detail.table.label.like")%>:&nbsp;<%=percentual%>%<br/>        
        <script type="text/javascript">
        $(function () {
          var chart;
          $(document).ready(function() {
            chart = new Highcharts.Chart({
              chart: {
                renderTo: 'usrprefchartbox',
                type: 'bar',
                width: 100,
                height: 70,
                spacingTop:-20,
                marginLeft:-1,
                marginRight:0
              },
              title: {
                text: ''
              },
              xAxis: {
                categories: [''],
                gridLineWidth:0
              },
              yAxis: {
                title: {
                  text: ''
                },
                min: 0,
                max:100,
                showFirstLabel:false,
                showLastLabel:false,
                gridLineWidth:0
              },
              tooltip: {
                enabled: false
              },            
              legend: {
                enabled: false
              },
              series: [{
                data: [
                {
                  color: 'blue',
                  y: <%=percentual%>
                }
                ]
              }]
            });
          });
        });
        </script>
        <div align="left" id="usrprefchartbox" style="width:100px;height:5px;border:#000000 1px solid;overflow: hidden;"></div>
        <%
        int endcounter=0;      
        if(percentual>0 && percentual<=20){
          endcounter=1; 
        }else if(percentual>20 && percentual<=40){ 
          endcounter=2; 
        }else if(percentual>40 && percentual<=60){
          endcounter=3; 
        }else if(percentual>60 && percentual<=80){ 
          endcounter=4; 
        }else if(percentual>80 && percentual<=100){ 
          endcounter=5; 
        }
        if(endcounter>0){%>
          <div align="left" id="usrprefstarsbox" style="width:100px;height:15px;">
          <%for(int starcount = 1; starcount<=endcounter; starcount++){%>
              <img width="14" height="15" src="/common/img/ico_stella.png" align="absmiddle" style="padding:0px;border:0px;">
          <%}%>
          </div><br/>
        <%}%>
        <%=lang.getTranslated("backend.utenti.detail.table.label.total_vote")%>:&nbsp;<%=total%><br/>
        <!---nsys-modcommunity7-->
        <%=lang.getTranslated("backend.utenti.detail.table.label.total_commenti_news")%>:&nbsp;<%=total_comment_news%>
        <!--nsys-addsuser2--><!---nsys-addsuser2-->
  </div>
<%}%>