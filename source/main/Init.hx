package main;

class Init extends FlxState
{
  override function create():Void
  {
    FlxG.autoPause = false;
    FlxG.fixedTimestep = false;
    FlxG.game.focusLostFramerate = 60;
    FlxG.keys.preventDefaultKeys = [TAB];
		FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();

		FlxG.signals.gameResized.add(function(width:Int, height:Int):Void
		{
			if (FlxG.cameras != null)
				for (cam in FlxG.cameras.list)
					if (cam != null)
						resetSpriteCache(cam.flashSprite);

			if (FlxG.game != null)
				resetSpriteCache(FlxG.game);
		});

		FlxG.switchState(new states.IntroState());
  }

	@:access(openfl.display.Sprite)
	static function resetSpriteCache(sprite:openfl.display.Sprite):Void
	{
		sprite.__cacheBitmap = null;
		sprite.__cacheBitmapData = null;
	}
}