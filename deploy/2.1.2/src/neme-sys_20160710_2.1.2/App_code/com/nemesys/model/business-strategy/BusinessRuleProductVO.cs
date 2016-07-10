using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

namespace com.nemesys.model
{	
	public class BusinessRuleProductVO
	{	
		private int _productId;
		private int _productCounter;
		private decimal _price;	
		private int _quantity;
		private bool _excludeBills;
		private IDictionary<int,IList<object>> _rulesInfo;
		private IDictionary<int,bool> _rulesApplied;
		
		
		public BusinessRuleProductVO(){
			_price = 0.00M;
			_productCounter = 0;
			_quantity = 0;
			_excludeBills = false;
			_rulesInfo = new Dictionary<int,IList<object>>();
			_rulesApplied = new Dictionary<int,bool>();
		}

		public virtual int productId {
			get { return _productId; }
			set { _productId = value; }
		}

		public virtual int productCounter {
			get { return _productCounter; }
			set { _productCounter = value; }
		}	

		public virtual decimal price {
			get { return _price; }
			set { _price = value; }
		}

		public virtual int quantity {
			get { return _quantity; }
			set { _quantity = value; }
		}

		public virtual bool excludeBills {
			get { return _excludeBills; }
			set { _excludeBills = value; }
		}

		public virtual IDictionary<int,IList<object>> rulesInfo {
			get { return _rulesInfo; }
			set { _rulesInfo = value; }
		}

		public virtual IDictionary<int,bool> rulesApplied {
			get { return _rulesApplied; }
			set { _rulesApplied = value; }
		}		
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("BusinessRuleProductVO: ")
			.Append(" - productId: ").Append(this._productId)
			.Append(" - productCounter: ").Append(this._productCounter)
			.Append(" - price: ").Append(this._price)
			.Append(" - quantity: ").Append(this._quantity)
			.Append(" - excludeBills: ").Append(this._excludeBills);
			
			return builder.ToString();			
		}
	}
}