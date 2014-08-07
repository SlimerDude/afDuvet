using build

class Build : BuildPod {

	new make() {
		podName = "afDuvet"
		summary = "Something soft and comfortable to wrap your Javascript up in!"
		version = Version("0.1.1")

		meta = [
			"proj.name"		: "Duvet",
			"afIoc.module"	: "afDuvet::DuvetModule",
			"tags"			: "web",
//			"internal"		: "true",	// internal or not?
			"repo.private"	: "true"
		]

		index = [	
			"afIoc.module"	: "afDuvet::DuvetModule"
		]
 
		depends = [
			"sys 1.0",
			"util 1.0",
			
			// ---- Core ------------------------
			"afConcurrent 1.0.6+",
			"afIoc 1.7.6+",
			"afIocConfig 1.0.14+",
			
			// ---- Web -------------------------
			"afBedSheet 1.3.14+",
			
			// ---- Test ------------------------
			"afBounce 1.0.12+",
			"afButter 1.0.2+"
		]
		
		srcDirs = [`test/`, `test/modules/`, `test/modules/my/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`res/`]
	}
	
	
	override Void compile() {
		// remove test pods from final build
		testPods := "afBounce afButter".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
}
