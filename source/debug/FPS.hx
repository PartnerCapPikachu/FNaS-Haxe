package debug;

class FPS extends openfl.text.TextField
{
	public function new(x:Float = 5, y:Float = 5, color:Int = 0xffffffff):Void
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

	var unitsOfMemory:Array<String> = ['b', 'kb', 'mb', 'gb', 'tb', 'pb'];
	var memoryMegas(get, never):String;
	inline function get_memoryMegas():String
	{
		var memory:Float = debug.memory.Memory.getCurrentUsage();

		var i:Int = 0;
		while (i < unitsOfMemory.length && memory >= 1000)
		{
			i++;
			memory *= .001;
		}

		memory = Math.fround(memory * 100) * .01;
		return memory + unitsOfMemory[i];
	}

	var currentFPS(default, null):Int = 0;
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

		text = 'FPS: $currentFPS\nRAM: $memoryMegas';
	}
}