package objects;

class TitleCharacter extends FlxSprite {

  override public function new(x:Float = 0, y:Float = 0, sx:Float = 1, sy:Float = 1, character:String):Void {
    super(x, y);

    frames = AssetManager.getSparrow('main_menu/characters/$character');
    animation.addByPrefix('normal', character + 'Normal', 1);
    animation.addByPrefix('scary', character + 'Scary', 24, false);
    animation.play('normal');
    animation.finishCallback = (name:String) -> {
      if (name == 'scary')
        animation.play('normal');
    }

    scale.set(sx, sy);
    updateHitbox();
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if (FlxG.random.bool(.5) && animation.name == 'normal')
      animation.play('scary', true);
  }

}