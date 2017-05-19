using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using com.nemesys.model;
using com.nemesys.database;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Caching;

namespace com.nemesys.database.repository
{
	public class SearchRepository : ISearchRepository
	{
		private static IDictionary<string,string> skipWord = new Dictionary<string,string>();
		private static List<string> separator = new List<string>();
		
		static SearchRepository()
		{		
			createSkipWord();
			createSeparator();	
		}
		
		static void createSkipWord()
		{				
			skipWord.Add("a","a"); 
			skipWord.Add("all",""); 
			skipWord.Add("am",""); 
			skipWord.Add("an",""); 
			skipWord.Add("and",""); 
			skipWord.Add("any",""); 
			skipWord.Add("are",""); 
			skipWord.Add("as",""); 
			skipWord.Add("at",""); 
			skipWord.Add("be",""); 
			skipWord.Add("but",""); 
			skipWord.Add("can",""); 
			skipWord.Add("did",""); 
			skipWord.Add("do",""); 
			skipWord.Add("does",""); 
			skipWord.Add("for",""); 
			skipWord.Add("from",""); 
			skipWord.Add("had",""); 
			skipWord.Add("has",""); 
			skipWord.Add("have",""); 
			skipWord.Add("here",""); 
			skipWord.Add("how",""); 
			skipWord.Add("i",""); 
			skipWord.Add("if",""); 
			skipWord.Add("in",""); 
			skipWord.Add("is",""); 
			skipWord.Add("it",""); 
			skipWord.Add("no",""); 
			skipWord.Add("not",""); 
			skipWord.Add("of",""); 
			skipWord.Add("on",""); 
			skipWord.Add("or",""); 
			skipWord.Add("so",""); 
			skipWord.Add("that",""); 
			skipWord.Add("the",""); 
			skipWord.Add("then",""); 
			skipWord.Add("there",""); 
			skipWord.Add("this",""); 
			skipWord.Add("to",""); 
			skipWord.Add("too",""); 
			skipWord.Add("up",""); 
			skipWord.Add("use",""); 
			skipWord.Add("what",""); 
			skipWord.Add("when",""); 
			skipWord.Add("where",""); 
			skipWord.Add("who",""); 
			skipWord.Add("why",""); 
			skipWord.Add("you","");
			skipWord.Add("di","");
			skipWord.Add("del","");
			skipWord.Add("dell'","");
			skipWord.Add("dello","");
			skipWord.Add("della","");
			skipWord.Add("dei","");
			skipWord.Add("degli","");
			skipWord.Add("delle","");
			skipWord.Add("al","");
			skipWord.Add("all'","");
			skipWord.Add("allo","");
			skipWord.Add("alla","");
			skipWord.Add("ai","");
			skipWord.Add("agli","");
			skipWord.Add("alle","");
			skipWord.Add("da","");
			skipWord.Add("dal","");
			skipWord.Add("dall'","");
			skipWord.Add("dallo","");
			skipWord.Add("dalla","");
			skipWord.Add("dai","");
			skipWord.Add("dagli","");
			skipWord.Add("dalle","");
			skipWord.Add("nel","");
			skipWord.Add("nell'","");
			skipWord.Add("nello","");
			skipWord.Add("nella","");
			skipWord.Add("nei","");
			skipWord.Add("negli","");
			skipWord.Add("nelle","");
			skipWord.Add("su","");
			skipWord.Add("sul","");
			skipWord.Add("sull'","");
			skipWord.Add("sullo","");
			skipWord.Add("sulla","");
			skipWord.Add("sui","");
			skipWord.Add("sugli","");
			skipWord.Add("sulle","");
			skipWord.Add("con","");
			skipWord.Add("col","");
			skipWord.Add("coll'","");
			skipWord.Add("collo","");
			skipWord.Add("colla","");
			skipWord.Add("coi","");
			skipWord.Add("cogli","");
			skipWord.Add("colle","");
			skipWord.Add("per","");
			skipWord.Add("pel","");
			skipWord.Add("pei","");
			skipWord.Add("fra","");
			skipWord.Add("tra","");
			skipWord.Add("il","");
			skipWord.Add("lo","");
			skipWord.Add("l'","");
			skipWord.Add("el","");
			skipWord.Add("o","");
			skipWord.Add("u","");
			skipWord.Add("le","");
			skipWord.Add("e","");
			skipWord.Add("gli","");
			skipWord.Add("los","");
			skipWord.Add("els","");
			skipWord.Add("os","");
			skipWord.Add("les","");
			skipWord.Add("la","");
			skipWord.Add("las","");
			skipWord.Add("un","");
			skipWord.Add("uno","");
			skipWord.Add("um","");
			skipWord.Add("unui","");
			skipWord.Add("unos","");
			skipWord.Add("uns","");
			skipWord.Add("unor","");
			skipWord.Add("una","");
			skipWord.Add("un'","");
			skipWord.Add("uma","");
			skipWord.Add("une","");
			skipWord.Add("unei","");
			skipWord.Add("unas","");
			skipWord.Add("unes","");
			skipWord.Add("umas","");			
		}
		
		static void createSeparator()
		{		
			separator.Add(";");
			separator.Add(",");
			separator.Add(":");
		}
			
		public IList<FContent> search(string title, string summary, string description, string keyword, string status, int userId, string publishDate, string deleteDate, int orderBy, IList<int> matchCategories, IList<int> matchLanguages, bool doAnd, bool withAttach, bool withLang, bool withCats, bool withFields)
		{		
			IList<FContent> results = null;
			List<string> idsCat = new List<string>();
			List<string> idsLang = new List<string>();
			string andOr = " or ";
			if(doAnd){andOr = " and ";}
			
			string[] titles = null;	
			string[] summaries = null;		
			string[] descriptions = null;		
			string[] keywords = null;				
			
			// first check on categories and languages
			if (matchCategories != null && matchCategories.Count > 0){
				foreach(int c in matchCategories){
					idsCat.Add(c.ToString());
				}						
			}
			if (matchLanguages != null && matchLanguages.Count > 0){
				foreach(int c in matchLanguages){
					idsLang.Add(c.ToString());
				}						
			}
			string idsCatC = "";
			if(idsCat.Count>0){
				idsCatC = string.Format("{0}",string.Join(",",idsCat.ToArray()));
			}
			string idsLangC = "";
			if(idsLang.Count>0){
				idsLangC = string.Format("{0}",string.Join(",",idsLang.ToArray()));
			}
			
			string strSQL = "from FContent where 1=1";

			// check on categories and languages
			if(idsCat.Count>0){strSQL+=string.Format(" and id in(select idParent from ContentCategory where idCategory in({0}))",string.Join(",",idsCat.ToArray()));}
			if(idsLang.Count>0){strSQL+=string.Format(" and id in(select idParentContent from ContentLanguage where idLanguage in({0}))",string.Join(",",idsLang.ToArray()));}
			
			if (userId > 0){			
				strSQL += " and userId=:userId";
			}
			
			if(!String.IsNullOrEmpty(title) || !String.IsNullOrEmpty(summary) || !String.IsNullOrEmpty(description) || !String.IsNullOrEmpty(keyword) || !String.IsNullOrEmpty(publishDate) || !String.IsNullOrEmpty(deleteDate)){
				strSQL += "and (";
				
				if (!String.IsNullOrEmpty(title)){	
					string jtitle = title;
					foreach(string xSep in separator){
						string[] words = Regex.Split(jtitle, xSep);
						if(words != null){
							for(int c=0;c<words.Length;c++){
								words[c]=words[c].Trim();
							}
							jtitle = string.Join(" ",words);
							//System.Web.HttpContext.Current.Response.Write("#"+jtitle+"#<br>");
						}
					}
					
					titles = jtitle.Split(' ');
					if(titles != null){
						int counter = 0;
						foreach(string x in titles){							
							if (!skipWord.ContainsKey(x)) {
								//System.Web.HttpContext.Current.Response.Write(x+"<br>");
								strSQL += andOr+" title like:title"+counter;
								counter++;
							}
						}	
					}					
				}
				
				if (!String.IsNullOrEmpty(summary)){
					string jsummary = summary;
					foreach(string xSep in separator){
						string[] words = Regex.Split(jsummary, xSep);
						if(words != null){
							for(int c=0;c<words.Length;c++){
								words[c]=words[c].Trim();
							}
							jsummary = string.Join(" ",words);
							//System.Web.HttpContext.Current.Response.Write(jsummary+"<br>");
						}
					}
					
					summaries = jsummary.Split(' ');
					if(summaries != null){
						int counter = 0;
						foreach(string x in summaries){
							if (!skipWord.ContainsKey(x)) {
								strSQL += andOr+" summary like:summary"+counter;
								counter++;
							}
						}	
					}				
				}
				
				if (!String.IsNullOrEmpty(description)){	
					string jdescription = description;
					foreach(string xSep in separator){
						string[] words = Regex.Split(jdescription, xSep);
						if(words != null){
							for(int c=0;c<words.Length;c++){
								words[c]=words[c].Trim();
							}
							jdescription = string.Join(" ",words);
							//System.Web.HttpContext.Current.Response.Write(jdescription+"<br>");
						}
					}
					
					descriptions = jdescription.Split(' ');
					if(descriptions != null){
						int counter = 0;
						foreach(string x in descriptions){
							if (!skipWord.ContainsKey(x)) {
								strSQL += andOr+" description like:description"+counter;
								counter++;
							}
						}	
					}			
				}
				
				if (!String.IsNullOrEmpty(keyword)){	
					string jkeyword = keyword;
					foreach(string xSep in separator){
						string[] words = Regex.Split(jkeyword, xSep);
						if(words != null){
							for(int c=0;c<words.Length;c++){
								words[c]=words[c].Trim();
							}
							jkeyword = string.Join(" ",words);
							//System.Web.HttpContext.Current.Response.Write(jkeyword+"<br>");
						}
					}
					
					keywords = jkeyword.Split(' ');
					if(keywords != null){
						int counter = 0;
						foreach(string x in keywords){
							if (!skipWord.ContainsKey(x)) {
								strSQL += andOr+" keyword like:keyword"+counter;
								counter++;
							}
						}	
					}			
				}

				if (!String.IsNullOrEmpty(publishDate)){
					strSQL += andOr+" publishDate <= :publishDate";
				}

				if (!String.IsNullOrEmpty(deleteDate)){
					strSQL += andOr+" deleteDate >= :deleteDate";
				}
				strSQL += ") ";
				
				strSQL = strSQL.Replace("( or","(");
				strSQL = strSQL.Replace("( and","(");
			}
			
			if (!String.IsNullOrEmpty(status)){			
				List<string> ids = new List<string>();
				string[] tstatus = status.Split(',');
				foreach(string r in tstatus){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and status in({0})",string.Join(",",ids.ToArray()));}
			}
			
			switch (orderBy)
			{
			    case 1:
				strSQL +=" order by title asc";
				break;
			    case 2:
				strSQL +=" order by title desc";
				break;
			    case 3:
				strSQL +=" order by summary asc";
				break;
			    case 4:
				strSQL +=" order by summary desc";
				break;
			    case 5:
				strSQL +=" order by keyword asc";
				break;
			    case 6:
				strSQL +=" order by keyword desc";
				break;
			    case 7:
				strSQL +=" order by publishDate asc";
				break;
			    case 8:
				strSQL +=" order by publishDate desc";
				break;
			    case 9:
				strSQL +=" order by status asc";
				break;
			    case 10:
				strSQL +=" order by status desc";
				break;
			    default:
				strSQL +=" order by title asc";
				break;
			}
			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL);					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (userId > 0){
						q.SetInt32("userId", Convert.ToInt32(userId));
					}					
					if(titles != null){
						int counter = 0;
						foreach(string x in titles){
							if (!skipWord.ContainsKey(x.Trim())) {
								q.SetString("title"+counter, String.Format("%{0}%", x));
								counter++;
							}
						}	
					}	
					if(summaries != null){
						int counter = 0;
						foreach(string x in summaries){
							if (!skipWord.ContainsKey(x.Trim())) {
								q.SetString("summary"+counter, String.Format("%{0}%", x));
								counter++;
							}
						}	
					}		
					if(descriptions != null){
						int counter = 0;
						foreach(string x in descriptions){
							if (!skipWord.ContainsKey(x.Trim())) {
								q.SetString("description"+counter, String.Format("%{0}%", x));
								counter++;
							}
						}	
					}	
					if(keywords != null){
						int counter = 0;
						foreach(string x in keywords){
							if (!skipWord.ContainsKey(x.Trim())) {
								q.SetString("keyword"+counter, String.Format("%{0}%", x));
								counter++;
							}
						}	
					}
					if (publishDate != null){
						q.SetDateTime("publishDate", Convert.ToDateTime(publishDate));
					}
					if (deleteDate != null){
						q.SetDateTime("deleteDate", Convert.ToDateTime(deleteDate));
					}
					results = q.List<FContent>();

					if(results != null){
						foreach(FContent content in results){							
							if(withAttach){
								content.attachments = session.CreateCriteria(typeof(ContentAttachment))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentContent", content.id))
								.List<ContentAttachment>();
							}
	
							if(withLang){
								content.languages = session.CreateCriteria(typeof(ContentLanguage))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentContent", content.id))
								.List<ContentLanguage>();		
							}
	
							if(withCats){
								content.categories = session.CreateCriteria(typeof(ContentCategory))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParent", content.id))
								.List<ContentCategory>();
							}			

							if(withFields){
								content.fields = session.CreateCriteria(typeof(ContentField))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentContent", content.id))
								.AddOrder(Order.Asc("sorting"))
								.List<ContentField>();	
							}								
						}
					}
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}
						
			return results;		
		}		
	}
}