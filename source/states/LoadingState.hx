package states;

import sys.thread.Thread;
import sys.thread.Mutex;

import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display.BitmapData;
import flash.media.Sound;

class LoadingState extends FlxState {

  var currentlyLoadedBar:FlxSprite;
  var currentItemLoading:FlxText;
  var mutex:Mutex;

  var targetState:FlxState;
  var destroyPreviousAssets:Bool;

  var images:Array<String>;
  var music:Array<String>;
  var sounds:Array<String>;

  var requestedBitmaps:Map<String, BitmapData> = [];
  var originalBitmapKeys:Map<String, String> = [];

  var currentlyLoaded:Int = 0;
  var loadLimit:Int = 0;

  override public function new(targetState:FlxState, ?images:Array<String>, ?music:Array<String>, ?sounds:Array<String>, destroyPreviousAssets:Bool = true):Void {
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

    if (destroyPreviousAssets) {
      AssetManager.clearUsed();
      AssetManager.clearUnused();
    }

    var h:Int = Math.floor(FlxG.height * .01);
    currentlyLoadedBar = new FlxSprite(0, FlxG.height - h).makeGraphic(1, h, 0xffffffff);
    add(currentlyLoadedBar);

    currentItemLoading = new FlxText(0, FlxG.height * .5, FlxG.width, '', Util.trueTextScale(120));
    add(currentItemLoading);
    currentItemLoading.setFormat(AssetManager.getFont('FNaS_Font'), currentItemLoading.size, 0xffffffff, 'center', FlxText.FlxTextBorderStyle.OUTLINE, 0x000000);
    currentItemLoading.borderSize = 0;
    currentItemLoading.antialiasing = false;

    super.create();

    mutex = new Mutex();
    for (i in images) initThread(function():Null<BitmapData> return preloadBitmapData(i), 'BITMAPDATA\n"$i"');
    for (i in music.concat(sounds)) initThread(function():Null<Sound> return preloadSound(i), 'SOUND\n"$i"');
  }

  var done:Bool = false;
  var percent:Float = 0;
  override function update(elapsed:Float):Void {
    super.update(elapsed);

    if (!done) {
      var isLoaded:Bool = checkLoaded();
      percent = currentlyLoaded / loadLimit;
      if (isLoaded) {
        done = true;
        FlxG.switchState(targetState);
        return;
      }
    }

    currentlyLoadedBar.scale.x = FlxG.width * 2 * percent;
    currentlyLoadedBar.updateHitbox();
  }

  function initThread(func:Void->Dynamic, key:String):Void {
    currentItemLoading.text = key;
    Thread.create(() -> {
      try {func();}
      mutex.acquire();
      currentlyLoaded++;
      mutex.release();
    });
  }

  @:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
  function preloadBitmapData(key:String):Null<BitmapData> {
    key += '.png';
    try {
      if (!AssetManager.trackedGraphics.exists(key) && OpenFlAssets.exists(key, IMAGE)) {
        var bitmap:BitmapData = OpenFlAssets.getBitmapData(key, false);
        mutex.acquire();
        requestedBitmaps.set(key, bitmap);
        originalBitmapKeys.set(key, key);
        mutex.release();
        return bitmap;
      }
      if (AssetManager.trackedGraphics.get(key) == null && FlxG.bitmap._cache.exists(key))
        AssetManager.trackedGraphics.set(key, FlxG.bitmap.get(key));
      return AssetManager.trackedGraphics.get(key).bitmap;
    }
    return null;
  }

  function preloadSound(key:String):Null<Sound> {
    key += '.ogg';
    try {
      if (!AssetManager.trackedAudio.exists(key)) {
        if (OpenFlAssets.exists(key, SOUND)) {
          mutex.acquire();
          AssetManager.trackedAudio.set(key, OpenFlAssets.getSound(key, false));
          mutex.release();
        } else
          return flixel.system.FlxAssets.getSound('flixel/sounds/beep');
      }
      mutex.acquire();
      AssetManager.localAssets.push(key);
      mutex.release();
      return AssetManager.trackedAudio.get(key);
    }
    return null;
  }

  function checkLoaded():Bool {
		for (key => bitmap in requestedBitmaps)
			if (bitmap != null) {
        var tempKey:String = originalBitmapKeys.get(key).substr(14);
        AssetManager.getImage(tempKey.substr(0, tempKey.length - 4));
      }

		requestedBitmaps.clear();
		originalBitmapKeys.clear();
    return currentlyLoaded == loadLimit;
  }

}
