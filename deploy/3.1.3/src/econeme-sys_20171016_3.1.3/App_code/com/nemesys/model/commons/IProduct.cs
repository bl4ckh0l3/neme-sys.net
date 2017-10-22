using System;
using System.Text;

namespace com.nemesys.model
{
	public interface IProduct
	{	
		int idProduct { get; set; }

		int productCounter { get; set; }

		int productQuantity { get; set; }

		int productType { get; set; }

		string productName { get; set; }
	}
}