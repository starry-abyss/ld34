package;

import flixel.FlxG;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class MenuState extends PlayState
{
	override public function create():Void
	{
		setLevelName("assets/data/info.png");
		
		super.create();
		
		flushWater();
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed: Float):Void
	{	
		if (FlxG.keys.anyPressed(["A", "LEFT", "D", "RIGHT"]))
			FlxG.switchState(new PlayState());
			
		super.update(elapsed);
	}
}