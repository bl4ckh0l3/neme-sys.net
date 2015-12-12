using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface ICountryRepository : IRepository<Country>
	{		
		void insert(Country value);
		
		void update(Country value);
		
		void delete(Country value);
		
		Country getById(int id);

		void saveCompleteCountry(Country country, IList<Geolocalization> listOfPoints, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
				
		IList<Country> find(string active, string useFor, string searchKey, int pageIndex, int pageSize,out long totalCount);
				
		IList<Country> findAllCountries(string useFor);
		
		IList<Country> findAllStateRegion(string useFor);
		
		IList<Country> findStateRegionByCountry(string countryCode, string useFor);
	}
}