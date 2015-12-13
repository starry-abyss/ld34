package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.math.FlxVector;
import flixel.system.FlxSound;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;

/**
 * ...
 * @author scorched
 */
class Boss extends FlxSprite
{

	var bullets: FlxGroup;
	var attackTimer: FlxTimer;
	var soundBossattack1: FlxSound;
	var soundBossattack2: FlxSound;
	
	var soundRandomizer: FlxRandom;
	
	public function new(x: Float, y: Float, bullets: FlxGroup) 
	{
		super(x, y);
		
		soundBossattack1 = FlxG.sound.load("assets/sounds/bossattack1.wav");
		soundBossattack2 = FlxG.sound.load("assets/sounds/bossattack2.wav");
		
		soundRandomizer = new FlxRandom();
		
		attackTimer = new FlxTimer();
		this.bullets = bullets;
		loadGraphic("assets/images/boss.png", false, 24, 32);
	}
	
	function attack(): Void
	{
		bullets.add(new Bullet(x + (if (flipX) 15 else 3), y + 10, FlxVector.get(if (flipX) 1 else -1, 0)));
		
		if (soundRandomizer.int(0, 1) == 0)
		{
			soundBossattack1.play();
		}
		else
		{
			soundBossattack2.play();
		}
	}
	
	public function setFacingLeft(left: Bool)
	{
		flipX = !left;
	}
	
	public function setAttackActive(active: Bool)
	{
		if (active)
		{
			if (!attackTimer.active)
			{
				attack();
				attackTimer.start(3.0, onTimer, 0);
			}
		}
		else
		{
			attackTimer.cancel();
		}
	}
	
	function onTimer(timer: FlxTimer): Void
	{
		attack();
	}
	
	override function destroy(): Void
	{
		attackTimer.cancel();
		
		FlxDestroyUtil.destroy(soundBossattack1);
		FlxDestroyUtil.destroy(soundBossattack2);
		
		super.destroy();
	}
	
}