package;

import main.*;

#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end
class Main extends openfl.display.Sprite
{
	public static function main():Void
	{
		openfl.Lib.current.addChild(new Main());
	}

  public function new():Void
  {
    super();

		#if android
		Sys.setCwd(Path.addTrailingSlash(android.content.Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

    #if (linux || mac)
    openfl.Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile('icon.png'));
    #end

    Native.fixScaling();

    addChild(new FlxGame(500, 500, Init, 60, 60, false, true));
    addChild(new debug.FPSCounter());
  }
}