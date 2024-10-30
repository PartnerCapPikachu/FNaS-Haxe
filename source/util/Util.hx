package util;

@:publicFields
class Util {

  static function trueTextScale(number:Int = 12):Int {
    var remain:Int = number % 12;
    if (remain != 0) number += 12 - remain;
    var bounds:lime.math.Rectangle = openfl.Lib.application.window.display.bounds;
    return Math.ceil(number * Math.min(FlxG.width / bounds.width, FlxG.height / bounds.height));
  }

  static function scanDirectory(directory:String, scanfor:String = '.png'):Array<String> {
    directory = 'assets/$directory';
    var result:Array<String> = [];
    if (FileSystem.exists(directory) && FileSystem.isDirectory(directory)) {
      for (file in FileSystem.readDirectory(directory)) {
        var filePath:String = '$directory/$file';
        if (FileSystem.isDirectory(filePath))
          result = result.concat(scanDirectory(filePath.substr(7)));
        else if (filePath.endsWith(scanfor))
          result.push(filePath.substr(0, filePath.length - scanfor.length));
      }
    }
    return result;
  }

}