import flixel.text.FlxTextBorderStyle;
import Xml;
import flixel.util.FlxSort;
import flixel.FlxObject;
import haxe.ds.StringMap;

using StringTools;

_characters = Reflect.hasField(data, "_characters") ? data._characters : "none";
public var roomName = Reflect.hasField(data, "_room") ? data._room : "test";
public var spawnID = Reflect.hasField(data, "_spawn") ? data._spawn : "main";
public var characters = [];
public var camUI = new FlxCamera(0, 0, FlxG.width, FlxG.height);
for (u in [camUI]) {
	u.bgColor = 0;
	FlxG.cameras.add(u, false);
}
public var tilesets = new StringMap();
public var tilemaps = new StringMap();
public var tilemapCollisions = new StringMap();
public var sprites = new StringMap();
public var spawnPoints = new StringMap();
public var worldBounds = [0,0,0,0];
public var roomTitle = "";
public var roomWidth = 0;
public var roomHeight = 0;
public var tileWidth = 0;
public var tileHeight = 0;
public var inCustcene = false;

function objectsOverlap(a, b) {
	var overlap = false;
	for (pos in [[a.x, a.y], [a.x+(a.width-1), a.y], [a.x, a.y+(a.height-1)], [a.x+(a.width-1), a.y+(a.height-1)]]) if (pos[0] > b.x && pos[0] < (b.x + b.width) && pos[1] > b.y && pos[1] < (b.y + b.height)) 
		overlap = true;
	return overlap;
}

function makeObjectsCollide(a, b) if (objectsOverlap(a, b)) FlxObject.separate(a, b);

public function gotoRoom(room, spawn) FlxG.switchState(new ModState("World", {
	_room: room,
	_spawn: spawn,
	_characters: characters,
}));

function create(){
	loadRoom(roomName);
	
	if (_characters != "none") characters = _characters;
	else {
		characters = [
			require("data/chars/kris"),
			require("data/chars/ralsei"),
		];
	}
	
	for (i=>character in characters) {
		character.x = spawnPoints[spawnID].x;
		character.y = spawnPoints[spawnID].y-(i*10);
		character.facing = spawnPoints[spawnID].facing;
		add(character);
	}
	
	overworldDialougeBox = new FlxSprite(0, 0).loadGraphic(Paths.image("ui/dialouge/textBox"));
	overworldDialougeBox.scale.set(2,2);
	overworldDialougeBox.updateHitbox();
	overworldDialougeBox.screenCenter(FlxAxes.X).y = FlxG.height - (overworldDialougeBox.height + 20);
	overworldDialougeBox.cameras = [camUI];
	add(overworldDialougeBox);
	
	dialouge = new FlxText(overworldDialougeBox.x + 50, overworldDialougeBox.y + 50).setFormat(Paths.font("main.ttf"), 56, FlxColor.WHITE, "left");
	dialouge.cameras = [camUI];
	add(dialouge);
	
	portrait = new FlxSprite(dialouge.x, dialouge.y);
	portrait.cameras = [camUI];
	add(portrait);
	
	portrait.visible = dialouge.visible = overworldDialougeBox.visible = false;
}

function update(){
	if (keys.MENU) FlxG.resetState();
	dialouge.fieldWidth = overworldDialougeBox.width - (100 - dialouge.offset.x);
	for (i=>character in characters) if(!inCustcene) {
		var follow = (i - 1) < 0 ? null : characters[i - 1];
		character.overworldUpdate(follow);
		character.x = FlxMath.bound(character.x, worldBounds[0], worldBounds[2]);
		character.y = FlxMath.bound(character.y, worldBounds[1], worldBounds[3]);
	}
	for (name=>tilemap in tilemaps) if(tilemapCollisions.exists(name) && tilemapCollisions.get(name) == true) FlxG.collide(tilemap, characters[0]);
	for (spr in sprites) if(spr.collideMode != "") makeObjectsCollide(characters[0], spr);
	members.sort((obj1, obj2) -> {
		if ((obj1.y) < (obj2.y))
			return -1;
		else if ((obj1.y) > (obj2.y))
			return 1;
		else
			return 0;
	}, -1);
	if(characters[0] != null) FlxG.camera.follow(characters[0]);
}

function loadRoom(roomName){
	var roomXmlString = Assets.getText(Paths.xml("rooms/" + roomName));
	var roomXml = Xml.parse(roomXmlString);
	var roomElement = roomXml.firstElement();
	roomWidth = Std.parseInt(roomElement.get("width"));
	roomHeight = Std.parseInt(roomElement.get("height"));
	tileWidth = Std.parseInt(roomElement.get("tilewidth"))*2;
	tileHeight = Std.parseInt(roomElement.get("tileheight"))*2;
	roomTitle = roomElement.get("title");
	worldBounds = [-tileWidth/2,-tileHeight/2,(roomWidth-0.5)*tileWidth,(roomHeight-0.5)*tileHeight];
	camera.minScrollY = 0;
	camera.maxScrollX = roomWidth*tileWidth;
	camera.minScrollX = 0;
	camera.maxScrollY = roomHeight*tileHeight;
	for (element in roomElement.elements()) {
		switch (element.nodeName) {
			case "tileset":
				var name = element.get("name");
				var path = element.get("path");
				tileset = new FlxSprite().loadGraphic(Paths.image(path),true,element.get("tilewidth"),element.get("tileheight"));
				tilesets.set(name, tileset);
			case "sprite":
				var name = element.get("name");
				var spr = createSpriteFromXMLElement(element);
				add(spr);
				sprites.set(name, spr);
			case "spawn":
				var name = element.get("name");
				var pos = {
					x: Std.parseFloat(element.get("x"))*2,
					y: Std.parseFloat(element.get("y"))*2,
					facing: element.get("facing"),
				};
				spawnPoints.set(name, pos);
			case "tilemap":
				var tileset = element.exists("tileset") ? tilesets.get(element.get("tileset")) : 0;
				var name = element.get("name");
				var group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
				var tileArray = parseTilemapData(element.get("data"), roomWidth);
				for(y=>row in tileArray) for(x=>til in row) if(til > 0){
					tile = new FlxSprite(tileWidth*x,tileHeight*y);
					if (tileset != 0) {
						tile.loadGraphicFromSprite(tileset);			
						tile.animation.add("idle",[til-1],1,true);
						tile.animation.play("idle");
					}
					if (element.exists("visible")) tile.visible = element.get("visible") == "true";
					if (element.exists("alpha")) tile.alpha = Std.parseFloat(element.get("alpha"));
					if (element.exists("color")) tile.color = FlxColor.fromString(element.get("color"));
					tile.immovable = true;
					tile.setGraphicSize(tileWidth, tileHeight);
					tile.updateHitbox();
					tile.offset.x = tileWidth*0.5;
					tile.offset.y = -tileHeight*0.5;
					group.add(tile);
				}
				add(group);
				if (group.length > 0) {
					tilemaps.set(name, group);
					if (element.get("collide") == "true") tilemapCollisions.set(name, true);
				}
		}
	}
	if (Assets.exists("data/rooms/" + roomName + ".hx")) importScript("data/rooms/" + roomName);
}

function parseTilemapData(str, width)
{
	var tiles = str.split(",");
	var row = [];
	var result = [];
	for (tile in tiles) {
		row.push(Std.parseInt(tile));
		if (row.length >= width) {
			result.push(row);
			row = [];
		}
	}
	return result;
}

function createSpriteFromXMLElement(element) {
	var spr = new OverworldSprite();
	spr.scale.set(2,2);
	spr.updateHitbox();
	if (element.exists("path")) spr.frames = Paths.getFrames(element.get("path"));
	var collideMode = "";
	if (element.exists("collideMode")) {
		collideMode = element.get("collideMode");
		if(collideMode == "solid") spr.immovable = true;
		else if(collideMode == "push") spr.immovable = false;
		else collideMode = "";
		spr.collideMode = collideMode;
	}
	if (element.exists("x")) spr.x = Std.parseFloat(element.get("x"))*2;
	if (element.exists("y")) spr.y = Std.parseFloat(element.get("y"))*2;
	if (element.exists("scroll")) spr.scrollFactor.set(Std.parseFloat(element.get("scroll")), Std.parseFloat(element.get("scroll")));
	if (element.exists("scrollx")) spr.scrollFactor.x = Std.parseFloat(element.get("scrollx"));
	if (element.exists("scrolly")) spr.scrollFactor.y = Std.parseFloat(element.get("scrolly"));
	if (element.exists("skew")) spr.skew.set(Std.parseFloat(element.get("skew")), Std.parseFloat(element.get("skew")));
	if (element.exists("skewx")) spr.skew.x = Std.parseFloat(element.get("skewx"));
	if (element.exists("skewy")) spr.skew.y = Std.parseFloat(element.get("skewy"));
	if (element.exists("antialiasing")) spr.antialiasing = element.get("antialiasing") == "true";
	if (element.exists("width")) spr.width = Std.parseFloat(element.get("width"))*2;
	if (element.exists("height")) spr.height = Std.parseFloat(element.get("height"))*2;
	if (element.exists("scale")) spr.scale.set(Std.parseFloat(element.get("scale"))*2, Std.parseFloat(element.get("scale"))*2);
	if (element.exists("scalex")) spr.scale.x = Std.parseFloat(element.get("scalex"))*2;
	if (element.exists("scaley")) spr.scale.y = Std.parseFloat(element.get("scaley"))*2;
	if (element.exists("graphicSize")) spr.setGraphicSize(Std.parseInt(element.get("graphicSize"))*2, Std.parseInt(element.get("graphicSize"))*2);
	if (element.exists("graphicSizex")) spr.setGraphicSize(Std.parseInt(element.get("graphicSizex"))*2);
	if (element.exists("graphicSizey")) spr.setGraphicSize(0, Std.parseInt(element.get("graphicSizey"))*2);
	if (element.exists("flipX")) spr.flipX = element.get("flipX") == "true";
	if (element.exists("flipY")) spr.flipY = element.get("flipY") == "true";
	if (element.exists("updateHitbox") && element.get("updateHitbox") == "true") spr.updateHitbox();
	if (element.exists("zoomfactor")) spr.zoomFactor = Std.parseFloat(element.get("zoomfactor"));
	if (element.exists("visible")) spr.visible = element.get("visible") == "true";
	if (element.exists("alpha")) spr.alpha = Std.parseFloat(element.get("alpha"));
	if (element.exists("color")) spr.color = FlxColor.fromString(element.get("color"));
	if (element.exists("angle")) spr.angle = Std.parseFloat(element.get("angle"));
	for (anim in element.elements()) if (anim.nodeName == "anim") {
		var indices = [];
		if (anim.exists("indices")) for (ind in anim.get("indices").split(",")) indices.push(Std.parseInt(ind));
		spr.addAnim(anim.get("name"), anim.get("anim"), Std.parseInt(anim.get("fps")), anim.get("loop") == "true", false, indices);
		spr.addOffset(anim.get("name"), anim.exists("x") ? -Std.parseFloat(anim.get("x")) : 0, anim.exists("y") ? -Std.parseFloat(anim.get("y")) : 0);
		spr.playAnim("idle");
	}
	return spr;
}

/**
 * TODO:
 * [] Change Room System
 * [+] Compatibility with multiple tilesets
 * [+] Improve Z index of sprites 
 * [+] Animated sprites support
 * [] UI & menu
 * [] Health
 * [] Save data system
 * [] Fix Party's Hitbox
 */

class OverworldSprite extends FunkinSprite {
	public var collideMode:String = "none";
}