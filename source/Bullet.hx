package;
import flixel.FlxSprite;
import flixel.math.FlxVector;
import flixel.util.FlxTimer;

/**
 * ...
 * @author scorched
 */
class Bullet extends FlxSprite 
{
	
	var direction: FlxVector;
	var speed: Float = 0.3;
	var lifeTimer: FlxTimer;

	public function new(x: Float, y: Float, direction: FlxVector) 
	{
		super(x, y);
		
		lifeTimer = new FlxTimer();
		lifeTimer.start(5.0, onTimer);
		
		this.direction = direction.normalize();
		loadGraphic("assets/images/bullet.png", false, 32, 32);
	}
	
	function onTimer(timer: FlxTimer): Void
	{
		destroy();
	}
	
	override function update(elapsed: Float): Void
	{
		super.update(elapsed);
		
		x += direction.x * speed;
		y += direction.y * speed;
	}
	
	/*override function destroy(): Void
	{
		super.destroy();
	}*/
	
}