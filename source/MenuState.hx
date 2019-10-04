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
		setBirdOffset(200);
		
		super.create();
		
		flushWater();
	}
	
	override function startMusic():Void
	{
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed: Float):Void
	{	
		if (FlxG.keys.anyPressed(["LEFT", "A", "C", "Q", "RIGHT", "D", "V", "E"]))
			FlxG.switchState(new PlayState());
			
		super.update(elapsed);
	}
}