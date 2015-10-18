using build

class Build : BuildPod {

	new make() {
		podName = "afDuvet"
		summary = "Something soft and comfortable to wrap your Javascript up in!"
		version = Version("1.1.0")

		meta = [
			"proj.name"		: "Duvet",
			"afIoc.module"	: "afDuvet::DuvetModule",
			"repo.tags"		: "web",
			"repo.public"	: "false"
		]
		
		index = [
			"afIoc.module"	: "afDuvet::DuvetModule" 
		]
 
		depends = [
			"sys 1.0",
			"util 1.0",
			"web 1.0",
			
			// ---- Core ------------------------
			"afConcurrent 1.0.12 - 1.0",
			"afIoc        3.0.0  - 3.0",
			"afIocConfig  1.1.0  - 1.1",
			
			// ---- Web -------------------------
			"afBedSheet   1.5.0  - 1.5",
			
			// ---- Test ------------------------
			"afBounce     1.1.0  - 1.1",
			"afButter     1.1.2  - 1.1"
		]
		
		srcDirs = [`test/`, `test/modules/`, `test/modules/my/`, `fan/`, `fan/public/`, `fan/public/advanced/`, `fan/internal/`]
		resDirs = [`doc/`,`res/`]
	}
	
	override Void compile() {
		// remove test pods from final build
		testPods := "afBounce afButter".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
}
