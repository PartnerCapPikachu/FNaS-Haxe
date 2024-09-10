package states;

class LoadingState extends FlxState {

  var twelveAM:FlxSprite;
  var night:FlxSprite;
  var curNight:FlxSprite;

  override function create():Void {
    super.create();

    twelveAM = new FlxSprite().loadGraphic(Paths.getImage('loading/12am'));
    twelveAM.screenCenter();
    twelveAM.y -= twelveAM.height * 1.125;
    add(twelveAM);

    night = new FlxSprite().loadGraphic(Paths.getImage('loading/night'));
    night.screenCenter();
    night.x -= 28;
    add(night);

    curNight = new FlxSprite();
    curNight.frames = Paths.getSparrow('loading/loadingNightNumbers');
    for (i in 1...7) curNight.animation.addByPrefix('night_$i', 'n$i', 1);
    curNight.animation.play('night_1');
    curNight.setPosition(night.x + night.width, night.y);
    add(curNight);
  }

}