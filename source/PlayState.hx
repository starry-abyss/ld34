package;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxStringUtil;
import openfl.Assets;
import flixel.util.FlxTimer;
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
	var water: FlxTilemap;
	var background: FlxBackdrop;
	var itemGroup: FlxGroup;
	
	/*var timeLeftPressed: Float = Math.NEGATIVE_INFINITY;
	var timeRightPressed: Float = Math.NEGATIVE_INFINITY;
	var timeJumpStarted: Float = Math.NEGATIVE_INFINITY;*/
	//var timerLeftPressed: FlxTimer;
	//var timerRightPressed: FlxTimer;
	var timerJump: FlxTimer;
	var jumping: Bool = false;
	
	var jumpTween: FlxTween;
	static inline var jumpLength: Float = 0.1;
	static inline var jumpHeight: Float = 10.0;
	
	var moveDelta: Float = 0;
	
	static inline var tileSize: Int = 8;
	
	static inline var levelGrowHeight: Float = tileSize * 3;
	static inline var levelGrowLength: Float = 1.5;
	
	static inline var waterReserve: Int = 100;
	 
	override public function create():Void
	{
		super.create();
		
		player = new FlxSprite();
		player.makeGraphic(5, 5, 0xFFFFFFFF);
		
		player.acceleration.y = 1000;
		
		
		//var backgroundImage: FlxSprite = new FlxSprite();
		//backgroundImage.makeGraphic(10, 10, 0x7dc1ff);
		background = new FlxBackdrop("assets/images/background.png");
		//background.makeGraphic(10, 10, 0x7dc1ff);
		background.scrollFactor.x = 0.5;
		background.scrollFactor.y = 0.5;
		
		var levelColors: Array<Int> = [ 0x7dc1ff, 0x9e5400, 0xfff740, 0x4c2b06 ];
		level = new FlxTilemap();
		var bitMapData = Assets.getBitmapData("assets/data/level.png");
		level.loadMapFromCSV(FlxStringUtil.bitmapToCSV(bitMapData, false, 1, levelColors), "assets/images/tileset.png", tileSize, tileSize);
		
		// empty
		level.setTileProperties(0, FlxObject.NONE);
		// ground
		level.setTileProperties(1, FlxObject.ANY);
		// item placeholder
		level.setTileProperties(2, FlxObject.NONE);
		// underground
		level.setTileProperties(3, FlxObject.NONE);
		
		itemGroup = new FlxGroup();
		
		var itemPosArray: Array<FlxPoint> = level.getTileCoords(2);
		if (itemPosArray != null)
		{
			for (itemPos in itemPosArray)
			{
				itemGroup.add(new Item(itemPos.x, itemPos.y));
				trace("item: " + itemPos.x + " " + itemPos.y);
			}
		}
		
		player.x = level.width / 2;
		player.y = 0;

		
		water = new FlxTilemap();
		water.x = -waterReserve * tileSize;
		water.y = 56 + tileSize / 2;
		
		var waterCSV: String = "";
		for (y in -waterReserve...waterReserve)
		{
			for (x in -waterReserve...waterReserve)
			{
				waterCSV += (if (y == -waterReserve) 16 else 17);
				if (x < waterReserve) waterCSV += ",";
			}
			waterCSV += "\n";
		}
		water.loadMapFromCSV(waterCSV, "assets/images/tileset.png", tileSize, tileSize);
		
		trace("item: " + player.x + " " + player.y);
		
		add(background);
		add(level);
		add(player);
		add(itemGroup);
		add(water);
		
		FlxG.camera.follow(player, PLATFORMER, null, 4);
		updateCameraBounds();
		
		//timerLeftPressed = new FlxTimer();
		//timerRightPressed = new FlxTimer();
		timerJump = new FlxTimer();
		
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
		if (jumpTween.backward)
			stopJump();
	}
	
	function startJump():Void
	{
		trace("jump start");
		
		if (!jumping)
		{
			jumping = true;
			jumpTween = FlxTween.tween(player, { y: player.y - jumpHeight }, jumpLength, { onComplete: jumpTweenEnded, type:FlxTween.PINGPONG, ease:FlxEase.quadInOut } );
			//timeJumpStarted = FlxGame.;
			/*timerJump.active = true;
			timerJump.start();*/
		}
	}
	
	function stopJump():Void
	{
		trace("jump stop");
		
		if (jumping)
		{
			//timeJumpStarted = Math.NEGATIVE_INFINITY;
			//timerJump.active = false;
			jumping = false;
			jumpTween.cancel();
		}
	}
	
	function pickupItem(who: FlxObject, what: FlxObject): Bool
	{
		what.destroy();
		growLevel();
		
		return true;
	}
	
	function updateCameraBounds():Void
	{
		FlxG.camera.setScrollBounds( -waterReserve * tileSize, waterReserve * tileSize, 0, water.y + levelGrowHeight);
	}
	
	function growLevel():Void
	{
		trace("growing level");
		
		FlxTween.tween(water, { y: water.y + levelGrowHeight }, levelGrowLength, { onComplete: growLevelEnded, onUpdate: growLevelEnded, type:FlxTween.ONESHOT } );
		FlxG.camera.shake(0.01, levelGrowLength);
		
		updateCameraBounds();
	}
	
	function growLevelEnded(tween: FlxTween):Void
	{
		updateCameraBounds();
	}
	
	function inWater(who: FlxObject, what: FlxObject): Bool
	{
		restartLevel();
		return true;
	}
	
	function restartLevel():Void
	{
		FlxG.switchState(new PlayState());
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed: Float):Void
	{
		var speed: Float = 1.0;
		var jumpThreshold: Float = 0.2;
		
		//var notGoingToJump: Bool = false;
		
		if (!jumping)
		{
			moveDelta = 0;
			
			if (FlxG.keys.anyPressed(["A", "LEFT"]))
			{
				if (FlxG.keys.anyJustPressed(["A", "LEFT"]))
					timerJump.start(jumpThreshold);
					
				//notGoingToJump = ;
				//timeLeftPressed = elapsed;
				
				moveDelta -= speed;
			}
			else
			{
				//if (elapsed - timeLeftPressed <= jumpThreshold)
				if (FlxG.keys.anyJustReleased(["A", "LEFT"]))
				{
					if (timerJump.active && !timerJump.finished)
					{
						startJump();
						moveDelta -= speed;
						//timeLeftPressed = Math.NEGATIVE_INFINITY;
						timerJump.active = false;
					}
				}
			}

			if (FlxG.keys.anyPressed(["D", "RIGHT"]))
			{
				if (FlxG.keys.anyJustPressed(["D", "RIGHT"]))
					timerJump.start(jumpThreshold);
					
				//timeRightPressed = elapsed;
				//timerJump.start(jumpThreshold);
				moveDelta += speed;
			}
			else
			{
				if (FlxG.keys.anyJustReleased(["D", "RIGHT"]))
				{
					//if (elapsed - timeRightPressed <= jumpThreshold)
					if (timerJump.active && !timerJump.finished)
					{
						startJump();
						moveDelta += speed;
						//timeRightPressed = Math.NEGATIVE_INFINITY;
						timerJump.active = false;
					}
				}
			}
		}
		else
		{
			/*if (elapsed - timeJumpStarted >= jumpLength)
			{
				stopJump();
			}*/
		}
		
		
		player.x += moveDelta;
		
		FlxG.overlap(player, itemGroup, null, pickupItem);
		
		FlxG.overlap(player, water, null, inWater);

		if (FlxG.collide(player, level))
		{
			//jumping = false;
			//stopJump();
		}
		
		/*if (jumping == false)
		{
			timeJumpStarted = Math.NEGATIVE_INFINITY;dasdw
			jumpTween.;
		}*/
		//FlxG.pixelPerfect
		
		/*FlxG.camera.x = player.x;
		FlxG.camera.y = water.y;*/
		
		//FlxG.collide(FlxG.camera, water);
		
		super.update(elapsed);
	}
}