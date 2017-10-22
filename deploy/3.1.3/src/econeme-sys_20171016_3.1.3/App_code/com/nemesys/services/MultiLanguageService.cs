using System;
using System.Web;
using System.Collections.Generic;
using System.Data;
using System.Threading;
using System.Web.Caching;
using System.Xml;
using System.IO;
using com.nemesys.database.repository;

namespace com.nemesys.services
{
	public class MultiLanguageService
	{
		
		private static IMultiLanguageRepository repository = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");

		public static string translate(String keyword,String currentLangCode,String defaultLangCode)
		{
			return repository.translate(keyword, currentLangCode, defaultLangCode);
		}

		public static string getLangCode(String baseLangCode, String checkLangCode, bool localeActive)
		{
			// check lang passed by request
			if (!String.IsNullOrEmpty(checkLangCode))
			{
				return checkLangCode;
			}
			// check lang on session
			if (!String.IsNullOrEmpty(baseLangCode))
			{
				return baseLangCode;
			}
			// check lang locale based
			if (localeActive)
			{
				return convertLocaleCode(Thread.CurrentThread.CurrentCulture.LCID.ToString());
			}	
			return null;
		}		

		public static string convertLocaleCode(String code)
		{
			return repository.convertLocaleCode(code);
		}	

		public static string convertErrorCode(String code)
		{
			return repository.convertErrorCode(code);
		}	

		public static string convertMessageCode(String code)
		{
			return repository.convertMessageCode(code);
		}
	}
}