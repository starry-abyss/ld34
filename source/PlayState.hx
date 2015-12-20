package;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxDestroyUtil;
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
	
	var levelName: String = "assets/data/level.png";
	
	function setLevelName(levelName: String):Void
	{
		this.levelName = levelName;
	}
	
	function setBirdOffset(birdOffset: Float):Void
	{
		this.birdOffset = birdOffset;
	}
	
	var birdOffset: Float = 0;
	
	function flushWater():Void
	{
		water.y = tileSize * 58;
		updateCameraBounds();
	}
	
	function movePlayer(x: Float, y: Float):Void
	{
		player.x = x;
		player.y = y;
	}
	
	function startMusic():Void
	{
		music = FlxG.sound.load("assets/music/track1.mp3");
		//FlxG.sound.playMusic(music, 1, true);
		music.looped = true;
		music.play();
	}
	
	var music: FlxSound;

	var player: FlxSprite;
	var revivor: FlxSprite;
	var level: FlxTilemap;
	var water: FlxTilemap;
	var background: FlxBackdrop;
	var itemGroup: FlxGroup;
	var bossGroup: FlxGroup;
	var bulletGroup: FlxGroup;
	
	var disableControls: Bool = false;
	
	/*var timeLeftPressed: Float = Math.NEGATIVE_INFINITY;
	var timeRightPressed: Float = Math.NEGATIVE_INFINITY;
	var timeJumpStarted: Float = Math.NEGATIVE_INFINITY;*/
	//var timerLeftPressed: FlxTimer;
	//var timerRightPressed: FlxTimer;
	var timerJump: FlxTimer;
	var timerEndgame: FlxTimer;
	
	var jumping: Bool = false;
	
	var jumpTween: FlxTween = null;
	var waterTween: FlxTween = null;
	static inline var jumpLength: Float = 0.1;
	static inline var jumpHeight: Float = 10.0;
	
	var moveDelta: Float = 0;
	
	static inline var tileSize: Int = 8;
	
	static inline var levelGrowHeight: Float = tileSize * 3;
	static inline var levelGrowLength: Float = 1.5;
	
	static inline var waterReserve: Int = 100;
	
	var soundItemtake: FlxSound;
	var soundBossdeath: FlxSound;
	var soundRevive: FlxSound;
	
	var weHaveSavegame: Bool = false;
	var birdGroup: FlxGroup;
	var birdRandomizer: FlxRandom;
	 
	override public function create():Void
	{
		super.create();
		
		startMusic();
		
		Reg.save.bind("save1");
		
		player = new FlxSprite();
		player.loadGraphic("assets/images/player.png", true, 5, 5);
		player.animation.add("idle", [0], 30, true, false, false);
		player.animation.add("leftjump", [3], 30, true, true, false);
		player.animation.add("rightjump", [3], 30, true, false, false);
		player.animation.add("left", [1, 2], 4, true, true, false);
		player.animation.add("right", [1, 2], 4, true, false, false);
		
		player.acceleration.y = 1000;
		
		soundItemtake = FlxG.sound.load("assets/sounds/itemtake.wav");
		soundBossdeath = FlxG.sound.load("assets/sounds/bossdeath.wav");
		soundRevive = FlxG.sound.load("assets/sounds/revive.wav");
		
		revivor = new FlxSprite();
		revivor.loadGraphic("assets/images/revive.png", true, 40, 40);
		revivor.animation.finishCallback = reviveAnimationEnded;
		revivor.animation.add("revive", [0, 1, 2, 3], 3, false, false, false);
		
		//var backgroundImage: FlxSprite = new FlxSprite();
		//backgroundImage.makeGraphic(10, 10, 0x7dc1ff);
		background = new FlxBackdrop("assets/images/background.png");
		//background.makeGraphic(10, 10, 0x7dc1ff);
		background.scrollFactor.x = 0.5;
		background.scrollFactor.y = 0.5;
		
		var levelColors: Array<Int> = [ 0x7dc1ff, 0x9e5400, 0xfff740, 0x4c2b06, 0xfd0003, 0x0e0904, 0x8c8c8c, 0xefffe7, 0x196800, 0x8aff50, 0xe67a00, 0x7c5400, 0x9e7a00, 0xc52eca ];
		level = new FlxTilemap();
		var bitMapData = Assets.getBitmapData(levelName);
		level.loadMapFromCSV(FlxStringUtil.bitmapToCSV(bitMapData, false, 1, levelColors), "assets/images/tileset.png", tileSize, tileSize);

		
		// empty
		level.setTileProperties(0, FlxObject.NONE);
		// ground
		level.setTileProperties(1, FlxObject.ANY);
		// item placeholder
		level.setTileProperties(2, FlxObject.NONE);
		// underground
		level.setTileProperties(3, FlxObject.NONE);
		// item placeholder over ground
		level.setTileProperties(4, FlxObject.NONE);
		// stalagmite (ambient)
		level.setTileProperties(5, FlxObject.NONE);
		// stalactite (ambient)
		level.setTileProperties(6, FlxObject.NONE);
		// skeleton (ambient)
		level.setTileProperties(7, FlxObject.NONE);
		// coral (ambient)
		level.setTileProperties(8, FlxObject.NONE);
		// skull (ambient)
		level.setTileProperties(9, FlxObject.NONE);
		// ground (upper)
		level.setTileProperties(10, FlxObject.ANY);
		// ground (lower)
		level.setTileProperties(11, FlxObject.ANY);
		// ground (variant)
		level.setTileProperties(12, FlxObject.ANY);
		// boss placeholder
		level.setTileProperties(13, FlxObject.NONE);
		
		itemGroup = new FlxGroup();
		
		var itemPosArray: Array<FlxPoint> = new Array<FlxPoint>();
		var itemPosArray1: Array<FlxPoint> = level.getTileCoords(2, true);
		var itemPosArray2: Array<FlxPoint> = level.getTileCoords(4, true);
		if (itemPosArray1 != null) itemPosArray = itemPosArray.concat(itemPosArray1);
		if (itemPosArray2 != null) itemPosArray = itemPosArray.concat(itemPosArray2);
		//level.getTileCoords(2);
		//if (itemPosArray != null)
		//{
			for (itemPos in itemPosArray)
			{
				itemGroup.add(new Item(itemPos.x - tileSize / 2, itemPos.y - tileSize / 2));
				trace("item: " + itemPos.x + " " + itemPos.y);
			}
		//}
		
		player.x = level.width / 2;
		player.y = 0;

		
		water = new FlxTilemap();
		water.x = -waterReserve * tileSize;
		water.y = 56 + tileSize / 2;
		
		//water.y = tileSize * 58;
		
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
		
		/*var specialTiles: Array<FlxTileSpecial> = new Array<FlxTileSpecial>();
		var newTile: FlxTileSpecial = new FlxTileSpecial(16, false, false, 0);
		//newTile.
		newTile.addAnimation([16, 17], 1);
		specialTiles.push(newTile);
		water.setSpecialTiles(specialTiles);*/
		
		trace("item: " + player.x + " " + player.y);
		
		bulletGroup = new FlxGroup();
		
		bossGroup = new FlxGroup();
		//bossGroup.add(new Boss(350, 35, bulletGroup));
		
				
		var bossPosArray: Array<FlxPoint> = new Array<FlxPoint>();
		var bossPosArray1: Array<FlxPoint> = level.getTileCoords(13, true);
		if (bossPosArray1 != null) bossPosArray = bossPosArray.concat(bossPosArray1);
		
		for (bossPos in bossPosArray)
		{
			bossGroup.add(new Boss(bossPos.x - 10, bossPos.y - 20, bulletGroup));
			trace("boss: " + bossPos.x + " " + bossPos.y);
		}
		
		
		birdRandomizer = new FlxRandom();
		birdGroup = new FlxGroup();
		for (i in 0...15)
		{
			birdGroup.add(new Bird(birdRandomizer.float(0, 400), birdOffset + birdRandomizer.float(-100, -70)));
		}
		
		
		add(background);
		add(birdGroup);
		add(level);
		add(player);
		add(itemGroup);
		add(bossGroup);
		add(bulletGroup);
		add(water);
		
		//FlxG.camera.zoom = 2;
		
		//FlxG.camera.bgColor = 0x7dc1ff;
		FlxG.scaleMode = new RatioScaleMode();
		FlxG.camera.follow(player, PLATFORMER, null, 4);
		updateCameraBounds();
		
		//timerLeftPressed = new FlxTimer();
		//timerRightPressed = new FlxTimer();
		timerJump = new FlxTimer();
		timerEndgame = new FlxTimer();
		
		FlxG.worldBounds.set(water.x, level.y - 100, water.width, level.height + 100);
		
		//jumpTween = new FlxTween();
		//saveGame();
		
		FlxG.watch.add(water, "y");
		FlxG.watch.add(player, "x");
		FlxG.watch.add(player, "y");
		FlxG.debugger.drawDebug = true;
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		FlxDestroyUtil.destroy(soundItemtake);
		FlxDestroyUtil.destroy(soundBossdeath);
		FlxDestroyUtil.destroy(soundRevive);
		
		super.destroy();
	}
	
	function jumpTweenEnded(tween: FlxTween):Void
	{
		if (jumpTween.backward)
			stopJump();
	}
	
	function startJump():Void
	{
		//trace("jump start");
		
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
		//trace("jump stop");
		
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
		itemGroup.remove(what, true);
		
		// save the item pos as player pos to fix the revive animation position
		var xBackup = player.x;
		var yBackup = player.y;
		
		player.x = what.x;
		player.y = what.y;
		
		what.destroy();
		
		soundItemtake.play();
		
		// save the future after-tween state and then revert
		water.y += levelGrowHeight;
		saveGame();
		water.y -= levelGrowHeight;
		
		player.x = xBackup;
		player.y = yBackup;
		
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
		
		disableControls = true;
		
		waterTween = FlxTween.tween(water, { y: water.y + levelGrowHeight }, levelGrowLength, { onComplete: growLevelEnded, onUpdate: growLevelUpdate, type:FlxTween.ONESHOT } );
		FlxG.camera.shake(0.01, levelGrowLength, null, true, X);
		
		updateCameraBounds();
	}
	
	function growLevelUpdate(tween: FlxTween):Void
	{
		updateCameraBounds();
	}
	
	function growLevelEnded(tween: FlxTween):Void
	{
		disableControls = false;
		updateCameraBounds();
	}
	
	function dieOnOverlap(who: FlxObject, what: FlxObject): Bool
	{
		restartLevel();
		return true;
	}
	
	function reviveAnimationEnded(animationName: String):Void
	{
		remove(revivor);
		
		disableControls = false;
	}
	
	function restartLevel():Void
	{
		if (!weHaveSavegame)
		{
			FlxG.switchState(new MenuState());
		}
		else
		{
			disableControls = true;	
			jumping = false;
					
			//soundBossattack1.stop();
			//soundBossattack2.stop();
			soundBossdeath.stop();
			soundItemtake.stop();
			
			for (bullet in bulletGroup)
			{
				bullet.destroy();
			}
			bulletGroup.clear();

			moveDelta = 0.0;
			if (jumpTween != null) jumpTween.cancel();
			if (waterTween != null) waterTween.cancel();
			FlxG.camera.stopFX();
			
			soundRevive.play();

			add(revivor);
			
			revivor.animation.play("revive");
			
			loadGame();
			
			revivor.x = player.x - revivor.frameWidth / 2 + 2;
			revivor.y = player.y - revivor.frameHeight / 2 + 6;
		}
	}
	
	function endGame(timer: FlxTimer):Void
	{
		FlxG.switchState(new EndState());
	}
	
	function saveGame():Void
	{
		trace("save game");
		
		Reg.save.data.playerX = player.x;
		Reg.save.data.playerY = player.y;
		Reg.save.data.waterY = water.y;
		
		var itemPosArray: Array<FlxPoint> = new Array<FlxPoint>();
		for (item in itemGroup)
		{
			var sprite: FlxSprite = cast(item, FlxSprite);
			itemPosArray.push(new FlxPoint(sprite.x, sprite.y));
		}
		Reg.save.data.itemPosArray = itemPosArray;
		
		
		var bossPosArray: Array<FlxPoint> = new Array<FlxPoint>();
		for (boss in bossGroup)
		{
			var sprite: FlxSprite = cast(boss, FlxSprite);
			bossPosArray.push(new FlxPoint(sprite.x, sprite.y));
		}
		Reg.save.data.bossPosArray = bossPosArray;
		
		
		Reg.save.flush();
		
		weHaveSavegame = true;
	}
	
	function loadGame():Void
	{
		trace("load game");
		
		for (item in itemGroup)
		{
			item.destroy();
		}
		itemGroup.clear();
		
		var itemPosArray: Array<FlxPoint> = Reg.save.data.itemPosArray;
		for (itemPos in itemPosArray)
		{
			itemGroup.add(new Item(itemPos.x, itemPos.y));
		}
		
		
		water.y = Reg.save.data.waterY;
		updateCameraBounds();
		
		
		for (boss in bossGroup)
		{
			boss.destroy();
		}
		bossGroup.clear();

		var bossPosArray: Array<FlxPoint> = Reg.save.data.bossPosArray;
		for (bossPos in bossPosArray)
		{
			if (!bossGoingToDie(bossPos.y, water.y))
				bossGroup.add(new Boss(bossPos.x, bossPos.y, bulletGroup));
		}
		
		movePlayer(Reg.save.data.playerX, Reg.save.data.playerY);
	}
	
	public function bossGoingToDie(bossY: Float, waterY: Float): Bool
	{
		return bossY < waterY - Boss.bossHeight;
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed: Float):Void
	{
		var speed: Float = 1.0;
		var jumpThreshold: Float = 0.2;
		
		//var notGoingToJump: Bool = false;
		
		if (disableControls)
		{
			moveDelta = 0;
			player.animation.play("idle");
		}
		else
		{
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
				
				if (Math.abs(moveDelta) < 0.01)
					player.animation.play("idle");
				else
					player.animation.play(if (moveDelta > 0) "right" else "left");
			}
			else
			{
				player.animation.play(if (moveDelta > 0) "rightjump" else "leftjump");
				
				/*if (elapsed - timeJumpStarted >= jumpLength)
				{
					stopJump();
				}*/
			}
		}
		
		for (bossBasic in bossGroup)
		{
			var boss = cast(bossBasic, Boss);
			
			boss.setFacingLeft(boss.x > player.x);
			//boss.setFacingLeft(true);
			
			if (boss.y < water.y)
			{
				//if (boss.y < water.y - boss.frameHeight)
				if (bossGoingToDie(boss.y, water.y))
				{
					bossGroup.remove(boss, true);
					boss.destroy();
					soundBossdeath.play();
				}
				else
				{
					boss.setAttackActive(true);
				}
			}
			else
			{
				boss.setAttackActive(false);
			}
		}
		
		player.x += moveDelta;

		if (FlxG.collide(player, level))
		{
			//jumping = false;
			//stopJump();
		}
		else
		{
			//jumping = true;
		}
		
		FlxG.overlap(player, water, null, dieOnOverlap);
		FlxG.overlap(player, bossGroup, null, dieOnOverlap);
		FlxG.overlap(player, bulletGroup, null, dieOnOverlap);
		
		FlxG.overlap(player, itemGroup, null, pickupItem);
		
		/*if (jumping == false)
		{
			timeJumpStarted = Math.NEGATIVE_INFINITY;
			jumpTween.;
		}*/
		//FlxG.pixelPerfect
		
		/*FlxG.camera.x = player.x;
		FlxG.camera.y = water.y;*/
		
		//FlxG.collide(FlxG.camera, water);
		
		if ((itemGroup.countLiving() <= 0) && !timerEndgame.active && !timerEndgame.finished)
		//if ((itemGroup.length == 0) && waterTween.finished)
		{
			disableControls = true;
			//FlxG.switchState(new EndState());
			timerEndgame.start(3.0, endGame);
		}		
		
		/*if (FlxG.keys.anyPressed(["F5"]))
		{
			water.y = 324;
			updateCameraBounds();
			movePlayer(32, 307);
			saveGame();
		}
		if (FlxG.keys.anyPressed(["F6"]))
		{
			water.y = 444;
			updateCameraBounds();
			movePlayer(456, 410);
			saveGame();
		}
		if (FlxG.keys.anyPressed(["F7"]))
		{
			water.y = 468;
			updateCameraBounds();
			movePlayer(264, 450);
			saveGame();
		}*/
		/*if (FlxG.keys.anyPressed(["F8"]))
		{
			itemGroup.clear();
		}*/
		
		super.update(elapsed);
	}
}