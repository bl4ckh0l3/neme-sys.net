using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using System.Xml;
using System.IO;
using System.Web.Caching;
using System.Threading;
using com.nemesys.model;
using com.nemesys.database;
using log4net;

namespace com.nemesys.database.repository
{
	public class MultiLanguageRepository : IMultiLanguageRepository
	{
		private static readonly object _Padlock = new object();
		private static readonly ILog log = LogManager.GetLogger(typeof(MultiLanguageRepository));
		
		private static IDictionary<string, MultiLanguage> multiLanguageGlobalResource = new Dictionary<string, MultiLanguage>();
		private static IDictionary<string, string> localeSet = new  Dictionary<string, string>();
		private static IDictionary<string, string> errorSet = new  Dictionary<string, string>();
		private static IDictionary<string, string> messageSet = new  Dictionary<string, string>();
		private static bool canGetElement = false;

		static MultiLanguageRepository()
		{		
			createLocaleSet();
			createErrorSet();
			createMessageSet();
			canLoadElements();
			//multithread don't work
			//ThreadUtil.FireAndForget(new InsertDelegate(WriteIt),null);			
		}
	
		public void insert(MultiLanguage value)
		{
			IList<MultiLanguage> ins = new List<MultiLanguage>();
			ins.Add(value);
			insert(ins);
		}
			
		public void insert(IList<MultiLanguage> values)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				foreach(MultiLanguage value in values){
					session.Save(value);
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
	
		public void update(MultiLanguage value)
		{
			IList<MultiLanguage> upd = new List<MultiLanguage>();
			upd.Add(value);
			update(upd);
		}
		
		public void update(IList<MultiLanguage> values)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				foreach(MultiLanguage value in values){
					//try{
						//System.Web.HttpContext.Current.Response.Write("value before: " + value.ToString());
						session.SaveOrUpdate(value);
						//System.Web.HttpContext.Current.Response.Write("value after: " + value.ToString());
					//}catch(Exception ex){
					//	System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					//}
				}		
				tx.Commit();
				NHibernateHelper.closeSession();				
			}
			
			foreach(MultiLanguage value in values){
				// cache cleaning
				cleanCache(value);
			}
		}
	
		public void delete(MultiLanguage value)
		{
			IList<MultiLanguage> del = new List<MultiLanguage>();
			del.Add(value);
			delete(del);
		}
		
		public void delete(IList<MultiLanguage> values)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				//System.Web.HttpContext.Current.Response.Write("<b>start: delete method</b><br>");
				List<string> ids = new List<string>();
				foreach(MultiLanguage value in values){
					ids.Add(value.id.ToString());
				}	
				
				string sql = string.Format("DELETE FROM MultiLanguage multiLanguage WHERE multiLanguage.id  IN ({0})",string.Join(",",ids.ToArray()));
				//System.Web.HttpContext.Current.Response.Write("<b>sql: </b>"+sql+"<br>");
				session.CreateQuery(sql).ExecuteUpdate();

				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			foreach(MultiLanguage value in values){
				// cache cleaning
				cleanCache(value);
			}
		}
	
		public MultiLanguage getById(int id)
		{
			MultiLanguage element = null;					
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				element = session.Get<MultiLanguage>(id);			
				NHibernateHelper.closeSession();
			}	
			return element;	
		}

		public MultiLanguage find(string keyword, string langCode)
		{
			MultiLanguage result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				//System.Web.HttpContext.Current.Response.Write("<b>start: delete method</b><br>");
				string strSQL = "from MultiLanguage as multiLanguage where keyword= :keyword and lang_code= :lang_code";				
				IQuery q = session.CreateQuery(strSQL);
				q.SetString("keyword",keyword);
				q.SetString("lang_code",langCode);
				result = q.UniqueResult<MultiLanguage>();
				NHibernateHelper.closeSession();
			}
			return result;		
		}
		
		public string translate(string keyword, string currentLangCode, string defaultLangCode)
		{
			//ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
			//Logger log = new Logger();
					
			//System.Web.HttpContext.Current.Response.Write("<b>method translate canGetElement multiLanguageGlobalResource==null? </b>"+(multiLanguageGlobalResource==null)+"<br>");
			if(isGRNullOrEmpty() || !canGetElement){
				canLoadElements();
				//multithread don't work
				//ThreadUtil.FireAndForget(new InsertDelegate(WriteIt),null);
			}

			MultiLanguage element = null;
			
			// se currentLangCode != null allora tento i primi tre cascade su quella chiave
			if (!String.IsNullOrEmpty(currentLangCode))
			{
				// recupero la label dalla cache
				if(HttpContext.Current.Cache.Get(currentLangCode+"-"+keyword) != null){					
					element = (MultiLanguage)HttpContext.Current.Cache.Get(currentLangCode+"-"+keyword);
					/*log.usr= "system";
					log.msg = "return multilanguage: "+element.ToString();
					log.type = "debug";
					log.date = DateTime.Now;
					lrep.write(log);*/	
					return element.value;
				}
						
				// primo cascade sulla mappa in memoria
				if(canGetElement)
				{
					//System.Web.HttpContext.Current.Response.Write("<b>method translate recupero da mappa in memoria: </b>"+canGetElement+" - count: "+multiLanguageGlobalResource.Count+"<br>");				
					multiLanguageGlobalResource.TryGetValue(currentLangCode+"-"+keyword, out element);				
					if(element != null){
						HttpContext.Current.Cache.Insert(currentLangCode+"-"+keyword, element, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
						//canGetElement = true;
						return element.value;
					}
				}			
				// secondo cascade sul DB
				using (ISession session = NHibernateHelper.getCurrentSession())
				{
					IQuery q = session.CreateQuery("from MultiLanguage as multiLanguage where keyword= :keyword and lang_code= :lang_code");
					q.SetString("keyword",keyword);
					q.SetString("lang_code",currentLangCode);
					element = q.UniqueResult<MultiLanguage>();
					NHibernateHelper.closeSession();	
				}	
				if(element != null){
					if(notGRNull()){
						lock (_Padlock)
						{
							multiLanguageGlobalResource[currentLangCode+"-"+keyword] = element;
							//canGetElement = true;
						}
					}					
					HttpContext.Current.Cache.Insert(currentLangCode+"-"+keyword, element, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
					return element.value;
				}
				else
				{
					element = new MultiLanguage();
					element.keyword = keyword;
					element.langCode = currentLangCode;
					element.value = "";
					if(notGRNull()){
						lock (_Padlock)
						{
							multiLanguageGlobalResource[currentLangCode+"-"+keyword] = element;
							//canGetElement = true;
						}
					}					
					HttpContext.Current.Cache.Insert(currentLangCode+"-"+keyword, element, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
					return element.value;					
				}
			}	
			
			// se defaultLangCode != null && currentLangCode == null allora tento i primi tre cascade sulla chiave di default
			if (!String.IsNullOrEmpty(defaultLangCode))
			{
				// recupero la label dalla cache
				if(HttpContext.Current.Cache.Get(defaultLangCode+"-"+keyword) != null)
				{
					element = (MultiLanguage)HttpContext.Current.Cache.Get(defaultLangCode+"-"+keyword);
					//System.Web.HttpContext.Current.Response.Write("<b>method translate recupero da cache: </b>"+element.ToString()+"<br>");
					return element.value;
				}			
				// primo cascade sulla mappa in memoria
				if(canGetElement)
				{
					//System.Web.HttpContext.Current.Response.Write("<b>method translate recupero da mappa in memoria: </b>"+canGetElement+" - count: "+multiLanguageGlobalResource.Count+"<br>");					
					multiLanguageGlobalResource.TryGetValue(defaultLangCode+"-"+keyword, out element);				
					if(element != null){
						HttpContext.Current.Cache.Insert(defaultLangCode+"-"+keyword, element, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
						//canGetElement = true;
						return element.value;
					}
				}			
				// secondo cascade sul DB	
				using (ISession session = NHibernateHelper.getCurrentSession())
				{
					IQuery q = session.CreateQuery("from MultiLanguage as multiLanguage where keyword= :keyword and lang_code= :lang_code");
					q.SetString("keyword",keyword);
					q.SetString("lang_code",defaultLangCode);
					element = q.UniqueResult<MultiLanguage>();
					NHibernateHelper.closeSession();	
				}
				if(element != null){
					if(notGRNull()){
						lock (_Padlock)
						{
							multiLanguageGlobalResource[defaultLangCode+"-"+keyword] = element;
							//canGetElement = true;
						}
					}					
					HttpContext.Current.Cache.Insert(defaultLangCode+"-"+keyword, element, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
					return element.value;
				}
				else
				{
					element = new MultiLanguage();
					element.keyword = keyword;
					element.langCode = defaultLangCode;
					element.value = "";
					if(notGRNull()){
						lock (_Padlock)
						{
							multiLanguageGlobalResource[defaultLangCode+"-"+keyword] = element;
							//canGetElement = true;
						}
					}					
					HttpContext.Current.Cache.Insert(defaultLangCode+"-"+keyword, element, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
					return element.value;					
				}
			}		
			//System.Web.HttpContext.Current.Response.Write("<b>method translate result: </b>"+result+"<br>");
			// il return keyword � scomodo in diversi casi
			//return keyword;
			return null;
		}		
		
		
		public IDictionary<string, MultiLanguage> find(string find_key_value, int pageIndex, int pageSize, int langSize, out IList<string> distinctKeys, out long totalCount)
		{		
			IDictionary<string, MultiLanguage> multilanguages = new Dictionary<string, MultiLanguage>();
			IList multikey = null;
			distinctKeys = null;
			totalCount = 0;

			string strSQL = "select {ml.*} from MULTI_LANGUAGES {ml} where 1=1";
			if (!String.IsNullOrEmpty(find_key_value)){			
				strSQL += " and {ml}.keyword in (";
				strSQL += "select distinct {ml}.keyword from MULTI_LANGUAGES {ml} where {ml}.keyword like :val1  or {ml}.value like :val2";
				strSQL += ")";
			}
			strSQL += " order by {ml}.keyword, {ml}.lang_code asc";

			string strSQL2 = "select distinct keyword from MULTI_LANGUAGES";
			string strSQLCount = "select count(DISTINCT keyword) as count from MULTI_LANGUAGES";
			if (!String.IsNullOrEmpty(find_key_value)){		
				strSQL2 += " where keyword like :val1  or value like :val2";
				strSQLCount += " where keyword like :val1  or value like :val2";							
			}		
			strSQL2 += " order by keyword asc";			

			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				try
				{
					IQuery q = session.CreateSQLQuery(strSQL).AddEntity ("ml", typeof(MultiLanguage))
					.SetFirstResult(((pageIndex * pageSize*langSize) - pageSize*langSize))
					.SetMaxResults(pageSize*langSize);
					IQuery q2 = session.CreateSQLQuery(strSQL2).AddScalar("keyword", NHibernateUtil.String)
					.SetFirstResult(((pageIndex * pageSize) - pageSize))
					.SetMaxResults(pageSize);
					IQuery qCount = session.CreateSQLQuery(strSQLCount).AddScalar("count", NHibernateUtil.Int64);
	
					if (!String.IsNullOrEmpty(find_key_value)){
						q.SetString("val1", String.Format("%{0}%", find_key_value));
						q.SetString("val2", String.Format("%{0}%", find_key_value));
						q2.SetString("val1", String.Format("%{0}%", find_key_value));
						q2.SetString("val2", String.Format("%{0}%", find_key_value));	
						qCount.SetString("val1", String.Format("%{0}%", find_key_value));
						qCount.SetString("val2", String.Format("%{0}%", find_key_value));
					}
	
					multikey = getByQuery(q,q2,qCount,session, out distinctKeys,out totalCount);
					}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				}

				tx.Commit();
				NHibernateHelper.closeSession();
			}
			//System.Web.HttpContext.Current.Response.Write("<br>multikey.Count: " + multikey.Count);
			if(multikey != null){
				foreach (MultiLanguage k in multikey)
				{
					//System.Web.HttpContext.Current.Response.Write("<br>k.langCode-k.keyword: " + k.langCode+"-"+k.keyword);
					multilanguages.Add(k.langCode+"-"+k.keyword,k);
				} 
			}

			return multilanguages;
		}			

		protected IList getByQuery(
			IQuery query, 
			IQuery query2, 
			IQuery queryCount,
			ISession session,  
			out IList<string> distKeys, 
			out long totalCount)
		{
			IList records = null;	
			distKeys = null;
			totalCount=0;

			try
			{
				IList results = session.CreateMultiQuery()
				.Add(query)
				.Add(query2)
				.Add(queryCount)
				.SetCacheable(true)
				.List();
				records = results[0] as IList;

				IList keywords = results[1] as IList;
				if(keywords != null){
					distKeys= new List<string>();
					foreach(Object key in keywords)
					{
						//System.Web.HttpContext.Current.Response.Write("<br>keyword:"+(string)key);
						distKeys.Add((string)key);
					}
				}
				totalCount = (long)((IList)results[2])[0];
	
				//System.Web.HttpContext.Current.Response.Write("<br>results.Count:"+results.Count);
				//System.Web.HttpContext.Current.Response.Write("<br>((IList)results[0]).Count:"+((IList)results[0]).Count);
				//System.Web.HttpContext.Current.Response.Write("<br>((IList)results[1]).Count:"+((IList)results[1]).Count);
				//System.Web.HttpContext.Current.Response.Write("<br>((IList)results[2]).Count:"+((IList)results[2]).Count);
				//System.Web.HttpContext.Current.Response.Write("<br>totalCount 2 GetType():"+((IList)results[2]).GetType());
				//System.Web.HttpContext.Current.Response.Write("<br>totalCount 2 count:"+((IList)results[2]).Count);
				//System.Web.HttpContext.Current.Response.Write("<br>totalCount 2-0:"+((IList)results[2])[0]);
				//System.Web.HttpContext.Current.Response.Write("<br>totalCount 2-0 GetType():"+(((IList)results[2])[0]).GetType());				
				//foreach(Object val in records)
				//{
					//System.Web.HttpContext.Current.Response.Write("<br>Multilanguage:"+((MultiLanguage)val).ToString());
				//}

				//Object tmpC = ((IList)results[2])[0];//(long)((IList)results[1])[0]
				//bool b5 = typeof(long).IsAssignableFrom(tmpC.GetType()); // true
				//System.Web.HttpContext.Current.Response.Write("<br>tmpC:"+tmpC.UniqueResult<long>());
				//System.Web.HttpContext.Current.Response.Write("<br>b5:"+b5);

				//distKeys = (IList<string>)results[1];	
				//System.Web.HttpContext.Current.Response.Write("<br>GetType val:"+((IList)results[1])[0]);	

				//IFutureValue<long> totalCountX = queryCount.FutureValue<long>();
				//IEnumerable<string> distKeysX = query2.Future<string>();
				//IEnumerable<MultiLanguage> recordsX = query.Future<MultiLanguage>();
				//System.Web.HttpContext.Current.Response.Write("<br>totalCountX.Value:"+totalCountX.Value);	
				//System.Web.HttpContext.Current.Response.Write("<br>query:"+query);	
				//foreach(string val in distKeysX)
				//{
					//System.Web.HttpContext.Current.Response.Write("<br>val:"+val);
				//}
				//totalCount = totalCountX.Value; 
				//distKeys = distKeysX;
				//records = recordsX; 
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}
			
			//System.Web.HttpContext.Current.Response.Write("<br>query:"+query);	
			//System.Web.HttpContext.Current.Response.Write("<br>query2:"+query2);	
			//System.Web.HttpContext.Current.Response.Write("<br>queryCount:"+queryCount);	
			//System.Web.HttpContext.Current.Response.Write("<br>pageIndex:"+pageIndex+" - pageSize:"+pageSize);	
			//System.Web.HttpContext.Current.Response.Write("<br>results==null:"+(results==null));	
			//System.Web.HttpContext.Current.Response.Write("<br>results[0]:"+results[0]);
			//System.Web.HttpContext.Current.Response.Write("<br>records.Count:"+records.Count);	
			//System.Web.HttpContext.Current.Response.Write("<br>totalCount:"+totalCount);	
			//System.Web.HttpContext.Current.Response.Write("<br>records.GetType:"+records.GetType());
			//System.Web.HttpContext.Current.Response.Write("<br>records[0].ToString():"+records[0].ToString());
			
			return records;
		}

		static void canLoadElements()
		{
			//ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository"); 
			//StringBuilder builder = new StringBuilder();
			//Logger logger = new Logger();			
			
			IList<Language> results = null;

			IDictionary<string, IList<MultiLanguage>> setOfKeyForLang = new Dictionary<string, IList<MultiLanguage>>();
			lock (_Padlock)
			{	
				multiLanguageGlobalResource.Clear();
			}
			try
			{
				log.Warn("enter canLoadElements before callning session");
				using (ISession session = NHibernateHelper.getCurrentSession())
				{
					log.Warn("session==null: " + (session==null));
					IQuery q = session.CreateQuery("from Language as language order by label");
					results = q.List<Language>();							
					if(results != null)
					{
						foreach (Language k in results)
						{
							q = session.CreateQuery("from MultiLanguage as multiLanguage where lang_code= :lang_code order by multiLanguage.keyword asc");
							q.SetString("lang_code",k.label);
							IList<MultiLanguage> singleLang = q.List<MultiLanguage>();
							log.Warn("after query canLoadElements singleLang != null:"+(singleLang != null)+" - count:"+singleLang.Count);
							if(singleLang != null)
							{
								setOfKeyForLang.Add(k.label, singleLang);
							}
						}
					}			
					NHibernateHelper.closeSession();
				}
				log.Warn("middle point canLoadElements if here I have the session and element loaded");
				
			}
			catch(Exception ex)
			{
				log.Warn("An error occured multilanguage not preloaded: " + ex.Message+"<br><br><br>"+ex.StackTrace,ex);
				canGetElement = false;
				//builder = new StringBuilder("Exception: ")
				//.Append("canLoadElements(): ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
				//logger = new Logger(builder.ToString(),"system","error",DateTime.Now);		
				//lrep.write(logger);	
			}

			if(setOfKeyForLang.Count>0)
			{	
				foreach (List<MultiLanguage> multilanguages in setOfKeyForLang.Values)
				{
					foreach (MultiLanguage elem in multilanguages)
					{						
						lock (_Padlock)
						{	
							multiLanguageGlobalResource.Add(elem.langCode+"-"+elem.keyword,elem);
						}
						HttpContext.Current.Cache.Insert(elem.langCode+"-"+elem.keyword, elem, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
					} 
				}

				//builder = new StringBuilder("canLoadElements(): ")
				//.Append(DateTime.Now).Append("load complete: ");	
				//logger = new Logger(builder.ToString(), "system", "debug", DateTime.Now);	
				//lrep.write(logger);	
				
				canGetElement = true;
			}
			else{
				canGetElement = false;
			}
				
			log.Warn("multilanguage preloaded: " + canGetElement);
			return;	
		}		


		static void createLocaleSet()
		{
			/************ CREO LA MAPPA DEI LOCALE CHE VERRANNO GESTITI DAL CMS E LA IMPOSTO COME VARIABILE Application	
			*********** DI SEGUITO L'ELENCO DI TUTTI I CODICI LOCALE INTERNAZIONALI
			'Afrikaans  				af  		0x0436  	1078
			'Albanian 				sq 		0x041C 	1052
			'Arabic - United Arab Emirates ar-ae 	0x3801 	14337
			'Arabic - Bahrain 			ar-bh 	0x3C01 	15361
			'Arabic - Algeria 			ar-dz 	0x1401 	5121
			'Arabic - Egypt 			ar-eg 	0x0C01 	3073
			'Arabic - Iraq 				ar-iq 	0x0801 	2049
			'Arabic - Jordan 			ar-jo 	0x2C01 	11265
			'Arabic - Kuwait 			ar-kw 	0x3401 	13313
			'Arabic - Lebanon 			ar-lb 	0x3001 	12289
			'Arabic - Libya 			ar-ly 	0x1001 	4097
			'Arabic - Morocco 			ar-ma 	0x1801 	6145
			'Arabic - Oman 			ar-om 	0x2001 	8193
			'Arabic - Qatar 			ar-qa 	0x4001 	16385
			'Arabic - Saudi Arabia 		ar-sa 	0x0401 	1025
			'Arabic - Syria 				ar-sy 	0x2801 	10241
			'Arabic - Tunisia 			ar-tn 	0x1C01 	7169
			'Arabic - Yemen 			ar-ye 	0x2401 	9217
			'Armenian 				hy 		0x042B 	1067
			'Azeri - Latin 				az-az 	0x042C 	1068
			'Azeri - Cyrillic 			az-az 	0x082C 	2092
			'Basque 					eu 		0x042D 	1069
			'Belarusian 				be 		0x0423 	1059
			'Bulgarian 				bg 		0x0402 	1026
			'Catalan 					ca 		0x0403 	1027
			'Chinese - China 			zh-cn 	0x0804 	2052
			'Chinese - Hong Kong S.A.R. 	zh-hk 	0x0C04 	3076
			'Chinese - Macau S.A.R 		zh-mo 	0x1404 	5124
			'Chinese - Singapore 		zh-sg 	0x1004 	4100
			'Chinese - Taiwan 			zh-tw 	0x0404 	1028
			'Croatian 					hr 		0x041A 	1050
			'Czech 					cs 		0x0405 	1029
			'Danish 					da 		0x0406 	1030
			'Dutch - The Netherlands 	nl-nl 	0x0413 	1043
			'Dutch - Belgium 			nl-be 	0x0813 	2067
			'English - Standard 			en 		0x0009 	9
			'English - Australia 			en-au 	0x0C09 	3081
			'English - Belize 			en-bz 	0x2809 	10249
			'English - Canada 			en-ca 	0x1009 	4105
			'English - Carribbean 		en-cb 	0x2409 	9225
			'English - Ireland 			en-ie 	0x1809 	6153
			'English - Jamaica 			en-jm 	0x2009 	8201
			'English - New Zealand 		en-nz 	0x1409 	5129
			'English - Phillippines 		en-ph 	0x3409 	13321
			'English - South Africa 		en-za 	0x1C09 	7177
			'English - Trinidad 			en-tt 	0x2C09 	11273
			'English - United Kingdom 	en-gb 	0x0809 	2057
			'English - United States 		en-us 	0x0409 	1033
			'Estonian 					et 		0x0425 	1061
			'Farsi 					fa 		0x0429 	1065
			'Finnish 					fi 		0x040B 	1035
			'Faroese 					fo 		0x0438 	1080
			'French - Standard 			fr 		0x040C 	1036
			'French - Belgium 			fr-be 	0x080C 	2060
			'French - Canada 			fr-ca 	0x0C0C 	3084
			'French - Luxembourg 		fr-lu 	0x140C 	5132
			'French - Switzerland 		fr-ch 	0x100C 	4108
			'Gaelic - Ireland 			gd-ie 	0x083C 	2108
			'Gaelic - Scotland 			gd 		0x043C 	1084
			'German - Standard 			de	 	0x0407 	1031
			'German - Austria 			de-at 	0x0C07 	3079
			'German - Liechtenstein 		de-li 	0x1407 	5127
			'German - Luxembourg 		de-lu 	0x1007 	4103
			'German - Switzerland 		de-ch 	0x0807 	2055
			'Greek 					el 		0x0408 	1032
			'Hebrew 					he 		0x040D 	1037
			'Hindi 					hi 		0x0439 	1081
			'Hungarian 				hu 		0x040E 	1038
			'Icelandic 				is 		0x040F 	1039
			'Indonesian 				id 		0x0421 	1057
			'Italian - Standard			it 		0x0410 	1040
			'Italian - Switzerland 		it-ch 	0x0810 	2064
			'Japanese 				ja 		0x0411 	1041
			'Korean 					ko 		0x0412 	1042
			'Latvian 					lv 		0x0426 	1062
			'Lithuanian 				lt 		0x0427 	1063
			'FYRO Macedonian 			mk 		0x042F 	1071
			'Malay - Malaysia 			ms-my 	0x043E 	1086
			'Malay - Brunei 			ms-bn 	0x083E 	2110
			'Maltese 					mt 		0x043A 	1082
			'Marathi 					mr 		0x044E 	1102
			'Norwegian - Bokm�l 		no-no 	0x0414 	1044
			'Norwegian - Nynorsk 		no-no 	0x0814 	2068
			'Polish 					pl 		0x0415 	1045
			'Portuguese - Standard 		pt	 	0x0816 	2070
			'Portuguese - Brazil 			pt-br 	0x0416 	1046
			'Raeto-Romance 			rm 		0x0417 	1047
			'Romanian - Romania 		ro 		0x0418 	1048
			'Romanian - Moldova 		ro-mo 	0x0818 	2072
			'Russian 					ru 		0x0419 	1049
			'Russian - Moldova 			ru-mo 	0x0819 	2073
			'Sanskrit 					sa 		0x044F 	1103
			'Serbian - Cyrillic 			sr-sp 	0x0C1A 	3098
			'Serbian - Latin 			sr-sp 	0x081A 	2074
			'Setsuana 				tn 		0x0432 	1074
			'Slovenian 				sl 		0x0424 	1060
			'Slovak 					sk 		0x041B 	1051
			'Sorbian 					sb 		0x042E 	1070
			'Spanish - Standard 			es	 	0x0C0A 	1034
			'Spanish - Argentina 		es-ar 	0x2C0A 	11274
			'Spanish - Bolivia 			es-bo 	0x400A 	16394
			'Spanish - Chile 			es-cl 	0x340A 	13322
			'Spanish - Colombia 			es-co 	0x240A 	9226
			'Spanish - Costa Rica 		es-cr 	0x140A 	5130
			'Spanish - Dominican Republic es-do 	0x1C0A 	7178
			'Spanish - Ecuador 			es-ec 	0x300A 	12298
			'Spanish - Guatemala 		es-gt 	0x100A 	4106
			'Spanish - Honduras 		es-hn 	0x480A 	18442
			'Spanish - Mexico 			es-mx 	0x080A 	2058
			'Spanish - Nicaragua 		es-ni 	0x4C0A 	19466
			'Spanish - Panama 			es-pa 	0x180A 	6154
			'Spanish - Peru 			es-pe 	0x280A 	10250
			'Spanish - Puerto Rico 		es-pr 	0x500A 	20490
			'Spanish - Paraguay 			es-py 	0x3C0A 	15370
			'Spanish - El Salvador 		es-sv 	0x440A 	17418
			'Spanish - Uruguay 			es-uy 	0x380A 	14346
			'Spanish - Venezuela 		es-ve 	0x200A 	8202
			'Sutu 					sx 		0x0430 	1072
			'Swahili 					sw 		0x0441 	1089
			'Swedish - Sweden 			sv-se 	0x041D 	1053
			'Swedish - Finland 			sv-fi 		0x081D 	2077
			'Tamil 					ta 		0x0449 	1097
			'Tatar 					tt 		0X0444 	1092
			'Thai 					th 		0x041E 	1054
			'Turkish 					tr 		0x041F 	1055
			'Tsonga 					ts 		0x0431 	1073
			'Ukrainian 				uk 		0x0422 	1058
			'Urdu 					ur 		0x0420 	1056
			'Uzbek - Cyrillic 			uz-uz 	0x0843 	2115
			'Uzbek - Latin 				uz-uz 	0x0443 	1091
			'Vietnamese 				vi 		0x042A 	1066
			'Xhosa 					xh 		0x0434 	1076
			'Yiddish 					yi 		0x043D 	1085
			'Zulu 					zu 		0x0435 	1077
			*/

			XmlDocument xml = new XmlDocument();			
			string resxFile = System.Web.HttpContext.Current.Server.MapPath("~/app_data/conf/lang-code-mapping.xml");
			try{
				StreamReader reader = File.OpenText(resxFile);
				xml.Load(reader);
				reader.Close();
			
				XmlNodeList  xnList = xml.SelectNodes("//root/lang-code-mapping");	
				lock (_Padlock)
				{	
					localeSet.Clear();			
					foreach (XmlNode nd in xnList)
					{
						//System.Web.HttpContext.Current.Response.Write("key name: "+nd["keyword"].InnerText+" - value: "+nd["value"].InnerText+"<br>");	
						localeSet.Add(nd["keyword"].InnerText,nd["value"].InnerText);
		
						/*
						localeSet.Add("1078","AF");
						localeSet.Add("1052","SQ");
						localeSet.Add("14337","AR");
						localeSet.Add("15361","AR");
						localeSet.Add("5121","AR");
						localeSet.Add("3073","AR");
						localeSet.Add("2049","AR");
						localeSet.Add("11265","AR");
						localeSet.Add("13313","AR");
						localeSet.Add("12289","AR");
						localeSet.Add("4097","AR");
						localeSet.Add("6145","AR");
						localeSet.Add("8193","AR");
						localeSet.Add("16385","AR");
						localeSet.Add("1025","AR");
						localeSet.Add("10241","AR");
						localeSet.Add("7169","AR");
						localeSet.Add("9217","AR");
						localeSet.Add("1067","HY");
						localeSet.Add("1068","AZ");
						localeSet.Add("2092","AZ");
						localeSet.Add("1069","EU");
						localeSet.Add("1059","BE");
						localeSet.Add("1026","BG");
						localeSet.Add("1027","CA");
						localeSet.Add("2052","ZH");
						localeSet.Add("3076","ZH");
						localeSet.Add("5124","ZH");
						localeSet.Add("4100","ZH");
						localeSet.Add("1028","ZH");
						localeSet.Add("1050","HR");
						localeSet.Add("1029","CS");
						localeSet.Add("1030","DA");
						localeSet.Add("1043","NL");
						localeSet.Add("2067","NL");
						localeSet.Add("9","EN");
						localeSet.Add("3081","EN");
						localeSet.Add("10249","EN");
						localeSet.Add("4105","EN");
						localeSet.Add("9225","EN");
						localeSet.Add("6153","EN");
						localeSet.Add("8201","EN");
						localeSet.Add("5129","EN");
						localeSet.Add("13321","EN");
						localeSet.Add("7177","EN");
						localeSet.Add("11273","EN");
						localeSet.Add("2057","EN");
						localeSet.Add("1033","EN");
						localeSet.Add("1061","ET");
						localeSet.Add("1065","FA");
						localeSet.Add("1035","FI");
						localeSet.Add("1080","FO");
						localeSet.Add("1036","FR");
						localeSet.Add("2060","FR");
						localeSet.Add("3084","FR");
						localeSet.Add("5132","FR");
						localeSet.Add("4108","FR");
						localeSet.Add("2108","GD");
						localeSet.Add("1084","GD");
						localeSet.Add("1031","DE");
						localeSet.Add("3079","DE");
						localeSet.Add("5127","DE");
						localeSet.Add("4103","DE");
						localeSet.Add("2055","DE");
						localeSet.Add("1032","EL");
						localeSet.Add("1037","HE");
						localeSet.Add("1081","HI");
						localeSet.Add("1038","HU");
						localeSet.Add("1039","IS");
						localeSet.Add("1057","ID");
						localeSet.Add("1040","IT");
						localeSet.Add("2064","IT");
						localeSet.Add("1041","JA");
						localeSet.Add("1042","KO");
						localeSet.Add("1062","LV");
						localeSet.Add("1063","LT");
						localeSet.Add("1071","MK");
						localeSet.Add("1086","MS");
						localeSet.Add("2110","MS");
						localeSet.Add("1082","MT");
						localeSet.Add("1102","MR");
						localeSet.Add("1044","NO");
						localeSet.Add("2068","NO");
						localeSet.Add("1045","PL");
						localeSet.Add("2070","PT");
						localeSet.Add("1046","PT");
						localeSet.Add("1047","RM");
						localeSet.Add("1048","RO");
						localeSet.Add("2072","RO");
						localeSet.Add("1049","RU");
						localeSet.Add("2073","RU");
						localeSet.Add("1103","SA");
						localeSet.Add("3098","SR");
						localeSet.Add("2074","SR");
						localeSet.Add("1074","TN");
						localeSet.Add("1060","SL");
						localeSet.Add("1051","SK");
						localeSet.Add("1070","SB");
						localeSet.Add("1034","ES");
						localeSet.Add("11274","ES");
						localeSet.Add("16394","ES");
						localeSet.Add("13322","ES");
						localeSet.Add("9226","ES");
						localeSet.Add("5130","ES");
						localeSet.Add("7178","ES");
						localeSet.Add("12298","ES");
						localeSet.Add("4106","ES");
						localeSet.Add("18442","ES");
						localeSet.Add("2058","ES");
						localeSet.Add("19466","ES");
						localeSet.Add("6154","ES");
						localeSet.Add("10250","ES");
						localeSet.Add("20490","ES");
						localeSet.Add("15370","ES");
						localeSet.Add("17418","ES");
						localeSet.Add("14346","ES");
						localeSet.Add("8202","ES");
						localeSet.Add("1072","SX");
						localeSet.Add("1089","SW");
						localeSet.Add("1053","SV");
						localeSet.Add("2077","SV");
						localeSet.Add("1097","TA");
						localeSet.Add("1092","TT");
						localeSet.Add("1054","TH");
						localeSet.Add("1055","TR");
						localeSet.Add("1073","TS");
						localeSet.Add("1058","UK");
						localeSet.Add("1056","UR");
						localeSet.Add("2115","UZ");
						localeSet.Add("1091","UZ");
						localeSet.Add("1066","VI");
						localeSet.Add("1076","XH");
						localeSet.Add("1085","YI");
						localeSet.Add("1077","ZU");	
						*/				
					}
				}
			}catch(Exception ex){
				//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}
		}
		
		static string getLocaleCode(string code)
		{
			string result = null;
			XmlDocument xml = new XmlDocument();			
			string resxFile = System.Web.HttpContext.Current.Server.MapPath("~/app_data/conf/lang-code-mapping.xml");
			try{
				StreamReader reader = File.OpenText(resxFile);
				xml.Load(reader);
				reader.Close();	
			
				XmlNodeList  xnList = xml.SelectNodes("//root/lang-code-mapping");					
				foreach (XmlNode nd in xnList)
				{
					if(nd["keyword"].InnerText==code)
					{	
						lock (_Padlock)
						{	
							//System.Web.HttpContext.Current.Response.Write("key name: "+nd["keyword"].InnerText+" - value: "+nd["value"].InnerText+"<br>");	
							localeSet.Add(nd["keyword"].InnerText,nd["value"].InnerText);			
						}
						result = nd["value"].InnerText;
						break;
					}
				}
			}catch(Exception ex){
				//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}
			
			return result;	
		}

		static void createErrorSet()
		{
			XmlDocument xml = new XmlDocument();			
			string resxFile = System.Web.HttpContext.Current.Server.MapPath("~/app_data/conf/error-messages.xml");
			try{
				StreamReader reader = File.OpenText(resxFile);
				xml.Load(reader);
				reader.Close();	
			
				XmlNodeList  xnList = xml.SelectNodes("//root/error-messages");	
				lock (_Padlock)
				{				
					errorSet.Clear();			
					foreach (XmlNode nd in xnList)
					{
						//System.Web.HttpContext.Current.Response.Write("key name: "+nd["keyword"].InnerText+" - value: "+nd["value"].InnerText+"<br>");	
						errorSet.Add(nd["keyword"].InnerText,nd["value"].InnerText);			
					}
				}
			}catch(Exception ex){
				//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}
		}
		
		static string getErrorMessage(string code)
		{
			string result = null;
			XmlDocument xml = new XmlDocument();			
			string resxFile = System.Web.HttpContext.Current.Server.MapPath("~/app_data/conf/error-messages.xml");
			try{
				StreamReader reader = File.OpenText(resxFile);
				xml.Load(reader);
				reader.Close();	
			
				XmlNodeList  xnList = xml.SelectNodes("//root/error-messages");					
				foreach (XmlNode nd in xnList)
				{
					if(nd["keyword"].InnerText==code)
					{	
						lock (_Padlock)
						{	
							//System.Web.HttpContext.Current.Response.Write("key name: "+nd["keyword"].InnerText+" - value: "+nd["value"].InnerText+"<br>");	
							errorSet.Add(nd["keyword"].InnerText,nd["value"].InnerText);			
						}
						result = nd["value"].InnerText;
						break;
					}
				}
			}catch(Exception ex){
				//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}
			
			return result;	
		}

		static void createMessageSet()
		{

			XmlDocument xml = new XmlDocument();			
			string resxFile = System.Web.HttpContext.Current.Server.MapPath("~/app_data/conf/global-messages.xml");
			try{
				StreamReader reader = File.OpenText(resxFile);
				xml.Load(reader);
				reader.Close();	
			
				XmlNodeList  xnList = xml.SelectNodes("//root/global-messages");		
				lock (_Padlock)
				{			
					messageSet.Clear();		
					foreach (XmlNode nd in xnList)
					{
						//System.Web.HttpContext.Current.Response.Write("key name: "+nd["keyword"].InnerText+" - value: "+nd["value"].InnerText+"<br>");	
						messageSet.Add(nd["keyword"].InnerText,nd["value"].InnerText);	
						//log.Debug("<b>keyword:</b>"+nd["keyword"].InnerText+" - <b>value:</b>"+nd["value"].InnerText+" - <b>xnList.Count:</b>"+xnList.Count+"<br>");		
						//System.Web.HttpContext.Current.Response.Write("<b>keyword:</b>"+nd["keyword"].InnerText+" - <b>value:</b>"+nd["value"].InnerText+"<br>");
					}
				}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}
		}
		
		static string getGlobalMessage(string code)
		{
			string result = null;
			XmlDocument xml = new XmlDocument();			
			string resxFile = System.Web.HttpContext.Current.Server.MapPath("~/app_data/conf/global-messages.xml");
			try{
				StreamReader reader = File.OpenText(resxFile);
				xml.Load(reader);
				reader.Close();	
			
				XmlNodeList  xnList = xml.SelectNodes("//root/global-messages");					
				foreach (XmlNode nd in xnList)
				{
					if(nd["keyword"].InnerText==code)
					{	
						lock (_Padlock)
						{	
							//System.Web.HttpContext.Current.Response.Write("key name: "+nd["keyword"].InnerText+" - value: "+nd["value"].InnerText+"<br>");	
							messageSet.Add(nd["keyword"].InnerText,nd["value"].InnerText);			
						}
						result = nd["value"].InnerText;
						break;
					}
				}
			}catch(Exception ex){
				//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}
			
			return result;	
		}
		
		public string convertErrorCode(string code)
		{
			string element = null;
			errorSet.TryGetValue(code, out element);
			if(element==null)
			{
				element = getErrorMessage(code);
			}
			return element;
		}
		
		public string convertMessageCode(string code)
		{
			string element = null;
			messageSet.TryGetValue(code, out element);
			if(element==null)
			{
				element = getGlobalMessage(code);
			}
			return element;
		}
		
		public string convertLocaleCode(string code)
		{
			string element = null;
			localeSet.TryGetValue(code, out element);
			if(element==null)
			{
				element = getLocaleCode(code);
			}
			return element;
		}

		private static bool notGRNull()
		{
			return (multiLanguageGlobalResource != null);
		}

		private static bool notGRNullOrEmpty()
		{
			if(multiLanguageGlobalResource == null) return false;
			return (multiLanguageGlobalResource.Count > 0);
		}	

		private static bool isGRNullOrEmpty()
		{
			if(multiLanguageGlobalResource == null) return true;
			return (multiLanguageGlobalResource.Count <= 0);
		}
		
		public static void cleanCache(MultiLanguage value)
		{
			// cache cleaning
			HttpContext.Current.Cache.Remove(value.langCode+"-"+value.keyword);
			// memory cleaning
			lock (_Padlock)
			{	
				multiLanguageGlobalResource.Remove(value.langCode+"-"+value.keyword);
			}		
		}

		// metodo di utilit� per eseguire un fire forget per caricare le label all'avvio dell'applicazione
		delegate void InsertDelegate();
					
		static void WriteIt()
		{
			canLoadElements();
		}
	}
}