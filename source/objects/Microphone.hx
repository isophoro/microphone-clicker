package objects;

import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEvent;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Microphone extends FlxSprite
{
	public var pressCallback:Void->Void;
	public var curScale:Float = 0;

	override public function new(x:Float, y:Float, daScale:Float)
	{
		super(x, y);
		loadGraphic("assets/images/microphoneShadow.png");
		centerOrigin();
		angle = 26;
		updateHitbox();
		screenCenter();
		curScale = daScale;
		scale.set(daScale, daScale);
		FlxMouseEvent.add(this, onDown, onUp, onOver, onOut, false, true, true);
	}

	function onDown(spr:FlxSprite)
	{
		tweenMic(0.95, 0.95, 0.5, FlxEase.bounceOut);
	}

	function onUp(spr:FlxSprite)
	{
		tweenMic(1.05, 1.05, 0.5, FlxEase.bounceOut);
		pressCallback();
	}

	function onOver(spr:FlxSprite)
	{
		tweenMic(1.05, 1.05, 0.5, FlxEase.bounceOut);
	}

	function onOut(spr:FlxSprite)
	{
		tweenMic(1, 1, 0.5, FlxEase.bounceOut);
	}

	function tweenMic(x:Float, y:Float, duration:Float, easeFunction:EaseFunction)
	{
		FlxTween.cancelTweensOf(this);
		FlxTween.tween(this, {"scale.x": curScale * x, "scale.y": curScale * y}, duration, {ease: easeFunction});
	}
}
