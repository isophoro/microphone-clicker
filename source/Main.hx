package;

import backend.Paths;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, PlayState));
		// addChild(new DebugInfo());
	}
}

class DebugInfo extends TextField
{
	public function new()
	{
		super();

		this.x = 5;
		this.y = 5;

		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(Paths.font('thing.ttf'), 14, 0xffffff);
		autoSize = LEFT;
		multiline = true;
		text = "V. 1\nmade by isophoro!";
	}
}
