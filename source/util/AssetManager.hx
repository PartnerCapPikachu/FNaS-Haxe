package util;

import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import flash.media.Sound;

@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
@:access(openfl.display.BitmapData)
@:publicFields
class AssetManager {

	static var trackedGraphics:Map<String, FlxGraphic> = [];
	static var trackedAudio:Map<String, Sound> = [];
  static var localAssets:Array<String> = [];

	static function clearUnused():Void {
		for (key in trackedGraphics.keys()) {
			if (!localAssets.contains(key) && FlxG.bitmap._cache.exists(key)) {
				destroyGraphic(trackedGraphics.get(key));
				trackedGraphics.remove(key);
			}
		}
		openfl.system.System.gc();
	}

	static function clearUsed():Void {
		for (key in FlxG.bitmap._cache.keys())
			if (!trackedGraphics.exists(key))
				destroyGraphic(FlxG.bitmap.get(key));

		for (key in trackedAudio.keys()) {
			if (!localAssets.contains(key)) {
				Assets.cache.clear(key);
				trackedAudio.get(key).close();
				trackedAudio.remove(key);
			}
		}

		localAssets = [];
	}

	static function destroyGraphic(graphic:FlxGraphic):Void {
		graphic.destroyOnNoUse = true;
		graphic.persist = false;
		graphic.decrementUseCount();
	}

  static function getImage(key:String):FlxGraphic {
    key += '.png';

    if (trackedGraphics.exists(key))
			return trackedGraphics.get(key);

		var file:String = 'assets/images/$key';
		var bitmap:openfl.display.BitmapData = null;
		if (OpenFlAssets.exists(file, IMAGE))
			bitmap = OpenFlAssets.getBitmapData(file);
		if (bitmap == null)
			return null;

		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		trackedGraphics.set(key, graphic);
    localAssets.push(key);
    return graphic;
  }

	static function getSparrow(key:String):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(getImage(key), 'assets/images/$key.xml');
	}

	static function getSound(key:String):Sound {
		return getOgg('sounds/$key');
	}

	static function getMusic(key:String):Sound {
		return getOgg('music/$key');
	}

	static function getOgg(key:String):Sound {
		var file:String = 'assets/$key.ogg';

		if (!trackedAudio.exists(file)) {
			if (OpenFlAssets.exists(file, SOUND)) {
				localAssets.push(file);
				trackedAudio.set(file, OpenFlAssets.getSound(file));
			}
			else
				return flixel.system.FlxAssets.getSound('flixel/sounds/beep');
		}

		if (!localAssets.contains(key))
			localAssets.push(key);
		return trackedAudio.get(file);
	}

	static function getFont(key:String):String {
		return 'assets/fonts/$key.ttf';
	}

}