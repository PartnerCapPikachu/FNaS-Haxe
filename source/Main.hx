package;

import debug.ALSoftConfig; //audio fix

import openfl.events.UncaughtErrorEvent;

class Main extends openfl.display.Sprite {

	public function new():Void {
		super();
		addChild(new flixel.FlxGame(FlxG.width, FlxG.height, states.IntroState #if (flixel < '5.0.0') 1, #end, 60, 60, true, false));
		addChild(new debug.FPSCounter());
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	var crashLocation:String = './crash/';
	function onCrash(error:UncaughtErrorEvent):Void {
		var errorPath:String = crashLocation + 'FNaSH_' + Date.now().toString().replace(' ', '_').replace(':', '\'');

		var errorMessage:String = '';
		for (i in haxe.CallStack.exceptionStack(true))
			switch (i) {
				case FilePos(s, file, line, column):
					errorMessage += '$file (line $line)\n';
				default:
					trace(i);
			}
		errorMessage += '\n\nUncaught Error: ' + error.error + '\nCRASH HANDLER ORIGINALLY WRITTEN BY sqirra-rng';

		if (!FileSystem.exists(crashLocation))
			FileSystem.createDirectory(crashLocation);

		File.saveContent(errorPath, '$errorMessage\n');
		lime.app.Application.current.window.alert(errorMessage, 'Uncaught Error!');
		Sys.exit(1);
	}

}