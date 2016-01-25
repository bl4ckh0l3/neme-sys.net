using System;
using System.Text;
using System.Globalization;

namespace com.nemesys.model
{
	public class Guids
	{	
		public static int createGuidMax10Len(int tmpLength)
		{
			if(tmpLength>10){tmpLength=10;}
			string result="";
			string strValid = "0123456789";
			Random random = new Random();
			for(int i = 1; i< tmpLength; i++){
				int start = (int)(random.NextDouble() * strValid.Length);
				if(start>strValid.Length){start=strValid.Length;}
				result += strValid.Substring(start,1);
			}
			return Convert.ToInt32(result);
		}	
		
		public static long createGuid13Digits(Random random)
		{		
			string result="";
			for(int i = 1; i<= 13; i++){
				int start = random.Next(0,10000);
				if(i==1 && start==0){
					start=1;
				}
				result += start.ToString().Substring(0,1);
			}
			return Convert.ToInt64(result);
		}	
		
		public static long createGuidMax18Len(int tmpLength)
		{
			//System.Web.HttpContext.Current.Response.Write("<br><b>createNumberGUIDRandomVarLenght:</b><br> - tmpLength:"+tmpLength+"<br>");
			if(tmpLength>18){tmpLength=18;}
			string result="";
			string strValid = "0123456789";
			Random random = new Random();
			for(int i = 1; i< tmpLength; i++){
				int start = (int)(random.NextDouble() * strValid.Length);
				if(start>strValid.Length){start=strValid.Length;}
				result += strValid.Substring(start,1);
			}
			return Convert.ToInt64(result);
		}

		public static string createGuidRandomLen(int tmpLength)
		{
			string result="";
			string strValid = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			Random random = new Random();
			for(int i = 1; i< tmpLength; i++){
				int start = (int)(random.NextDouble() * strValid.Length);
				if(start>strValid.Length){start=strValid.Length;}
				result += strValid.Substring(start,1);
			}
			return result;
		}
		
		public static string generateStandardGuid()
		{		
			return Guid.NewGuid().ToString();
		}
		
		public static string generateComb()
		{
			byte[] destinationArray = Guid.NewGuid().ToByteArray();
			DateTime time = new DateTime(0x76c, 1, 1);
			DateTime now = DateTime.Now;
		 
			// Get the days and milliseconds which will be
			// used to build the byte string
			TimeSpan span = new TimeSpan(now.Ticks - time.Ticks);
			TimeSpan timeOfDay = now.TimeOfDay;
		 
			// Convert to a byte array
			// Note that SQL Server is accurate to 1/300th of a 
			// millisecond so we divide by 3.333333
			byte[] bytes = BitConverter.GetBytes(span.Days);
			byte[] array = BitConverter.GetBytes(
						   (long)
						   (timeOfDay.TotalMilliseconds / 3.333333));
		 
			// Reverse the bytes to match SQL Servers ordering
			Array.Reverse(bytes);
			Array.Reverse(array);
		 
			// Copy the bytes into the guid
			Array.Copy(bytes, bytes.Length - 2,
							  destinationArray,
							  destinationArray.Length - 6, 2);
			Array.Copy(array, array.Length - 4,
							  destinationArray,
							  destinationArray.Length - 4, 4);
			return new Guid(destinationArray).ToString();
		} 		

		public static string getUniqueKey(int length)
		{
			string guidResult = string.Empty;			
			while (guidResult.Length < length)
			{
				// Get the GUID.
				guidResult += Guid.NewGuid().ToString().GetHashCode().ToString("x");
			}
		
			// Make sure length is valid.
			if (length <= 0 || length > guidResult.Length)
				throw new ArgumentException("Length must be between 1 and " + guidResult.Length);
		
			// Return the first length bytes.
			return guidResult.Substring(0, length);
		}

		public static string createOrderGuid()
		{
		  return generateComb();
		}
		
		public static string createUserGuid()
		{
		  return generateComb() + getUniqueKey(10) + getUniqueKey(15) + getUniqueKey(25);
		}
		
		public static string createPasswordGuid()
		{
		  return getUniqueKey(12);
		}
		
		public static string createVoucherCodeGuid()
		{
		  return generateComb();
		}
				
		/*
		Function CreateGUIDTime()
		  Dim tmpTemp
		  tmpTemp = Right(String(4,48) & Year(Now()),4)
		  tmpTemp = tmpTemp & Right(String(4,48) & Month(Now()),2)
		  tmpTemp = tmpTemp & Right(String(4,48) & Day(Now()),2)
		  tmpTemp = tmpTemp & Right(String(4,48) & Hour(Now()),2)
		  tmpTemp = tmpTemp & Right(String(4,48) & Minute(Now()),2)
		  tmpTemp = tmpTemp & Right(String(4,48) & Second(Now()),2)
		  CreateGUIDTime = tmpTemp
		End Function
		
		Function CreateGUIDTime2()
		  Dim tmpTemp1,tmpTemp2
		  tmpTemp1 = Right(String(15,48) & CStr(CLng(DateDiff("s","1/1/2000",Date()))), 15)
		  tmpTemp2 = Right(String(5,48) & CStr(CLng(DateDiff("s","12:00:00 AM",Time()))), 5)
		  CreateGUIDTime2 = tmpTemp1 & tmpTemp2
		End Function
		
		Function CreateGUIDTime3()
		  Randomize Timer
		  Dim tmpTemp1,tmpTemp2,tmpTemp3
		  tmpTemp1 = Right(String(10,48) & CStr(CLng(DateDiff("s","1/1/2000",Date()))), 10)
		  tmpTemp2 = Right(String(5,48) & CStr(CLng(DateDiff("s","12:00:00 AM",Time()))), 5)
		  tmpTemp3 = Right(String(5,48) & CStr(Int(Rnd(1) * 100000)),5)
		  CreateGUIDTime3 = tmpTemp1 & tmpTemp2 & tmpTemp3
		End Function
		
		Function CreateGUIDTime4()
		  Randomize Timer
		  Dim tmpTemp1,tmpTemp2,tmpTemp3
		  tmpTemp1 = Right(String(10,48) & CStr(CLng(DateDiff("s","1/1/2000",Date()))), 7)
		  tmpTemp2 = Right(String(5,48) & CStr(CLng(DateDiff("s","12:00:00 AM",Time()))), 3)
		  CreateGUIDTime4 = tmpTemp1 & tmpTemp2
		End Function
		
		Function CreateGUIDRandom()
		  Randomize Timer
		  Dim tmpCounter,tmpGUID
		  Const strValid = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		  For tmpCounter = 1 To 20
			tmpGUID = tmpGUID & Mid(strValid, Int(Rnd(1) * Len(strValid)) + 1, 1)
		  Next
		  CreateGUIDRandom = tmpGUID
		End Function
		
		Function CreateGUIDRandomVarLenght(tmpLength)
		  Randomize Timer
		  Dim tmpCounter,tmpGUID
		  Const strValid = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		  For tmpCounter = 1 To tmpLength
			tmpGUID = tmpGUID & Mid(strValid, Int(Rnd(1) * Len(strValid)) + 1, 1)
		  Next
		  CreateGUIDRandomVarLenght = tmpGUID
		End Function
		
		Function CreateNumberGUIDRandomVarLenght(tmpLength)
		  Randomize Timer
		  Dim tmpCounter,tmpGUID
		  Const strValid = "0123456789"
		  For tmpCounter = 1 To tmpLength
			tmpGUID = tmpGUID & Mid(strValid, Int(Rnd(1) * Len(strValid)) + 1, 1)
		  Next
		  CreateNumberGUIDRandomVarLenght = tmpGUID
		End Function
		
		Function CreateWindowsGUID()
		  CreateWindowsGUID = CreateGUIDRandomVarLenght(8) & "-" & _
			CreateGUIDRandomVarLenght(4) & "-" & _
			CreateGUIDRandomVarLenght(4) & "-" & _
			CreateGUIDRandomVarLenght(4) & "-" & _
			CreateGUIDRandomVarLenght(12)
		End Function
		
		Function CreateOrderGUIDLong()
			CreateOrderGUIDLong = CreateGUIDTime3() & _
			CreateGUIDRandomVarLenght(5) & _
			CreateGUIDRandomVarLenght(10) & _
			CreateGUIDRandomVarLenght(15) & _
			CreateGUIDRandomVarLenght(20) & _
			CreateGUIDRandomVarLenght(25) & _
			CreateGUIDRandomVarLenght(50)
		End Function
		
		Function CreateOrderGUID()
		  CreateOrderGUID = CreateGUIDTime3()' & _
			'CreateGUIDRandomVarLenght(10) & _
			'CreateGUIDRandomVarLenght(15) & _
			'CreateGUIDRandomVarLenght(25) & _
			'CreateGUIDRandomVarLenght(25)
		End Function
		
		Function CreateUserGUID()
		  CreateUserGUID = CreateGUIDTime3() & _
			CreateGUIDRandomVarLenght(10) & _
			CreateGUIDRandomVarLenght(15) & _
			CreateGUIDRandomVarLenght(25)
		End Function
		
		Function CreatePasswordGUID()
		  CreatePasswordGUID = CreateGUIDRandomVarLenght(12)
		End Function
		
		Function CreateVoucherCodeGUID()
		  CreateVoucherCodeGUID = CreateGUIDTime3()' & _
			CreateGUIDRandomVarLenght(10)
		End Function
		
		Function orderGUIDLength
			 orderGUIDLength = CInt(100)
		End Function
		*/
	}
}