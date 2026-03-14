import funkin.menus.ModSwitchMenu;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.text.FlxTextBorderStyle;
import flixel.FlxCamera.FlxCameraFollowStyle;
import haxe.io.Path;
import openfl.text.TextField;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.ui.FlxBar;
import FunkinBitmapText;
import deltaflixel.objects.DeltaCharacter;
import deltaflixel.objects.DeltaEnemy;
import deltaflixel.objects.BattleButton;
import deltaflixel.objects.FightBox;
import deltaflixel.objects.HealthBox;

scripts = Reflect.hasField(data, "scripts") ? data.scripts : "none";
_characters = Reflect.hasField(data, "characters") ? data.characters : "none";
_enemies = Reflect.hasField(data, "enemies") ? data.enemies : "none";

public var dialougeStartupText:String;

public var characters:Array = [];
public var enemies:Array = [];

var enemy_x:Float;
var player_x:Float = 275;

var turn:Int = 0;
var state = "actions";
var textOptionCase = "";

var timerThatRunsWhenTheFightThingEnds:FlxTimer;

var hpBar:FlxBar;
var tpBar:FlxBar;

public var overworldBack = new FlxCamera(0, 0, FlxG.width, FlxG.height);
public var overworldFront = new FlxCamera(0, 0, FlxG.width, FlxG.height);
public var camUI = new FlxCamera(0, 0, FlxG.width, FlxG.height);
for (u in [overworldBack, overworldFront, camUI]) {
	u.bgColor = 0;
	FlxG.cameras.add(u, false);
}

public var tensionPoints:Float = 0;

public var undos:Array<Float> = [];
public var char_acts:Array = [];

var fightTurn = 0;
var curAction:Int = 0;
var curSel:Int = 0;
var targetCharacter:Int = 0;
var menuItems:Array<String> = ["fight", "act", "item", "spare", "defend"];
var groupMenuItems:FlxTypedGroup = [];
var textOptions:FlxTypedGroup = [];
var fightBoxes:FlxTypedGroup = [];
var healthBoxes:FlxTypedGroup = [];

public var gridBack:FlxBackdrop;
public var grid:FlxBackdrop;

public function doTextOptions(stuff) {
	curSel = 0;
	for (that in textOptions)
		remove(that.obj, true);
	textOptions = [];
	if (stuff != null) {
		for (daOption in stuff) {
			text = new FlxText(70, hudBase.y + 95, 0, daOption.text).setFormat(Paths.font("main.ttf"), 55, FlxColor.WHITE, "center");
			text.cameras = [camUI];
			textOptions.push({obj: text, data: daOption});
			add(text);
		}
	}
}

function create() {
	
	enemy_x = FlxG.width - 320;
	
	gridBack = new FlxBackdrop(Paths.image("deltaruneBackground"));
	gridBack.velocity.set(-gridBack.width/2, -gridBack.height/2);
	gridBack.alpha = 0.5;
	gridBack.cameras = [overworldBack];
	add(gridBack);
	
	grid = new FlxBackdrop(Paths.image("deltaruneBackground"));
	grid.velocity.set(grid.width/2, grid.height/2);
	grid.cameras = [overworldBack];
	add(grid);
	
	tpBar = new FlxBar(0, 0, FlxBarFillDirection.RIGHT_TO_LEFT, 859, 100, null, "", 0, 100);
	tpBar.createImageBar(Paths.image("ui/battle/tpBar_empty"), Paths.image("ui/battle/tpBar_filled"));
	tpBar.setPosition(-320,250);
	tpBar.angle = 90;
	tpBar.scale.set(0.5, 0.6);
	tpBar.antialiasing = false;
	tpBar.numDivisions = 500;
	tpBar.cameras = [camUI];
	add(tpBar);
	
	tpLabel = new FlxSprite().loadGraphic(Paths.image("ui/battle/tp"));
	tpLabel.scale.set(2,2);
	tpLabel.updateHitbox();
	tpLabel.setPosition(30, 150);
	tpLabel.cameras = [camUI];
	add(tpLabel);
	
	tpText = new FlxText(35, tpLabel.y + 90);
	tpText.setFormat(Paths.font("main.ttf"), 56, FlxColor.WHITE, 0, FlxTextBorderStyle.OUTLINE, 0xFF000000);
	tpText.borderSize = 3;
	tpText.borderQuality = 1;
	tpText.fieldWidth = tpBar.x;
	tpText.cameras = [camUI];
	add(tpText);
	
	hudBase = new FlxSprite().loadGraphic(Paths.image("ui/battle/base"));
	hudBase.scale.set(FlxG.width,1.25);
	hudBase.updateHitbox();
	hudBase.y = FlxG.height - hudBase.height;
	hudBase.cameras = [camUI];
	add(hudBase);
	
	for (i in 0...menuItems.length) {
		item = new BattleButton(0,0,menuItems[i],2);
		item.cameras = [camUI];
		groupMenuItems.push(item);
		add(item);
	}
	
	dialouge = new FlxText();
	dialouge.setFormat(Paths.font("main.ttf"), 56, FlxColor.WHITE, "left");	dialouge.fieldWidth = FlxG.width - (dialouge.x+45);
	dialouge.text = "* Cheezborger";
	dialouge.cameras = [camUI];
	add(dialouge);
	
	portrait = new FlxSprite(35, hudBase.y + 75);
	portrait.cameras = [camUI];
	portrait.visible = false;
	add(portrait);
	
	textOptHP = new FlxBar(10,10, FlxBar.FILL_LEFT_TO_RIGHT, 200, 50, null, "", 0, 1);
	textOptHP.cameras = [camUI];
	textOptHP.createFilledBar(0xFFAA0000, 0xFF00FF00);
	add(textOptHP);
	
	textOptHPText = new FlxText(13, 13);
	textOptHPText.setFormat(Paths.font("main.ttf"), 50, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	textOptHPText.cameras = [camUI];
	textOptHPText.borderSize = 3;
	add(textOptHPText);
	
	textOptSpare = new FlxBar(FlxG.width - 210, 20, FlxBar.FILL_LEFT_TO_RIGHT, 200, 50, null, "", 0, 1);
	textOptSpare.cameras = [camUI];
	textOptSpare.createFilledBar(0xFFAA0000, 0xFFFFF00);
	add(textOptSpare);
	
	textOptSpareText = new FlxText(FlxG.width - 197, 23).setFormat(Paths.font("main.ttf"), 50, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	textOptSpareText.cameras = [camUI];
	textOptSpareText.borderSize = 3;
	add(textOptSpareText);
	
	textOptDescription = new FlxText(FlxG.width - 250, hudBase.y + 90, 250).setFormat(Paths.font("main.ttf"), 50, FlxColor.GRAY, "left");
	textOptDescription.cameras = [camUI];
	textOptDescription.borderSize = 3;
	add(textOptDescription);
	
	textOptTP = new FlxText(FlxG.width - 250, FlxG.height - 60, 250).setFormat(Paths.font("main.ttf"), 50, FlxColor.ORANGE, "left");
	textOptTP.cameras = [camUI];
	textOptTP.borderSize = 3;
	add(textOptTP);
	
	soul = new FlxSprite(0,0).loadGraphic(Paths.image("ui/soul"));
	soul.scale.set(3, 3);
	soul.updateHitbox();
	soul.cameras = [camUI];
	add(soul);
	
	if (_characters != "none") 
		characters = _characters;
	else {
		characters = [
			require("data/chars/kris"),
			require("data/chars/susie"),
			require("data/chars/ralsei"),
		];
	}
	
	if (_enemies != "none") 
		enemies = _enemies;
	else {
		enemies = [
			require("data/enemies/cheese"),
		];
	}
	
	eventName = "startup";
	events[eventName] = [
		() -> doTextStuff(dialougeStartupText == null ? "* Wait, what?!|w|w|w\nNow in Friday Night Funkin?!|w|w|w\nGOD, Seek for some mental help!" : dialougeStartupText, false, true, "default", null, 0.05),
	];
	handleEvent();
	
	for (i=>character in characters) {
		character.y = 150 + ((400/characters.length) * (characters.length < 2 ? 0.25 : i));
		character.camera = overworldFront;
		add(character);
		undos.push(0);
		char_acts.push("");
		var box = new FightBox(120, (hudBase.y+75) + 75*i, character);
		for (spr in [box, box.icon, box.boxBar, box.bar]) add(spr);
		box.camera = camUI;
		fightBoxes.push(box);
		var hpBox = new HealthBox((FlxG.width / 2) - (((characters.length / 2) - i) * 424), hudBase.y, character);
		for (spr in [hpBox, hpBox.boxOverlay, hpBox.hpBar, hpBox.hpText, hpBox.hpMax, hpBox.name, hpBox.icon]) add(spr);
		insert(members.indexOf(hudBase)+1, hpBox.boxBehindOverlay);
		hpBox.camera = camUI;
		healthBoxes.push(hpBox);
	}
	for (i=>enemy in enemies) {
		enemy.camera = overworldFront;
		enemy.y = 150 + ((400/enemies.length) * (enemies.length < 2 ? 0.25 : i));
		add(enemy);
	}
	
	playMusic("RudeBuster", 0.5, true, true);
	
	if (scripts != "none") for (path in scripts) importScript(path);
	
	updateHealthBoxes();
	
	for (box in fightBoxes) {
		if(box.canUpdate) box.canUpdate = false;
		if(box.visible) box.visible = false;
	}
}

public function changeAction(number:Int = 0){
	curAction = FlxMath.wrap(curAction + number, 0, menuItems.length-1);
	playSound("menu/scroll", true);
}

public function changeSel(number:Int = 0){
	curSel = FlxMath.wrap(curSel + number, 0, textOptions.length-1);
	playSound("menu/scroll", true);
}

function update() {
	dialouge.fieldWidth = FlxG.width - (45 - dialouge.offset.x);
	if (keys.MENU) FlxG.resetState();
	if (state != "enemyAttack")
		targetCharacter = turn;
	tensionPoints = FlxMath.bound(tensionPoints, 0, 100);
	targetCharacter = FlxMath.bound(targetCharacter, 0, characters.length-1);
	var hpRef = healthBoxes[targetCharacter];
	if (dialouge != null) {
		dialouge.setPosition(50, hudBase.y + 100);
	}
	if (tpText != null) {
		if (tensionPoints >= 100) {
			tpText.text = "M\nA\nX";
			tpText.color = FlxColor.YELLOW;
		} else {
			tpText.text = Math.floor(tensionPoints) + "\n%";
			tpText.color = FlxColor.WHITE;
		}
	}
	//tpBar.value = CoolUtil.fpsLerp(tpBar.value, tensionPoints, 0.1);
	for (i=>item in groupMenuItems) {
		item.x = hpRef.x + 7 + (((hpRef.width/2) - (40*groupMenuItems.length)) + (80*i));
		item.y = hudBase.y + 15;
	}
	if (state == "actions") {
		for (i=>enemy in enemies) {
			if (enemy.hp <= 0) {
				enemies = removeFromArray(i, enemies);
			}
		}
		dialouge.visible = true;
		if (keys.BACK) {
			if (turn > 0) {
				playSound("menu/cancel", true);
				prevTurn();
			}
		}
		characters[turn].playAnim("idle", false);
		if (keys.ACCEPT) {
			if (characters[turn].hp < 0) {
				nextTurn();
				return;
			}
			playSound("menu/confirm", true);
			switch (groupMenuItems[curAction].buttonName) {
				case "fight":
					state = "select";
					textOptionCase = "fight";
					characters[turn].choices[0] = 0;
					doTextOptions(getEnemyOptions());
				case "magic":
					var spells = characters[turn].spells;
					var theRealSpells = [];
					for (spell in spells) {
						var enemyName = spell.enemySpecific ?? "";
						if(enemyName != "") {
							var canPush = false;
							for (enemy in enemies) if (enemyName == enemy.name) canPush = true;
							if(canPush) {
								spell.color = characters[turn].actColor;
								theRealSpells.push(spell);
							}
						} else theRealSpells.push(spell);
					}
					if (theRealSpells.length <= 0) return;
					state = "select";
					textOptionCase = "magic";
					characters[turn].choices[0] = 1;
					doTextOptions(theRealSpells);
				case "act":
					state = "select";
					textOptionCase = "act";
					characters[turn].choices[0] = 1;
					doTextOptions(getEnemyOptions());
				case "defend":
					characters[turn].choices[0] = 4;
					undos[turn] = 16 - ((tensionPoints + 16) - 100);
					tensionPoints += 16;
					characters[turn].playAnim("defend", false);
					nextTurn();
			}
			return;
		}
		
		if (keys.LEFT_P) {
			changeAction(-1);
		}
		
		if (keys.RIGHT_P) {
			changeAction(1);
		}
		
		for (i=>item in groupMenuItems) {
			var id = item.buttonName;
			if (id == "act" || id == "magic") item.buttonName = characters[turn].canSpell ? "magic" : "act";
			item.updateGraphic(i == curAction);
		}
	} else dialouge.visible = state == "events" || state == "win";
	if (state == "select") {
		var data = textOptions[curSel].data;
		if (data.tp == null) data.tp = 0;
		var text = textOptions[curSel].obj;
		textOptDescription.text = "";
		textOptTP.text = "";
		if (data.hp != null && data.maxHP != null) {
			textOptHP.value = FlxMath.bound(data.hp/data.maxHP, 0, 1);
			textOptHPText.text = Math.floor(FlxMath.bound(data.hp/data.maxHP, 0, 1)*100) + "%";
			textOptHP.visible = textOptHPText.visible = true;
		} else {
			textOptHP.visible = textOptHPText.visible = false;
			if (data.tp > 0)
				textOptTP.text = data.tp + "% TP";
			if (data.info != null)
				textOptDescription.text += data.info;
		}
		textOptSpare.setPosition(FlxG.width-(textOptSpare.width+10), text.y-0);
		textOptSpareText.setPosition(textOptSpare.x+3, textOptSpare.y+3);
		textOptHP.setPosition(textOptSpare.x-(textOptHP.width+30), textOptSpare.y);
		textOptHPText.setPosition(textOptHP.x+3, textOptHP.y+3);
		soul.x = text.x - 60;
		soul.y = text.y - 5;
		if (data.spare != null) {
			textOptSpare.value = FlxMath.bound(data.spare/100, 0, 1);
			textOptSpareText.text = FlxMath.bound(data.spare, 0, 100) + "%";
			textOptSpare.visible = textOptSpareText.visible = true;
		} else {
			textOptSpare.visible = textOptSpareText.visible = false;
		}
		if (keys.BACK) {
			playSound("menu/cancel", true);
			switch(textOptionCase) {
				default:
					state = "actions";
					characters[turn].choices[0] = 0;
					doTextOptions([]);
				case "magic2":
					char_acts[turn] = "";
					state = "select";
					textOptionCase = "magic";
					characters[turn].choices[2] = 0;
					doTextOptions(characters[turn].spells);
					if (undos[turn] != 0) {
						tensionPoints -= undos[turn];
						undos[turn] = 0;
					}
				case "magicPlayer":
					char_acts[turn] = "";
					state = "select";
					textOptionCase = "magic";
					characters[turn].choices[2] = characters[turn].choices[3] = 0;
					doTextOptions(characters[turn].spells);
					if (undos[turn] != 0) {
						tensionPoints -= undos[turn];
						undos[turn] = 0;
					}
				case "act2":
					state = "select";
					textOptionCase = "act";
					characters[turn].choices[1] = 0;
					doTextOptions(getEnemyOptions());
					if (undos[turn] != 0) {
						tensionPoints -= undos[turn];
						undos[turn] = 0;
					}
			}
		}
		if (keys.ACCEPT) {
			playSound("menu/confirm", true);
			switch(textOptionCase) {
				case "fight":
					characters[turn].playAnim("attackprep", true);
				case "magic2":
					characters[turn].playAnim("spellprep", true);
				case "magicPlayer":
					characters[turn].playAnim("spellprep", true);
				case "act2":
					characters[turn].playAnim("actprep", true);
			}
			switch(textOptionCase) {
				default:
					characters[turn].choices[1] = curSel;
					nextTurn();
					doTextOptions([]);
				case "act":
					characters[turn].choices[1] = curSel;
					state = "select";
					textOptionCase = "act2";
					doTextOptions(enemies[curSel].acts.get(characters[turn].name));
				case "act2":
					if (tensionPoints >= data.tp) {
						char_acts[turn] = data.func;
						tensionPoints -= data.tp;
						undos[turn] = -data.tp;
						characters[turn].choices[2] = curSel;
						nextTurn();
						doTextOptions([]);
					}
				case "magic":
					if (tensionPoints >= data.tp) {
						char_acts[turn] = data.func;
						tensionPoints -= data.tp;
						undos[turn] = -data.tp;
						characters[turn].choices[2] = curSel;
						state = "select";
						characters[turn].choices[3] = data.party ? 1 : 0;
						textOptionCase = data.party ? "magicPlayer" : "magic2";
						doTextOptions(data.party ? getPartyOptions() : getEnemyOptions());
					}
			}
			return;
		}
		soul.visible = true;
		updateTextOptions();
	} else {
		soul.visible = false;
		textOptHP.visible = textOptHPText.visible = textOptSpare.visible = textOptSpareText.visible = false;
		textOptDescription.text = "";
		textOptTP.text = "";
	}
	if (state == "FightState") {
		for (i=>box in fightBoxes) {
			box.visible = characters[i].choices[0] == 0;
			box.canUpdate = characters[i].choices[0] == 0;
			box.canPress = (i == fightTurn);
			if (characters[i].choices[0] == 0) {
				var enemy = enemies[characters[i].choices[1]];
				if (enemy.hp <= 0) characters[i].choices[0] = -1;
				if (i == fightTurn && box.pressed) {
					if (box.accuracy >= 0.95)
						box.bar.color = FlxColor.YELLOW;
					if (box.accuracy >= 0)
						tensionPoints += 24;
					playSound("slash", true);
					new FlxTimer().start(0.32, () -> {
						if (box.accuracy > 0) {
							enemy.hurt(Math.floor(((characters[i].attack*(box.accuracy*100))/20)-(3*characters[i].defense)));
							new FlxTimer().start(0.32, (tmr) -> {
								enemy.playAnim("idle", true);
							});
						}
					});
					characters[i].playAnim("attack", false);
					fightTurn += 1;
				}
			}
			if (i == fightTurn && characters[i].choices[0] != 0) fightTurn += 1;
		}
		if (fightTurn >= characters.length) {
			if (timerThatRunsWhenTheFightThingEnds == null) {
				timerThatRunsWhenTheFightThingEnds = new FlxTimer().start(1, resetTurns);
			}
		}
	}
	for (i=>character in characters) {
		if (character.x != player_x) character.x = player_x;
		if (character.shake > 0) {
			enemy.x += FlxG.random.float(-character.shake,character.shake);
			character.shake -= 0.25;
		}
		character.hp = Math.min(character.hp, character.maxHP);
	}
	for (i=>enemy in enemies) {
		if (enemy.hp <= 0) {
			if (!enemy.tweened) {
				enemy.playAnim("dead");
				new FlxTimer().start(0.5, (x) -> {
					if (enemy != null) FlxTween.tween(enemy, {x: FlxG.width*1.1}, 0.2);
				});
				enemy.tweened = true;
			}
		} else {
			enemy.tweened = false;
			if (enemy.x != enemy_x) enemy.x = enemy_x;
			if (enemy.shake > 0) {
				enemy.x += FlxG.random.float(-enemy.shake,enemy.shake);
				enemy.shake -= 0.25;
			}
		}
		enemy.hp = Math.min(enemy.hp, enemy.maxHP);
	}
	var deadChars = 0;
	for (character in characters) {
		if (character.hp <= 0) {
			character.playAnim("dead", true);
			deadChars += 1;
		}else{
			if (character.animation.name == "dead") {
				character.playAnim("idle", true);
			}
		}
	}
	if (deadChars == characters.length) FlxG.resetState();
	for (box in fightBoxes) box.update(keys.ACCEPT);
	for (box in healthBoxes) box.update();
	if (enemies.length <= 0 && state != "win") {
		eventName = "youWon";
		events[eventName] = [
			() -> doTextStuff("You won!\n0 XP - 0 D$", false, false, "default", null, 0.05),
			() -> FlxG.switchState(new ModState("Menu")),
		];
		handleEvent();
		state = "win";
		for (character in characters) character.playAnim("victory", true);
	}
}

function updateTextOptions() {
	if (keys.UP_P) changeSel(-1);
	if (keys.DOWN_P) changeSel(1);
	for (i=>o in textOptions) {
		var text = o.obj;
		text.y = (hudBase.y + 95) + (60*(i-Math.max(curSel-2,0)));
		text.offset.y = 10;
		if (o.data.color != null) text.color = o.data.color;
		else text.color = FlxColor.WHITE;
		text.visible = !(text.y < (hudBase.y + 85));
		text.alpha = (o.data.tp == null || (o.data.tp != null && tensionPoints >= o.data.tp)) ? 1 : 0.5;
	}
}

function resetTurns() {
	FlxG.state.call("onTurnsReset");
	state = "actions";
	turn = 0;
	for (character in characters) {
		character.playAnim("idle", true);
		character.choices = [0,0,0,0,0,0];
	}
	updateHealthBoxes();
	timerThatRunsWhenTheFightThingEnds = null;
	for (box in fightBoxes) {
		if(box.canUpdate) box.canUpdate = false;
		if(box.visible) box.visible = false;
	}
}

public function nextTurn() {
	turn += 1;
	updateHealthBoxes();
	if (turn >  characters.length-1)  {
		state = "events";
		eventName = "postPlayerTurn";
		events[eventName] = [];
		for (i=>character in characters) {
			var to_do = char_acts[i];
			if (to_do != ""){
				var enemy = character.choices[3] == 1 ? characters[character.choices[1]] : enemies[character.choices[1]];
				to_do(character, enemy);
				char_acts[i] = "";
			}
		}
		var fight = false;
		for (character in characters) if (character.choices[0] == 0) fight = true;
		if (fight) events[eventName].push(() -> {
			fightTurn = 0;
			for (i=>box in fightBoxes) {
				box.resetX();
				box.pressed = false;
				box.bar.offset.x -= i*125;
				box.bar.color = FlxColor.WHITE;
			}
			state = "FightState";
		});
		else events[eventName].push(() -> {
			resetTurns();
		});
		handleEvent();
	} else
		state = "actions";
}

public function prevTurn() {
	turn -= 1;
	updateHealthBoxes();
	if (undos[turn] != 0) {
		tensionPoints -= undos[turn];
		undos[turn] = 0;
	}
	char_acts[turn] = "";
	characters[turn].choices = [0,0,0,0,0,0];
	state = "actions";
}

public function getEnemyOptions() {
	var t:Array<Dynamic> = [];
	for (enemy in enemies) t.push({text: enemy.name, hp: enemy.hp, maxHP: enemy.maxHP, spare: enemy.spare});
	return t;
}

public function getPartyOptions() {
	var t:Array<Dynamic> = [];
	for (character in characters) t.push({text: character.name, hp: character.hp, maxHP: character.maxHP});
	return t;
}

public function removeFromArray(id, array) {
	var t = [];
	for (i=>stuff in array) if(i != id) 
		t.push(stuff);
	return t;
}

public function setPartyPosition(x, y, max_height) {
	player_x = x;
	for (i=>character in characters) character.y = y + ((max_height/characters.length) * (characters.length < 2 ? 0.25 : i));
}

public function setEnemiesPosition(x, y, max_height) {
	enemy_x = x;
	for (i=>enemy in enemies) enemy.y = y + ((max_height/enemies.length) * (enemies.length < 2 ? 0.25 : i));
}

function updateHealthBoxes() {
	for (i=>character in characters) {
		hpBox = healthBoxes[i];
		hpBox.boxBehindOverlay.y = hudBase.y;
		if (hpBox.tween != null) {
			hpBox.tween.cancel();
		}
		if (i == turn) {
			hpBox.tween = FlxTween.tween(hpBox, {y: hudBase.y - 76}, 0.25, { ease: FlxEase.quadOut });
			hpBox.enableColor = true;
			hpBox.loadGraphic(Paths.image("ui/battle/activeBox"));
		} else {
			hpBox.tween = FlxTween.tween(hpBox, {y: hudBase.y}, 0.25, { ease: FlxEase.quadOut });
			hpBox.enableColor = false;
			hpBox.loadGraphic(Paths.image("ui/battle/inactiveBox"));
		}
		hpBox.updateHitbox();
	}
}