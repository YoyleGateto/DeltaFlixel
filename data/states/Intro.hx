import funkin.backend.MusicBeatState;
import deltaflixel.objects.WaveSprite;

var canPress:Bool = true;
var fadeOut___:Bool = false;
var noise:FlxSound;

function create(){
	FlxG.camera.alpha = 0;
	FlxTween.tween(FlxG.camera, {alpha: 1}, 2.57142857);
	new FlxTimer().start(2.57142857+2.78571429, (k) -> {
		fadeOut___ = true;
		FlxTween.tween(FlxG.camera, {alpha: 0}, 3);
		new FlxTimer().start(4.5, function(tmr){
			MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
			FlxG.switchState(new ModState("Menu"));
		});
	});
	logo = new WaveSprite().loadGraphic(Paths.image('logo'));
	logo.sinOffset = 200;
	logo.screenCenter();
	logo.init();
	logo.antialiasing = true;
	FlxTween.tween(logo, {sinOffset: 0}, 2.57142857);
	noise = playSound("intronoise");
}

var variant:Int = 0;
function update(e:Float) {
	if (fadeOut___) {
		var random = FlxG.random.bool(50);
		if (random) {
			variant = (variant + 1) % 3;
			logo.loadGraphic(Paths.image('flx' + (variant + 1)));
		}
		logo.sinOffset += 1;
		noise.pitch = FlxG.random.float(0.95,1.05);
	}
	if (canPress) {
		if (keys.ACCEPT || controls.ACCEPT) {
			canPress = false;
			FlxTween.tween(FlxG.camera, {alpha: 0}, 0.5, { ease: FlxEase.quadOut });
			new FlxTimer().start(0.5, function(tmr){
				MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
				FlxG.switchState(new ModState("Menu"));
			});
		}
	}
}
