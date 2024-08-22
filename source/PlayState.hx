package;

import HUD.MessageBoard;
import backend.Paths;
import backend.PlayerData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEvent;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import hxIni.IniManager;
import objects.Microphone;
import sys.FileSystem;

@:allow(MessageBoard)
class PlayState extends FlxState
{
	var bg:FlxSprite;
	var mic:Microphone;

	public static var micPresses(default, set):Int = 0;
	public static var hud:HUD;

	public var perSecond:Int = 0;

	var secondTimer:FlxTimer;

	override public function create()
	{
		super.create();

		PlayerData.loadData();

		add(bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY));
		add(mic = new Microphone(100, 0, 0.5));
		mic.pressCallback = doMicPressedStuff;
		mic.y += 50;

		secondTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			microphoneAdd(perSecond);
			secondTimer.reset(1);
		});

		add(hud = new HUD());

		micPresses = PlayerData.mics;
		perSecond = PlayerData.perSecond;
		FlxG.stage.window.title = '$micPresses Microphones - Microphone Clicker';
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function perSecondAdd(addAmount:Int)
	{
		perSecond += addAmount;

		PlayerData.perSecond = perSecond;
		PlayerData.saveData();
	}

	function microphoneAdd(addAmount:Int)
	{
		micPresses += addAmount;
		FlxG.stage.window.title = '$micPresses Microphones - Microphone Clicker';

		PlayerData.mics = micPresses;
		PlayerData.saveData();
	}

	function doMicPressedStuff()
	{
		microphoneAdd(1);

		FlxG.sound.play("assets/sounds/clicked.wav");

		var smallMic:FlxSprite = new FlxSprite().loadGraphic("assets/images/microphone.png");
		smallMic.scale.set(0.2, 0.2);
		smallMic.updateHitbox();
		add(smallMic);
		smallMic.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		smallMic.acceleration.y = 550;
		smallMic.velocity.y -= 140;
		smallMic.angularVelocity = 240;
		smallMic.velocity.x = FlxG.random.int(-110, 110);

		FlxTween.tween(smallMic, {alpha: 0}, 1, {
			onComplete: (twn) ->
			{
				smallMic.destroy();
				remove(smallMic);
			}
		});

		var text:FlxText = new FlxText(FlxG.mouse.x, FlxG.mouse.y, 0, "+1", 32);
		add(text);
		text.font = Paths.font("vcr.ttf"); // fnf reference
		text.antialiasing = false;
		FlxTween.tween(text, {y: text.y - 100, alpha: 0}, 2, {
			onComplete: (twn) ->
			{
				text.destroy();
				remove(text);
			}
		});
	}

	static function set_micPresses(value:Int):Int
	{
		micPresses = value;
		hud.mics = value;
		hud.updateText();
		return value;
	}
}
