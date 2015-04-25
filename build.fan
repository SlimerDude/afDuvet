using build

class Build : BuildPod {

	new make() {
		podName = "afDuvet"
		summary = "Something soft and comfortable to wrap your Javascript up in!"
		version = Version("1.0.10")

		meta = [
			"proj.name"		: "Duvet",
			"afIoc.module"	: "afDuvet::DuvetModule",
			"tags"			: "web",
			"repo.private"	: "false"
		]

		index = [	
			"afIoc.module"	: "afDuvet::DuvetModule"
		]
 
		depends = [
			"sys 1.0",
			"util 1.0",
			"web 1.0",
			
			// ---- Core ------------------------
			"afConcurrent 1.0.8  - 1.0",
			"afIoc        2.0.6  - 2.0",
			"afIocConfig  1.0.16 - 1.0",
			
			// ---- Web -------------------------
			"afBedSheet   1.4.10  - 1.4",
			
			// ---- Test ------------------------
			"afBounce     1.0.20 - 1.0",
			"afButter     1.1.2  - 1.1"
		]
		
		srcDirs = [`test/`, `test/modules/`, `test/modules/my/`, `fan/`, `fan/public/`, `fan/public/advanced/`, `fan/internal/`]
		resDirs = [`res/`]
	}
	
	override Void compile() {
		// remove test pods from final build
		testPods := "afBounce afButter".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
}
