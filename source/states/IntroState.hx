package states;

class IntroState extends FlxState {

  var CacheLoadingState:LoadingState;

  override function create():Void {
    var images:Array<String> = Util.scanDirectory('images/main_menu');
    var music:Array<String> = ['assets/music/title'];
    var sounds:Array<String> = ['assets/sounds/multipurpose/camera_option_change'];
    CacheLoadingState = new LoadingState(new TitleState(), images, music, sounds);

    add(new FlxSprite().loadGraphic(AssetManager.getImage('intro/intro')));

		FlxG.autoPause = false;
    super.create();
    new flixel.util.FlxTimer().start(2.5, _ -> FlxG.switchState(CacheLoadingState));
  }

}