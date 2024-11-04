package util;

import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;

import openfl.display.BitmapData;
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
		for (key => graphic in trackedGraphics)
			if (!localAssets.contains(key)) {
				trackedGraphics.remove(key);
				destroyGraphic(graphic);
			}
		openfl.system.System.gc();
	}

	static function clearUsed():Void {
		for (key => graphic in FlxG.bitmap._cache)
			if (!trackedGraphics.exists(key))
				destroyGraphic(graphic);

		for (key => ogg in trackedAudio)
			if (!localAssets.contains(key)) {
				trackedAudio.remove(key);
				Assets.cache.clear(key);
			}

		localAssets = [];
	}

	inline static function destroyGraphic(graphic:FlxGraphic):Void {
		graphic.destroyOnNoUse = true;
		graphic.persist = false;
		graphic.decrementUseCount();
	}

  inline static function getImage(key:String):FlxGraphic {
    key += '.png';
    return trackedGraphics.exists(key) ? trackedGraphics.get(key) : getGraphic(key);
  }

	inline static function getSparrow(key:String):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(getImage(key), 'assets/images/$key.xml');
	}

	static function getGraphic(key:String):FlxGraphic {
		var file:String = 'assets/images/$key';

		var bitmap:BitmapData;
		OpenFlAssets.exists(file, IMAGE) ? bitmap = OpenFlAssets.getBitmapData(file) : return null;
		if (bitmap.image != null)
			bitmap.disposeImage();

		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		trackedGraphics.set(key, graphic);
    localAssets.push(key);
    return graphic;
	}

	inline static function getSound(key:String):Sound {
		return getOgg('sounds/$key');
	}

	inline static function getMusic(key:String):Sound {
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

}