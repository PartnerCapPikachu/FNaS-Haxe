package states;

import lime.app.Future;

#if cpp
@:headerCode('
  #include <iostream>
  #include <thread>
')
#end
class LoadingState extends FlxState
{
  var targetState:FlxState;

  var images:Array<String>;
  var music:Array<String>;
  var sounds:Array<String>;

  override public function new(targetState:FlxState, ?images:Array<String>, ?music:Array<String>, ?sounds:Array<String>):Void
  {
    this.targetState = targetState;
    this.images = images ?? [];
    this.music = music ?? [];
    this.sounds = sounds ?? [];
    super();
  }

  override function create():Void
  {
    super.create();
    persistentUpdate = true;
    AssetManager.clearUsed();
    new Future<Void>(cacheImages, true).then(Void -> new Future<Void>(cacheOggs, true)).onComplete(Void -> FlxG.switchState(targetState));
    AssetManager.clearUnused();
  }

  function cacheImages():Void
  {
    while (images.length != 0)
    {
      var currentImage:String = images.shift();
      AssetManager.getBitmap('$currentImage.png');
      var xmlExists:Bool = FileSystem.exists('$currentImage.xml');
      currentImage = currentImage.substr(14);
      if (xmlExists) AssetManager.getSparrow(currentImage);
      AssetManager.getImage(currentImage);
    }
  }

  function cacheOggs():Void
  {
    var oggs:Array<String> = music.concat(sounds);
    while (oggs.length != 0)
      AssetManager.getOgg(oggs.shift());
  }
}