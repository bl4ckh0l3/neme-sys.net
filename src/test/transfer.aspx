<%@ Page Language="C#" Debug="true"%>

<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.Net.Security" %>
<%@ import Namespace="System.Security.Cryptography" %>
<%@ import Namespace="System.Security.Cryptography.X509Certificates" %>
<!--%@ import Namespace="RestSharp" %-->
<!--%@ import Namespace="RestSharp.Authenticators" %-->


<script runat="server">
protected List<Transfer> tresult = new List<Transfer>();
protected DateTime searchDtOut = DateTime.Now;
protected DateTime searchDtRtn = DateTime.Now;
protected string searchFrom = null;
protected string searchTo = null;
protected IDictionary<string,string> types = new Dictionary<string,string>();
protected IDictionary<int,int> durations = new Dictionary<int,int>();
protected List<int> sortedDurations = new List<int>();
protected string minDuration = "0";
protected string maxDuration = "0";
protected string durationsRange = "";

public static bool ValidateServerCertificate(
      object sender,
      X509Certificate certificate,
      X509Chain chain,
      SslPolicyErrors sslPolicyErrors)
{
	//System.Web.HttpContext.Current.Response.Write("(sslPolicyErrors == SslPolicyErrors.None):<br>"+(sslPolicyErrors == SslPolicyErrors.None));

	if (sslPolicyErrors == SslPolicyErrors.None)
        return true;

    //Console.WriteLine("Certificate error: {0}", sslPolicyErrors);

    // Do not allow this client to communicate with unauthenticated servers.
    return false;
}


public bool callback(object obj, X509Certificate cert, X509Chain chain, SslPolicyErrors err)
{
	return true;
}


public string HttpCall(string url, string method, string strPost){
	string result="";

	//To Add the credentials from the profile

	//System.Web.HttpContext.Current.Response.Write("url: " + url+"<br>strPost: " + strPost+"<br><br>");

		
	HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
	if(!string.IsNullOrEmpty(method)){
		request.Method = method;	
	}
	request.ServerCertificateValidationCallback += new System.Net.Security.RemoteCertificateValidationCallback(callback); 
	
	request.ContentType = "application/json; charset=utf-8";
	//request.ContentType = "application/x-www-form-urlencoded";
	//request.Timeout = Timeout;	
	//request.PreAuthenticate = true;
	//request.KeepAlive = true;
	
	//request.Headers.Add("X-TripGo-Key", "14b0d25af44a7fd9114227f471f87f2d");
	request.Headers.Add("api-key", "priv_FwHibPUhdRhesMuwFLRFPHfAb");
	//request.Headers.Add("authref", "hackathon");
	
	ServicePointManager.Expect100Continue = true;
	ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls | (SecurityProtocolType)3072;
	ServicePointManager.ServerCertificateValidationCallback += new System.Net.Security.RemoteCertificateValidationCallback(callback); 
	
		
	if("POST".Equals(method)){
		byte[] byteArray = Encoding.UTF8.GetBytes (strPost);
		request.ContentLength = byteArray.Length;
		Stream dataStream = request.GetRequestStream();
		dataStream.Write (byteArray, 0, byteArray.Length);
		dataStream.Close();
	}
	
	
	/*
	using (var streamWriter = new StreamWriter(request.GetRequestStream()))
	{
		string json = new JavaScriptSerializer().Serialize(new
				{"details" : {
				"name" : "Arthur Dent",
				"email" : "arthur@example.com",
				"phone" : "+4470123456789",
				"allnames" : [ "Arthur Dent", "Ford Prefect" ]
				},
				"out" : {
				"sequence" : 1,
				"dt" : "2016-11-21T11:10",
				"pax" : { "adult": 1, "child": 1 },
				"extras" : { }
				}
				}
				);
		streamWriter.Write(json);
		streamWriter.Flush();
		streamWriter.Close();
	}	
	*/
	
	using (WebResponse myWebResponse = request.GetResponse())
	{			
		// Obtain a 'Stream' object associated with the response object.
		Stream ReceiveStream = myWebResponse.GetResponseStream();							
		Encoding encode = System.Text.Encoding.GetEncoding("utf-8");						
		// Pipe the stream to a higher level stream reader with the required encoding format. 
		StreamReader readStream = new StreamReader( ReceiveStream, encode );					
		result = readStream.ReadToEnd();	
	}         
	 
	return result;
}


protected void Page_Load(Object sender, EventArgs e)
{
	try
	{
		/*** TEST CALL EXAMPLE
		http://www.blackholenet.com/test/transfer.aspx?from_type=geo&to_type=geo&pickupName=Aeroporto+di+Milano-Malpensa&pickupLatitude=45.6300625&pickupLongitude=8.725530700000036&dropoffName=Milano+Centrale&dropoffLatitude=45.4870123&dropoffLongitude=9.205478999999968&pickupDate=2018-10-01&trip=return&returnDate=2018-10-03
		***/
		
		
		/********* 
		retrieve search parameters	
		
		http://www.blackholenet.com/test/transfer.aspx?
		from_type=geo
		&to_type=geo
		&pickupName=Aeroporto+di+Milano-Malpensa
		&pickupLatitude=45.6300625
		&pickupLongitude=8.725530700000036
		&dropoffName=Via+Fabio+Filzi
		&dropoffLatitude=45.4847353
		&dropoffLongitude=9.200556699999993
		&pickupDate=2018-09-01
		&trip=return
		&returnDate=2018-09-03	
		
		*********/
		
		string sfrom_type = Request["from_type"];
		string sfrom = Request["pickupLatitude"]+","+Request["pickupLongitude"];
		string sto_type = Request["to_type"];
		string sto = Request["dropoffLatitude"]+","+Request["dropoffLongitude"];
		string sdtout = Request["pickupDate"]+"T12:00";
		string sdtrtn = "";
		if(!string.IsNullOrEmpty(Request["returnDate"])){
			sdtrtn = Request["returnDate"]+"T12:00";
		}
		
		string urlCall = "https://orange.indigo-connect.com/e/3/search?";
		urlCall+="from_type="+sfrom_type;
		urlCall+="&from="+sfrom;
		urlCall+="&to_type="+sto_type;
		urlCall+="&to="+sto;
		urlCall+="&out_dt="+sdtout;
		if(!string.IsNullOrEmpty(sdtrtn)){
			urlCall+="&rtn_dt="+sdtrtn;
		}
		
		//Response.Write(urlCall);
	
	
		//************************* DIRECT HTTPREQUEST IMPLEMENTATION *************************
		
		//string jsonresult = HttpCall("https://jsonplaceholder.typicode.com/posts","GET","");	
		//string jsonresult = HttpCall("https://api.publicapis.org/entries","GET","");	
		//string jsonresult = HttpCall("https://api.tripgo.com/v1/routing.json?from=(39.6989777,-104.96610620000001)&to=(39.745,-104.994)&departAfter=1532466000&arriveBefore=0&modes[]=ps_tax_FLITWAYS&wp=(1,1,1,1)&tt=0&unit=auto&v=11&locale=en&ir=1&ws=1&cs=1","GET","");
		
		/** INDIGO CONNECT: SEARCH **/
		//string jsonresult = HttpCall("https://orange.indigo-connect.com/e/3/search?from_type=iata&from=MXP&to_type=geo&to=45.6958,9.0582&out_dt=20180911&rtn_dt=20180913","GET","");
		//string jsonresult = HttpCall("https://orange.indigo-connect.com/e/3/search?from_type=iata&from=MXP&to_type=geo&to=45.4846422,9.2010603&out_dt=2018-09-01T12:00&rtn_dt=2018-09-02T12:00","GET","");
		//string jsonresult = "{'status':'ok','results':[{'search_id':'S-nWWeFG-7sSKtx9xndxfkduMfjKYpH','search_app':'perkm','out_dt':'20180901','out':{'search_id':'S-nWWeFG-7sSKtx9xndxfkduMfjKYpH','bookable':true,'realtime_mobile':true,'must_print':false,'must_deliver':false,'liveticket_operation':'driver_code','rules':{'show_rules':true,'cancelonstrike':false,'paxaction':false,'tpcancel':false,'pxmodify':false,'ticketvalidity':'journeyonly','refundable':true},'delivery':{'ca':'walk_up_to_taxi_rank','ac':'walk_up_to_taxi_rank','pp':'walk_up_to_taxi_rank'},'price_basis':'vehicle','direction':'AC','from':{'iata':'MXP','display':'Milan MXP','display2':'Milan Malpensa (MXP)','address':'Milan Malpensa (MXP), Italy','stop_id':'MXPT1','source':'indigo','type':'airport','geometry':{'type':'Point','coordinates':[8.714089393615723,45.62733415423001]},'is_pickup':true},'pickup':{'display':'Milan MXP','display2':'Milan Malpensa (MXP)','stop_id':'MXPT1','geometry':{'type':'Point','coordinates':[8.714089393615723,45.62733415423001]},'is_from':true},'dropoff':{'display':'23 Via Rampoldi','display2':'Via Rampoldi, 23, 22070 Bregnano CO, Italy','stop_id':'G:ChIJS3DN6qeQhkcRLjdj4AqcxB4','geometry':{'type':'Point','coordinates':[9.0584887,45.69586349999999]},'is_to':true},'to':{'iata':null,'display':'23 Via Rampoldi','display2':'Via Rampoldi, 23, 22070 Bregnano CO, Italy','address':'Via Rampoldi, 23, 22070 Bregnano CO, Italy','stop_id':'G:ChIJS3DN6qeQhkcRLjdj4AqcxB4','source':'google','type':'stop','geometry':{'type':'Point','coordinates':[9.0584887,45.69586349999999]},'is_dropoff':true},'polylines':{'from_pickup':null,'pickup_dropoff':'','dropoff_to':null},'times':{'dt_requested':'20180901','tz':'Europe/Paris','dt_depart':'20180901','dt_arrive':'2018-09-01T00:47','duration':2841,'dt':'20180901'},'journey_time':2841,'distance':39.7,'is_scheduled':false,'max_pax':3,'type':'TX','operator':'Yellow Taxi Multiservice','operator_id':'milan6969','route_id':'milan6969.taxi','service_name':'Yellow Taxi Multiservice','line_name':'Sedan','info_url':null,'images':[{'src':'https://front.indigo-connect.com/api-assets/vehicle-large/94cf856388640d130636bca7fba64bda-0-l.jpg','thumb':'https://front.indigo-connect.com/api-assets/vehicle-small/94cf856388640d130636bca7fba64bda-0-s.jpg','featured':true,'generic':false}],'logo':{'bw':'https://front.indigo-connect.com/api-assets/logo-web-bw/milan6969.png','colour':null,'print':'https://front.indigo-connect.com/api-assets/logo-ticket-bw/milan6969.png','liveticket':null},'services':{'morning':null,'daytime':null,'evening':null,'overnight':null},'tags':{'active':['private','changes','cancelations','certified','insurance','flighttrack','wheelchair','pets','bagoversize','baghold','bagcabin','stroller','golf','bike'],'tags':[{'tag':'wifi','type':'rt','active':false},{'tag':'green','type':'rt','active':false},{'tag':'excludestip','type':'rt','active':false},{'tag':'notsheltered','type':'rt','active':false},{'tag':'noenglish','type':'op','active':false},{'tag':'indestination','type':'op','active':false},{'tag':'private','type':'ca','active':true},{'tag':'doortodoor','type':'ca','active':false},{'tag':'changes','type':'ca','active':true},{'tag':'cancelations','type':'ca','active':true},{'tag':'highfrequency','type':'ca','active':false},{'tag':'certified','type':'ca','active':true},{'tag':'insurance','type':'ca','active':true},{'tag':'24hservice','type':'ca','active':false},{'tag':'flexibleticket','type':'ca','active':false},{'tag':'eticket','type':'ca','active':false},{'tag':'flighttrack','type':'ca','active':true},{'tag':'needmobile','type':'ca','active':false},{'tag':'paper','type':'ca','active':false},{'tag':'print','type':'ca','active':false},{'tag':'wheelchair','type':'ex','active':true},{'tag':'pets','type':'ex','active':true},{'tag':'childseat_a','type':'ex','active':false},{'tag':'childseat_b','type':'ex','active':false},{'tag':'childseat_c','type':'ex','active':false},{'tag':'childseat_d','type':'ex','active':false},{'tag':'meetandgreet','type':'ex','active':false},{'tag':'guidedog','type':'ex','active':false},{'tag':'bagoversize','type':'bg','active':true},{'tag':'bagstandard','type':'bg','active':false},{'tag':'baghold','type':'bg','active':true},{'tag':'bagcabin','type':'bg','active':true},{'tag':'stroller','type':'bg','active':true},{'tag':'golf','type':'bg','active':true},{'tag':'skis','type':'bg','active':false},{'tag':'bike','type':'bg','active':true},{'tag':'instruments','type':'bg','active':false},{'tag':'bigdelicate','type':'bg','active':false},{'tag':'bigheavy','type':'bg','active':false},{'tag':'bigsports','type':'bg','active':false}]},'fares':[],'pax':{'infant':0,'student':0,'child':0,'senior':0,'adult':1},'pax_types':{'infant':'infant','child':'child','student':'student','adult':'adult','senior':'senior'},'advance_booking_dt_out_min':'2018-08-10T09:48','advance_booking_dt_out_max':'2019-02-06T00:00','advance_booking_dt_rtn_max':'2019-02-06T00:00','walking_dist_depart':null,'walking_dist_arrival':null,'user_cost_basefare':{'amount':107.14,'currency':'EUR','is_return_fare':false}},'details':{'out':[{'legacy':true,'can_change':false,'label':'Drop-off street address for trip from airport','name':'acdropoff','optional':false,'type':'text'},{'legacy':true,'can_change':false,'label':'Outbound Pickup Date','name':'outdate','optional':false,'type':'date'},{'legacy':true,'can_change':false,'label':'Outbound Pickup Time','name':'outtime','optional':false,'type':'time'},{'legacy':true,'can_change':false,'label':'Name','name':'name','optional':false,'type':'text'},{'legacy':false,'can_change':false,'label':'Mobile Phone','name':'phone','optional':false,'type':'text'},{'legacy':false,'can_change':false,'label':'Email for Ticketing','name':'email','optional':false,'type':'text'}],'rtn':[{'legacy':true,'can_change':false,'label':'Pick-up street address for trip to airport','name':'capickup','optional':false,'type':'text'},{'legacy':true,'can_change':false,'label':'Name','name':'name','optional':false,'type':'text'},{'legacy':false,'can_change':false,'label':'Mobile Phone','name':'phone','optional':false,'type':'text'},{'legacy':false,'can_change':false,'label':'Email for Ticketing','name':'email','optional':false,'type':'text'}]},'extras':{'out':[{'label':'Luggage (Standard Checkin/Hold Size)','tags':['luggage'],'name':'bagstandard','number_required':false,'max':3,'first_free':false,'cost':0},{'label':'Wheelchair','tags':[],'name':'wheelchair','book':true,'max':1,'first_free':false,'cost':0},{'label':'Pets','tags':[],'name':'pets','book':true,'max':1,'first_free':false,'cost':0},{'label':'Luggage (Oversize)','tags':['luggage'],'name':'bagoversize','number_required':false,'book':true,'first_free':false,'cost':0},{'label':'Buggy/Stroller','tags':['luggage'],'name':'stroller','book':true,'max':1,'first_free':false,'cost':0},{'label':'Golf Clubs','tags':['luggage'],'name':'golf','number_required':false,'book':true,'max':1,'first_free':false,'cost':0},{'label':'Pairs of Skis','tags':['luggage'],'name':'skis','number_required':false,'book':true,'first_free':false,'cost':0},{'label':'Bicycle','tags':['luggage'],'name':'bike','number_required':false,'book':true,'max':1,'first_free':false,'cost':0}],'rtn':[{'label':'Luggage (Standard Checkin/Hold Size)','tags':['luggage'],'name':'bagstandard','number_required':false,'max':3,'first_free':false,'cost':0},{'label':'Wheelchair','tags':[],'name':'wheelchair','book':true,'max':1,'first_free':false,'cost':0},{'label':'Pets','tags':[],'name':'pets','book':true,'max':1,'first_free':false,'cost':0},{'label':'Luggage (Oversize)','tags':['luggage'],'name':'bagoversize','number_required':false,'book':true,'first_free':false,'cost':0},{'label':'Buggy/Stroller','tags':['luggage'],'name':'stroller','book':true,'max':1,'first_free':false,'cost':0},{'label':'Golf Clubs','tags':['luggage'],'name':'golf','number_required':false,'book':true,'max':1,'first_free':false,'cost':0},{'label':'Pairs of Skis','tags':['luggage'],'name':'skis','number_required':false,'book':true,'first_free':false,'cost':0},{'label':'Bicycle','tags':['luggage'],'name':'bike','number_required':false,'book':true,'max':1,'first_free':false,'cost':0}]},'can_refund':false,'can_modify':false,'deeplink':{'details':'https://orange.indigo-connect.com/go/kpr8G6m23DSwR6dmRBRyiv6qoZJqPyuBbakDQ2lohVP6yewbePTMgJQpNBM7SgYnjN','booking':'https://orange.indigo-connect.com/go/P71GabejdEuY2beR2O2jSr3q7ayqY8CD5m3keVQwSGw748B28wf8ovrVgjdjFLnaM1','landing':'https://orange.indigo-connect.com/go/dGXOA7ZN2DUJ2N0X2k23S7rWjZJWwnSBOeZyLl6khr7bY1aE17FyVBad6QVeH7V42N'},'image_key':null,'cost_lineitems':[{'item':'Peak Fare - 1 - Sedan (Public Hire Taxi)','currency':'EUR','amount':'102.85','unit':'','subtotal':'102.85'},{'item':'Standing Charge x 1','unit':'1','amount':'3.30','currency':'EUR','subtotal':'3.30'},{'item':'Call-out Charge x 1','unit':'1','amount':'1.00','currency':'EUR','subtotal':'1.00'},{'item':'Subtotal','unit':'','amount':'','currency':'EUR','subtotal':'107.14'}],'cost_total':'€107.14','cost_summary':'Journey with Yellow Taxi Multiservice','cost':{'currency':'EUR','user_currency':'EUR','amount':107.14,'user_amount':107.14,'forex_quote':1,'forex_timestamp':1533887303684,'forex_required':true,'forex_provider':'Indigo'},'commission':{'currency':'EUR','amount':2.05},'terms':'https://orange.indigo-connect.com/e/3/terms/S-nWWeFG-7sSKtx9xndxfkduMfjKYpH','terms_privacy':'https://orange.indigo-connect.com/e/3/terms/S-nWWeFG-7sSKtx9xndxfkduMfjKYpH/privacy','semantic_key':'7620affcf30dc7ebd53bb414d72fc6cc','summary':{'id':'S-nWWeFG-7sSKtx9xndxfkduMfjKYpH','semantic_key':'7620affcf30dc7ebd53bb414d72fc6cc','cost_total':'€107.14','agent':null,'logo':'https://front.indigo-connect.com/api-assets/logo-web-bw/milan6969.png','logo_mobile':'https://front.indigo-connect.com/api-assets/logo-liveticket-circle/milan6969.png','dot_image':null,'image':'https://front.indigo-connect.com/api-assets/vehicle-large/94cf856388640d130636bca7fba64bda-0-l.jpg','categories':['prebook','private'],'label':'Sedan','short':'Sedan Yellow Taxi Multiservice','display1':'Yellow Taxi Multiservice\nSedan','display2':'','booking':{'rental_deliver':false,'rental_tomorrow':false,'bookable':true,'realtime_mobile':true,'must_print':false,'must_deliver':false,'mode':'TX'},'out':{'route_id':'milan6969.taxi','mode':'TX','group':null,'list_name':'Sedan','service_name':'Yellow Taxi Multiservice','line_name':'Sedan','seats':3,'operator':'Yellow Taxi Multiservice','from':'Milan MXP','pickup':'Milan MXP','dropoff':'23 Via Rampoldi','to':'23 Via Rampoldi','from_is_pickup':true,'to_is_dropoff':true,'walking_dist_depart':null,'walking_dist_arrival':null,'duration':2841,'dt':'20180901','dt_arrive':'2018-09-01T00:47'},'rtn':null}},{'search_id':'S-nWWeFG-7sSKtx9xndxfkduMfjKYpH','search_app':'perkm','out_dt':'20180901','out':{'search_id':'S-nWWeFG-7sSKtx9xndxfkduMfjKYpH','bookable':true,'realtime_mobile':true,'must_print':false,'must_deliver':false,'liveticket_operation':'driver_code','rules':{'show_rules':true,'cancelonstrike':false,'paxaction':false,'tpcancel':false,'pxmodify':false,'ticketvalidity':'journeyonly','refundable':true},'delivery':{'ca':'walk_up_to_taxi_rank','ac':'walk_up_to_taxi_rank','pp':'walk_up_to_taxi_rank'},'price_basis':'vehicle','direction':'AC','from':{'iata':'MXP','display':'Milan MXP','display2':'Milan Malpensa (MXP)','address':'Milan Malpensa (MXP), Italy','stop_id':'MXPT1','source':'indigo','type':'airport','geometry':{'type':'Point','coordinates':[8.714089393615723,45.62733415423001]},'is_pickup':true},'pickup':{'display':'Milan MXP','display2':'Milan Malpensa (MXP)','stop_id':'MXPT1','geometry':{'type':'Point','coordinates':[8.714089393615723,45.62733415423001]},'is_from':true},'dropoff':{'display':'23 Via Rampoldi','display2':'Via Rampoldi, 23, 22070 Bregnano CO, Italy','stop_id':'G:ChIJS3DN6qeQhkcRLjdj4AqcxB4','geometry':{'type':'Point','coordinates':[9.0584887,45.69586349999999]},'is_to':true},'to':{'iata':null,'display':'23 Via Rampoldi','display2':'Via Rampoldi, 23, 22070 Bregnano CO, Italy','address':'Via Rampoldi, 23, 22070 Bregnano CO, Italy','stop_id':'G:ChIJS3DN6qeQhkcRLjdj4AqcxB4','source':'google','type':'stop','geometry':{'type':'Point','coordinates':[9.0584887,45.69586349999999]},'is_dropoff':true},'polylines':{'from_pickup':null,'pickup_dropoff':'','dropoff_to':null},'times':{'dt_requested':'20180901','tz':'Europe/Paris','dt_depart':'20180901','dt_arrive':'2018-09-01T00:47','duration':2841,'dt':'20180901'},'journey_time':2841,'distance':39.7,'is_scheduled':false,'max_pax':3,'type':'TX','operator':'Yellow Taxi Multiservice','operator_id':'milan6969','route_id':'milan6969.taxi','service_name':'Yellow Taxi Multiservice','line_name':'Sedan','info_url':null,'images':[{'src':'https://front.indigo-connect.com/api-assets/vehicle-large/94cf856388640d130636bca7fba64bda-0-l.jpg','thumb':'https://front.indigo-connect.com/api-assets/vehicle-small/94cf856388640d130636bca7fba64bda-0-s.jpg','featured':true,'generic':false}],'logo':{'bw':'https://front.indigo-connect.com/api-assets/logo-web-bw/milan6969.png','colour':null,'print':'https://front.indigo-connect.com/api-assets/logo-ticket-bw/milan6969.png','liveticket':null},'services':{'morning':null,'daytime':null,'evening':null,'overnight':null},'tags':{'active':['private','changes','cancelations','certified','insurance','flighttrack','wheelchair','pets','bagoversize','baghold','bagcabin','stroller','golf','bike'],'tags':[{'tag':'wifi','type':'rt','active':false},{'tag':'green','type':'rt','active':false},{'tag':'excludestip','type':'rt','active':false},{'tag':'notsheltered','type':'rt','active':false},{'tag':'noenglish','type':'op','active':false},{'tag':'indestination','type':'op','active':false},{'tag':'private','type':'ca','active':true},{'tag':'doortodoor','type':'ca','active':false},{'tag':'changes','type':'ca','active':true},{'tag':'cancelations','type':'ca','active':true},{'tag':'highfrequency','type':'ca','active':false},{'tag':'certified','type':'ca','active':true},{'tag':'insurance','type':'ca','active':true},{'tag':'24hservice','type':'ca','active':false},{'tag':'flexibleticket','type':'ca','active':false},{'tag':'eticket','type':'ca','active':false},{'tag':'flighttrack','type':'ca','active':true},{'tag':'needmobile','type':'ca','active':false},{'tag':'paper','type':'ca','active':false},{'tag':'print','type':'ca','active':false},{'tag':'wheelchair','type':'ex','active':true},{'tag':'pets','type':'ex','active':true},{'tag':'childseat_a','type':'ex','active':false},{'tag':'childseat_b','type':'ex','active':false},{'tag':'childseat_c','type':'ex','active':false},{'tag':'childseat_d','type':'ex','active':false},{'tag':'meetandgreet','type':'ex','active':false},{'tag':'guidedog','type':'ex','active':false},{'tag':'bagoversize','type':'bg','active':true},{'tag':'bagstandard','type':'bg','active':false},{'tag':'baghold','type':'bg','active':true},{'tag':'bagcabin','type':'bg','active':true},{'tag':'stroller','type':'bg','active':true},{'tag':'golf','type':'bg','active':true},{'tag':'skis','type':'bg','active':false},{'tag':'bike','type':'bg','active':true},{'tag':'instruments','type':'bg','active':false},{'tag':'bigdelicate','type':'bg','active':false},{'tag':'bigheavy','type':'bg','active':false},{'tag':'bigsports','type':'bg','active':false}]},'fares':[],'pax':{'infant':0,'student':0,'child':0,'senior':0,'adult':1},'pax_types':{'infant':'infant','child':'child','student':'student','adult':'adult','senior':'senior'},'advance_booking_dt_out_min':'2018-08-10T09:48','advance_booking_dt_out_max':'2019-02-06T00:00','advance_booking_dt_rtn_max':'2019-02-06T00:00','walking_dist_depart':null,'walking_dist_arrival':null,'user_cost_basefare':{'amount':107.14,'currency':'EUR','is_return_fare':false}},'details':{'out':[{'legacy':true,'can_change':false,'label':'Drop-off street address for trip from airport','name':'acdropoff','optional':false,'type':'text'},{'legacy':true,'can_change':false,'label':'Outbound Pickup Date','name':'outdate','optional':false,'type':'date'},{'legacy':true,'can_change':false,'label':'Outbound Pickup Time','name':'outtime','optional':false,'type':'time'},{'legacy':true,'can_change':false,'label':'Name','name':'name','optional':false,'type':'text'},{'legacy':false,'can_change':false,'label':'Mobile Phone','name':'phone','optional':false,'type':'text'},{'legacy':false,'can_change':false,'label':'Email for Ticketing','name':'email','optional':false,'type':'text'}],'rtn':[{'legacy':true,'can_change':false,'label':'Pick-up street address for trip to airport','name':'capickup','optional':false,'type':'text'},{'legacy':true,'can_change':false,'label':'Name','name':'name','optional':false,'type':'text'},{'legacy':false,'can_change':false,'label':'Mobile Phone','name':'phone','optional':false,'type':'text'},{'legacy':false,'can_change':false,'label':'Email for Ticketing','name':'email','optional':false,'type':'text'}]},'extras':{'out':[{'label':'Luggage (Standard Checkin/Hold Size)','tags':['luggage'],'name':'bagstandard','number_required':false,'max':3,'first_free':false,'cost':0},{'label':'Wheelchair','tags':[],'name':'wheelchair','book':true,'max':1,'first_free':false,'cost':0},{'label':'Pets','tags':[],'name':'pets','book':true,'max':1,'first_free':false,'cost':0},{'label':'Luggage (Oversize)','tags':['luggage'],'name':'bagoversize','number_required':false,'book':true,'first_free':false,'cost':0},{'label':'Buggy/Stroller','tags':['luggage'],'name':'stroller','book':true,'max':1,'first_free':false,'cost':0},{'label':'Golf Clubs','tags':['luggage'],'name':'golf','number_required':false,'book':true,'max':1,'first_free':false,'cost':0},{'label':'Pairs of Skis','tags':['luggage'],'name':'skis','number_required':false,'book':true,'first_free':false,'cost':0},{'label':'Bicycle','tags':['luggage'],'name':'bike','number_required':false,'book':true,'max':1,'first_free':false,'cost':0}],'rtn':[{'label':'Luggage (Standard Checkin/Hold Size)','tags':['luggage'],'name':'bagstandard','number_required':false,'max':3,'first_free':false,'cost':0},{'label':'Wheelchair','tags':[],'name':'wheelchair','book':true,'max':1,'first_free':false,'cost':0},{'label':'Pets','tags':[],'name':'pets','book':true,'max':1,'first_free':false,'cost':0},{'label':'Luggage (Oversize)','tags':['luggage'],'name':'bagoversize','number_required':false,'book':true,'first_free':false,'cost':0},{'label':'Buggy/Stroller','tags':['luggage'],'name':'stroller','book':true,'max':1,'first_free':false,'cost':0},{'label':'Golf Clubs','tags':['luggage'],'name':'golf','number_required':false,'book':true,'max':1,'first_free':false,'cost':0},{'label':'Pairs of Skis','tags':['luggage'],'name':'skis','number_required':false,'book':true,'first_free':false,'cost':0},{'label':'Bicycle','tags':['luggage'],'name':'bike','number_required':false,'book':true,'max':1,'first_free':false,'cost':0}]},'can_refund':false,'can_modify':false,'deeplink':{'details':'https://orange.indigo-connect.com/go/kpr8G6m23DSwR6dmRBRyiv6qoZJqPyuBbakDQ2lohVP6yewbePTMgJQpNBM7SgYnjN','booking':'https://orange.indigo-connect.com/go/P71GabejdEuY2beR2O2jSr3q7ayqY8CD5m3keVQwSGw748B28wf8ovrVgjdjFLnaM1','landing':'https://orange.indigo-connect.com/go/dGXOA7ZN2DUJ2N0X2k23S7rWjZJWwnSBOeZyLl6khr7bY1aE17FyVBad6QVeH7V42N'},'image_key':null,'cost_lineitems':[{'item':'Peak Fare - 1 - Sedan (Public Hire Taxi)','currency':'EUR','amount':'102.85','unit':'','subtotal':'102.85'},{'item':'Standing Charge x 1','unit':'1','amount':'3.30','currency':'EUR','subtotal':'3.30'},{'item':'Call-out Charge x 1','unit':'1','amount':'1.00','currency':'EUR','subtotal':'1.00'},{'item':'Subtotal','unit':'','amount':'','currency':'EUR','subtotal':'107.14'}],'cost_total':'€107.14','cost_summary':'Journey with Yellow Taxi Multiservice','cost':{'currency':'EUR','user_currency':'EUR','amount':107.14,'user_amount':107.14,'forex_quote':1,'forex_timestamp':1533887303684,'forex_required':true,'forex_provider':'Indigo'},'commission':{'currency':'EUR','amount':2.05},'terms':'https://orange.indigo-connect.com/e/3/terms/S-nWWeFG-7sSKtx9xndxfkduMfjKYpH','terms_privacy':'https://orange.indigo-connect.com/e/3/terms/S-nWWeFG-7sSKtx9xndxfkduMfjKYpH/privacy','semantic_key':'7620affcf30dc7ebd53bb414d72fc6cc','summary':{'id':'S-nWWeFG-7sSKtx9xndxfkduMfjKYpH','semantic_key':'7620affcf30dc7ebd53bb414d72fc6cc','cost_total':'€107.14','agent':null,'logo':'https://front.indigo-connect.com/api-assets/logo-web-bw/milan6969.png','logo_mobile':'https://front.indigo-connect.com/api-assets/logo-liveticket-circle/milan6969.png','dot_image':null,'image':'https://front.indigo-connect.com/api-assets/vehicle-large/94cf856388640d130636bca7fba64bda-0-l.jpg','categories':['prebook','private'],'label':'Sedan','short':'Sedan Yellow Taxi Multiservice','display1':'Yellow Taxi Multiservice\nSedan','display2':'','booking':{'rental_deliver':false,'rental_tomorrow':false,'bookable':true,'realtime_mobile':true,'must_print':false,'must_deliver':false,'mode':'TX'},'out':{'route_id':'milan6969.taxi','mode':'TX','group':null,'list_name':'Sedan','service_name':'Yellow Taxi Multiservice','line_name':'Sedan','seats':3,'operator':'Yellow Taxi Multiservice','from':'Milan MXP','pickup':'Milan MXP','dropoff':'23 Via Rampoldi','to':'23 Via Rampoldi','from_is_pickup':true,'to_is_dropoff':true,'walking_dist_depart':null,'walking_dist_arrival':null,'duration':2841,'dt':'20180901','dt_arrive':'2018-09-01T00:47'},'rtn':null}}],'hail':null,'hailing_available':null,'result_count':2}";
		string jsonresult = HttpCall(urlCall,"GET","");
		
		/** INDIGO CONNECT: BOOKING (add pax) **/
		//string strPost = "";
		//strPost = "{\"details\" : {\"name\" : \"Arthur Dent\",\"email\" : \"blackhole01@gmail.com\",\"phone\" : \"+393335833710\",\"allnames\" : [ \"Arthur Dent\" ]},\"out\" : {\"sequence\" : 1,\"dt\" : \"2018-09-01T00:47\",\"pax\" : { \"adult\": 1},\"extras\" : { }}}";
		//string jsonresult = HttpCall("https://orange.indigo-connect.com/e/3/booking?search_id=S-nWWeFG-7sSKtx9xndxfkduMfjKYpH","POST",strPost);
		
		/** INDIGO CONNECT: BOOKING (payment) **/
		//string jsonresult = HttpCall("https://orange.indigo-connect.com/e/3/booking/rGJAPR63J?authref=hackathon","POST","");

		/** INDIGO CONNECT: BOOKING (check status) **/
		//string jsonresult = HttpCall("https://orange.indigo-connect.com/e/3/booking/rGJAPR63J","GET","");
		
		/** INDIGO CONNECT: CHECKIN **/
		//string jsonresult = HttpCall("https://orange.indigo-connect.com/e/3/checkin?res_id=r3K9NA8KO","GET","");

		
		
		
		// manage results
		if(!string.IsNullOrEmpty(jsonresult)){
			//Response.Write("<code>");
			//Response.Write(jsonresult);
			//Response.Write("</code>");		
		
			JObject o = JObject.Parse(@jsonresult);
			
			//Response.Write("JObject:<br>"+o+"<br>");	
			
			JToken results = null;
			
			
			if(o.TryGetValue("results",out results)){
				int counter = 1;
				foreach(JToken jt in results){
					Transfer t = new Transfer();
					
					string service_name = jt.SelectToken("out.service_name").ToString();
					string op = jt.SelectToken("out.operator").ToString();		
					string seats = jt.SelectToken("out.max_pax").ToString();
					
					string logo = jt.SelectToken("summary.logo.bw").ToString();
					string image = jt.SelectToken("summary.image").ToString();
					
					string luggage = "";
					IList<JToken> luggages = jt["extras"]["out"].Children().ToList();
					foreach(JToken jl in luggages){
						if("bagstandard".Equals(jl.SelectToken("name").ToString())){
							luggage = jl.SelectToken("max").ToString();
							break;
						}
					}
					
					string duration = jt.SelectToken("summary.out.duration").ToString();			
					string cost = jt.SelectToken("cost.user_amount").ToString();
					string currency = jt.SelectToken("cost.user_currency").ToString();
					
					string dOut = jt.SelectToken("out_dt").ToString();
					string dRtn = null;
					if(jt.SelectToken("rtn_dt") !=null){
						dRtn = jt.SelectToken("rtn_dt").ToString();
					}
					string from = jt.SelectToken("out.from.display2").ToString();
					string to = jt.SelectToken("out.to.display2").ToString();
 
					//Response.Write("service_name: "+service_name+"<br>");
					//Response.Write("<img src="+logo+" width=70 align=left><br>");
					//Response.Write("operator: "+op+"<br>");
					//Response.Write("seats: 1-"+seats+" passeggeri<br>");
					//Response.Write("<img src="+image+" width=200 align=left><br>");
					//Response.Write("amount: "+currency+" "+cost+"<br>");
					//Response.Write("duration: "+date+"<br>");
					//Response.Write(luggage +" valigie<br>");					
	
	
					if(counter % 3==0){
						service_name="traco";
					}					
					
					t.serviceName=service_name;
					t.operatorName=op;
					t.seat=Convert.ToInt32(seats);
					t.logo=logo;
					t.image=image;
					t.maxLuggage=Convert.ToInt32(luggage);
					t.duration=Convert.ToInt32(duration);
					t.amount=Convert.ToDecimal(cost);
					t.currency=currency;
					t.dOut = DateTime.ParseExact(dOut, "dd/MM/yyyy hh:mm:ss", null);
					if(!string.IsNullOrEmpty(dRtn)){
						t.dRtn = DateTime.ParseExact(dRtn, "dd/MM/yyyy hh:mm:ss", null);
					}
					t.from = from;
					t.to = to;
					
					tresult.Add(t);
					
					//add types for filters
					types[t.serviceName] = t.serviceName;
					durations[t.duration] = t.duration;
					
					counter++;
				}
				
				if(tresult.Count>0){
					Transfer tmp = tresult[0];
					    
					searchDtOut = tmp.dOut;
					if(!string.IsNullOrEmpty(Request["returnDate"])){
						searchDtRtn = tmp.dRtn;
					}
					searchFrom = tmp.from;
					searchTo = tmp.to;	
					
					tresult.Sort();
					
					foreach(int d in durations.Keys){
						sortedDurations.Add(d);
					}
					sortedDurations.Sort();
					
					minDuration = sortedDurations[0].ToString();
					maxDuration = sortedDurations[sortedDurations.Count-1].ToString();
					
					foreach(int d in sortedDurations){
						durationsRange += d+","; 
					}
					if(!string.IsNullOrEmpty(durationsRange)){
						durationsRange = durationsRange.Substring(0,durationsRange.Length-1);
					}
				}
			}
		}
		
	
		//************************* INTERNAL REST CLIENT IMPLEMENTATION *************************
		
		/*
		BasicAuthenticator auth = new BasicAuthenticator();
		//auth.user = "LM2";
		//auth.password = "14b0d25af44a7fd9114227f471f87f2d";

		// start call shopping cart create
		RestClient client = new com.nemesys.model.RestClient();
		client.Authenticator = auth;
		
		//client.Headers = new Dictionary<string,string>();
		//client.Headers.Add("X-TripGo-Key","14b0d25af44a7fd9114227f471f87f2d");
		
		//client.EndPoint = @"https://connect.holidaytaxis.com/products/search/from/IATA/MAD/to/GEO/40.4098,-3.694/travelling/2016-12-22T09:55:00/returning/2016-12-24T15:30:00/adults/2/children/0/infants/0";
		//client.EndPoint = @"https://api.tripgo.com/v1/routing.json?from=(-33.859,151.207)&to=(-33.891,151.209)&modes[]=pt_pub&v=11&locale=en";
		//client.Method = HttpVerb.POST;
		
		client.EndPoint = @"https://jsonplaceholder.typicode.com/posts";
		//client.EndPoint = @"https://httpbin.org/get";
		//client.EndPoint = @"https://api.publicapis.org/entries?category=animals&https=true";
		
		ServicePointManager.Expect100Continue = true;
		ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls | (SecurityProtocolType)3072;
		//ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
		//ServicePointManager.DefaultConnectionLimit = 9999; 
		//Certificates.Instance.GetCertificatesAutomatically();
		//ServicePointManager.ServerCertificateValidationCallback +=new RemoteCertificateValidationCallback (ValidateServerCertificate);	
		ServicePointManager.ServerCertificateValidationCallback = new System.Net.Security.RemoteCertificateValidationCallback(callback); 
		
		string[] json = client.MakeRequest();	
		
		Response.Write("sent the request!<br>");

		
		Response.Write(json[0]+"<br><br>"+json[1]+"<br><br>"+json[2]);
		*/
		/*
		Dictionary<string, string> fieldValues = JsonConvert.DeserializeObject<Dictionary<string, string>>(json[1]);

		string loc = null;
		bool foundel = fieldValues.TryGetValue("Location", out loc);		
		if(foundel){
			client.EndPoint = loc;
			client.Method = HttpVerb.GET;
			json = client.MakeRequest();
			Response.Write(json[0]+"<br><br>"+json[1]+"<br><br>"+json[2]);
		}
		*/
		

		
		
		
		
		//************************* RESTSHARP IMPLEMENTATION *************************
		
		/*
		client.execute(:url => 'https://jsonplaceholder.typicode.com/posts', :method => :post,
                                :headers => {:content_type => 'application/x-www-form-urlencoded', :accept =>'application/json'},
                                :verify_ssl => false,
                                :proxy => nil);
                                
                                //:payload => {username: "xxxxx", password: "xxxxx"},
		*/
		
		/*
		RestRequest request = new RestRequest();
		//request.Method = Method.POST;		

		
		RestSharp.RestClient client = new RestSharp.RestClient();
		client.BaseUrl = new Uri("https://api.tripgo.com");
		request.Resource = "v1/routing.json?from=(-33.859,151.207)&to=(-33.891,151.209)&modes[]=pt_pub&v=11&locale=en";
		request.AddHeader("X-TripGo-Key", "14b0d25af44a7fd9114227f471f87f2d");
		
		//client.BaseUrl = new Uri("https://jsonplaceholder.typicode.com");
		//request.Resource = "posts";
		
		//client.BaseUrl = new Uri("https://api.publicapis.org");
		//request.Resource = "entries?category=animals&https=true";
		
		//client.BaseUrl = new Uri("https://httpbin.org");
		//request.Resource = "get";
		
		//client.BaseUrl = new Uri("https://reqres.in");
		//request.Resource = "api/users";
		
		//client.Authenticator = new HttpBasicAuthenticator("username", "password");
		
		ServicePointManager.Expect100Continue = true;
		ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls | (SecurityProtocolType)3072;
		ServicePointManager.DefaultConnectionLimit = 999999; 
		
		//ServicePointManager.ServerCertificateValidationCallback +=new RemoteCertificateValidationCallback (ValidateServerCertificate);
		//client.RemoteCertificateValidationCallback = new RemoteCertificateValidationCallback (ValidateServerCertificate);
		
		client.RemoteCertificateValidationCallback = new RemoteCertificateValidationCallback (callback);
		ServicePointManager.ServerCertificateValidationCallback = new System.Net.Security.RemoteCertificateValidationCallback(callback); 
		
		//Certificates.Instance.GetCertificatesAutomatically();
		
		IRestResponse response = client.Execute(request);		
		
        if (response.ErrorException != null)
        {
        	Response.Write("response.ErrorException:<br>"+response.ErrorException);
            string message = "Error retrieving response.  Check inner details for more info.";
            //ApplicationException twilioException = new ApplicationException(message, response.ErrorException);
            //throw twilioException;
        }else{
        	Response.Write("DATA:<br>"+response.Content);	
        }
        */
		
		
	}
	    catch (Exception ex)
	{
	    Response.Write("<br>An error occurred: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
	
}
</script>
<html>
<head>
<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/smoothness/jquery-ui.css">
<style>#slider { margin: 10px; width:300px;}	</style>
<script src="//code.jquery.com/jquery-1.12.4.js"></script>
<script src="//code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<script>
function formatTime(hours,minutes){
	var h = " ora ";
	var m = " minuto";
	var date = "";
	
	if(Number(minutes) >1){m = " minuti";}
	
	if(Number(hours) >0){
		if(Number(hours) >1){h = " ore ";}
		date = hours +h+ minutes +m;
	}else{
		date=minutes +m;
	}
	
	return date;
}

function addZero(i) {
    if (i < 10) {
        i = "0" + i;
    }
    return i;
}

function round(value, decimals) {
    return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function myFunction(minutes) {
	var h = (Number(minutes) - Number(minutes) % 60) / 60;
	var m = Number(minutes) - Number(h)*60;   
    var formattedDate = formatTime(h,m);
    
	$('#durationSelected').empty();
	$('#durationSelected').append(formattedDate);
}


function filterResultByDuration(duration){
	$(".myresults").each(function(){
		var tduration = $(this).attr("duration");
		if(Number(tduration)>duration){
			$(this).hide();
		}else{
			$(this).show();
		}
	});	
}

function filterResultByProvider(){
	var providers = []; 
	$('input[name*="service_type"]').each( function(){
		if($(this).is(':checked')){
			providers.push($(this).val());
		}
	});	


	$(".myresults").each(function(){
		var tprovider = $(this).attr("provider");
		
		if(providers.indexOf(tprovider) == -1){
			$(this).hide();
		}else{
			$(this).show();
		}
	});	
}
</script>
</head>
<body>
<div>   
	<p><strong>pickup:</strong> <%=searchFrom%></p>
	<p><strong>dropoff:</strong> <%=searchTo%></p> 
	<div>
		<p><strong>partenza:</strong> <%=searchDtOut.ToString("dd/MM/yyyy hh:mm")%></p>  
		<%if(!string.IsNullOrEmpty(Request["returnDate"])){%>
		<p><strong>ritorno:</strong> <%=searchDtRtn.ToString("dd/MM/yyyy hh:mm")%></p>
		<%}%>
	</div> 
</div>   
<div style="margin-top:50px;">   
	<p><strong>Tipo di veicolo</strong></p> 
	<div>
		<%foreach(string type in types.Keys){%>
		<p><input type="checkbox" name="service_type" value="<%=type%>" onclick="filterResultByProvider()" checked="checked">&nbsp;&nbsp;<strong><%=type%></strong></p>
		<%}%>
	</div> 
</div> 

<div style="margin-top:50px;">   
	<p><strong>Durata del viaggio</strong></p> 
	<div id="slider"></div> 
</div> 
<p id="durationSelected"></p>
<script>
$(document).ready(function() {
	$("#slider").slider({
		min: <%=minDuration%>,
		max: <%=maxDuration%>,
		range: <%=minDuration%>,
		step: 1,
		value: <%=maxDuration%>,
		change: function( event, ui ) {
			myFunction(ui.value);
			filterResultByDuration(ui.value);
		}
	});
	myFunction(<%=maxDuration%>);
});
</script>


<%
foreach(Transfer tr in tresult){
	int duration = tr.duration;
	int hours = (duration-duration%60)/60;
	int minutes = duration-hours*60;
	
	string date = "";
	string h = " ora ";
	string m = " minuto";
	
	if(minutes >1){m = " minuti";}
	
	if(hours >0){
		if(hours >1){h = " ore ";}
		date = hours +h+ minutes +m;
	}else{
		date=minutes+m;
	}	
	%>
	
	<div class="myresults" style="margin-bottom:10px;margin-top:10px;clear:left;border-top: 2px solid rgb(201, 201, 201);" provider="<%=tr.serviceName%>" duration="<%=tr.duration%>">
		<div style="">
			<div style="padding-right:20px;float:left;">
				<strong><%=tr.serviceName%></strong>
			</div>
			<div style="display:inline-block;">
				1-<%=tr.seat%> passeggeri
			</div>
		</div>
		<div style="float:left;display:inline-block;">
			<div style="background-color:#f3f2f5;padding:10px;margin:5px;min-width:100px;float:left;display:inline-block;">
				<%=tr.maxLuggage%> valigie
			</div>
			<div style="background-color:#f3f2f5;padding:10px;margin:5px;min-width:100px;display:inline-block;">
				<strong>durata:</strong> <%=date%>
			</div>
			<div>
				<img src="<%=tr.logo%>" width=70 align=left>
			</div>
		</div>
		<div style="float:left;display:inline-block;">
			<img src="<%=tr.image%>" width=200 align=left style="margin-bottom:5px;">		
		</div>
		<div style="">
			<%=tr.currency%> <%=tr.amount%> <input type=submit value=PRENOTA>	
			<div style="font-size:10px">
				servizio offerto da:</br>
				<%=tr.operatorName%>
			</div>
		</div>
	</div>
<%}%>

</body>
</html>