using afIoc::Inject
using afIocConfig::Config
using afBedSheet

internal const class PodModules {
	
	@Inject private const Log				log
	@Inject private const PodHandler		podHandler
	@Inject private const BedSheetServer	bedServer

	new make(|This|in) { in(this) }

	ScriptModule[] scriptModules() {
		if (bedServer.appPod == null) {
			log.warn("Can not define RequireJS modules for Fantom pods: BedSheetServer.appPod == null")
			return ScriptModule#.emptyList
		}
		
		if (podHandler.baseUrl == null)
			return ScriptModule#.emptyList
		
		jsDepends	:= addPod(PodModuleCtx(), Pod:Pod[][:] { ordered = true }, bedServer.appPod)

		return jsDepends.map |depends, pod->ScriptModule?| {
			podUrl		:= `fan://${pod.name}/${pod.name}.js`
			if (podUrl.get(null, false) == null)
				return null
			clientUrl 	:= podHandler.fromPodResource(podUrl).clientUrl
			module		:= ScriptModule(pod.name).atUrl(clientUrl).requires(depends.join(" ") { it.name })
			return module
		}.vals.exclude { it == null }
	}

	private Pod:Pod[] addPod(PodModuleCtx ctx, Pod:Pod[] jsDepends, Pod daddyPod) {
		ctx.preventRecursion(daddyPod) |->| {
			deps := jsDepends.getOrAdd(daddyPod) { Pod[,] }
			daddyPod.depends.map |depend->Pod| { Pod.find(depend.name) }.each |Pod pod| {
				if (isJsPod(jsDepends, pod) && !deps.contains(pod)) {
					deps.add(pod)
					addPod(ctx, jsDepends, pod)
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
