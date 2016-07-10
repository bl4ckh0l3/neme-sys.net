using System;
using System.Globalization;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using System.Xml;
using System.IO;
using System.Web.Caching;
using com.nemesys.model;
using com.nemesys.database;

namespace com.nemesys.services
{
	public class GeolocalizationService
	{		
		//'****************************** START: COPPIA DI FUNZIONI STATICHE PER DETERMINARE SE UN PUNTO APPARTIENE AD UN POLIGONO DATO IL PUNTO E I VERTICI DEL POLIGONO
		private static double isLeft(Geolocalization P0, Geolocalization P1, Geolocalization P2)
		{
			return Convert.ToDouble(((P1.latitude-P0.latitude)*(P2.longitude-P0.longitude)-(P2.latitude-P0.latitude)*(P1.longitude-P0.longitude)));
		}
	
		public static bool isPointInPolygon(Geolocalization point, IList<Geolocalization> vertices)
		{
			try{
				int wn = 0;    //' the  winding number counter
				//'loop through all edges of the polygon
				for(int i=0;i<=vertices.Count-2;i++)	//' edge from V[i] to  V[i+1]
				{
					//System.Web.HttpContext.Current.Response.Write("vertices[i].longitude:"+vertices[i].longitude+" - point.longitude:"+point.longitude+" - vertices[i].longitude <= point.longitude: " + (vertices[i].longitude <= point.longitude) +"<br>");
					if (vertices[i].longitude <= point.longitude)           //' start y <= P.y
					{
						if (vertices[i+1].longitude > point.longitude)       //' an upward crossing
						{
							if (isLeft( vertices[i], vertices[i+1], point) > 0)  //' P left of  edge
							{
								wn=wn+1;            //' have  a valid up intersect
							}
						}
					}else{                         //' start y > P.y (no test needed)
						//System.Web.HttpContext.Current.Response.Write("vertices[i+1].longitude:"+vertices[i+1].longitude+" - point.longitude:"+point.longitude+" - vertices[i+1].longitude <= point.longitude: " + (vertices[i+1].longitude <= point.longitude) +"<br>");
						if (vertices[i+1].longitude <= point.longitude)      //' a downward crossing
						{
							if (isLeft( vertices[i], vertices[i+1], point) < 0)   //' P right of  edge
							{
								wn = wn-1;            //' have  a valid down intersect
							}
						}
					}
				}

				return wn!=0;
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				return false;
			}
		}
		//'****************************** END: COPPIA DI FUNZIONI STATICHE PER DETERMINARE SE UN PUNTO APPARTIENE AD UN POLIGONO DATO IL PUNTO E I VERTICI DEL POLIGONO
		
	
		//'****************************** START: FUNZIONE STATICA PER DETERMINARE SE UN PUNTO APPARTIENE AD UN CERCHIO, DATO IL PUNTO, IL CENTRO DEL CERCHIO E IL RAGGIO (il raggio va passato in metri)
		public static bool isPointInCircleOnEarthSurface(Geolocalization point, Geolocalization center, double radiusParam)
		{
			//System.Web.HttpContext.Current.Response.Write("radiusParam:" + radiusParam+"<br>");			
			double distanceInMeters = greatCircleDistanceInMeters(point.longitude, point.latitude, center.longitude, center.latitude);	
			//System.Web.HttpContext.Current.Response.Write("distanceInMeters:" + distanceInMeters+"<br>");
			return distanceInMeters < radiusParam;
		}
		//'****************************** END: FUNZIONE STATICA PER DETERMINARE SE UN PUNTO APPARTIENE AD UN CERCHIO, DATO IL PUNTO, IL CENTRO DEL CERCHIO E IL RAGGIO (il raggio va passato in metri)
	
	
	
		//'****************************** START: FUNZIONE STATICA PER CONVERTIRE UNA STRINGA DI VERTICI ORDINATI SEPARATI DA | E RAPPRESENTANTI UN POLIGONO CHIUSO(CONVAVO E/O CONVESSO) IN UNA LISTA DI OGGETTI LocalizationClass
		//'****************************** PER FUNZIONARE CORRETTAMENTE L ULTIMO VERTICE DELLA LISTA DEVE ESSERE LA RIPETIZIONE DEL PRIMO IN MODO DA DEFINIRE CON SICUREZZA IL POLIGONO CHIUSO
		public static IList<Geolocalization> convertVertices(string vertices)
		{
			IList<Geolocalization> elements = null;
			//System.Web.HttpContext.Current.Response.Write("vertices: " + vertices+"<br>");
			string[] listVertices = vertices.Split('|');
			if(listVertices != null)
			{
				elements = new List<Geolocalization>();
				foreach(string x in listVertices)
				{
					string[] arrLatLon = x.Split(',');
					if(arrLatLon != null)
					{
						//System.Web.HttpContext.Current.Response.Write("arrLatLon[0]:" + arrLatLon[0]+" - arrLatLon[1]:"+arrLatLon[1]+"<br>");
						Geolocalization pointV = new Geolocalization();
						pointV.latitude=decimal.Parse(arrLatLon[0], CultureInfo.InvariantCulture);
						pointV.longitude=decimal.Parse(arrLatLon[1], CultureInfo.InvariantCulture);	
						//System.Web.HttpContext.Current.Response.Write("pointV:" + pointV.ToString()+"<br>");
						elements.Add(pointV);
					}
				}   
			}
			return elements;
		}
	
		
		//'****************************** START: FUNZIONE STATICA PER CONVERTIRE UN PUNTO (LAT,LON) IN UN OGGETTO LocalizationClass
		public static Geolocalization convertCenter(string center)
		{
			Geolocalization pointCenterCircle = null;
			string[] arrCenterPoint = center.Split(',');
			if(arrCenterPoint != null)
			{
				pointCenterCircle = new Geolocalization();
				pointCenterCircle.latitude=decimal.Parse(arrCenterPoint[0], CultureInfo.InvariantCulture);
				pointCenterCircle.longitude=decimal.Parse(arrCenterPoint[1], CultureInfo.InvariantCulture);
			}
			return pointCenterCircle;
		}
	
	
		//'************************* START: FUNZIONI DI UTILITÀ TRIGONOMETRICHE
		//' Find the great-circle distance in metres, assuming a spherical earth, between two lat-long points in degrees. */
		private static double greatCircleDistanceInMeters(decimal aLong1, decimal aLat1, decimal aLong2, decimal aLat2)
		{
			double KPiDouble = 3.14159265358979;
			double KDegreesToRadiansDouble = KPiDouble / 180.0;
			//'A constant to convert radians to metres for the Mercator and other projections.
			//'It is the semi-major axis (equatorial radius) used by the WGS 84 datum (see http://en.wikipedia.org/wiki/WGS84).
			long KEquatorialRadiusInMetres = 6378137;
	
			double aLong1x = Convert.ToDouble(aLong1)*KDegreesToRadiansDouble;
			double aLat1x = Convert.ToDouble(aLat1)*KDegreesToRadiansDouble;
			double aLong2x = Convert.ToDouble(aLong2)*KDegreesToRadiansDouble;
			double aLat2x = Convert.ToDouble(aLat2)*KDegreesToRadiansDouble;
	
			double angle = Math.Acos(Math.Sin(aLat1x) * Math.Sin(aLat2x) + Math.Cos(aLat1x) * Math.Cos(aLat2x) * Math.Cos(aLong2x - aLong1x));
	
			return angle * KEquatorialRadiusInMetres;
		}
		//'************************* END: FUNZIONI DI UTILITÀ TRIGONOMETRICHE	
	}
}