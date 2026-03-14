class DeltaEnemy extends FunkinSprite
{

	// battle
	public var name = "";
	public var hp = 0;
	public var maxHP = 0;
	public var acts:Map<String, Array> = [];
	public var spare = 0;
	public var shake = 0;
	public var tweened = false;
	
	public function new(_name, _spritesheet, _animations, _scale, _hp, _acts) { 
		super();
		name = _name;
		hp = _hp;
		maxHP = _hp;
		acts = _acts;
		frames = Paths.getFrames(_spritesheet);
		scale.set(_scale,_scale);
		for (anim in _animations) {
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
	
	public function spare(v, ?removeSound:Bool = false) {
		var s = v;
		if(v > (spare + v)) s -= ((spare + v) - 100);
		spare += s;
		if(!removeSound) playSound((spare + s) >= 100 ? "finalSpare" : "spare");
	}
	
	public function heal(v, ?removeSound:Bool = false) {
		hp += v;
		if(!removeSound) playSound("heal");
	}
	
	public function hurt(v, ?removeSound:Bool = false, ?customShake:Int = 10) {
		hp -= v;
		playAnim("hurt");
		if(!removeSound) playSound("damage");
		shake = customShake;
	}
}