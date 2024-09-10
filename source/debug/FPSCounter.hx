package debug;

using cpp.vm.Gc;

class FPSCounter extends openfl.text.TextField {

	@:noCompletion private var times:Array<Float> = [];
	@:noCompletion private var curTime:Float = 0;

	public function new():Void {
		super();
		x = FlxG.width * .01;
		y = FlxG.height * .01;
		selectable = mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat('assets/fonts/FNaS_Font.ttf', Util.trueTextScale(60), 0xffffffff);
		autoSize = LEFT;
		multiline = true;
	}

	private override function __enterFrame(deltaTime:Float):Void {
		curTime += deltaTime;
		times.push(curTime);
		while (times[0] < curTime - 1000) times.shift();
		text = 'FPS: ${times.length}\nGCM: ${flixel.util.FlxStringUtil.formatBytes(Gc.MEM_INFO_USAGE.memInfo64())}';
	}

}