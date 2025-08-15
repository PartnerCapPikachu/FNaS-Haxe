package states;

class IntroState extends FlxState
{
  var introImage:FlxSprite;
  override function create():Void
  {
    super.create();
    persistentUpdate = true;
    AssetManager.clearUsed();
    introImage = new FlxSprite().loadGraphic(AssetManager.getImage('intro'));
    add(introImage);
    AssetManager.clearUnused();
  }
}