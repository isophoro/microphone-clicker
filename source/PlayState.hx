package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var bg:FlxSprite;
	var mic:FlxSprite;
	var micPresses:Float = 0;

	override public function create()
	{
		super.create();

		add(bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY));

		add(mic = new FlxSprite(100, 0).loadGraphic("assets/images/microphone.png"));
		mic.centerOrigin();
		mic.angle = 26;
		mic.updateHitbox();
		mic.screenCenter(Y);
	}

	private var canClick(default, set):Bool = false;
	private var micPressed:Bool = false;

	override public function update(elapsed:Float)
	{
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
					spawnEarnedTxt();
					micPresses++;
					trace(micPresses);
				}
			}
		}
		else if (mic.scale.x > 1 || mic.scale.x < 1)
		{
			canClick = micPressed = false;
			tweenMicScale(1, 1);
		}
	}

	function spawnEarnedTxt()
	{
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
