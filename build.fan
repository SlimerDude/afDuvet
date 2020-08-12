using build

class Build : BuildPod {

	new make() {
		podName = "afDuvet"
		summary = "Something soft and comfortable to wrap your Javascript up in!"
		version = Version("1.1.12")

		meta = [
			"pod.dis"			: "Duvet",
			"afIoc.module"		: "afDuvet::DuvetModule",
			"repo.tags"			: "web",
			"repo.public"		: "true"
		]
 
		depends = [
			"sys          1.0.71 - 1.0",
			"util         1.0.71 - 1.0",
			"web          1.0.71 - 1.0",
			
			// ---- Core ------------------------
			"afConcurrent 1.0.24 - 1.0",
			"afIoc        3.0.6  - 3.0",
			"afIocConfig  1.1.0  - 1.1",
			
			// ---- Web -------------------------
			"afBedSheet   1.5.16  - 1.5",
			
			// ---- Test ------------------------
			"afBounce     1.1.12  - 1.1",
			"afButter     1.2.10  - 1.2"
		]
		
		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `fan/public/advanced/`, `test/`, `test/modules/`, `test/modules/my/`]
		resDirs = [`doc/`,`res/`]
		
		meta["afBuild.testPods"]	= "afBounce afButter"
	}
}
