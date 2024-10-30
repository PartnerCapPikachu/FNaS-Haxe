package debug.memory;

/**
 * Memory class to properly get accurate memory counts for the program.
 * If you are not running on a CPP Platform, the code just will not work properly, sorry!

 * @author Leather128 (Haxe) - David Robert Nadeau (Original C Header)
 */
@:publicFields
#if cpp
@:buildXml('<include name="../../../source/debug/memory/build.xml"/>')
@:include('memory.h')
extern
#end
class Memory {
	/**
	 * Returns the peak (maximum so far) resident set size (physical
	 * memory use) measured in bytes, or zero if the value cannot be
	 * determined on this OS.

	 * (Non cpp platform)
	 * Returns 0.
	 */
	#if cpp
	@:native('getPeakRSS')
	#else
	inline
	#end
	static function getPeakUsage():Float #if !cpp return 0 #end;

	/**
 	 * Returns the current resident set size (physical memory use) measured
 	 * in bytes, or zero if the value cannot be determined on this OS.

	 * (Non cpp platform)
	 * Returns 0.
	 */
	#if cpp
	@:native('getCurrentRSS')
	#else
	inline
	#end
	static function getCurrentUsage():Float #if !cpp return 0 #end;

	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	inline static function getGPUUsage():Float {
		var total:Float = 0;
		for (key in FlxG.bitmap._cache.keys()) {
			var graphic:flixel.graphics.FlxGraphic = FlxG.bitmap.get(key);
			if (graphic == null && AssetManager.trackedGraphics.exists(key)) {
				graphic = AssetManager.trackedGraphics.get(key);
				if (graphic == null)
					continue;
			}
			total += graphic.width * graphic.height * 4;
		}
		return total;
	}

	inline static function getGarbageCollection():Float {
		return #if hl hl.Gc.stats().currentMemory #else openfl.system.System.totalMemory #end;
	}

}