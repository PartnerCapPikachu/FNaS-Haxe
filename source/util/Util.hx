package util;

@:publicFields
class Util
{
  static function scanDirectory(directory:String, scanfor:String = '.png'):Array<String>
  {
    directory = 'assets/$directory';
    var result:Array<String> = [];
    if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
      for (file in FileSystem.readDirectory(directory))
      {
        var filePath:String = '$directory/$file';
        if (FileSystem.isDirectory(filePath)) result = result.concat(scanDirectory(filePath.substr(7)));
        else if (filePath.endsWith(scanfor)) result.push(filePath.substr(0, filePath.length - scanfor.length));
      }
    return result;
  }
}