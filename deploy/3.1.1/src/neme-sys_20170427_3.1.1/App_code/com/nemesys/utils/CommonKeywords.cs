using System;
using System.Text;

namespace com.nemesys.model
{
	public class CommonKeywords
	{	
		public static string getSuccessKey()
		{
			return "SUCCESS";
		}	
		public static string getPendingKey()
		{
			return "PENDING";
		}	
		public static string getFailedKey()
		{
			return "FAILED";
		}
		
		public static string getUniqueKeyOrderIdPayment()
		{
			return "id_order_ack";
		}
		
		public static string getUniqueKeyOrderAmountPayment()
		{
			return "amount_order_ack";
		}
		
		public static string getUniqueKeyOrderGUIDPayment()
		{
			return "order_guid_ack";
		}
		
		public static string getUniqueKeyOrderTypePayment()
		{
			return "payment_type_ack";
		}
		
		public static string getUniqueKeyExtURLPayment()
		{
			return "external_url";
		}
	}
}