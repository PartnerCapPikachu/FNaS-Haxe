package states;

import sys.thread.Thread;
import sys.thread.Mutex;

import openfl.utils.AssetType;
import openfl.display.BitmapData;
import flash.media.Sound;

class LoadingState extends FlxState {

  var currentlyLoadedBar:FlxSprite;
  var mutex:Mutex;

  var targetState:FlxState;

  var images:Array<String>;
  var music:Array<String>;
  var sounds:Array<String>;

  var destroyPreviousAssets:Bool;

  var requestedBitmaps:Map<String, BitmapData> = [];

  var currentlyLoaded:Int = 0;
  var loadLimit:Int = 0;

  override public function new(targetState:FlxState, ?images:Array<String>, ?music:Array<String>, ?sounds:Array<String>, destroyPreviousAssets = true):Void {
    this.targetState = targetState;
    this.images = images ?? [];
    this.music = music ?? [];
    this.sounds = sounds ?? [];
    loadLimit = this.images.length + this.music.length + this.sounds.length;
    this.destroyPreviousAssets = destroyPreviousAssets;
    super();
  }

  override function create():Void {
    persistentUpdate = true;
    AssetManager.clearUsed();

    var h:Int = Math.floor(FlxG.height * .01);
    currentlyLoadedBar = new FlxSprite(0, FlxG.height - h).makeGraphic(1, h, 0xffffffff);
    add(currentlyLoadedBar);

    mutex = new Mutex();
    super.create();
    AssetManager.clearUnused();

    for (i in images) initThread(() -> preloadBitmapData(i));
    for (i in music.concat(sounds)) initThread(() -> AssetManager.getOgg(i.substr(7)));
  }

  var previousAssetsDestroyed:Bool = false;
  var done:Bool = false;
  override function update(elapsed:Float):Void {
    super.update(elapsed);
    if (done)
      return;
    @:privateAccess currentlyLoadedBar._frame.frame.width = FlxG.width * currentlyLoaded / loadLimit;
    if (checkLoaded()) {
      done = true;
      FlxG.switchState(targetState);
    }
  }

  function initThread(func:Void->Void):Void {
    Thread.create(() -> {
      mutex.acquire();
      try {func();}
      currentlyLoaded++;
      mutex.release();
    });
  }

  @:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
  function preloadBitmapData(key:String) {
    try {
      key += '.png';
      if (!AssetManager.trackedGraphics.exists(key.substr(14)) && FileSystem.exists(key)) {
        var bitmap:BitmapData = BitmapData.fromFile(key);
        if (bitmap.image != null)
          bitmap.disposeImage();
        requestedBitmaps.set(key, bitmap);
      }
    }
  }

  function checkLoaded():Bool {
		for (key => bitmap in requestedBitmaps)
			if (bitmap != null)
        AssetManager.getGraphic(key.substr(14, key.length - 4));
		requestedBitmaps.clear();
    return currentlyLoaded == loadLimit;
  }

}