function getColorFromRGBArray(c) return FlxColor.fromRGB(c[0], c[1], c[2]);

class DeltaCharacter extends FunkinSprite
{
	public var name = "";
	public var icon = "";
	public var hp = 0;
	public var maxHP = 0;
	public var attack:Int;
	public var defense:Int;
	public var magic:Int;
	public var color = FlxColor.WHITE;
	public var actColor = FlxColor.WHITE;
	public var attackBoxColor = FlxColor.WHITE;
	public var attackBarColor = FlxColor.WHITE;
	public var damageColor = FlxColor.WHITE;
	public var choices = [0,0,0,0,0,0];
	public var canSpell = false;
	public var spells = [];
	public var shake = 0;
	
	var movementHistory = [];
	public var speed:Float = 200;
	public var facing = "down";
	public var isMoving:Bool;
	public var canMove:Bool = true;
	public var action:String = "idle";
	public var hsp:Float = 0;
	public var vsp:Float = 0;
	
	var overworldX:Float;
	var overworldY:Float;
	
	public function new(data) { 
		super();
		name = data.name;
		icon = data.icon;
		hp = data.stats.hp;
		maxHP = data.hp;
		color = getColorFromRGBArray(data.color);
		actColor = getColorFromRGBArray(data.actColor);
		attackBoxColor = getColorFromRGBArray(data.attackBoxColor);
		attackBarColor = getColorFromRGBArray(data.attackBarColor);
		damageColor = getColorFromRGBArray(data.damageColor);
		attack = data.stats.attack;
		defense = data.stats.defense;
		canSpell = data.canSpell;
		if(canSpell) {
			spells = data.spells;
			magic = data.stats.magic;
		}
		frames = Paths.getFrames(data.spritesheet);
		scale.set(data.scale,data.scale);
		for (anim in data.animations) {
			var autoIndices = [];
			if (anim.endFrame != null) for (i in 0...(anim.endFrame + 1))
				autoIndices.push(i);
			addAnim(anim.name, anim.prefix, anim.fps, anim.loop, false, anim.indices == null ? autoIndices : anim.indices);
			if (anim.offset != null)
				addOffset(anim.name, anim.offset[0], anim.offset[1]);
			else
				addOffset(anim.name, 0,0);
		}
		playAnim('idle');
		updateHitbox();
	}
	public function overworldUpdate(parent){
		overworldX = x;
		overworldY = y;
		
		if (parent == null) {
			var temp_speed = speed;
			
			var up = keys.UP;
			var down = keys.DOWN;
			var left = keys.LEFT;
			var right = keys.RIGHT;
	
			if (keys.BACK_HOLD && action == "walk"){ 
				temp_speed += 100;
				animation.timeScale = 1.5;
			}
			else animation.timeScale = 1.0;
			if (up || down || left || right) {
				if (up && down)
					up = down = false;
				if (left && right)
					left = right = false;
			}
			if(canMove && (up || down || left || right)){
				var temp_hsp:Float = 0;
				var temp_vsp:Float = 0;
				if (up){
					temp_vsp = -temp_speed;
					facing = 'up';
					if (left) temp_hsp = -temp_speed;
					else if (right) temp_hsp = temp_speed;	
				} else if (down){
					temp_vsp = temp_speed;
					facing = 'down';
					if (left) temp_hsp = -temp_speed;
					else if (right) temp_hsp = temp_speed;	
				} else if (left){
					temp_hsp = -temp_speed;
					facing = 'left';
				} else if (right){
					temp_hsp = temp_speed;	
					facing = 'right';
				}
				hsp = temp_hsp;
				vsp = temp_vsp;
			}
			x += hsp / getFPS();
			y += vsp / getFPS();
			action = (hsp != 0 || vsp != 0) ? "walk" : "idle";
			isMoving = (hsp != 0 || vsp != 0);
			hsp = vsp = 0;
		} else {
			if (parent.movementHistory.length > 30) {
				isMoving = true;
				var movement = parent.movementHistory.shift();
				facing = movement.facing;
				action = movement.action;
				animation.timeScale = movement.timeScale;
				x = movement.x;
				y = movement.y;
			} else {
				action = "idle";
				isMoving = false;
			}
		}
		if (isMoving) {
			movementHistory.push({
				x: this.x,
				y: this.y,
				facing: this.facing,
				action: this.action,
				timeScale: animation.timeScale,
			});
		}
		switch (facing)
		{
			case 'left':
				playAnim('l_' + action);
			case 'right':
				playAnim("r_" + action);
			case 'up':
				playAnim("u_" + action);
			case 'down':
				playAnim("d_" + action);
			default:
		}
	}
	
	public function heal(v, ?removeSound:Bool = false) {
		hp += v;
		if(!removeSound) playSound("heal");
	}
	
	public function hurt(v, ?removeSound:Bool = false, ?customShake:Int = 10) {
		hp -= v;
		playAnim("hurt");
		if(!removeSound) playSound("hurt");
		shake = customShake;
	}
}