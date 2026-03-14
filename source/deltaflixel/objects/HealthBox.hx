class HealthBox extends FlxSprite {
	var character:DeltaCharacter;
	var boxBehindOverlay:FlxSprite;
	var boxOverlay:FlxSprite;
	var hpBar:FlxBar;
	var hpText:FlxText;
	var hpMax:FlxText;
	var name:FunkinBitmapText;
	var icon:FlxSprite;
	var tween:FlxTween;
	var enableColor:Bool = true;
	
	public function new(X, Y, Character) {
		super(X, Y);
		character = Character;
		
		boxBehindOverlay = new FlxSprite(X, Y).loadGraphic(Paths.image("ui/battle/thingBelowActiveBox"));
		boxBehindOverlay.scale.set(2,2);
		boxBehindOverlay.updateHitbox();
		
		loadGraphic(Paths.image("ui/battle/activeBox"));
		scale.set(2,2);
		updateHitbox();
		
		boxOverlay = new FlxSprite(X, Y).loadGraphic(Paths.image("ui/battle/hpBoxOverlay"));
		boxOverlay.scale.set(2,2);
		boxOverlay.updateHitbox();
		
		hpBar = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, 152, 18, null, "", 0, 1);
		
		hpText = new FlxText();
		hpText.setFormat(Paths.font("small.ttf"), 29, FlxColor.WHITE, "right");
		hpText.fieldWidth = 158*2;
		
		hpMax = new FlxText();
		hpMax.setFormat(Paths.font("small.ttf"), 29, FlxColor.WHITE, "right");
		hpMax.fieldWidth = 60;
		
		name = new FunkinBitmapText(0, 0, "name", " ABCDEFGHIJKLMNOPQRSTUVWXYZ", 11, 18, "", 2);
		
		icon = new FlxSprite();
	}
	
	public function update(?elapsed)
	{
		for (spr in [boxBehindOverlay, boxOverlay, hpBar, hpText, hpMax, name, icon]) {
			if(spr.alpha != alpha) spr.alpha = alpha;
			if(spr.visible != visible) spr.visible = visible;
			if(spr.cameras != cameras) spr.cameras = cameras;
			if(spr.camera != camera) spr.camera = camera;
		}
		boxOverlay.x = boxBehindOverlay.x = x;
		boxOverlay.y = y;
		color = enableColor ? character.color : FlxColor.WHITE;
		boxBehindOverlay.color = character.color;
		if (!enableColor) boxBehindOverlay.visible = false;
		if (icon != null) {
			icon.loadGraphic(Paths.image("ui/battle/icons/" + character.icon));
			icon.scale.set(2.1, 2.1);
			icon.updateHitbox();
			icon.x = x + 24;
			icon.y = y + 18;
		}
		if (name != null) {
			name.text = character.name.toUpperCase();
			name.updateHitbox();
			name.y = y + 24;
			name.x = x + 105;
		}
		if (hpBar != null) {
			hpBar.createFilledBar(0xFFAA0000, character.color);
			hpBar.value = character.hp/character.maxHP;
			hpBar.x = x + 256;
			hpBar.y = y + 42;
		}
		if (hpText != null) {
			hpText.text = character.hp;
			hpText.color = character.hp <= 0 ? FlxColor.RED : (character.hp <= character.maxHP/4 ? FlxColor.YELLOW : FlxColor.WHITE);
			hpText.x = x + 5;
			hpText.y = y + 8;
		}
		if (hpMax != null) {
			hpMax.text = character.maxHP;
			hpMax.color = character.hp <= 0 ? FlxColor.RED : (character.hp <= character.maxHP/4 ? FlxColor.YELLOW : FlxColor.WHITE);
			hpMax.x = x + (176*2);
			hpMax.y = y + 8;
		}
	}
}