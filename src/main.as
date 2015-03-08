package  {
	
	/**
	 * ...
	 * @author Ladji Diakite
	 */
	
	import flash.display.*;
	import flash.events.*;
	import service.Service;
	import respository.Repository;
	import views.VideoView;
	import myevents.VastParsedEvent;
	import assets.PlayerController;
	import flash.text.*;
	import assets.BufferingAnimation;
	
	public class main extends MovieClip  {
		
		public var _service:Service = new Service();
		public var _repository:Repository = new Repository();
		public var _videoView:VideoView = new VideoView();
		public var _playerController:PlayerController = new PlayerController();
		public var _bufferingAnimation:BufferingAnimation = new BufferingAnimation();
		public var rollsCount:Number = 0;
		public var rollsArray:Array = new Array();
		

		public function main() {
			
			//http://se-showroom.videoplaza.tv/proxy/distributor/v2?tt=p&t=sport,beauty&f=&s=9adfc0d5-645a-4b3c-bdf0-91824730a30f&rnd=[random]&rt=vast_2.0
			var mediaSource = (root.loaderInfo.parameters["mediasource"]) ? root.loaderInfo.parameters["mediasource"] : "big_buck_bunny_720p_h264.flv";
			var preroll = (root.loaderInfo.parameters["preroll"]) ? root.loaderInfo.parameters["preroll"] : "http://se-showroom.videoplaza.tv/proxy/distributor/v2?tt=p&t=sport,beauty&f=&s=9adfc0d5-645a-4b3c-bdf0-91824730a30f&rnd=[random]&rt=vast_2.0";
			var postRoll = (root.loaderInfo.parameters["postroll"]) ? root.loaderInfo.parameters["postroll"]: "http://se-showroom.videoplaza.tv/proxy/distributor/v2?tt=p&t=sport,beauty&f=&s=9adfc0d5-645a-4b3c-bdf0-91824730a30f&rnd=[random]&rt=vast_2.0";
			
			if (preroll != "") {
				
				rollsArray.push({preRollSource:preroll, name:"preRoll"})
			}
			
			if (postRoll != "") {
				
				rollsArray.push({preRollSource:postRoll, name:"postRoll"})
			}
			
			_repository.init(_service, _videoView, _playerController, _bufferingAnimation, mediaSource, rollsArray, this);
			_repository.addEventListener(VastParsedEvent.VAST_PARSED, vastParsed, false);
			
		}
		
		public function vastParsed(ev:VastParsedEvent):void 
		{
			IfAddFoundOrNot(true);
		}
		
		public function IfAddFoundOrNot(AdFound:Boolean):void 
		{
			if(AdFound){
				rollsCount++;
				if (rollsCount == rollsArray.length) {
					addVideoAndController();
				}
			}else 
			{
				addVideoAndController();
			}		
		}
		
		public function addVideoAndController():void 
		{
			_service.init(_repository);
			_videoView.init(_repository);
			addChild(_videoView);
			addChild(_playerController);
			addChild(_bufferingAnimation);
			_bufferingAnimation.visible = false;
			_repository.scaleAndResize();
		}
	}
	
}
