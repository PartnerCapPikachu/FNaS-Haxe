package states;

import flixel.util.FlxTimer;

class IntroState extends FlxState {

  override function create():Void {
    super.create();
    add(new FlxSprite().loadGraphic(Paths.getImage('intro/intro')));
    new FlxTimer().start(2.5, (t:FlxTimer) -> FlxG.switchState(new TitleState()));
    FlxG.autoPause = false;
  }

}