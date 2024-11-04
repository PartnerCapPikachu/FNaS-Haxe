package debug;

class FPSCounter extends openfl.text.TextField {

	public function new():Void {
		super();
		x = FlxG.width * .01;
		y = FlxG.height * .01;
		selectable = mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat('assets/fonts/FNaS_Font.ttf', Util.trueTextScale(60), 0xffffffff);
		autoSize = LEFT;
		multiline = true;
	}

	var times:Array<Float> = [];
	var curTime:Float = 0;
	override function __enterFrame(deltaTime:Float):Void {
		curTime += deltaTime;
		times.push(curTime);
		while (times[0] < curTime - 1000)
			times.shift();
		text = 'FPS: ' + times.length + '\nRAM: ' + formatBytes(debug.memory.Memory.getCurrentUsage());
	}

	var unitsOfMemory:Array<String> = ['', 'K', 'M', 'G', 'T', 'P'];
	function formatBytes(memoryToFormat:Float):String {
		var index:Int = 0;
		while (memoryToFormat >= 1000) {
			memoryToFormat *= .001;
			index++;
		}
		return (Math.fround(memoryToFormat * 100) * .01) + ' ' + unitsOfMemory[index] + 'B';
	}

}