package debug;

import debug.memory.Memory;

class FPSCounter extends openfl.text.TextField {

	var showMemoryStats:Bool = false;

	public function new():Void {
		super();
		x = FlxG.width * .01;
		y = FlxG.height * .01;
		selectable = mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat(AssetManager.getFont('FNaS_Font'), Util.trueTextScale(60), 0xffffffff);
		autoSize = LEFT;
		multiline = true;
	}

	var times:Array<Float> = [];
	var curTime:Float = 0;
	override function __enterFrame(deltaTime:Float):Void {
		curTime += deltaTime;
		times.push(curTime);
		while (times[0] < curTime - 1000) times.shift();

		text = 'FPS: ' + times.length;
		if (showMemoryStats) {
			var memoryMegas:String = formatBytes(Memory.getCurrentUsage());
			var gpuMegas:String = formatBytes(Memory.getGPUUsage());
			var garbageMemoryMegas:String = formatBytes(Memory.getGarbageCollection());
			text += '\nRAM: $memoryMegas\nGPU: $gpuMegas\nGCM: $garbageMemoryMegas';
		}

		if (FlxG.keys.justPressed.TAB) //check after the current frame has been tracked
			showMemoryStats = !showMemoryStats;
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