package util;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import openfl.display.BitmapData;
import openfl.media.Sound;

@:publicFields
class AssetManager
{
	static var localAssets:Array<String> = [];
	static inline function markUsed(key:String):Void
	{
		if (!localAssets.contains(key))
			localAssets.push(key);
	}

	static var excludeFromDump:Array<String> = [];
	static inline function markExcluded(key:String):Void
	{
		if (!excludeFromDump.contains(key))
			excludeFromDump.push(key);
	}

	static function destroyGraphic(key:String, graphic:FlxGraphic):Void
	{
		graphic.persist = false;
		graphic.destroyOnNoUse = true;
		graphic.decrementUseCount();
	}

	static function clearUnused():Void
	{
		for (key in trackedGraphics.keys())
		{
			if (localAssets.contains(key) || excludeFromDump.contains(key))
				continue;

			var graphic:FlxGraphic = trackedGraphics[key];
			if (graphic != null)
			{
				trackedGraphics.remove(key);
				destroyGraphic(key, graphic);
			}
		}

		openfl.system.System.gc();
	}

	static function clearUsed():Void
	{
		for (key in trackedAudio.keys())
		{
			if (excludeFromDump.contains(key))
				continue;

			var sound:Sound = trackedAudio[key];
			trackedAudio.remove(key);
			openfl.Assets.cache.removeSound(key);
			if (sound != null) try sound.close() catch (error:Dynamic) {}
		}

		localAssets = [];
	}

	static function getSparrow(key:String, exclude:Bool = false):FlxAtlasFrames
	{
		var graphic:FlxGraphic = getImage(key, exclude);
		if (graphic == null)
			return null;

		var xmlPath:String = 'assets/images/$key.xml';
		if (!FileSystem.exists(xmlPath))
			return null;

		return FlxAtlasFrames.fromSparrow(graphic, xmlPath);
	}

	static var trackedGraphics:Map<String, FlxGraphic> = [];
	static function getImage(key:String, exclude:Bool = false):FlxGraphic
	{
		var path:String = 'assets/images/$key.png';
		if (exclude) markExcluded(path);

		var graphic:FlxGraphic = trackedGraphics[path];
		if (graphic != null)
		{
			markUsed(path);
			return graphic;
		}

		if (!FileSystem.exists(path))
			return null;

		graphic = FlxGraphic.fromBitmapData(getBitmap(path), false, path);
		trackedGraphics.set(path, graphic);
		markUsed(path);
		return graphic;
	}

	static var trackedBitmaps:Map<String, BitmapData> = [];
	static function getBitmap(path:String):BitmapData
	{
		var bitmap:BitmapData = trackedBitmaps[path];
		if (bitmap != null)
			return bitmap;

		bitmap = BitmapData.fromFile(path);
		trackedBitmaps.set(path, bitmap);
		return bitmap;
	}

	static function getSound(key:String, exclude:Bool = false):Sound
	{
		return getOgg('sounds/$key', exclude);
	}

	static function getMusic(key:String, exclude:Bool = false):Sound
	{
		return getOgg('music/$key', exclude);
	}

	static var trackedAudio:Map<String, Sound> = [];
	static function getOgg(key:String, exclude:Bool = false):Sound
	{
		var path:String = 'assets/$key.ogg';
		if (exclude) markExcluded(path);

		var sound:Sound = trackedAudio[path];
		if (sound != null)
			return sound;

		if (!FileSystem.exists(path))
			return flixel.system.FlxAssets.getSound('flixel/sounds/beep');

		sound = Sound.fromFile(path);
		trackedAudio.set(path, sound);
		return sound;
	}
}