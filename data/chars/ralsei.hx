import deltaflixel.objects.DeltaCharacter;
var character = new DeltaCharacter({
	// stats, acts and magic part
	name: "Ralsei",
	hp: 180,
	stats: {
		hp: 180,
		attack: 14,
		defense: 2,
		magic: 13,
	},
	canSpell: true,
	spells: [
		{
			text: "Heal Prayer",
			tp: 32,
			party: true,
			func: (charA, charB) -> {
				var charB = charB;
				var charA = charA;
				events[eventName].push(() -> doTextStuff("* Ralsei casts Heal Prayer.", false, true, "default", null, 0.05));
				events[eventName].push(() -> {
					charA.playAnim("spell", true);
					new FlxTimer().start(framesDuration(12, 2), () -> FlxTween.tween(charB.colorTransform, {redOffset: 255, greenOffset: 255, blueOffset: 255}, framesDuration(12, 5), {ease: FlxEase.quadIn, onComplete: handleEvent}));
				});
				events[eventName].push(() -> {
					charB.heal(charA.magic * 5);
					charA.playAnim("spellend", true);
					FlxTween.tween(charB.colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0}, 0.32, {ease: FlxEase.quadOut, onComplete: handleEvent});
				});
				events[eventName].push(() -> {
					conditionFunction = () -> {
						if(keys.ACCEPT) {
							endDialouge(false);
							return true;
						}
					}
				});
			},
		},
	],
	// visual stuff
	color: [0, 255, 0],
    damageColor: [128, 255, 128],
    attackBarColor: [181, 230, 29],
    attackBoxColor: [0, 128, 0],
    actColor: [0.5, 1, 0.5],
	icon: "ralsei",
	spritesheet: "characters/ralsei",
	scale: 4,
	animations: [
		{
			name: "idle",
			prefix: "idle",
			fps: 12,
			loop: true,
			endFrame: 5,
		},
		{
			name: "dead",
			prefix: "dead",
			fps: 1,
			loop: true,
		},
		{
			name: "attackprep",
			prefix: "attackprep",
			fps: 1,
			loop: true,
			offset: [0, 10],
		},
		{
			name: "actprep",
			prefix: "actprep",
			fps: 4,
			loop: true,
		},
		{
			name: "itemprep",
			prefix: "itemprep",
			fps: 4,
			loop: true,
		},
		{
			name: "spellprep",
			prefix: "spellprep",
			fps: 12,
			loop: true,
			offset: [0, 5],
		},
		{
			name: "spell",
			prefix: "spell",
			fps: 12,
			loop: false,
			offset: [0, 5],
			indices: [0,1,2,3,4,5,6,7],
		},
		{
			name: "attack",
			prefix: "attack",
			fps: 24,
			loop: false,
			offset: [0, 10],
		},
		{
			name: "defend",
			prefix: "defend",
			fps: 12,
			loop: false,
		},
		{
			name: "hurt",
			prefix: "hurt",
			fps: 1,
			loop: false,
		},
		{
			name: "swordjump",
			prefix: "swordjump",
			fps: 12,
			loop: true,
		},
		{
			name: "battlestart",
			prefix: "battlestart",
			fps: 12,
			loop: false,
		},
		{
			name: "victory",
			prefix: "victory",
			fps: 12,
			loop: false,
		},
		{
			name: "u_idle",
			prefix: "walk_overworld_up",
			fps: 12,
			loop: true,
			indices: [0],
		},
		{
			name: "r_idle",
			prefix: "walk_overworld_right",
			fps: 12,
			loop: true,
			indices: [0],
		},
		{
			name: "d_idle",
			prefix: "walk_overworld_down",
			fps: 12,
			loop: true,
			indices: [0],
		},
		{
			name: "l_idle",
			prefix: "walk_overworld_left",
			fps: 12,
			loop: true,
			indices: [0],
		},
		{
			name: "u_walk",
			prefix: "walk_overworld_up",
			fps: 6,
			loop: true,
			endFrame: 3,
		},
		{
			name: "r_walk",
			prefix: "walk_overworld_right",
			fps: 6,
			loop: true,
			endFrame: 3,
		},
		{
			name: "d_walk",
			prefix: "walk_overworld_down",
			fps: 6,
			loop: true,
			endFrame: 3,
		},
		{
			name: "l_walk",
			prefix: "walk_overworld_left",
			fps: 6,
			loop: true,
			endFrame: 3,
		},
	],
});
script_return(character);