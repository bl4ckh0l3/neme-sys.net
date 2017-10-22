using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IAdsRepository : IRepository<Ads>
	{		
		void insert(Ads ads);
		
		void update(Ads ads);
		
		void delete(Ads ads);
		
		Ads getById(int id);
		
		Ads getByIdElement(int idElement, int idUser);
				
		IList<Ads> find(int adsType, decimal priceFrom, decimal priceTo, string dateFrom, string dateTo, string title, IList<int> matchCategories, IList<int> matchLanguages);
		
		void activatePromotion(int idAds, int idElement);
	}
}