using build

class Build : BuildPod {

	new make() {
		podName = "afDuvet"
		summary = "Something soft and comfortable to wrap your Javascript up in!"
		version = Version("0.0.1")

		meta = [
			"proj.name"		: "Duvet",
			"afIoc.module"	: "afDuvet::DuvetModule",
			"tags"			: "web",
			"internal"		: "true",
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
			"afIoc 1.6.4+",
			"afIocConfig 1.0.8+",
			
			// ---- Web -------------------------
			"afBedSheet 1.3.8+",
			
			// ---- Test ------------------------
			"afButter 1.0.0+",
			"afBounce 1.0.4+"
		]
		
		
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`res/`]
	}
}
