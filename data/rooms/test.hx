function update() {
	var tree = sprites["tree2"];
	if (tree.overlaps(characters[0]) && keys.ACCEPT && !inCustcene) {
		inCustcene = true;
		eventName = "tree";
		events[eventName] = [
			() -> doTextStuff("* Testing.", false, false, "default", null, 0.05),
			() -> doTextStuff("* Testing Testor.", false, false, "ralsei", "ralsei/neutral", 0.05),
			() -> inCustcene = false,
		];
		handleEvent();
	}
}