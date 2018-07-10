<%@ Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="HtmlAgilityPack" %>
<%@ Import Namespace="ScrapySharp.Html" %>
<%@ Import Namespace="ScrapySharp.Html.Forms" %>
<%@ Import Namespace="ScrapySharp.Extensions" %>
<%@ Import Namespace="ScrapySharp.Network" %>
<%@ import Namespace="com.nemesys.model" %>

<html>
<head>
<title>HtmlAgilityPack - Hello World</title>
</head>
<body>
<%
try{
	
	ScrapingBrowser browser = new ScrapingBrowser();
	
	//set UseDefaultCookiesParser as false if a website returns invalid cookies format
	//browser.UseDefaultCookiesParser = false;
	
	
	/******************************* TEST CODE ONLY *******************************/
	
	/*
	WebPage homePage = browser.NavigateToPage(new Uri("http://www.bing.com/"));	
	PageWebForm form = homePage.FindFormById("sb_form");
	form["q"] = "scrapysharp";
	form.Method = HttpVerb.Get;
	WebPage resultsPage = form.Submit();
	
	HtmlNode[] resultsLinks = resultsPage.Html.CssSelect("li.b_algo").ToArray();
	//Response.Write("resultsLinks.Length: "+resultsLinks.Length);
    
	foreach (var node in resultsLinks)
    {
      //Response.Write(node.CssSelect("h2 a").Single().InnerText+"<br>");
      //Response.Write(node.OuterHtml);
    }
	
	
	
	var url = "https://tipidpc.com/catalog.php?cat=0&sec=s";
	var webGet = new HtmlWeb();
	if (webGet.Load(url) is HtmlDocument document)
	{
		var nodes = document.DocumentNode.CssSelect("#item-search-results li").ToList();
		foreach (var node in nodes)
		{
			Response.Write("Selling: " + node.CssSelect("h2 a").Single().InnerText);
		}
	}	
	
	
	
	
	
    var nodes = resultsPage.Html.CssSelect("div.b_title h2 a").ToList();
    foreach (var node in nodes)
    {
      Response.Write(node.InnerText);
    }
    
    
    //var singletitle = resultsPage.Html.CssSelect("div.b_title h2 a").Single().InnerText;
    //Response.Write("singletitle: "+singletitle);
 
    //Response.Write(resultsPage.Html.CssSelect("title").Single().InnerText);
	
	//WebPage blogPage = resultsPage.FindLinks(By.Text("romcyber blog | Just another WordPress site")).Single().Click();
	
	
	
	var html = @"http://html-agility-pack.net/";
	HtmlWeb web = new HtmlWeb();
	var htmlDoc = web.Load(html);
	var node = htmlDoc.DocumentNode.SelectSingleNode("//head/title");
	Response.Write("Node Name: " + node.Name + "\n" + node.OuterHtml);
	
	*/
	
	/******************************* END: TEST CODE ONLY *******************************/

	
	
	
	/******************************* TEST: pagina offerta eni gas e luce *******************************/
	
	var proposal = new List<String>();
	proposal.Add("gas-luce-cont");
	proposal.Add("luce-cont");
	proposal.Add("gas-cont");
	
	List<Offer> offers = new List<Offer>();
	
	
	
	WebPage eniPage = browser.NavigateToPage(new Uri("https://enigaseluce.com/offerta/casa/gas-e-luce/"));	
	var nodes = eniPage.Html.CssSelect("div.cont.round-6").ToList();
	foreach (var node in nodes)
	{
		var subNodes = node.CssSelect("div.col-xs-12.col-lg-8.box-offer").ToList();
		
		//Response.Write("subNodes.Count: "+subNodes.Count+"<br><br>");
		
		foreach (var snode in subNodes)
		{		
			
			var classValue = snode.Attributes["class"] == null ? null : snode.Attributes["class"].Value;
			
			//Response.Write("classValue: "+classValue+"<br><br>");
		
			var title = "";
			var subtitle = "";
			var testNote = snode.SelectSingleNode(".//h2/span");
			
			if(testNote != null){
				title = testNote.InnerText;
			}else{
				title = snode.CssSelect("h2").Single().InnerText;
			}
			subtitle = snode.CssSelect("p.small.italic").Single().InnerText;
			if(!String.IsNullOrEmpty(subtitle)){
				var substart = subtitle.IndexOf("fino al")+7;
				var subend = subtitle.IndexOf(".");
				subtitle = subtitle.Substring(substart,subend-substart);
				if(subtitle.EndsWith("<br>")){
					subtitle = subtitle.Substring(0,subtitle.LastIndexOf("<br>"));
				}
				subtitle = subtitle.Trim();
			}
				
			foreach(var prop in proposal){
				var cname = "col-xs-12 col-lg-8 box-offer "+prop;
				if (cname.Equals(classValue))
				{
					Offer offer = new Offer();
					OfferType type = null;
					IList<OfferPrice> prices = new List<OfferPrice>();
					
					offer.name = title;
					offer.isActive = true;
					offer.insertDate = DateTime.Now;
					offer.lastUpdate = DateTime.Now;
					offer.expireDate = DateTime.ParseExact(subtitle, "dd/MM/yyyy", null);	
					
					if(prop.Equals("luce-cont")){
						type = new OfferType((int)OfferType.Types.LIGHT);
						offer.type = type;
					}else if(prop.Equals("gas-cont")){
						type = new OfferType((int)OfferType.Types.GAS);
						offer.type = type;
					}else if(prop.Equals("gas-luce-cont")){
						type = new OfferType((int)OfferType.Types.GASLIGHT);
						offer.type = type;
					}
					
					
					var priceEl = "";
					var priceNodes = node.SelectNodes(".//div[@class='col-md-12 col-lg-4 hidden-xs hidden-sm offerDett "+prop+"']");
					
					if(priceNodes != null){
						//Response.Write("priceNodes.Count: "+priceNodes.Count+"<br>");
						//Response.Write("priceNodes.OuterHtml: "+priceNodes.OuterHtml+"<br><br>");
						
						var pricesEl = priceNodes.Single().SelectNodes(".//div[@class='col-xs-12 col-md-6 col-lg-12 border-bottom']"); 
						
						if(pricesEl != null){
							foreach (var nNode in pricesEl)
							{
								if (nNode.NodeType == HtmlNodeType.Element)
								{
									var priceamount = nNode.SelectSingleNode(".//p[@class='big']").ChildNodes[0].OuterHtml;
									var pricetype = nNode.SelectSingleNode(".//p[@class='big']").ChildNodes[1].InnerText;
									pricetype = pricetype.Substring(pricetype.IndexOf("/")+1);
									
									OfferPrice price = new OfferPrice();
									if("kwh".Equals(pricetype.ToLower())){
										price.type = new OfferType((int)OfferType.Types.LIGHT);
									}else if("smc".Equals(pricetype.ToLower())){
										price.type = new OfferType((int)OfferType.Types.GAS);
									}
									
									//Response.Write("priceamount: "+priceamount+"<br>");
									//Response.Write("pricetype: "+pricetype+"<br>");
									//Response.Write("price.ToString(): "+price.ToString()+"<br>");
									
									
									price.amount = Convert.ToDecimal(priceamount);
									price.measurement = pricetype;
									price.insertDate = DateTime.Now;
									prices.Add(price);
									
								}
							}
						
							offer.prices = prices;
							offers.Add(offer);
						}
					}
					
				}				
			}

		}
		
	}
	
	foreach(Offer of in offers){
		Response.Write(of.ToString()+"<br>");
		if(of.prices != null){
			foreach(OfferPrice p in of.prices){
				Response.Write(p.ToString()+"<br>");
			}
		}
		Response.Write("<br><br>");
	}
	
	
	

}catch(Exception ex){
	Response.Write("An error occured: " + ex.Message);
}
%>
</body>
</html>