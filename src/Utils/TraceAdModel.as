package Utils 
{
	/**
	 * ...
	 * @author Ladji Diakite
	 */
	
	import flash.utils.Dictionary;
	
	public class TraceAdModel
	{
		public static function traceValues(obj:Dictionary) : void{
			
			for each (var item in obj) {
				
				trace(item.id);
				trace("\n")
				trace(item.adSystem);
				trace("\n")
				trace(item.adTitles);
				trace("\n")
				trace(item.error);
				trace("\n")
				trace(item.impressions["Impression1"]);
				trace("\n")
				trace(item.creatives["Creative1"]);
				trace("\n")
				trace(item.extensions["Extension1"]);
			}
		}
		
	}
}