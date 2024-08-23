package;

import backend.Paths;
import backend.PlayerData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.crypto.Sha1;
import objects.ShopPurchase;
import openfl.Lib;
import openfl.display.Shape;
import openfl.net.URLRequest;

class HUD extends FlxUIGroup
{
	public var mics:Int = 0;
	public var MSG_BOARD:MessageBoard;

	public var pressText:FlxText;
	public var secText:FlxText;

	public var shopOptions:Array<ShopPurchase> = [];

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

		add(MSG_BOARD = new MessageBoard(0, 50));
		MSG_BOARD.screenCenter(X);

		// pressing text
		add(pressText = new FlxText(0, (MSG_BOARD.y + MSG_BOARD.height) + 10, FlxG.width, 'Microphones: $mics', 22));
		pressText.setFormat(Paths.font("thing.ttf"), 22, FlxColor.WHITE, CENTER, SHADOW, FlxColor.BLACK);

		add(secText = new FlxText(0, (pressText.y + pressText.height) - 5, FlxG.width, 'per second: ', 18));
		secText.setFormat(Paths.font("thing.ttf"), 18, FlxColor.WHITE, CENTER, SHADOW, FlxColor.BLACK);
		updateSecText();

		// purchases... could be way simpler but im RUSHING this out
		var printerPurchase = new ShopPurchase("3D Printer", "Prints a microphone every 5 seconds.", PRINTER, 0);
		var rapperPurchase = new ShopPurchase("Rapper", "Produces a microphone every second.", RAPPER, (printerPurchase.y + printerPurchase.height));
		var sweatPurchase = new ShopPurchase("Sweatshop", "Produces 5 microphones every second.", SWEATSHOP, (rapperPurchase.y + rapperPurchase.height));
		var labPurchase = new ShopPurchase("Microphone Lab", "Produces 35 microphones every second.", LAB, (sweatPurchase.y + sweatPurchase.height));
		var factoryPurchase = new ShopPurchase("Factory", "Produces 230 microphones every second.", FACTORY, (labPurchase.y + labPurchase.height));

		for (i in [printerPurchase, rapperPurchase, sweatPurchase, labPurchase, factoryPurchase])
		{
			add(i);
			shopOptions.push(i);
		}

		var infoBox = new FlxSprite(25, 25).makeGraphic(335, 600, FlxColor.BLACK);
		add(infoBox);
		infoBox.alpha = 0.25;

		var infoTitle = new FlxText(infoBox.x + 5, infoBox.y + 5, 0, "INFORMATION");
		infoTitle.setFormat(Paths.font("thing.ttf"), 22, FlxColor.WHITE, LEFT, SHADOW, FlxColor.BLACK);
		add(infoTitle);

		var info = new FlxText(infoBox.x + 5, infoTitle.y + 35, infoBox.width - 15,
			"helo! this is isophoro,\nthis game is very rushed! and might be bugged, i wanted to get it out asap and get feedback and use people as my playtesters!\n\nplspls report and bugs,,, and also,, we need more messages to appear in the message box! i only added a few so you guys could help\n\ni'm also planning on adding achievements, upgrades,,, offline progression,, and basically making everything better, like getting rid of the 99 limit,,, oops!\n\ngo check out my website isophoro.com");
		info.setFormat(Paths.font("thing.ttf"), 16, FlxColor.WHITE, LEFT, SHADOW, FlxColor.BLACK);
		add(info);
		info.alpha = 0.75;

		var websiteIcon = new FlxSprite(0, 0).loadGraphic("assets/images/logo_small.png");
		add(websiteIcon);
		websiteIcon.alpha = 0.5;
		websiteIcon.setPosition(FlxG.width - websiteIcon.width, FlxG.height - websiteIcon.height);
		FlxMouseEvent.add(websiteIcon, function(spr:FlxSprite)
		{
			Lib.getURL(new URLRequest("https://isophoro.com"));
		}, null, function(spr:FlxSprite)
		{
			spr.alpha = 1;
		}, function(spr:FlxSprite)
		{
			spr.alpha = 0.5;
		});

		// debug bottom left
		var debugInfo = new FlxText(0, 0, 0, 'V. 1\nmade by isophoro', 22);
		add(debugInfo);
		debugInfo.setFormat(Paths.font("thing.ttf"), 22, FlxColor.WHITE, LEFT, SHADOW, FlxColor.BLACK);
		debugInfo.alpha = 0.45;
		debugInfo.setPosition(5, (FlxG.height - debugInfo.height) - 2.5);
	}

	// this is ognna suck so bad
	public function updateSecText():Void
	{
		var finalAmt:Float = 0;

		finalAmt += PlayerData.buildings[PRINTER] * (1 / 5);
		finalAmt += PlayerData.buildings[RAPPER];
		finalAmt += 5 * PlayerData.buildings[SWEATSHOP];
		finalAmt += 35 * PlayerData.buildings[LAB];
		finalAmt += 230 * PlayerData.buildings[FACTORY];

		secText.text = 'per second: ' + finalAmt;
	}

	public function updateText():Void
		pressText.text = 'Microphones: $mics';
}

class MessageBoard extends FlxSpriteGroup
{
	public var back:FlxSprite;
	public var message:FlxText;

	// the messages and how many mics you need
	public var messages:Array<Dynamic> = [];

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

		timerCheck = new FlxTimer().start(TIMER_TIME, function(tmr:FlxTimer)
		{
			updateMessage();
			timerCheck.reset(TIMER_TIME);
		});
	}

	public function initMessages():Void
	{
		// microphone amount stuff
		addMessage({min: 0, max: 50}, ["You feel like selling microphones, as you like rapping."], MIN_MAX);
		addMessage({min: 50, max: 100}, ["You manage to sell one! You get a negative review about it being cheap."], MIN_MAX);
		addMessage({min: 100, max: 500}, ["You sell to your friends! They rarely use them."], MIN_MAX);
		addMessage({min: 500, max: 1000}, ["Your microphones are getting popular with the local karaoke."], MIN_MAX);
		addMessage({min: 1000, max: 5000}, ["Local upcoming rappers are starting to get ahold of your microphone."], MIN_MAX);
		addMessage({min: 5000, max: 10000}, [
			"The entire town supports your microphone business, excluding your girlfriend's dad."
		], MIN_MAX);
		addMessage({min: 10000, max: 50000}, [
			"Your microphones are making good profit.",
			"The entire town supports your microphone business, excluding your girlfriend's dad."
		], MIN_MAX);
		addMessage({min: 50000, max: 100000}, ["Your microphone is being used on the local radio."], MIN_MAX);
		addMessage({min: 100000, max: 500000}, ["You started a website for your microphones!"], MIN_MAX);
		addMessage({min: 500000, max: 1000000}, ["Audiophiles are reviewing your microphone all over YouFunk."], MIN_MAX);
		addMessage({min: 1000000, max: 500000000000}, ["FunkNite streamers are starting to use your microphone for streaming."], MIN_MAX);
		addMessage({min: 500000000000, max: 1000000000000}, ["Multiple sources confirm Kai Cenat has bought your microphone."], MIN_MAX);
		addMessage(1000000000000, ["You feel like it's time to go touch grass for the first time in your life."], ABOVE);

		// printer
		addMessage(() -> return PlayerData.buildings[PRINTER] >= 1 && PlayerData.buildings[PRINTER] < 5,
			["\"Skee bap boop.\" -Boyfriend", "\"This is stupid.\" -Girlfriend"], ETC);
		addMessage(() -> return PlayerData.buildings[PRINTER] >= 5 && PlayerData.buildings[PRINTER] < 10, ["Breaking News! Local mans printer explodes!"], ETC);
		addMessage(() -> return PlayerData.buildings[PRINTER] >= 10 && PlayerData.buildings[PRINTER] < 50, [
			"Don't you just love printers?",
			"Printers galore!",
			"I love my girlfriend -isophoro",
			"hello1111 - isophoro",
			"isophoro.com"
		], ETC);
		addMessage(() -> return PlayerData.buildings[PRINTER] >= 50, ["Breaking News! Printer-Heads are joining Skibidi Toilet!"], ETC);

		// rapper
		addMessage(() -> return PlayerData.buildings[RAPPER] >= 1 && PlayerData.buildings[RAPPER] < 5, [
			"\"Yo yo yo!\" -Local Rapper",
			"\"Buy my product off my FunkTok shop!\" -FunkToker"
		], ETC);
		addMessage(() -> return PlayerData.buildings[RAPPER] >= 5, ["Do you like funny rapping too?"], ETC);

		// sweatshop pls dont cancel me
		addMessage(() -> return PlayerData.buildings[SWEATSHOP] >= 1 && PlayerData.buildings[SWEATSHOP] < 5, [
			"Breaking News! Local microphone business under investigation for not paying their workers much."
		], ETC);
		addMessage(() -> return PlayerData.buildings[SWEATSHOP] >= 5 && PlayerData.buildings[SWEATSHOP] < 50, [
			"Breaking News! Local microphone business under investigation for not paying their workers much.",
			"Breaking News! A sweatshop belonging to a local microphone business burns down!"
		], ETC);
		addMessage(() -> return PlayerData.buildings[SWEATSHOP] >= 50, [
			"Breaking News! Local microphone business under investigation for not paying their workers much.",
			"Breaking News! A sweatshop belonging to a local microphone business burns down!",
			"Breaking News! Sweatshops are bad?"
		], ETC);

		// labs
		addMessage(() -> return PlayerData.buildings[LAB] >= 1 && PlayerData.buildings[LAB] < 5, ["We need to produce more microphones!"], ETC);
		addMessage(() -> return PlayerData.buildings[LAB] >= 5 && PlayerData.buildings[LAB] < 10, [
			"\"We need to produce.\" -W. W.",
			"\"Bitch!\" -Jesse",
			"We will break bad with all these microphones."
		], ETC);
		addMessage(() -> return PlayerData.buildings[LAB] >= 10, [
			"\"We need to produce.\" -W. W.",
			"\"Bitch!\" -Jesse",
			"We will break bad with all these microphones.",
			"We might need a lawyer!"
		], ETC);

		// factory
		addMessage(() -> return PlayerData.buildings[FACTORY] >= 1, ["im gonna be honest i have no idea pls submit message ideas"], ETC);

		//	addMessage(() -> return PlayState.instance.someLevel >= 3, ["Level time!"], ETC);
	}

	public function updateMessage()
	{
		var text:String = getMessageForCondition();

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

	// message stuff
	private function getMessageForCondition():String
	{
		var possibleMessages:Array<String> = [];

		for (entry in messages)
		{
			if (checkCondition(entry.condition, entry.type))
			{
				if (Std.is(entry.texts, Array))
				{
					var texts:Array<String> = cast entry.texts;

					for (text in texts)
					{
						possibleMessages.push(text);
						trace([possibleMessages]);
					}
				}
			}
		}

		if (possibleMessages.length > 0)
			return possibleMessages[FlxG.random.int(0, possibleMessages.length - 1)];

		return "";
	}

	private function checkCondition(condition:Dynamic, type:MessageConditionType):Bool
	{
		if (condition == null)
			return true;

		switch (type)
		{
			case ETC:
				return condition();
			case ABOVE:
				return PlayerData.micsLifeTime >= condition;
			case MIN_MAX:
				return PlayerData.micsLifeTime >= condition.min && PlayerData.micsLifeTime < condition.max;
			default:
				return false;
		}
	}

	public function addMessage(condition:Dynamic, textArray:Array<String>, type:MessageConditionType):Void
		messages.push({condition: condition, texts: textArray, type: type});
	/*



		public function hasMessage(condition:Dynamic):Bool
		{
			for (entry in messages)
			{
				if (compareConditions(entry.condition, condition))
				{
					return true;
				}
			}
			return false;
		}

		public function removeMessage(condition:Dynamic):Void
		{
			for (i in 0...messages.length)
			{
				if (compareConditions(messages[i].condition, condition))
				{
					messages.splice(i, 1);
					break;
				}
			}
		}

		private function compareConditions(cond1:Dynamic, cond2:Dynamic):Bool
		{
			switch (Type.typeof(cond1))
			{
				case TFunction:
					return Reflect.compareMethods(cond1, cond2);
				default:
					return cond1 == cond2;
			}

			return false;
	}*/
}

enum MessageConditionType
{
	ABOVE;
	MIN_MAX;
	ETC;
}
