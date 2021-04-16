using System;
using System.Data;
using System.Text;
using System.Collections;
using System.Collections.Generic;

namespace com.nemesys.model
{
	public class Category : IComparable<Category>
	{		
		private int _id;
		private int _numMenu;
		private string _hierarchy;
		private string _description;
		private bool _hasElements;
		private bool _visible;
		private bool _automatic;
		private int _idTemplate;
		private string _subDomainUrl;
		private string _metaDescription;
		private string _metaKeyword;
		private string _pageTitle;
		private string _filePath;
		private IList<CategoryTemplate> _templates;
		
		public Category(){}
		
		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int numMenu {
			get { return _numMenu; }
			set { _numMenu = value; }
		}

		public virtual string hierarchy {
			get { return _hierarchy; }
			set { _hierarchy = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual bool hasElements {
			get { return _hasElements; }
			set { _hasElements = value; }
		}

		public virtual bool visible {
			get { return _visible; }
			set { _visible = value; }
		}

		public virtual bool automatic {
			get { return _automatic; }
			set { _automatic = value; }
		}

		public virtual int idTemplate {
			get { return _idTemplate; }
			set { _idTemplate = value; }
		}

		public virtual string subDomainUrl {
			get { return _subDomainUrl; }
			set { _subDomainUrl = value; }
		}

		public virtual string metaDescription {
			get { return _metaDescription; }
			set { _metaDescription = value; }
		}

		public virtual string metaKeyword {
			get { return _metaKeyword; }
			set { _metaKeyword = value; }
		}

		public virtual string pageTitle {
			get { return _pageTitle; }
			set { _pageTitle = value; }
		}

		public virtual string filePath {
			get { return _filePath; }
			set { _filePath = value; }
		}

		public virtual IList<CategoryTemplate> templates {
			get { return _templates; }
			set { _templates = value; }
		}
		
		public virtual int getLevel(){
			int level = 0;
			string[] lv = this.hierarchy.Split('.');
			if(lv!=null){level=lv.Length;}
			return level;
		}
		
		public virtual double hierarchy2double()
		{
			return hierarchy2double(this.hierarchy);
		}		

		public virtual int CompareTo(Category other)
		{
			//return this._hierarchy.CompareTo(other.hierarchy);
			int val = hierarchy2double(this._hierarchy).CompareTo(hierarchy2double(other.hierarchy));
			//System.Web.HttpContext.Current.Response.Write("this._hierarchy:"+this._hierarchy+" - other._hierarchy:"+other._hierarchy+" - compareTo val:"+val+"<br>");
			return val;
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Category id: ")
			.Append(this._id)
			.Append(" - numMenu: ").Append(this._numMenu)
			.Append(" - hierarchy: ").Append(this._hierarchy)
			.Append(" - description: ").Append(this._description)
			.Append(" - hasElements: ").Append(this._hasElements)
			.Append(" - visible: ").Append(this._visible)
			.Append(" - automatic: ").Append(this._automatic)
			.Append(" - idTemplate: ").Append(this._idTemplate)
			.Append(" - subDomainUrl: ").Append(this._subDomainUrl)
			.Append(" - metaDescription: ").Append(this._metaDescription)
			.Append(" - metaKeyword: ").Append(this._metaKeyword)
			.Append(" - pageTitle: ").Append(this._pageTitle)
			.Append(" - filePath: ").Append(this._filePath);
			
			return builder.ToString();			
		}

		private double hierarchy2double(string hierarchy)
		{			
			double gerarchiaDbl= 0.0;
			double scale= 1.0 / 100.0;
			
			string[] p = null;
			if(!String.IsNullOrEmpty(hierarchy)){
				p = hierarchy.Split('.');
			}
			if(p!=null){
				foreach (string item in p){
					int level = Convert.ToInt32(item);
					gerarchiaDbl = gerarchiaDbl + (level * scale);	
					scale = scale / 100.0;					
				}
			} 

			return gerarchiaDbl;
		}
	}
}