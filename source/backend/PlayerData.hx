package backend;

import flixel.FlxG;

class PlayerData
{
	public static var mics:Int = 0;
	public static var perSecond:Int = 0;

	public static function loadData():Void
	{
		FlxG.save.bind("micClicker");

		if (FlxG.save.data.mics == null)
			FlxG.save.data.mics = 0;

		if (FlxG.save.data.perSec == null)
			FlxG.save.data.perSec = 0;

		mics = FlxG.save.data.mics;
		perSecond = FlxG.save.data.perSec;

		FlxG.save.flush();
		FlxG.sound.soundTrayEnabled = false;
	}

	public static function saveData():Void
	{
		FlxG.save.data.mics = mics;
		FlxG.save.data.perSec = perSecond;

		FlxG.save.flush();
	}
}
