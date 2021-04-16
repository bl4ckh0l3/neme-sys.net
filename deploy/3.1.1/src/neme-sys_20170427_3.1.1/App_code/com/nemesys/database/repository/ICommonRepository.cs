using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface ICommonRepository
	{		
		IList<SystemFieldsType> getSystemFieldsType();
		
		IList<SystemFieldsTypeContent> getSystemFieldsTypeContent();
	}
}