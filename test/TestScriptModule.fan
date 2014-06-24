
internal class TestScriptModuleWithIoc : DuvetTest {
	
	Void testEmptyShim() {
		shim := ScriptModule("wotever").addToShim([:])
		verify(shim.isEmpty)
	}
}

internal class TestScriptModule : DuvetTest {
	
	override Void setup() { }
	
	Void testEmptyShim() {
		shim := ScriptModule("wotever").addToShim([:])
		verify(shim.isEmpty)
	}
	
	Void testOnePath() {
		paths := ScriptModule("wotever").atUrl(`/primary`).addToPath([:], `/modules/`)
		verifyEq(paths["wotever"], "/primary")
	}
	
	Void testTwoPaths() {
		paths := ScriptModule("wotever").atUrl(`http://wot.com/ever`).fallbackToUrl(`/primary`).addToPath([:], `/modules/`)
		list := paths["wotever"] as Str[]
		verifyEq(list[0], "http://wot.com/ever")
		verifyEq(list[1], "/primary")
	}
	
	Void testJsExtIsRemoved() {
		paths := ScriptModule("wotever").atUrl(`/primary/script.js`).addToPath([:], `/modules/`)
		verifyEq(paths["wotever"], "/primary/script")

		paths = ScriptModule("wotever").atUrl(`http://wot.com/ever.js`).addToPath([:], `/modules/`)
		verifyEq(paths["wotever"], "http://wot.com/ever")
	}

	Void testPathIsRelToBase() {
		paths := ScriptModule("wotever").atUrl(`/modules/sub/script.js`).addToPath([:], `/modules/`)
		verifyEq(paths["wotever"], "sub/script")
	}

	Void testExportsShim() {
		shim := ScriptModule("wotever").exports("jQuery").addToShim([:])
		conf := shim["wotever"] as Str:Obj
		verifyEq(conf["exports"], "jQuery")
		verifyEq(conf.size, 1)
	}

	Void testExportsAndDepShim() {
		shim := ScriptModule("wotever").exports("backbone").requires("jquery").addToShim([:])
		conf := shim["wotever"] as Str:Obj
		verifyEq(conf["exports"], "backbone")
		verifyEq(conf["deps"], ["jquery"])
		verifyEq(conf.size, 2)
	}

	Void testExportsAndDepsShim() {
		shim := ScriptModule("wotever").exports("backbone").requires("jquery bootstrap").addToShim([:])
		conf := shim["wotever"] as Str:Obj
		verifyEq(conf["exports"], "backbone")
		verifyEq(conf["deps"], ["jquery", "bootstrap"])
		verifyEq(conf.size, 2)
	}

	Void testDepsOnly() {
		shim := ScriptModule("wotever").requires("jquery bootstrap").addToShim([:])
		conf := shim["wotever"] as List
		verifyEq(conf.size, 2)
		verifyEq(conf, ["jquery", "bootstrap"])
	}
	
}
