import deltaflixel.options.OptionText;

var list:FlxTypedGroup<OptionText> = [
	new OptionText("[ GRAPHICS N' PERFORMANCE ]"),
	new OptionText("30 FPS", "bool", null, DeltaFlixelOptions.data, "thirtyLags"),
	#if mobile
		new OptionText("[ TOUCH CONTROLS ]"),
		new OptionText("Opacity", "float", {min: 0, max: 1, step: 0.1}, DeltaFlixelOptions.data, "buttonOpacity"),
		new OptionText("Color", "string", ["Monster","Determination","Integrity","Perseverance","Patience","Kindness","Justice","Bravery"], DeltaFlixelOptions.data, "soul"),
		new OptionText("Edit Controls", null, () -> {
			persistentUpdate = !(persistentDraw = true);
			openSubState(new ModSubState("ControlsEditorSubState"));
		}),
	#end
];

var realListFunny:FlxTypedGroup<OptionText> = [];

var curSelected:Int = 0;
var soul:FlxSprite;

function create(){
	animDepths = new FlxSprite();
    animDepths.frames = Paths.getSparrowAtlas('menus/goner');
	animDepths.animation.addByPrefix('hoooooolyshit', 'woaoooh', 24, true);
    animDepths.animation.play('hoooooolyshit');
	animDepths.scale.set(2.2, 2.2);
	animDepths.updateHitbox();
	animDepths.screenCenter();
	animDepths.antialiasing = true;
    add(animDepths);
	for (i=>text in list) {
		if (text.type == "int" || text.type == "float" || text.type == "string" || text.type == "bool" || text.func != null) realListFunny.push(text);
		add(text);
	}
	soul = new FlxSprite(-150,10).loadGraphic(Paths.image('ui/soul'));
	soul.scale.set(3, 3);
	soul.updateHitbox();
	add(soul);
}

function changeSelection(number:Int = 0){
	curSelected = FlxMath.wrap(curSelected + number, 0, realListFunny.length-1);
	playSound("menu/scroll", true);
}

function update(e:Float) {
	var sel = realListFunny[curSelected];
	
	soul.x = lerp(soul.x, 10, 0.1);
	soul.y = lerp(soul.y, sel.y, 0.1);
	
	for (i=>text in list) {
		text.update();
		if (text.type == "int" || text.type == "float" || text.type == "string" || text.type == "bool" || text.func != null) text.x = 74;
		else text.screenCenter(FlxAxes.X);
		text.y = 30 + (50*i);
	}
	
	for (i=>text in realListFunny) text.color = (i == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
	
	if (keys.UP_P)
		changeSelection(-1);
	
	if (keys.DOWN_P)
		changeSelection(1);
	
	if (sel.type == "int" || sel.type == "float" || sel.type == "string") {
		if (keys.LEFT_P)
			sel.stepNum(-1);
		if (keys.RIGHT_P)
			sel.stepNum(1);
	}
			
	if ((keys.LEFT_P || keys.RIGHT_P) && sel.type == "bool")
		sel.swapBool();
		
	if (keys.ACCEPT && sel.type != "int" && sel.type != "float" && sel.type != "string" && sel.func != null)
		sel.func();
		
	if (keys.BACK) {
		DeltaFlixelOptions.flush();
		FlxG.switchState(new ModState("Menu"));
	}
}