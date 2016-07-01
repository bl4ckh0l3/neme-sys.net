using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class ShoppingCart
	{	
		private int _id;
		private int _idUser;
		private DateTime _lastUpdate;
		IDictionary<string,ShoppingCartProduct> _products;
		
		
		public ShoppingCart(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idUser {
			get { return _idUser; }
			set { _idUser = value; }
		}

		public virtual DateTime lastUpdate {
			get { return _lastUpdate; }
			set { _lastUpdate = value; }
		}

		public virtual IDictionary<string,ShoppingCartProduct> products {
			get { return _products; }
			set { _products = value; }
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ShoppingCart: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - idUser: ").Append(this._idUser)
			.Append(" - lastUpdate: ").Append(this._lastUpdate);
			
			return builder.ToString();			
		}
	}
}