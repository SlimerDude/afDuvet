
const class ScriptModules {

	private const Str:Obj shimConfigs
	private const Str:Uri modulePaths
	
	new make(ScriptModule[] modules, |This|in) {
		baseUrl := `/modules`
		this.shimConfigs = modules.reduce(Str:Obj?[:] { ordered = true }) |config, module -> Map| { module.addToShim(config) }
		this.modulePaths = modules.reduce(Str:Obj?[:] { ordered = true }) |config, module -> Map| { module.addToPath(config, baseUrl) }
		in(this)
	}
	
	Str:Obj? addConfig(Str:Obj? config) {
		config["paths"] = modulePaths
		config["shim"]  = shimConfigs		
		return config
	}
}

// * Used to define a <a href="http://requirejs.org/docs/api.html#config-shim">module shim</a>, used to adapt non-AMD JavaScript libraries
// * to operate like proper modules.  This information is used to build up a list of dependencies for the contributed JavaScript module,
// * and to identify the resource to be streamed to the client.
class ScriptModule {

	private Str 	moduleId
	private Uri?	atUrl
	private Str[]?	dependencies
	private Str?	globalExport
	
	new make(Str moduleId, |This|? in := null) {
		this.moduleId = moduleId
		in?.call(this) 
	}
	
	** A list of other module names the shim depends on.
	This requires(Str moduleIds) {
		this.dependencies = moduleIds.split
		return this
	}

	** The name of a global variable exported by the module. 
	** This will be the value injected into modules that depend on the shim.
	This exports(Str exports) {
		this.globalExport = exports
		return this
	}
	
	This at(Uri url) {
		this.atUrl = url
		if (this.atUrl.ext == "js")
			this.atUrl = this.atUrl.toStr[0..<-3].toUri
		return this
	}
	
	This fallbackTo(Uri localUrl) {
		// FIXME: http://requirejs.org/docs/api.html#pathsfallbacks
		return this
	}

//	"highcharts" : {
//      "deps" : ["highcharts-more"],
//      "exports" : "Highcharts"
//    },
	internal Str:Obj? addToShim(Str:Obj? shim) {
		module := Str:Obj[:]
		if (dependencies != null)
			module["deps"] = dependencies
		if (globalExport != null)
			module["exports"] = globalExport
		return shim.add(moduleId, module)
	}

	internal Str:Obj? addToPath(Str:Obj? paths, Uri baseUrl) {
		Env.cur.err.printLine("$moduleId $atUrl -> $baseUrl")
		if (atUrl != null)
			paths[moduleId] = atUrl.relTo(baseUrl)
		return paths
	}
	
}

