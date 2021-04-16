using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IRepository<T>
	{
		void insert(T value);
		
		void update(T value);
		
		void delete(T value);
		
		T getById(int id);
	}
}