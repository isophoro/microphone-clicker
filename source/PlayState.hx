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
import objects.Microphone;
import openfl.Assets;
import openfl.media.Sound;

@:allow(MessageBoard)
class PlayState extends FlxState
{
	public static var instance:PlayState;

	var bg:FlxSprite;
	var mic:Microphone;

	public static var micPresses(default, set):Int = 0;
	public static var hud:HUD;

	var secondTimer:FlxTimer;
	var timesRan:Int = 0;

	override public function create()
	{
		super.create();

		#if cpp
		FlxG.sound.playMusic(AssetPaths.bg__ogg, 1, true);
		#elseif html5
		FlxG.sound.playMusic(AssetPaths.bg__mp3, 1, true);
		#end

		instance = this;

		PlayerData.loadData();

		add(bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY));
		add(mic = new Microphone(100, 0, 0.5));
		mic.pressCallback = doMicPressedStuff;
		mic.y += 50;

		// more jank code woohoo!
		secondTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			// for some reason having another timer has a slight delay?
			timesRan++;
			if (timesRan == 5)
			{
				microphoneAdd(1 * PlayerData.buildings[PRINTER]);
				timesRan = 0;
			}

			var additive = 0;

			additive += PlayerData.buildings[RAPPER];
			additive += 5 * PlayerData.buildings[SWEATSHOP];
			additive += 35 * PlayerData.buildings[LAB];
			additive += 230 * PlayerData.buildings[FACTORY];

			microphoneAdd(additive);
			secondTimer.reset(1);
		});

		add(hud = new HUD());

		PlayState.micPresses = PlayerData.mics;
		FlxG.stage.window.title = '$micPresses Microphones - Microphone Clicker';

		hud.MSG_BOARD.initMessages();
		hud.MSG_BOARD.updateMessage();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function microphoneAdd(addAmount:Int)
	{
		micPresses += addAmount;
		FlxG.stage.window.title = '$micPresses Microphones - Microphone Clicker';

		PlayerData.micsLifeTime += addAmount;
		PlayerData.mics = micPresses;
		PlayerData.saveData();
	}

	function doMicPressedStuff()
	{
		microphoneAdd(1);

		for (i in 0...hud.shopOptions.length)
			hud.shopOptions[i].updateColors();

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

		for (i in 0...hud.shopOptions.length)
			hud.shopOptions[i].updateColors();

		return value;
	}
}
