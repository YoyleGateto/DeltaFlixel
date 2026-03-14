import flixel.addons.display.FlxBackdrop;

var transCam = new FlxCamera();

function create() {
	
	transCam.alpha = (newState != null) ? 0 : 1;
	FlxG.cameras.add(transCam, false);
	
	transitionTween.cancel();

	remove(blackSpr);
	remove(transitionSprite);
	
	new FlxTimer().start(0.25, () -> {
		finish();
	});
	FlxTween.tween(transCam, {alpha: (newState != null) ? 1 : 0}, 0.25);
}