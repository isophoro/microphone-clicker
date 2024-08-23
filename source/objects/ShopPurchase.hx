package objects;

import backend.Constants;
import backend.Paths;
import backend.PlayerData.Buildings;
import backend.PlayerData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.macro.Expr.Constant;

class ShopPurchase extends FlxSpriteGroup
{
	public var price:Int = 0;
	public var name:String = "Placeholder";
	public var type:Buildings;
	public var description:String = "Placeholder !";
	public var numOwnedInt:Int = 0;

	var back:FlxSprite;

	public var nameText:FlxText;
	public var descText:FlxText;
	public var numOwned:FlxText;
	public var priceText:FlxText;
	public var img:FlxSprite;

	var overlapping:Bool = false;

	override public function new(name:String, description:String, type:Buildings, y:Float)
	{
		super(FlxG.width - 332, y);

		this.name = name;
		this.type = type;
		this.description = description;
		numOwnedInt = PlayerData.buildings[type];

		var powd = PlayerData.buildings[type] == 0 ? 1 : PlayerData.buildings[type];
		price = Std.int(Constants.BASIC_PRICES[type] * Math.pow(powd, 1.15));

		back = new FlxSprite(0, 0).loadGraphic("assets/images/ui/backing.png");
		add(back);
		back.color = PlayerData.mics >= price ? 0xFFeeeeee : FlxColor.GRAY;
		FlxMouseEvent.add(back, purchase, null, function(spr:FlxSprite)
		{
			back.color = PlayerData.mics >= price ? FlxColor.WHITE : FlxColor.GRAY;
			overlapping = true;
		}, function(spr:FlxSprite)
		{
			back.color = PlayerData.mics >= price ? 0xFFeeeeee : FlxColor.GRAY;
			overlapping = false;
		}, false, true, true);

		add(img = new FlxSprite(2, 2).loadGraphic('assets/images/ui/${name.toLowerCase()}.png'));

		add(nameText = new FlxText(70, 7.5, 185, '$name -   $price', 16));
		nameText.setFormat(Paths.font("vcr.ttf"), name == "Microphone Lab" ? 12 : 16, PlayerData.mics >= price ? FlxColor.BLACK : FlxColor.RED, LEFT);
		nameText.bold = true;

		add(descText = new FlxText(70, 30, 185, '$description', 10));
		descText.setFormat(Paths.font("vcr.ttf"), 10, PlayerData.mics >= price ? FlxColor.BLACK : FlxColor.RED, LEFT);

		add(numOwned = new FlxText(270, 5, 54, '$numOwnedInt', 32));
		numOwned.setFormat(Paths.font("thing.ttf"), 32, FlxColor.BLACK, CENTER);
		numOwned.alpha = 0.65;
	}

	public function purchase(spr:FlxSprite)
	{
		if (PlayerData.mics < price || PlayerData.buildings[type] == 99)
			return;

		switch (type)
		{
			default:
				trace("ah!");
		}

		PlayerData.mics -= price;
		PlayState.micPresses = PlayerData.mics;
		PlayerData.buildings[type]++;
		numOwnedInt = PlayerData.buildings[type];
		PlayerData.saveData();
		PlayState.hud.updateSecText();

		price = Std.int(Constants.BASIC_PRICES[type] * Math.pow(PlayerData.buildings[type], 1.15));

		nameText.text = '$name -   $price';
		numOwned.text = '$numOwnedInt';

		updateColors();
	}

	public function updateColors()
	{
		if (PlayerData.mics < price || PlayerData.buildings[type] == 99)
		{
			back.color = FlxColor.GRAY;
			nameText.color = descText.color = FlxColor.RED;
		}
		else
		{
			back.color = overlapping ? FlxColor.WHITE : 0xFFeeeeee;
			nameText.color = descText.color = FlxColor.BLACK;
		}
	}
}
