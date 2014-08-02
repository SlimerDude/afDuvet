using afIoc::Inject
using afIocConfig::Config
using afBedSheet

// TODO: maybe convert to const, for kicks!
internal class PodModules {
	
	@Inject private const FileHandler		fileHandler
	@Inject private const BedSheetServer	bedServer

	@Config
	@Inject private const Uri 				basePodUrl

	private PodModuleCtx	ctx			:= PodModuleCtx()
	private Pod:Pod[] 		jsDepends	:= Pod:Pod[][:] { ordered = true }
			File			podDir

	new make(|This|in) { 
		in(this)
		
		if (bedServer.appPod == null) return	// TODO: log warning
		
		dirName := "${bedServer.appPod.name}-${bedServer.appPod.version}" 
		podDir  = Env.cur.tempDir.createDir(dirName).deleteOnExit

		addPod(bedServer.appPod)
	}

	ScriptModule[] scriptModules() {
		jsDepends.map |depends, pod->ScriptModule| { 
			localUrl	:= basePodUrl + `${pod.name}.js`
			clientUrl 	:= fileHandler.fromLocalUrl(localUrl).clientUrl
			module		:= ScriptModule(pod.name).atUrl(localUrl).requires(depends.join(" ") { it.name })
			return module
		}.vals
	}
	
	private Void addPod(Pod daddyPod) {
		ctx.preventRecursion(daddyPod) |->| {
			if (isJsPod(daddyPod)) {
				deps := jsDepends.getOrAdd(daddyPod) { Pod[,] }
				daddyPod.depends.map |depend->Pod| { Pod.find(depend.name) }.each |Pod pod| {
					if (isJsPod(pod) && !deps.contains(pod)) {
						deps.add(pod)
						addPod(pod)
					}
				}
			}
		}
	}

	private Bool isJsPod(Pod pod) {
		if (jsDepends.keys.contains(pod)) return true
		
		jsFile := pod.file(`/${pod.name}.js`, false)
		if (jsFile == null) return false
		
		createScriptModule(jsFile)		
		return true
	}
	
	private Void createScriptModule(File podJsFile) {
		jsFile	:= podDir + podJsFile.name.toUri
		if (jsFile.exists) return

		out	:= jsFile.out(false, 1024)
		try {

			podJsFile.in(1024).pipe(out)
			out.flush
			
		} finally out.close
	}
}

internal class PodModuleCtx {
	private Pod[] podStack := Pod[,]

	Void preventRecursion(Pod pod, |->| operation) {
		if (podStack.contains(pod))	{
			Env.cur.err.printLine("Recurse prevent ${pod}")
			return
		}
		
		podStack.push(pod)
		try {
			operation.call()			
		} finally {			
			podStack.pop
		}
	}	
	
	Pod peek() {
		podStack.peek
	}
}