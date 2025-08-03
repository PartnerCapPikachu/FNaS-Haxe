package states;

import sys.thread.FixedThreadPool;

#if cpp
@:headerCode('
  #include <iostream>
  #include <thread>
')
#end
class LoadingState extends FlxState
{
  var targetState:FlxState;

  static var pool:FixedThreadPool;

  var images:Array<String>;
  var music:Array<String>;
  var sounds:Array<String>;

  var currentlyLoaded:Int = 0;
  var amountToLoad:Int = 0;

  override public function new(targetState:FlxState, ?images:Array<String>, ?music:Array<String>, ?sounds:Array<String>):Void
  {
    this.targetState = targetState;
    this.images = images ?? [];
    this.music = music ?? [];
    this.sounds = sounds ?? [];
    amountToLoad = this.images.length + this.music.length + this.sounds.length;
    super();
  }

  override function create():Void
  {
    super.create();
    AssetManager.clearUsed();
    AssetManager.clearUnused();

    persistentUpdate = true;
    pool = new FixedThreadPool(#if cpp getCPUThreadsCount() #else 1 #end);

    var finishedCache:Bool = false;
    var oggs:Array<String> = music.concat(sounds);
    music = sounds = [];
    pool.run(function():Void
    {
      while (!finishedCache)
      {
        if (currentlyLoaded == amountToLoad)
        {
          finishedCache = true;
          pool.shutdown();
          pool = null;
          FlxG.switchState(targetState);
          break;
        }

        if (images.length != 0)
        {
          var currentImage:String = images.shift();
          AssetManager.getBitmap('$currentImage.png');
          var xmlExists:Bool = FileSystem.exists('$currentImage.xml');
          currentImage = currentImage.substr(14);
          if (xmlExists) AssetManager.getSparrow(currentImage);
          AssetManager.getImage(currentImage);
          currentlyLoaded++;
        }
        else if (oggs.length != 0)
        {
          AssetManager.getOgg(oggs.shift());
          currentlyLoaded++;
        }
      }
    });
  }

	#if cpp
	@:functionCode('return std::thread::hardware_concurrency();')
	static function getCPUThreadsCount():Int return -1;
	#end
}