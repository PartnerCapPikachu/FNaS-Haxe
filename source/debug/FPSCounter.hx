package debug;

class FPSCounter extends openfl.text.TextField
{
	var currentFPS(default, null):Int = 0;

	var memoryMegas(get, never):Float;
	inline function get_memoryMegas():Float
	{
		return debug.memory.Memory.getCurrentUsage();
	}

	public function new(x:Float = 10, y:Float = 10, color:Int = 0xffffffff):Void
	{
		super();
		this.x = x;
		this.y = y;
		selectable = mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat('_sans', 12, color);
		autoSize = LEFT;
		multiline = true;
    #if flash
		addEventListener(Event.ENTER_FRAME, __enterFrame);
		#end
	}

	var ticks:Int = 0;
	var timer:Float = 0;
	#if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		ticks++;
		timer += FlxG.elapsed;
		if (timer >= 1)
		{
			currentFPS = ticks;
			ticks = 0;
			timer -= 1;
		}
		text = 'FPS: $currentFPS\nRAM: ${formatBytes(memoryMegas)}';
	}

	var unitsOfMemory:Array<String> = [' b', ' kb', ' mb', ' gb', ' tb', ' pb'];
	function formatBytes(memory:Float):String
	{
		var index:Int = 0;
		while (memory >= 1000)
		{
			memory *= .001;
			index++;
		}
		return (Math.fround(memory * 100) * .01) + unitsOfMemory[index];
	}
}