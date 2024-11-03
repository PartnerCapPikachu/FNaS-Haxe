package states;

class PlayState extends FlxState {

  //planned to grab ai difficulty from a parsed json (maybe?)
  public static var night(default, set):Int = 0;
  @:noCompletion inline static function set_night(value:Int):Int {
    return night = value;
  }

}