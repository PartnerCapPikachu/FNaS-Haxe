package states;

class IntroState extends FlxState {
  override function create():Void {
    add(new FlxSprite().loadGraphic(AssetManager.getImage('intro/intro')));

    var images:Array<String> = Util.scanDirectory('images/main_menu');
    var music:Array<String> = ['assets/music/title'];
    var sounds:Array<String> = ['assets/sounds/multipurpose/camera_option_change'];
    var CacheTitleState:TitleState = new TitleState();
    var CacheLoadingState:LoadingState = new LoadingState(CacheTitleState, images, music, sounds);
		new flixel.util.FlxTimer().start(2.5, _ -> FlxG.switchState(CacheLoadingState));

		FlxG.autoPause = false;
    super.create();
  }
}
