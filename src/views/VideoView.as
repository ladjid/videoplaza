package views 
{
	/**
	 * ...
	 * @author Ladji Diakite
	 */
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetDataEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.*;
	import flash.net.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import respository.Repository;
	import myevents.VastParsedEvent;
	
	public class VideoView extends MovieClip
	{
		private var _repository:Repository;
		public  var totalDuration:Number;
		private var netConnetion:NetConnection;
		public  var netStream:NetStream;
		private var playSequence:Array = new Array();
		private var currentSequenceCount:Number = 0;
		private var txtField:TextField;
		public  var timer:Timer = new Timer(1000);
		public  var video:Video;
		
		public function VideoView() 
		{
		}
		
		public function init(repository:Repository) 
		{
			_repository = repository;
			netConnetion = new NetConnection();
			netConnetion.connect(null);
			netStream = new NetStream(netConnetion);
			var clientObj = new Object();
			netStream.client = clientObj;
			var stageSize = _repository.getStageSize();
			video = new Video(stageSize.width, stageSize.height);
			video.attachNetStream(netStream);
			addChild(video);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, netStreamStatusChanged, false);
			netStream.useJitterBuffer = true;
			video.smoothing = true;
			clientObj.onMetaData = onMetaDataHandler;
			setupPlaySequence();
			startPlay();
		}
	
		
		private function onMetaDataHandler(info:Object) {
			totalDuration = info.duration;
		}
		
		private function setupPlaySequence():void 
		{	
			if (_repository.getpreRollSource() != null) {
				
				var preRoll = { name:'preRoll', details:_repository.getpreRollSource() };
				playSequence.push(preRoll)
			}
			
			var mainContent = { name:'mainContent', details:_repository.getMediaSource() };
			playSequence.push(mainContent)
			
			if (_repository.getPostRollSource() != null) {
				
				var postRoll = { name:'postRoll', details:_repository.getPostRollSource() };
				playSequence.push(postRoll)
			}
			
		}
		
		private function startPlay():void 
		{
			var currentSequence = playSequence[currentSequenceCount];
			
			if (currentSequence.name == "preRoll" || currentSequence.name == "postRoll") {
				
				var source = currentSequence.details["Ad1"].creatives["Creative1"].Linear.MediaFiles.MediaFile.children()[0].toString();
				var videoclickTrough = currentSequence.details["Ad1"].creatives["Creative1"].Linear.VideoClicks.children()[0].toString();
				var companionBanner = currentSequence.details["Ad1"].creatives["Creative2"].CompanionAds.Companion.IFrameResource.toString();
				netStream.play(source);
				_repository.addBanner(companionBanner, bannerLoaded);
		
				var stageSize = _repository.getStageSize();
				var coverClip:Shape = new Shape();
				coverClip.graphics.beginFill(0x990000, 0);
				coverClip.graphics.drawRect(0, 0, stageSize.width, stageSize.height);
				var coverClipContainer = new MovieClip();
				coverClipContainer.name = "coverClipContainer";
				coverClipContainer.addChild(coverClip);
				addChild(coverClipContainer);
				_repository.addClickTrough(coverClipContainer, videoclickTrough);
				_repository.hidePlayerController();
			}
			
			if (currentSequence.name == "mainContent") {
				
				removeChilds();
				netStream.play(_repository.getMediaSource());
				_repository.showplayerController();
				_repository.setVolumeLevel(0.5);
				timer.addEventListener(TimerEvent.TIMER, setCurrentPlayerHeadAndTime, false);
				timer.start();
			}
			
		}
		
		public function bannerLoaded(ev:Event):void 
		{
			txtField = new TextField();
			txtField.name = "textField";
			txtField.x = -5;
			txtField.y = -60;
			txtField.autoSize = TextFieldAutoSize.LEFT;
			txtField.htmlText = ev.target.data;
			addChild(txtField);
		}
		
		private function netStreamStatusChanged(ev:NetStatusEvent):void 
		{
			
			if (ev.info.code == "NetStream.Play.Stop") {
			
				currentSequenceCount++;
					
				if (currentSequenceCount <= playSequence.length-1) {
					startPlay();
				}
					
				if (currentSequenceCount == playSequence.length) {
						
					_repository.movePlayPauseBtnToPlay();
					playSequence = [];
					var mainContent = { name:'mainContent', details:_repository.getMediaSource() };
					playSequence.push(mainContent);
					currentSequenceCount = 0;
					startPlay();
					netStream.pause();
					removeChilds();
				}
				
			}
			
			if (ev.info.code == "NetStream.Buffer.Empty") {
				_repository.showBufferingAnimation();
			}
			
			if (ev.info.code == "NetStream.Buffer.Full") {
				_repository.hideBufferingAnimation();
			}
			
		}
		
		public function removeChilds():void 
		{
			if (this.getChildByName("coverClipContainer") != null) {
				var coverClipChild = this.getChildByName("coverClipContainer");
				this.removeChild(coverClipChild);
			}
				
			if (this.getChildByName("textField") != null) {
				var textFieldChild = this.getChildByName("textField");
				this.removeChild(textFieldChild);
			}
		}
		
		private function setCurrentPlayerHeadAndTime(ev:TimerEvent):void 
		{
			_repository.setCurrentPlayerHeadAndTime(netStream.time, totalDuration);
		}
	}
}