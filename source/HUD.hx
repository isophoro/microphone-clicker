package;

import backend.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.crypto.Sha1;
import openfl.display.Shape;

class HUD extends FlxUIGroup
{
	public var mics:Int = 0;

	public var pressText:FlxText;

	override public function new()
	{
		super();

		var backBoyfriend = new FlxSprite().loadGraphic("assets/images/backing.png");
		add(backBoyfriend);
		backBoyfriend.alpha = 0.45;
		backBoyfriend.antialiasing = true;

		var boyfriendText = new FlxText(0, 10, 0, "Boyfriend's Microphone Business", 14);
		boyfriendText.font = Paths.font("thing.ttf");
		boyfriendText.color = 0xFFD8D8D8;
		add(boyfriendText);
		boyfriendText.screenCenter(X);

		backBoyfriend.y = boyfriendText.y - 2;
		backBoyfriend.screenCenter(X);

		var messageBoard = new MessageBoard(0, 50);
		add(messageBoard);
		messageBoard.screenCenter(X);

		// pressing text
		add(pressText = new FlxText(0, (messageBoard.y + messageBoard.height) + 10, FlxG.width, 'Microphones: $mics', 22));
		pressText.setFormat(Paths.font("thing.ttf"), 22, FlxColor.WHITE, CENTER, SHADOW, FlxColor.BLACK);
	}

	public function updateText():Void
		pressText.text = 'Microphones: $mics';
}

class MessageBoard extends FlxSpriteGroup
{
	public var back:FlxSprite;
	public var message:FlxText;

	// the messages and how many mics you need
	public var messages:Array<Dynamic> = [
		[0, ["You feel like selling microphones, as you like rapping."]],
		[50, ["You manage to sell one! You get a negative review about it being cheap."]],
		[100, ["You sell to your friends! They rarely use them."]],
		[500, ["Your microphones are getting popular with the local karaoke."]],
		[1000, ["Local upcoming rappers are starting to get ahold of your microphone."]],
		[
			5000,
			[
				"The entire town supports your microphone business, excluding your girlfriends dad."
			]
		],
		[
			10000,
			[
				"Your microphones are making good profit.",
				"The entire town supports your microphone business, excluding your girlfriends dad."
			]
		],
		[50000, ["Your microphone is being used on the local radio."]],
		[100000, ["You started a website for your microphones!"]],
		[500000, ["Audiophiles are reviewing your microphone all over YouFunk."]],
		[
			1000000,
			["FunkNite streamers are starting to use your microphone for streaming."]
		],
		[500000000000, ["Multiple sources confirm Kai Cenat has bought your microphone."]],
		[
			1000000000000,
			["You feel like it's time to go touch grass for the first time in your life."]
		]
	];

	// the timer
	public var timerCheck:FlxTimer;
	public final TIMER_TIME:Float = 15;

	public final MIN_FONT_SIZE:Int = 16;
	public final MAX_FONT_SIZE:Int = 64;

	override public function new(x:Float, y:Float)
	{
		super(x, y);

		add(back = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width / 2.5), 125, FlxColor.BLACK));
		back.visible = true;
		back.alpha = 1;

		add(message = new FlxText(0, 5, back.width / 1.1, "", 32));
		message.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		updateMessage();

		timerCheck = new FlxTimer().start(TIMER_TIME, function(tmr:FlxTimer)
		{
			updateMessage();
			timerCheck.reset(TIMER_TIME);
		});
	}

	private function updateMessage()
	{
		var text:String = getMessageForMicPresses(PlayState.micPresses);

		if (message.text != text)
		{
			FlxTween.tween(message, {y: message.y + 5, alpha: 0}, 1, {
				onComplete: (twn) ->
				{
					message.y = y;
					fontSizeThing(text);
					trace(message.size);
					FlxTween.tween(message, {y: y + 5, alpha: 1}, 1);
				}
			});
		}
		else
			fontSizeThing(text);

		message.x = back.x + ((back.width - message.width) / 2);
	}

	private function fontSizeThing(text:String):Void
	{
		var fontSize:Int = MAX_FONT_SIZE;
		message.setFormat(Paths.font("vcr.ttf"), fontSize, FlxColor.WHITE, CENTER);
		message.text = text;

		while (message.height > (back.height - 10) && fontSize > MIN_FONT_SIZE)
		{
			fontSize--;
			message.setFormat(Paths.font("vcr.ttf"), fontSize, FlxColor.WHITE, CENTER);
			message.text = text;
		}
	}

	private function getMessageForMicPresses(micPresses:Int):String
	{
		var daMessage:String = "";

		for (key in 0...messages.length)
			if (micPresses >= messages[key][0])
				daMessage = messages[key][1][FlxG.random.int(0, Std.int(messages[key][1].length - 1))];

		trace(daMessage);
		return daMessage;
	}
}
