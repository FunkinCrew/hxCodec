package hxcodec.flixel;

#if flixel
import flixel.FlxG;
import hxcodec.openfl.Video;
import openfl.events.Event;
import sys.FileSystem;
import openfl.utils.Assets;

class FlxVideo extends Video
{
	// Variables
	public var autoResize:Bool = true;
	public var autoPause:Bool = FlxG.autoPause;

	public function new():Void
	{
		super();

		onOpening.add(function()
		{
			#if FLX_SOUND_SYSTEM
			volume = Std.int((FlxG.sound.muted ? 0 : 1) * (FlxG.sound.volume * 100));
			#end
		});

		FlxG.addChildBelowMouse(this);
	}

	override public function play(location:String, shouldLoop:Bool = false):Int
	{
		if (autoPause)
		{
			if (!FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.add(resume);

			if (!FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.add(pause);
		}

		FlxG.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

		if (Assets.exists(location))
			return super.play(Assets.getPath(location), shouldLoop);
		else if (FileSystem.exists(Sys.getCwd() + location))
			return super.play(Sys.getCwd() + location, shouldLoop);
		else
			return super.play(location, shouldLoop);
	}

	override public function dispose():Void
	{
		if (autoPause)
		{
			if (FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.remove(resume);

			if (FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.remove(pause);
		}

		if (FlxG.stage.hasEventListener(Event.ENTER_FRAME))
			FlxG.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

		super.dispose();

		FlxG.removeChild(this);
	}

	@:noCompletion private function onEnterFrame(e:Event):Void
	{
		if (autoResize)
		{
			var aspectRatio:Float = FlxG.width / FlxG.height;

			if (FlxG.stage.stageWidth / FlxG.stage.stageHeight > aspectRatio)
			{
				// stage is wider than video
				width = FlxG.stage.stageHeight * aspectRatio;
				height = FlxG.stage.stageHeight;
			}
			else
			{
				// stage is taller than video
				width = FlxG.stage.stageWidth;
				height = FlxG.stage.stageWidth * (1 / aspectRatio);
			}
		}

		#if FLX_SOUND_SYSTEM
		volume = Std.int((FlxG.sound.muted ? 0 : 1) * (FlxG.sound.volume * 100));
		#end
	}
}
#end
