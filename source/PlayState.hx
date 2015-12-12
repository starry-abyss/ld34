package;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import openfl.Assets;
//import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	
	var player: FlxSprite;
	var level: FlxTilemap;
	var background: FlxSprite;
	
	var timeLeftPressed: Float = Math.NEGATIVE_INFINITY;
	var timeRightPressed: Float = Math.NEGATIVE_INFINITY;
	var timeJumpStarted: Float = Math.NEGATIVE_INFINITY;
	var jumping: Bool = false;
	
	var jumpTween: FlxTween;
	var jumpLength: Float = 0.3;
	var jumpHeight: Float = 10.0;
	 
	override public function create():Void
	{
		super.create();
		
		player = new FlxSprite();
		player.makeGraphic(5, 5, 0xFFFFFFFF);
		
		//player.acceleration.y = 1000;
		
		
		//var backgroundImage: FlxSprite = new FlxSprite();
		//backgroundImage.makeGraphic(10, 10, 0x7dc1ff);
		background = new FlxBackdrop("assets/images/background.png");
		//background.makeGraphic(10, 10, 0x7dc1ff);
		background.scrollFactor.x = 0.5;
		background.scrollFactor.y = 0.5;
		
		var levelColors: Array<Int> = [ 0x7dc1ff, 0x9e5400 ];
		level = new FlxTilemap();
		var bitMapData = Assets.getBitmapData("assets/data/level.png");
		level.loadMapFromCSV(FlxStringUtil.bitmapToCSV(bitMapData, false, 1, levelColors), "assets/images/tileset.png", 8, 8);
		
		level.setTileProperties(0, FlxObject.NONE);
		level.setTileProperties(1, FlxObject.ANY);
		
		add(background);
		add(level);
		add(player);
		
		FlxG.camera.follow(player, PLATFORMER);
		
		//jumpTween = new FlxTween();
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
	
	function jumpTweenEnded(tween: FlxTween):Void
	{
		stopJump();
	}
	
	function startJump(elapsed: Float):Void
	{
		trace("jump start");
		
		jumping = true;
		jumpTween = FlxTween.tween(player, { y: player.y - jumpHeight }, jumpLength, { onComplete: jumpTweenEnded} );
		timeJumpStarted = elapsed;
	}
	
	function stopJump():Void
	{
		trace("jump stop");
		
		if (jumping)
		{
			timeJumpStarted = Math.NEGATIVE_INFINITY;
			jumping = false;
			jumpTween.cancel();
		}
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed: Float):Void
	{
		var moveDelta: Float = 0;
		var speed: Float = 2.0;
		var jumpThreshold: Float = 0.5;
		
		if (!jumping)
		{
			if (FlxG.keys.anyPressed(["A", "LEFT"]))
			{
				timeLeftPressed = elapsed;
				moveDelta -= speed;
			}
			else
			{
				if (elapsed - timeLeftPressed <= jumpThreshold)
				{
					startJump(elapsed);
					moveDelta -= speed;
					timeLeftPressed = Math.NEGATIVE_INFINITY;
				}
			}
			
			if (FlxG.keys.anyPressed(["D", "RIGHT"]))
			{
				timeRightPressed = elapsed;
				moveDelta += speed;
			}
			else
			{
				if (elapsed - timeRightPressed <= jumpThreshold)
				{
					startJump(elapsed);
					moveDelta += speed;
					timeRightPressed = Math.NEGATIVE_INFINITY;
				}
			}
		}
		else
		{
			if (elapsed - timeJumpStarted >= jumpLength)
			{
				stopJump();
			}
		}
		
		
		player.x += moveDelta;
		
		
		if (FlxG.collide(player, level))
		{
			//jumping = false;
			//stopJump();
		}
		
		/*if (jumping == false)
		{
			timeJumpStarted = Math.NEGATIVE_INFINITY;
			jumpTween.;
		}*/
		//FlxG.pixelPerfect
		
		super.update(elapsed);
	}
}