package;

import flixel.FlxG;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class EndState extends PlayState
{
	override public function create():Void
	{
		setLevelName("assets/data/end.png");
		setBirdOffset(200);
		
		super.create();
		
		flushWater();
		movePlayer(195, 340);
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
		/*if (FlxG.keys.anyPressed(["A", "LEFT", "D", "RIGHT"]))
			FlxG.switchState(new PlayState());*/
			
		super.update(elapsed);
	}
}