package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * ...
 * @author scorched
 */
class Item extends FlxSprite 
{

	public function new(x: Float, y: Float) 
	{
		super(x, y);
		
		loadGraphic("assets/images/item.png", false, 8, 8);
	}
	
	//public function
}