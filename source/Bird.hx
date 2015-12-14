package;
import flixel.FlxSprite;
import flixel.math.FlxVector;
import flixel.util.FlxTimer;

/**
 * ...
 * @author scorched
 */
class Bird extends FlxSprite 
{
	
	var speed: Float = 0.5;

	public function new(x: Float, y: Float) 
	{
		super(x, y);
		
		loadGraphic("assets/images/bird.png", true, 10, 10);
		animation.add("fly", [0, 1, 0, 1, 0, 0, 1, 1], 1, true);
		animation.play("fly");
	}
	
	function onTimer(timer: FlxTimer): Void
	{
		destroy();
	}
	
	override function update(elapsed: Float): Void
	{
		super.update(elapsed);
		
		x -= speed;
		if (x < -350) x = 750;
		//y += direction.y * speed;
	}
	
	/*override function destroy(): Void
	{
		super.destroy();
	}*/
	
}