package myevents 
{
	/**
	 * ...
	 * @author Ladji Diakite
	 */
	
	import flash.events.*;
	
	public class VastParsedEvent extends Event
	{
		public static const VAST_PARSED:String = "vastParsed";
		public var message:Object;
		
		public function VastParsedEvent(type:String, message:Object, bubbles:Boolean = false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this.message = message;
		}
		
		override public function clone():Event 
		{
			return new VastParsedEvent(type, message, bubbles, cancelable);
		}
	}

}