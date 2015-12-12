<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;
	
protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Clear();				
	Response.ContentType = "text/csv";
	Response.AddHeader("content-disposition", "attachment;  filename=csv_prod_catalog.csv");
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	login.acceptedRoles = "1";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}

	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IProductRepository productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
	ISupplementRepository suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
	StringBuilder result = new StringBuilder();
	IList<Product> products;
	IList<Language> languages;	
	IList<Category> categories;
	
	try{			
		languages = langrep.getLanguageList();	
		if(languages == null){				
			languages = new List<Language>();						
		}
	}catch (Exception ex){
		languages = new List<Language>();
	}
	try{			
		categories = catrep.getCategoryList();	
		if(categories == null){				
			categories = new List<Category>();						
		}
	}catch (Exception ex){
		categories = new List<Category>();
	}
	
	try{
		products = productrep.find(null,null,null,-1,-1,null,null,-1,null,null,false,true,true,false,false);
		if(products == null){				
			products = new List<Product>();						
		}
	}catch (Exception ex){
		products = new List<Product>();
	}
		
	try
	{	
		//CREATE CSV HEADER
		result
		.Append(lang.getTranslated("backend.prodotti.view.table.label.id_prodotto").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.prodotti.view.table.label.cod_prod").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.prodotti.view.table.label.nome_prod").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.product.lista.table.header.prod_type").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.product.lista.label.status").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.prodotti.view.table.label.prezzo_prod").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.prodotti.view.table.label.sconto_prod").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.prodotti.view.table.label.qta_prod").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.prodotti.view.table.label.tassa_applicata").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.prodotti.lista.table.header.category").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.prodotti.lista.table.header.lang").ToUpper())
		.Append(System.Environment.NewLine);
		
		//APPEND CSV ROWS
		if(products != null && products.Count>0){
			string status = "";
			string supplement = "";
			string type = "";
			string quantity = "";
			foreach(Product p in products){
				if(p.status==0){status=lang.getTranslated("backend.product.lista.label.status_inactive");}else if(p.status==1){status=lang.getTranslated("backend.product.lista.label.status_active");}
				if(p.prodType==0){type=lang.getTranslated("backend.product.detail.table.label.type_portable");}else if(p.prodType==1){type=lang.getTranslated("backend.product.detail.table.label.type_download");}else if(p.prodType==2){type=lang.getTranslated("backend.product.detail.table.label.type_ads");}
				if(p.quantity<0){quantity=lang.getTranslated("backend.product.detail.table.label.qta_unlimited");}else{quantity=p.quantity.ToString();}

				StringBuilder category = new StringBuilder();
				foreach (Category x in categories){
					if(p.categories!=null){
						bool hasCat = false;
						foreach(ProductCategory cl in p.categories){
							if(x.id==cl.idCategory){
								hasCat = true;
								break;
							}
						}
						if(hasCat){category.Append("- "+x.description+"\n");}
					}
				}				

				StringBuilder language = new StringBuilder();
				int lCount = 1;
				foreach (Language x in languages){
					if(p.languages!=null){
						bool hasLang = false;
						foreach(ProductLanguage cl in p.languages){
							if(x.id==cl.idLanguage){
								hasLang = true;
								break;
							}
						}
						if(hasLang){
							language.Append(lang.getTranslated("portal.header.label.desc_lang."+x.label)).Append(" ");
							if(lCount % 4 == 0){language.Append("\n");}
						}
					}
					lCount++;
				}				

				if(p.idSupplement != null && p.idSupplement>0){
					try{			
						Supplement sup = suprep.getById(p.idSupplement);	
						if(sup != null){				
							supplement = sup.description;						
						}
					}catch (Exception ex){}
				}
	
				result.Append("\"").Append(p.id).Append("\",")
				.Append("\"").Append(p.keyword).Append("\",")
				.Append("\"").Append(p.name).Append("\",")
				.Append("\"").Append(type).Append("\",")
				.Append("\"").Append(status).Append("\",")
				.Append("\"").Append("EUR ").Append(p.price.ToString("###0.00")).Append("\",")
				.Append("\"").Append(p.discount.ToString("###0.00")).Append(" %").Append("\",")
				.Append("\"").Append(quantity).Append("\",")
				.Append("\"").Append(supplement).Append("\",")
				.Append("\"").Append(category.ToString()).Append("\",")
				.Append("\"").Append(language.ToString()).Append("\"")
				//.Append("\"").Append(p.downloadDate.ToString("dd/MM/yyyy HH:mm")).Append("\"")
				.Append(System.Environment.NewLine);
			}
		}
	}
	catch (Exception ex)
	{
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
		
	Response.Write(result.ToString());
	Response.End();
}
</script>