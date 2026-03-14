import funkin.backend.utils.ShaderResizeFix;
import funkin.options.Options;
import funkin.backend.system.framerate.Framerate;
import openfl.text.TextFormat;
import deltaflixel.mobile.Joystick;
import deltaflixel.mobile.Button;
import openfl.system.Capabilities;
import flixel.util.FlxSave;
import funkin.backend.assets.ModsFolder;

importScript("data/scripts/EventSystem");

public static var DeltaFlixelOptions:FlxSave;
public static var DeltaFlixelControls:FlxSave;
public static var gameSaves:Array<FlxSave> = [];
public static var currentSave:Int = 0;

var redirectStates:Map<FlxState, String> = [
	//BetaWarningState => "Play",
	TitleState => "Play",
];

public static var keys:Dynamic = {
	UP: false,
	DOWN: false,
	LEFT: false,
	RIGHT: false,
	UP_P: false,
	DOWN_P: false,
	LEFT_P: false,
	RIGHT_P: false,
	ACCEPT: false,
	ACCEPT_HOLD: false,
	BACK: false,
	BACK_HOLD: false,
	MENU: false,
	MENU_HOLD: false,
};

static var buttonVisible = true;

var defaultSettings = [
	"thirtyLags" => false,
	"buttonOpacity" => 0.5,
	"soul" => "Monster",
];

public static var buttonPositions = [];

function new() {
	DeltaFlixelOptions = new FlxSave();
	DeltaFlixelOptions.bind("deltaflixel");
	DeltaFlixelControls = new FlxSave();
	DeltaFlixelControls.bind("deltaflixel_mobile");
	for (i in 0...3) {
		save = new FlxSave();
		save.bind(ModsFolder.currentModFolder + "_save_" + i);
		gameSaves.push(save);
	}
	for (key in defaultSettings.keys()) if (!Reflect.hasField(DeltaFlixelOptions.data, key))
		Reflect.setField(DeltaFlixelOptions.data, key, defaultSettings[key]);
	setGameResolution(1280, 960);
	buttonPositions = [
		"joystick" => [100, FlxG.height-460],
		"accept" => [FlxG.width - 400, FlxG.height-260],
		"back" => [FlxG.width - 300, FlxG.height-460],
		"menu" => [FlxG.width - 200, FlxG.height-260],
	];
	for (key in buttonPositions.keys()) if (!Reflect.hasField(DeltaFlixelControls.data, key))
		Reflect.setField(DeltaFlixelControls.data, key, buttonPositions[key]);
}

function preStateSwitch() {
    for (redirectState in redirectStates.keys())
        if (FlxG.game._requestedState is redirectState)
            FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
}

var joystick:Joystick;
var acceptButton:Button;
var backButton:Button;
var menuButton:Button;
public static var mobileCam:FlxCamera;
function postStateSwitch() {
	mobileCam = new FlxCamera();
    FlxG.cameras.add(mobileCam, false).bgColor = 0;
	joystick = new Joystick(100, FlxG.height-460, 1280, "ui/mobile/joystick", "ui/mobile/joystick");
	joystick.scale.set(2,2);
	acceptButton = new Button(FlxG.width - 400, FlxG.height-260, "ui/mobile/z");
	backButton = new Button(FlxG.width - 300, FlxG.height-460, "ui/mobile/x");
	menuButton = new Button(FlxG.width - 200, FlxG.height-260, "ui/mobile/c");
	joystick.startJoystick();
	joystick.camera = mobileCam;
	updateControlsPosition();
    for (btn in [acceptButton, backButton, menuButton]) FlxG.state.add(btn).camera = mobileCam;
    Framerate.codenameBuildField.visible = Framerate.memoryCounter.memoryPeakText.visible = Framerate.memoryCounter.memoryText.visible = false;
	Framerate.fpsCounter.fpsNum.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('PixelOperator-Bold.ttf')), 40, FlxColor.WHITE);
	Framerate.fpsCounter.fpsLabel.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('PixelOperator-Bold.ttf')), 40, FlxColor.WHITE);
}

function update() {
	if (FlxG.keys.justPressed.F2) buttonVisible = !buttonVisible;
	if (FlxG.keys.justPressed.F3) FlxG.resetState();
	if (FlxG.keys.justPressed.F4) ModsFolder.switchMod(ModsFolder.currentModFolder);
	for (btn in [acceptButton, backButton, menuButton, joystick]) {
		btn.update();
		btn.alpha = DeltaFlixelOptions.data.buttonOpacity;
		btn.color = switch (DeltaFlixelOptions.data.soul) {
			default: FlxColor.WHITE;
			case "Determination": FlxColor.RED;
			case "Integrity": FlxColor.BLUE;
			case "Perseverance": FlxColor.PURPLE;
			case "Patience": FlxColor.CYAN;
			case "Kindness": FlxColor.GREEN;
			case "Justice": FlxColor.YELLOW;
			case "Bravery": FlxColor.ORANGE;
		}
		if (btn != joystick) btn.buttonColor = btn.color;
		#if mobile
			btn.visible = buttonVisible;
		#else
			btn.visible = false;
		#end
	}
	keys.UP = FlxG.keys.pressed.UP || joystick.UP;
	keys.DOWN = FlxG.keys.pressed.DOWN || joystick.DOWN;
	keys.LEFT = FlxG.keys.pressed.LEFT || joystick.LEFT;
	keys.RIGHT = FlxG.keys.pressed.RIGHT || joystick.RIGHT;
	keys.UP_P = FlxG.keys.justPressed.UP || joystick.UP_P;
	keys.DOWN_P = FlxG.keys.justPressed.DOWN || joystick.DOWN_P;
	keys.LEFT_P = FlxG.keys.justPressed.LEFT || joystick.LEFT_P;
	keys.RIGHT_P = FlxG.keys.justPressed.RIGHT || joystick.RIGHT_P;
	keys.ACCEPT = acceptButton.justPressed || FlxG.keys.justPressed.Z;
	keys.ACCEPT_HOLD = acceptButton.pressed || FlxG.keys.pressed.Z;
	keys.BACK = backButton.justPressed || FlxG.keys.justPressed.X;
	keys.BACK_HOLD = backButton.pressed || FlxG.keys.pressed.X;
	keys.MENU = menuButton.justPressed || FlxG.keys.justPressed.C;
	keys.MENU_HOLD = menuButton.pressed || FlxG.keys.pressed.C;
	FlxG.set_updateFramerate(DeltaFlixelOptions.thirtyLags ? 30 : 60);
	FlxG.set_drawFramerate(DeltaFlixelOptions.thirtyLags ? 30 : 60);
}

function destroy() {
	#if mobile
		joystick.stopJoystick();
		for (btn in [acceptButton, backButton, menuButton, joystick]) btn.destroy();
	#end
	FlxG.set_updateFramerate(Options.framerate);
	FlxG.set_drawFramerate(Options.framerate);
	setGameResolution(1280, 720);
}

public static function setGameResolution(width:Int, height:Int){
    FlxG.resizeWindow(width, height);
    FlxG.resizeGame(width, height);
    FlxG.scaleMode.width = FlxG.width = FlxG.initialWidth = width;
    FlxG.scaleMode.height = FlxG.height = FlxG.initialHeight = height;
    ShaderResizeFix.doResizeFix = true;
    ShaderResizeFix.fixSpritesShadersSizes();
}

// utils

public static function playSound(path, ?force:Bool = false) {
	var sound = FlxG.sound.load(Paths.sound(path));
	sound.play(force);
	return sound;
}

var musicID:String = "";
public static function playMusic(path, ?volume:Float = 1, ?loop:Bool = false, ?force:Bool = false) if (musicID != path || force) {
	if (FlxG.sound.music != null) FlxG.sound.music.stop();
	FlxG.sound.playMusic(Paths.music(path), volume, loop);
	musicID = path;
}

public static function updateControlsPosition() {
	btnPos = DeltaFlixelControls.data;
	joystick.setPosition(btnPos.joystick[0], btnPos.joystick[1]);
	acceptButton.setPosition(btnPos.accept[0], btnPos.accept[1]);
	backButton.setPosition(btnPos.back[0], btnPos.back[1]);
	menuButton.setPosition(btnPos.menu[0], btnPos.menu[1]);
}

public static function reverseMin(v, max) if(v > max) return max + (max - v); else return v;

public static function getFPS() return Math.floor(FlxG.rawElapsed == 0 ? 30 : (1 / FlxG.rawElapsed));

public static function getIDFromString(string, array) for (i=>string2 in array) if (string2 == string) return i;

public static function framesDuration(fps, frames) return (1 / fps) * frames;

static var returnVar = null;
public static function require(path) {
	importScript(path);
	if (returnVar != null) {
		var v = returnVar;
		returnVar = null;
		return v;
	}
}
public static function script_return(v) returnVar = v;