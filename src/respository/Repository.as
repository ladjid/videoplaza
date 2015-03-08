package respository 
{
	/**
	 * ...
	 * @author Ladji Diakite
	 */
	
	import adobe.utils.CustomActions;
	import assets.BufferingAnimation;
	import assets.PlayerController;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display.StageQuality;
	import flash.display.StageAlign;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.media.SoundTransform;
	import flash.net.*;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import service.Service;
	import views.VideoView;
	import flash.events.*;
	import myevents.VastParsedEvent;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import Utils.caurina.transitions.*;

	public class Repository extends MovieClip
	{
		private var _service:Service;
		private var _videoView:VideoView;
		private var _playerController:PlayerController;
		private var _mediaSource:String;
		private var _mainRoot:main;
		private var _bufferingAnimation:BufferingAnimation;
		private var preRollObject:Dictionary = null;
		private var postRollObject:Dictionary = null;
		private var videoClickSource:String;
		private var playerScrubbarPosLimit:Number;
		private var scrubbarThumbIsDragging:Boolean;
		private var volumeThumbIsDragging:Boolean;
		private var volumeThumbScrubbarPosLimit:Number;
		private var controllHideTimer:Timer = new Timer(5000);
		
		public function Repository() 
		{
		}
		
		public function init(service:Service, videoView:VideoView, playerController:PlayerController, bufferingAnimation:BufferingAnimation, mediaSource:String, rolls:Array , mainRoot:main) 
		{
			_service = service;
			_videoView = videoView;
			_playerController = playerController;
			_mainRoot = mainRoot;
			_bufferingAnimation = bufferingAnimation;
			_mediaSource = mediaSource;
			
			for (var i:int = 0; i <rolls.length ; i++) 
			{
				var callback = (rolls[i].name == "preRoll") ? preRollLoaded : postRollLoaded;
				getVast(rolls[i].preRollSource, callback);
			}
			
			_mainRoot.addEventListener(MouseEvent.MOUSE_UP, stopScrubbarThumbDragging, false);
			_mainRoot.stage.quality = StageQuality.HIGH;
			_mainRoot.stage.scaleMode = StageScaleMode.NO_SCALE;
			_mainRoot.stage.align = StageAlign.TOP_LEFT;
			_mainRoot.stage.addEventListener(Event.RESIZE, onStageResize);
			
			playerScrubbarPosLimit = _playerController.scrubbarControll.scubbarBg.width - _playerController.scrubbarControll.scrubbarThumb.width;
			volumeThumbScrubbarPosLimit = _playerController.volumeControll.volumeBg.width - _playerController.volumeControll.volumeThumb.width;
			setupPlayerInteractions();
			
			if (rolls.length == 0) {
				
				_mainRoot.IfAddFoundOrNot(false);
			}
		}
		
		
		public function getVast(source, callBack) {
			
			_service.getVast(source, callBack)
		}
		
		public function preRollLoaded(ev:Event) {
			
			preRollObject = _service.parseVast(new XML(ev.target.data));
			dispatchEvent(new VastParsedEvent(VastParsedEvent.VAST_PARSED, { message:"vast parsed" } ));
		}
		
		public function postRollLoaded(ev:Event):void 
		{
			postRollObject = _service.parseVast(new XML(ev.target.data));
			dispatchEvent(new VastParsedEvent(VastParsedEvent.VAST_PARSED, { message:"vast parsed" } ));
		}
		
		public function getMediaSource():String {
			
			return _mediaSource
		}
		
		public function getpreRollSource():Dictionary {
			 
			return preRollObject;
		}
		
		public function getPostRollSource():Dictionary {
			
			return postRollObject;
		}
		
		public function getStageSize():Object {
			
			return { width:_mainRoot.stage.stageWidth, height:_mainRoot.stage.stageHeight };
		}
		
		public function addBanner(source:String, callback:Function):void 
		{
			_service.addBanner(source, callback);
		}
		
		public function addClickTrough(coverClip:MovieClip, source):void {
			
			videoClickSource = source;
			coverClip.buttonMode=true;
			coverClip.useHandCursor=true;
			coverClip.mouseChildren = false;
			coverClip.addEventListener(MouseEvent.MOUSE_DOWN, videoClicked, false);
		}
		
		public function removeClickTrough(video:Video):void {
			
			video.removeEventListener(MouseEvent.MOUSE_DOWN, videoClicked, false);
		}
		
		public function videoClicked(ev:Event):void 
		{
			var urlReq:URLRequest = new URLRequest(videoClickSource);
			navigateToURL(urlReq, '_blank');
		}
		
		public function showplayerController():void 
		{
			_playerController.visible = true;
			controllHideTimer.addEventListener(TimerEvent.TIMER, hideController, false);
			controllHideTimer.start();
			_mainRoot.addEventListener(MouseEvent.MOUSE_MOVE, showController, false);
		}
		
		public function hidePlayerController():void 
		{
			_playerController.visible = false;
			_mainRoot.removeEventListener(MouseEvent.MOUSE_MOVE, showController, false);
		}
		
		public function setCurrentPlayerHeadAndTime(currentTime:Number, totalTime:Number, moveScrubbarThumbFlag:Boolean=true):void 
		{
			var totalTimeConverted = ConvertTime(totalTime);
			var currentTimeConverted = ConvertTime(currentTime);
			_playerController.currentTime.autoSize = TextFieldAutoSize.LEFT;
			_playerController.currentTime.text = currentTimeConverted + " / " + totalTimeConverted;
			var playerPosition = Math.floor(currentTime / totalTime * playerScrubbarPosLimit);
			_playerController.scrubbarControll.scrubbarTime.width = playerPosition;
			
			if(moveScrubbarThumbFlag){
				_playerController.scrubbarControll.scrubbarThumb.x = playerPosition;
			}
			
		}
		
		public function ConvertTime(time):String{
			
			var hour = Math.floor(time/3600);
			var minute = Math.floor((time%3600)/60);
			var second = Math.floor((time%3600)%60);
			
			var mainSecond = (second<10) ? "0"+second : second;
			var mainMinute = (minute<10) ? "0"+minute : minute;
			var mainHours  = (hour<10)  ? "0"+hour : hour;
			
			var currentTime = mainHours+":"+mainMinute+":"+mainSecond;
			
			return currentTime;
		}
		
		public function setupPlayerInteractions():void 
		{
			_playerController.playPauseBtn.buttonMode = true;
			_playerController.playPauseBtn.useHandCursor = true;
			_playerController.playPauseBtn.addEventListener(MouseEvent.MOUSE_DOWN, playPauseBtnDown, false);
			
			_playerController.fullScreenBtn.buttonMode = true;
			_playerController.fullScreenBtn.useHandCursor = true;
			_playerController.fullScreenBtn.addEventListener(MouseEvent.MOUSE_DOWN, fullScreenBtnDown, false);
			
			_playerController.scrubbarControll.scrubbarThumb.buttonMode = true;
			_playerController.scrubbarControll.scrubbarThumb.useHandCursor = true;
			_playerController.scrubbarControll.scrubbarThumb.addEventListener(MouseEvent.MOUSE_DOWN, scrubbarThumbDown, false);
			_playerController.scrubbarControll.scrubbarThumb.addEventListener(MouseEvent.MOUSE_UP, scrubbarThumbUp, false);
			
			_playerController.scrubbarControll.scrubbarClick.buttonMode = true;
			_playerController.scrubbarControll.scrubbarClick.useHandCursor = true;
			_playerController.scrubbarControll.scrubbarClick.addEventListener(MouseEvent.MOUSE_DOWN, scrubbarClickDown, false);
			
			_playerController.volumeControll.volumeThumb.buttonMode = true;
			_playerController.volumeControll.volumeThumb.useHandCursor = true;
			_playerController.volumeControll.volumeThumb.addEventListener(MouseEvent.MOUSE_DOWN, volumeThumbDown, false);
			_playerController.volumeControll.volumeThumb.addEventListener(MouseEvent.MOUSE_UP, volumeThumbUp, false);
			
			_playerController.volumeControll.volumeBtn.buttonMode = true;
			_playerController.volumeControll.volumeBtn.useHandCursor = true;
			_playerController.volumeControll.volumeBtn.addEventListener(MouseEvent.MOUSE_DOWN, volumeBtnDown, false);
			
			_playerController.volumeSymbol.buttonMode = true;
			_playerController.volumeSymbol.useHandCursor = true;
			_playerController.volumeSymbol.addEventListener(MouseEvent.MOUSE_DOWN, volumeSymbolDown, false);
			
		}
		
		public function playPauseBtnDown(ev:MouseEvent):void 
		{
			if (_playerController.playPauseBtn.currentFrame == 1) {
				
				_playerController.playPauseBtn.gotoAndStop(2);
				_videoView.netStream.pause();
				
			}else {
				
				_playerController.playPauseBtn.gotoAndStop(1);
				_videoView.netStream.resume();
			}
		}
		
		public function fullScreenBtnDown(ev:MouseEvent):void 
		{
			_mainRoot.stage.displayState = (_mainRoot.stage.displayState == StageDisplayState.NORMAL) ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL ;
		}
		
		public function scrubbarThumbDown(ev:MouseEvent):void 
		{	
			scrubbarThumbIsDragging = true;
			_videoView.timer.stop();
			var rect:Rectangle = new Rectangle(0, 0,playerScrubbarPosLimit , 0);
			ev.target.startDrag(false, rect);
			ev.target.addEventListener(Event.ENTER_FRAME, ScrubbarThumdDragging);
		}
		
		public function ScrubbarThumdDragging(ev:Event):void 
		{
			var playerPosition = Math.floor(ev.target.x / playerScrubbarPosLimit * _videoView.totalDuration);
			_videoView.netStream.seek(playerPosition);
			setCurrentPlayerHeadAndTime(playerPosition, _videoView.totalDuration, false)
			
		}
		
		public function scrubbarThumbUp(ev:MouseEvent):void 
		{	
			scrubbarThumbIsDragging = false;
			_videoView.timer.start();
			ev.target.stopDrag();
			ev.target.removeEventListener(Event.ENTER_FRAME, ScrubbarThumdDragging);
		}
		
		public function stopScrubbarThumbDragging(ev:MouseEvent):void 
		{
			if (scrubbarThumbIsDragging) {
				scrubbarThumbIsDragging = false;
				_videoView.timer.start();
				_playerController.scrubbarControll.scrubbarThumb.stopDrag();
				_playerController.scrubbarControll.scrubbarThumb.removeEventListener(Event.ENTER_FRAME, ScrubbarThumdDragging);
			}
			
			if (volumeThumbIsDragging) {
				volumeThumbIsDragging = false;
				_playerController.volumeControll.volumeThumb.stopDrag();
				_playerController.volumeControll.volumeThumb.removeEventListener(Event.ENTER_FRAME, volumeThumbDragging);
			}
		}
		
		public function scrubbarClickDown(ev:MouseEvent):void 
		{
			var xposition = ev.target.mouseX;
			var playerPosition = Math.floor(xposition / playerScrubbarPosLimit * _videoView.totalDuration);
			_videoView.netStream.seek(playerPosition);
			setCurrentPlayerHeadAndTime(playerPosition, _videoView.totalDuration, true)
		}
		
		public function volumeThumbDown(ev:MouseEvent) {
			
			volumeThumbIsDragging = true;
			var rect:Rectangle = new Rectangle(0, 0, volumeThumbScrubbarPosLimit, 0);
			ev.target.startDrag(false,rect);
			ev.target.addEventListener(Event.ENTER_FRAME, volumeThumbDragging, false );
		}
		
		public function volumeThumbDragging(ev:Event) {
			
			var volume = (ev.target.x / volumeThumbScrubbarPosLimit * 1);
			setVolumeLevel(volume);
		}
		
		public function volumeThumbUp(ev:MouseEvent) {
			
			volumeThumbIsDragging = false;
			ev.target.stopDrag();
			volumeThumbIsDragging = true;
			ev.target.removeEventListener(Event.ENTER_FRAME, volumeThumbDragging, false);
		}
		
		public function volumeBtnDown(ev:MouseEvent):void 
		{
			var volume = (ev.target.mouseX / volumeThumbScrubbarPosLimit *  1);
			setVolumeLevel(volume);
		}
		
		public function setVolumeLevel(volume:Number) {
			
			var volumeLevelwidth  = Math.floor(volume / 1 * volumeThumbScrubbarPosLimit);
			var maskWidth = Math.floor(volume / 1 * _playerController.volumeSymbol.maskBg.width);
			_playerController.volumeSymbol.volumeIconMask.width = maskWidth;
			_playerController.volumeControll.volumeLevel.width = volumeLevelwidth;
			_playerController.volumeControll.volumeThumb.x = volumeLevelwidth;
			var Soundtrans:SoundTransform = new SoundTransform(volume,0);
			_videoView.netStream.soundTransform = Soundtrans;
			
			if (volume == 0) {
				_playerController.volumeSymbol.VolumeIcongrey.alpha = 0;
				_playerController.volumeSymbol.volumeMuted.alpha = 1;
			}else {
				_playerController.volumeSymbol.volumeMuted.alpha = 0;
				_playerController.volumeSymbol.VolumeIcongrey.alpha = 1;
			}
		}
		
		public function volumeSymbolDown(ev:MouseEvent):void 
		{
			if(_playerController.volumeSymbol.volumeMuted.alpha == 1){
				setVolumeLevel(0.5);
			}else {
				setVolumeLevel(0);
			}
			
		}
		
		public function showController(ev:MouseEvent):void 
		{
			Tweener.addTween(_playerController, { alpha:1, time:1 })
			controllHideTimer.addEventListener(TimerEvent.TIMER, hideController, false);
			controllHideTimer.start();
		}
		
		public function hideController(ev:Event):void 
		{
			Tweener.addTween(_playerController, { alpha:0, time:1 })
			ev.target.stop();
		}
		
		public function onStageResize(ev:Event):void 
		{
			scaleAndResize();
			
		}
		
		public function scaleAndResize():void 
		{
			_videoView.video.width = _mainRoot.stage.stageWidth;
			_videoView.video.height = _mainRoot.stage.stageHeight;
			_playerController.y = _mainRoot.stage.stageHeight - _playerController.height;
			_playerController.controllerBg.width = _mainRoot.stage.stageWidth;
			_playerController.scrubbarControll.scubbarBg.width =  _mainRoot.stage.stageWidth;
			playerScrubbarPosLimit = _playerController.scrubbarControll.scubbarBg.width - _playerController.scrubbarControll.scrubbarThumb.width;
			_bufferingAnimation.x = (_mainRoot.stage.stageWidth - _bufferingAnimation.width) / 2;
			_bufferingAnimation.y = (_mainRoot.stage.stageHeight - _bufferingAnimation.height) / 2;
		}
		
		public function movePlayPauseBtnToPlay():void 
		{
			_playerController.playPauseBtn.gotoAndStop(2);
		}
		
		public function showBufferingAnimation() {
			
			_bufferingAnimation.visible = true;
		}
		
		public function hideBufferingAnimation():void 
		{
			_bufferingAnimation.visible = false;
		}
	}

}