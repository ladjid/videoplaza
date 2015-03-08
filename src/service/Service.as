package service 
{
	/**
	 * ...
	 * @author Ladji Diakite
	 */
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import respository.Repository;
	import flash.events.Event;
	import flash.net.*;
	import flash.xml.*;
	import models.AdModel;
	import Utils.TraceAdModel;
	import flash.utils.Dictionary;
	
	public class Service extends MovieClip
	{
		private var _repository:Repository
		private var vastParsedCount = 0;
		
		public function Service() 
		{
	
		}
		
		public function init(repository:Repository) 
		{
			_repository = repository;
		}
		
		public function getVast(source:String, callback:Function):void 
		{
			var urlrequest:URLRequest = new URLRequest(source);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.load(urlrequest);
			urlLoader.addEventListener(Event.COMPLETE, callback, false);
		}
		
		public function parseVast(vastXml:XML):Dictionary 
		{
			var adList:Dictionary = new Dictionary();
			var count = 0;
			
			for each (var ad in vastXml.Ad) 
			{
			  var adModel:AdModel = new AdModel();
			  adModel.id = ad.@id;
			  adModel.adSystem = ad.InLine.AdSystem;
			  adModel.adTitles = ad.InLine.adTitle;
			  adModel.error = ad.InLine.Error;
			  adModel.impressions = extractNodesToDictionary(ad.InLine.Impression);
			  adModel.creatives = extractNodesToDictionary(ad.InLine.Creatives.Creative);
			  adModel.extensions = extractNodesToDictionary(ad.InLine.Extensions.Extension);
			  count++;
			  var key = "Ad" + count;
			  adList[key] = adModel;
			}
			return adList;
		}
		
		public function extractNodesToDictionary(xmlList:XMLList):Dictionary {
			
			var tempDictionary:Dictionary = new Dictionary();
			var count = 0;
			
			for each (var item in xmlList) 
			{
				count++;
				tempDictionary[item.name() + count] = item;
			}
			
			return tempDictionary;
		}
		
		public function addBanner(source:String, callback:Function):void 
		{
			var urlReq:URLRequest = new	URLRequest(source);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.load(urlReq);
			urlLoader.addEventListener(Event.COMPLETE, callback, false);
		}

	}
}