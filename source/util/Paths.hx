package util;

import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import lime.utils.Assets;

@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
@:access(openfl.display.BitmapData)
@:publicFields
class Paths {

  static var currentTrackedAssets:Map<String, FlxGraphic> = [];
  static var currentTrackedSounds:Map<String, Sound> = [];
	static var locallyTracked:Array<String> = [];

	inline static function clearUnusedMemory():Void {
		for (key in currentTrackedAssets.keys()) {
			if (!locallyTracked.contains(key))
				trace('cleared unused memory from graphic ($key)');
				destroyGraphic(currentTrackedAssets.get(key));
				currentTrackedAssets.remove(key);
		}
		openfl.system.System.gc();
	}

	inline static function clearStoredMemory():Void {
		for (key in FlxG.bitmap._cache.keys()) {
			if (!currentTrackedAssets.exists(key))
				trace('cleared stored memory from graphic ($key)');
				destroyGraphic(FlxG.bitmap.get(key));
		}

		for (key => asset in currentTrackedSounds) {
			if (!locallyTracked.contains(key) && asset != null)
				trace('cleared stored memory from sound ($key)');
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
		}

		locallyTracked = [];
	}

	inline static function destroyGraphic(graphic:FlxGraphic):Void {
    FlxG.bitmap.remove(graphic);
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
      graphic.bitmap.__texture.dispose();
	}

  inline static function getImage(key:String):FlxGraphic {
		key += '.png';

		if (currentTrackedAssets.exists(key)) {
			locallyTracked.push(key);
			return currentTrackedAssets.get(key);
		}

		var file:String = 'assets/images/$key';
		var bitmap:openfl.display.BitmapData = null;
		if (OpenFlAssets.exists(file, IMAGE)) bitmap = OpenFlAssets.getBitmapData(file);
		if (bitmap == null) return null;

		var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;

		currentTrackedAssets.set(key, graph);
		locallyTracked.push(key);
		return graph;
  }

	inline static function getSparrow(key:String):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(getImage(key), 'assets/images/$key.xml');
	}

	static function getSound(key:String, ?isSound:Bool = false):Sound {
		var file:String = 'assets/${isSound ? 'sounds' : 'music'}/$key.ogg';
		if (!currentTrackedSounds.exists(file)) {
			if (OpenFlAssets.exists(file, SOUND)) currentTrackedSounds.set(file, OpenFlAssets.getSound(file));
			else return flixel.system.FlxAssets.getSound('flixel/sounds/beep');
		}
		locallyTracked.push(file);
		return currentTrackedSounds.get(file);
	}

}