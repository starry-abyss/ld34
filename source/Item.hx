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
		
		makeGraphic(5, 5, FlxColor.YELLOW);
	}
	
	//public function
}