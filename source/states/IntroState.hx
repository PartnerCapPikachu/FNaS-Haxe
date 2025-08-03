package states;

class IntroState extends FlxState
{
  var introImage:FlxSprite;

  override function create():Void
  {
    super.create();
    persistentUpdate = true;

    introImage = new FlxSprite().loadGraphic(AssetManager.getImage('intro'));
    add(introImage);
  }
}