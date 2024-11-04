package states;

import flixel.group.FlxSpriteGroup;

class TitleState extends FlxState {

  var titleGrp:FlxSpriteGroup;
  var optionsGrp:FlxSpriteGroup;
  var miscGrp:FlxSpriteGroup;

  var gray:FlxSprite;
  var sonic:TitleCharacter;
  var tails:TitleCharacter;
  var mario:TitleCharacter;
  var yoshi:TitleCharacter;
  var screenStatic:FlxSprite;
  var titleText:FlxSprite;

  var newGame:FlxSprite;
  var continueGame:FlxSprite;

  var night:FlxSprite;
  var curNight:FlxSprite;

  var CacheLoadingState:LoadingState;

  var optionSound:flash.media.Sound;

  override function create():Void {
    titleGrp = new FlxSpriteGroup();
    optionsGrp = new FlxSpriteGroup();
    miscGrp = new FlxSpriteGroup();
    add(titleGrp);
    add(optionsGrp);
    add(miscGrp);

    gray = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xff202020);
    titleGrp.add(gray);

    yoshi = new TitleCharacter(5, 293, .65, .65, 'yoshi');
    mario = new TitleCharacter(0, 260, .65, .65, 'mario');
    tails = new TitleCharacter(288, 294, .65, .65, 'tails');
    sonic = new TitleCharacter(402.5, 227.75, .75, .75, 'sonic');
    titleGrp.add(yoshi);
    titleGrp.add(mario);
    titleGrp.add(tails);
    titleGrp.add(sonic);

    screenStatic = new FlxSprite();
    screenStatic.frames = AssetManager.getSparrow('multipurpose/static');
    screenStatic.animation.addByPrefix('idle', 'static');
    screenStatic.animation.play('idle');
    titleGrp.add(screenStatic);

    titleText = new FlxSprite().loadGraphic(AssetManager.getImage('main_menu/title'));
    titleText.setPosition(FlxG.width * .5 - titleText.width * .5, FlxG.width * .5 - titleText.height * 1.25);
    add(titleText);

    newGame = new FlxSprite().loadGraphic(AssetManager.getImage('main_menu/options/new_game'));
    newGame.setPosition(FlxG.width * .5 - newGame.width * .5, titleText.y + titleText.height + titleText.height * .1875);
    optionsGrp.add(newGame);

    continueGame = new FlxSprite().loadGraphic(AssetManager.getImage('main_menu/options/continue'));
    continueGame.setPosition(FlxG.width * .5 - continueGame.width * .5, newGame.y + titleText.height * .1875);
    optionsGrp.add(continueGame);

    night = new FlxSprite().loadGraphic(AssetManager.getImage('main_menu/options/continue/night'));
    night.setPosition(continueGame.x + continueGame.width * .5 + continueGame.width * .1875, continueGame.y + continueGame.height);
    miscGrp.add(night);

    curNight = new FlxSprite();
    curNight.frames = AssetManager.getSparrow('main_menu/options/continue/titleNumbers');
    for (i in 1...6) curNight.animation.addByPrefix('night_$i', 'n$i', 1);
    curNight.animation.play('night_1');
    curNight.setPosition(night.x + night.width, night.y);
    miscGrp.add(curNight);

    super.create();
    FlxG.sound.playMusic(AssetManager.getMusic('title'), .5, true);
    optionSound = AssetManager.getSound('multipurpose/camera_option_change');

    //will cache nothing for now
    CacheLoadingState = new LoadingState(new PlayState(), null, null, null);
  }

  var curSelected:Int = -1;
  var playedSound:Bool = false;
  var loadingPlayState:Bool = false;
  override function update(elapsed:Float):Void {
    super.update(elapsed);
    if (loadingPlayState)
      return;

    var overlapping:Bool = false;
    for (option in optionsGrp.members)
      if (FlxG.mouse.overlaps(option)) {
        overlapping = true;
        var oldSelected:Int = curSelected;
        curSelected = optionsGrp.members.indexOf(option);
        if (!playedSound && curSelected != oldSelected) {
          FlxG.sound.play(optionSound);
          playedSound = true;
          break;
        }
      }
    if (!overlapping) {
      curSelected = -1;
      playedSound = false;
    }

    if (FlxG.mouse.justPressed && curSelected != -1) {
      loadingPlayState = true;
      FlxG.sound.music.stop();

      //switch case curSelected (handle game save)
      //0 = new game, 1 = load latest night, 2 = load night 6 (if unlocked)
      FlxG.switchState(CacheLoadingState);
    }
  }

}