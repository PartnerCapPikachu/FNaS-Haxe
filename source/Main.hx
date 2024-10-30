package;

//TESTING WEBHOOK

import debug.ALSoftConfig; // audio fix

import openfl.events.UncaughtErrorEvent;
import haxe.io.Path;

class Main extends openfl.display.Sprite {
	public function new():Void {
		super();
		addChild(new flixel.FlxGame(FlxG.width, FlxG.height, states.IntroState #if (flixel < '5.0.0') 1, #end, 60, 60, false, false));
		addChild(new debug.FPSCounter());

		var location:String = './crash/';
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (uError:UncaughtErrorEvent) -> {
			var errorPath:String = location + 'FNaSH_' + Date.now().toString().replace(' ', '_').replace(':', '\'');

			var errorMessage:String = '';
			for (i in haxe.CallStack.exceptionStack(true)) {
				switch (i) {
					case FilePos(s, file, line, column):
						errorMessage += '$file (line $line)\n';
					default:
						trace(i);
				}
			}
			errorMessage += '\n\nUncaught Error: ' + uError.error + '\nCRASH HANDLER ORIGINALL WRITTEN BY sqirra-rng';

			if (!FileSystem.exists(location))
				FileSystem.createDirectory(location);

			File.saveContent(errorPath, '$errorMessage\n');
			lime.app.Application.current.window.alert(errorMessage, 'Uncaught Error!');
			Sys.exit(1);
		});
	}
}
