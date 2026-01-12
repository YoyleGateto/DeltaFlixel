class FightBox extends FlxSprite
{
	public var accuracy = 0;
	public var canUpdate = false;
	public var canPress = false;
	public var pressed = false;
	public var icon:FlxSprite;
	public var boxBar:FlxSprite;
	public var bar:FlxSprite;
	public var barAlpha:Float = 1;
	public var character:DeltaCharacter;
	public function new(x, y, char)
	{
		super(x,y);
		character = char;
		loadGraphic(Paths.image('ui/battle/fightBox'));
		scale.set(2,2);
		updateHitbox();
		icon = new FlxSprite();
		icon.scale.set(2.5,2.5);
		boxBar = new FlxSprite().loadGraphic(Paths.image('ui/battle/fightBoxBar'));
		boxBar.scale.set(2,2);
		boxBar.updateHitbox();
		bar = new FlxSprite().loadGraphic(Paths.image('ui/battle/fightBar'));
		bar.scale.set(2,2);
		bar.updateHitbox();
	}
	
	public function resetX()
		bar.offset.x = 0;
		
	public function update(keyPress)
	{
		icon.loadGraphic(Paths.image('ui/battle/icons/' + character.icon));
		icon.updateHitbox();
		for (spr in [icon, boxBar, bar]) {
			if(spr.alpha != alpha) spr.alpha = alpha;
			if(spr.visible != visible) spr.visible = visible;
			if(spr.cameras != cameras) spr.cameras = cameras;
			if(spr.camera != camera) spr.camera = camera;
		}
		boxBar.color = character.attackBarColor;
		color = character.attackBoxColor;
		bar.alpha = alpha*barAlpha;
		icon.setPosition(x-100,y);
		boxBar.setPosition(x+4,y+4);
		bar.setPosition(x+width,y+4);
		if (canUpdate) {
			accuracy = reverseMin(bar.offset.x/width, 1);
			if (keyPress && bar.offset.x >= 50 && canPress && !pressed)
				pressed = true;
			if (bar.offset.x >= (width+75)) {
				accuracy = 0;
				pressed = true;
				canUpdate = false;
				canPress = false;
			}
			if (pressed) {
				if (barAlpha > 0)
					barAlpha -= 0.1;
				bar.scale.x += 0.1;
				bar.scale.y += 0.1;
			}else{
				bar.offset.x += 150 / getFPS();
				barAlpha = 1;
				bar.scale.set(2,2);
			}
		}
	}
}