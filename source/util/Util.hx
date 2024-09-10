package util;

@:publicFields
class Util {

  inline static function trueTextScale(?number:Int = 12):Int {
    var remain:Int = number % 12;
    if (remain != 0) number += 12 - remain;

    var bounds = openfl.Lib.application.window.display.bounds;
    return Math.ceil(number * Math.min(FlxG.width / bounds.width, FlxG.height / bounds.height));
  }

}