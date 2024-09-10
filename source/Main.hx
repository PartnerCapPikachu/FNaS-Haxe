package;

class Main extends openfl.display.Sprite {

	public function new():Void {
		cache();
		super();
		addChild(new flixel.FlxGame(FlxG.width, FlxG.height, states.IntroState #if (flixel < '5.0.0') 1, #end, 60, 60, false, false));
		addChild(new debug.FPSCounter());
	}

	// Intended to cache IntroState and TitleState, minimizing lag.
	// Caching for PlayState will be its own class.
	inline function cache():Void {
		// IntroState
		Paths.getImage('intro/intro');

		// TitleState
		Paths.getSparrow('main_menu/characters/sonic');
		Paths.getSparrow('main_menu/characters/tail');
		Paths.getSparrow('main_menu/characters/mario');
		Paths.getSparrow('main_menu/characters/yoshi');
		Paths.getSparrow('multipurpose/static');

		Paths.getImage('main_menu/title');
		Paths.getImage('main_menu/options/new_game');
		Paths.getImage('main_menu/options/continue');
		Paths.getImage('main_menu/options/continue/night');
		Paths.getSparrow('main_menu/options/continue/titleNumbers');

		Paths.getSound('title');
		Paths.getSound('cam_option-change', true);
		//

		// LoadingState
		Paths.getImage('loading/12am');
		Paths.getImage('loading/night');
		Paths.getSparrow('loading/loadingNightNumbers');
		//
	}

}