package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import hxIni.IniManager;
import sys.FileSystem;

class PlayState extends FlxState
{
	var bg:FlxSprite;
	var mic:FlxSprite;
	var pressesText:FlxText;

	var micPresses:Float = 0;
	var perSecond:Float = 0;

	var secondTimer:FlxTimer;

	override public function create()
	{
		super.create();

		// ACTUAL save file
		FlxG.save.bind("micClicker");

		checkSaveFlxG();
		checkSaveIni();

		var ini:Ini = IniManager.loadFromFile("save.ini");
		micPresses = Std.parseFloat(ini["data"]["presses"]);
		perSecond = Std.parseFloat(ini["data"]["ps"]);

		trace(ini["data"]["presses"] + " - " + FlxG.save.data.mics);
		if (ini["data"]["presses"] != FlxG.save.data.mics || ini["data"]["ps"] != FlxG.save.data.perSec) // ehehehee
		{
			FileSystem.deleteFile("save.ini");
			FlxG.save.erase();

			FlxG.stage.window.alert("Cheated microphones aren't professional.");
			Sys.exit(0);
		}

		add(bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY));

		add(mic = new FlxSprite(100, 0).loadGraphic("assets/images/microphone.png"));
		mic.centerOrigin();
		mic.angle = 26;
		mic.updateHitbox();
		mic.screenCenter(Y);

		add(pressesText = new FlxText(5, 5, 0, "game by isophoro - mics: " + Std.int(micPresses) + '\nmics per second: $perSecond', 32)); // placeholder

		secondTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			cookieAdd(perSecond);
			secondTimer.reset(1);
		});
	}

	private var canClick(default, set):Bool = false;
	private var micPressed:Bool = false;

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.P && micPresses >= 25)
		{
			micPresses -= 25;
			perSecondAdd(999);
			trace("bought !");
		}

		micMouseCheck();

		super.update(elapsed);
	}

	function micMouseCheck()
	{
		// talk about shitty code LOL
		if (FlxG.mouse.overlaps(mic))
		{
			if (!canClick)
			{
				canClick = true;
				tweenMicScale(1.1, 1.1);
			}

			if (canClick)
			{
				if (FlxG.mouse.pressed && !micPressed)
				{
					micPressed = true;
					tweenMicScale(0.9, 0.9);
				}

				if (micPressed && FlxG.mouse.justReleased)
				{
					micPressed = false;
					tweenMicScale(1.1, 1.1);
					doMicPressedStuff();
				}
			}
		}
		else if (mic.scale.x > 1 || mic.scale.x < 1)
		{
			canClick = micPressed = false;
			tweenMicScale(1, 1);
		}
	}

	function doMicPressedStuff()
	{
		cookieAdd(1);

		var text:FlxText = new FlxText(FlxG.mouse.x, FlxG.mouse.y, 0, "+1", 32);
		add(text);
		FlxTween.tween(text, {y: text.y - 100, alpha: 0}, 2, {
			onComplete: (twn) ->
			{
				text.destroy();
				remove(text);
			}
		});
	}

	function perSecondAdd(addAmount:Float)
	{
		perSecond += addAmount;
		pressesText.text = "game by isophoro - mics: " + Std.int(micPresses) + '\nmics per second: $perSecond';

		checkSaveIni();
		var ini:Ini = IniManager.loadFromFile("save.ini");
		ini["data"]["ps"] = Std.string(perSecond);
		IniManager.writeToFile(ini, "save.ini");

		checkSaveFlxG();
		FlxG.save.data.perSec = perSecond;
		FlxG.save.flush();

		trace(ini["data"]["ps"] + " - " + FlxG.save.data.perSec);
	}

	function cookieAdd(addAmount:Float)
	{
		micPresses += addAmount;
		pressesText.text = "game by isophoro - mics: " + Std.int(micPresses) + '\nmics per second: $perSecond';

		checkSaveIni();
		var ini:Ini = IniManager.loadFromFile("save.ini");
		ini["data"]["presses"] = Std.string(micPresses);
		IniManager.writeToFile(ini, "save.ini");

		checkSaveFlxG();
		FlxG.save.data.mics = micPresses;
		FlxG.save.flush();

		trace(ini["data"]["presses"] + " - " + FlxG.save.data.mics);
	}

	function checkSaveFlxG()
	{
		if (FlxG.save.data.mics == null)
			FlxG.save.data.mics = 0;

		if (FlxG.save.data.perSec == null)
			FlxG.save.data.perSec = 0;

		FlxG.save.flush();
	}

	function checkSaveIni()
	{
		if (!FileSystem.exists("save.ini"))
		{
			var ini:Ini = IniManager.loadFromString("[data]\npresses=0\nps=0");
			IniManager.writeToFile(ini, "save.ini");
		}
	}

	function tweenMicScale(daX:Float = 1, daY:Float = 1)
	{
		FlxTween.cancelTweensOf(mic.scale);
		FlxTween.tween(mic.scale, {x: daX, y: daY}, 0.5, {ease: FlxEase.backOut});
	}

	function set_canClick(value:Bool):Bool
	{
		canClick = value;
		return canClick;
	}
}
