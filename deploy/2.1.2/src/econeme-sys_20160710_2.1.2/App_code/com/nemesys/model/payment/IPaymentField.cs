using System;
using com.nemesys.model;

namespace com.nemesys.model
{
	public interface IPaymentField
	{		
		int id{get; set;}

		int idPayment{get; set;}

		int idModule{get; set;}

		string keyword{get; set;}

		string value{get; set;}

		string matchField{get; set;}
		
		string ToString();
	}
}