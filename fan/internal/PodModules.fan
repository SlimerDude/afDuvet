using afIoc::Inject
using afIocConfig::Config
using afBedSheet

internal const class PodModules {
	
	@Config
	@Inject private const Uri 				basePodUrl
	@Inject private const FileHandler		fileHandler
	@Inject private const BedSheetServer	bedServer
			private const Pod:Pod[] 		jsDepends
					const File				podDir

	new make(|This|in) { 
		in(this)
		
		if (bedServer.appPod == null) return	// TODO: log warning
		
		dirName 	:= "${bedServer.appPod.name}-${bedServer.appPod.version}" 
		podDir  	= Env.cur.tempDir.createDir(dirName).deleteOnExit
		jsDepends	= addPod(PodModuleCtx(), Pod:Pod[][:] { ordered = true }, bedServer.appPod)
		
		copyPods
	}

	ScriptModule[] scriptModules() {
		jsDepends.map |depends, pod->ScriptModule| { 
			localUrl	:= basePodUrl + `${pod.name}.js`
			clientUrl 	:= fileHandler.fromLocalUrl(localUrl).clientUrl
			module		:= ScriptModule(pod.name).atUrl(localUrl).requires(depends.join(" ") { it.name })
			return module
		}.vals
	}

	private Void copyPods() {
		jsDepends.keys.each { createScriptModule(it) }
	}

	private Pod:Pod[] addPod(PodModuleCtx ctx, Pod:Pod[] jsDepends, Pod daddyPod) {
		ctx.preventRecursion(daddyPod) |->| {
			if (isJsPod(jsDepends, daddyPod)) {
				deps := jsDepends.getOrAdd(daddyPod) { Pod[,] }
				daddyPod.depends.map |depend->Pod| { Pod.find(depend.name) }.each |Pod pod| {
					if (isJsPod(jsDepends, pod) && !deps.contains(pod)) {
						deps.add(pod)
						addPod(ctx, jsDepends, pod)
					}
				}
			}
		}
		return jsDepends
	}

	private Bool isJsPod(Pod:Pod[] jsDepends, Pod pod) {
		if (jsDepends.keys.contains(pod)) return true
		jsFile := pod.file(`/${pod.name}.js`, false)
		return jsFile != null
	}
	
	private Void createScriptModule(Pod pod) {
		podJsFile := pod.file(`/${pod.name}.js`, true)
		jsFile	:= podDir + podJsFile.name.toUri
		podJsFile.copyTo(jsFile, ["overwrite":true])
	}
}

internal class PodModuleCtx {
	private Pod[] podStack := Pod[,]

	Void preventRecursion(Pod pod, |->| operation) {
		if (podStack.contains(pod))	return
		
		podStack.push(pod)
		try {
			operation.call()			
		} finally {			
			podStack.pop
		}
	}
}
