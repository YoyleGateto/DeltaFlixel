class WaveSprite extends FlxSprite
{
    public var lines:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
    public var sinOffset:Float = 10; 
    
    public function new(?x:Float = 0.0, ?y:Float = 0.0, ?dehGraphic) {
        super(x, y, dehGraphic);
        if (graphic != null) graphicLoaded();
    }
	
    public function init() {
        var state:FlxState = FlxG.state.subState != null ? FlxG.state.subState : FlxG.state;
		state.add(lines); 
	}
	
    public function destroy() {
        lines.destroy();
        super.destroy();
	}
	
	public function update(?elapsed)
	{
		visible = false;
        for (i=>spr in lines.members) {
            spr.alpha = alpha;
            spr.visible = true;
            spr.cameras = cameras;
            spr.color = color;
            spr.scale = scale;
            spr.x = x;
            spr.y = y + i;
			spr.offset.x = offset.x + (Math.sin((FlxG.game.ticks + (100 * i)) / 500) * sinOffset);
            spr.offset.y = offset.y;
		}
	}
	
    override function graphicLoaded() {
        super.graphicLoaded();
		lines.clear(); 
        if (graphic == null || graphic.height == 0) return;
		for (i in 0...graphic.height) {
			var spr = new FlxSprite();
            spr.loadGraphic(graphic, true, graphic.width, 1); 
            spr.animation.add('row', [i]);
			spr.animation.play('row');
			spr.visible = false;
			lines.add(spr);
		}
	}
	override public function updateHitbox() {
        super.updateHitbox(); 
        lines.forEach(function(spr:FlxSprite) {
            spr.updateHitbox();
        });
	}
}
