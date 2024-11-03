package states;

import sys.thread.Thread;
import sys.thread.Mutex;

import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display.BitmapData;
import flash.media.Sound;

class LoadingState extends FlxState {

  var currentlyLoadedBar:FlxSprite;
  var mutex:Mutex;

  var targetState:FlxState;

  var images:Array<String>;
  var music:Array<String>;
  var sounds:Array<String>;

  var requestedBitmaps:Map<String, BitmapData> = [];
  var originalBitmapKeys:Map<String, String> = [];

  var currentlyLoaded:Int = 0;
  var loadLimit:Int = 0;

  override public function new(targetState:FlxState, ?images:Array<String>, ?music:Array<String>, ?sounds:Array<String>):Void {
    this.targetState = targetState;
    this.images = images ?? [];
    this.music = music ?? [];
    this.sounds = sounds ?? [];
    loadLimit = this.images.length + this.music.length + this.sounds.length;
    super();
  }

  override function create():Void {
    persistentUpdate = true;

    var h:Int = Math.floor(FlxG.height * .01);
    currentlyLoadedBar = new FlxSprite(0, FlxG.height - h).makeGraphic(1, h, 0xffffffff);
    add(currentlyLoadedBar);

    super.create();

    mutex = new Mutex();
    for (i in images) initThread(() -> preloadBitmapData(i));
    for (i in music.concat(sounds)) initThread(() -> preloadSound(i));
  }

  var done:Bool = false;
  override function update(elapsed:Float):Void {
    super.update(elapsed);
    if (done)
      return;
    var isLoaded:Bool = checkLoaded();
    currentlyLoadedBar.scale.x = FlxG.width * 2 * (currentlyLoaded / loadLimit);
    currentlyLoadedBar.updateHitbox();
    if (isLoaded) {
      done = true;
      FlxG.switchState(targetState);
      return;
    }
  }

  function initThread(func:Void->Void):Void {
    Thread.create(() -> {
      try {func();}
      mutex.acquire();
      currentlyLoaded++;
      mutex.release();
    });
  }

  @:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
  function preloadBitmapData(key:String):Void {
    key += '.png';
    try {
      mutex.acquire();
      if (!AssetManager.trackedGraphics.exists(key) && OpenFlAssets.exists(key, IMAGE)) {
        requestedBitmaps.set(key, OpenFlAssets.getBitmapData(key, false));
        originalBitmapKeys.set(key, key);
      }
      mutex.release();
    }
  }

  function preloadSound(key:String):Void {
    key += '.ogg';
    try {
      mutex.acquire();
      if (!AssetManager.trackedAudio.exists(key) && OpenFlAssets.exists(key, SOUND)) {
        AssetManager.localAssets.push(key);
        AssetManager.trackedAudio.set(key, OpenFlAssets.getSound(key, false));
      }
      mutex.release();
    }
  }

  function checkLoaded():Bool {
		for (key => bitmap in requestedBitmaps)
			if (bitmap != null) {
        var tempKey:String = originalBitmapKeys.get(key).substr(14);
        AssetManager.getGraphic(tempKey.substr(0, tempKey.length - 4));
      }
		requestedBitmaps.clear();
		originalBitmapKeys.clear();
    return currentlyLoaded == loadLimit;
  }

}