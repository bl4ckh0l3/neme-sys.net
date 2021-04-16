using System;
using System.Collections;
using System.Data;
using System.Web;
using System.Text;

namespace com.nemesys.exception
{
	public class QuantityException : Exception
	{
		public QuantityException()
			: base() { }
		
		public QuantityException(string message)
			: base(message) { }
		
		public QuantityException(string format, params object[] args)
			: base(string.Format(format, args)) { }
		
		public QuantityException(string message, Exception innerException)
			: base(message, innerException) { }
		
		public QuantityException(string format, Exception innerException, params object[] args)
			: base(string.Format(format, args), innerException) { }
	}
}