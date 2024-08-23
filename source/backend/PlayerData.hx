package backend;

import flixel.FlxG;

class PlayerData
{
	public static var mics:Int = 0;
	public static var micsLifeTime:Int = 0;

	// i could automate this LOL
	public static var buildings:Map<Buildings, Int> = [PRINTER => 0, RAPPER => 0, SWEATSHOP => 0, LAB => 0, FACTORY => 0];

	public static function loadData():Void
	{
		FlxG.save.bind("micClicker");

		if (FlxG.save.data.mics == null)
			FlxG.save.data.mics = 0;
		if (FlxG.save.data.micsLifeTime == null)
			FlxG.save.data.micsLifeTime = 0;
		if (FlxG.save.data.buildings == null)
			FlxG.save.data.buildings = buildings;

		mics = FlxG.save.data.mics;
		buildings = FlxG.save.data.buildings;
		micsLifeTime = FlxG.save.data.micsLifeTime;

		FlxG.save.flush();
		FlxG.sound.soundTrayEnabled = false;
	}

	public static function saveData():Void
	{
		FlxG.save.data.mics = mics;
		FlxG.save.data.buildings = buildings;
		FlxG.save.data.micsLifeTime = micsLifeTime;

		FlxG.save.flush();
	}
}

enum Buildings
{
	PRINTER;
	RAPPER;
	SWEATSHOP;
	LAB;
	FACTORY;
}
