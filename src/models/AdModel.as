package models 
{
	import flash.utils.Dictionary;
	
	public class AdModel extends Object 
	{
		public var id:String;
		public var adSystem:String;
		public var error:String;
		public var adTitles:String;
		public var impressions:Dictionary;
		public var creatives:Dictionary;
		public var extensions:Dictionary;
	}

}