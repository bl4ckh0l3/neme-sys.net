using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IGeolocalizationRepository : IRepository<Geolocalization>
	{		
		void insert(Geolocalization value);
		
		void update(Geolocalization value);
		
		void delete(Geolocalization value);
		
		Geolocalization getById(int id);
		
		IList<Geolocalization> findByElement(int idElement, int type);
	}
}