using afIoc
using afIocConfig

@NoDoc	// dont' overwhelm the masses! 
const class ScriptModules {
	@Inject @Config 
	private const Uri		requireBaseUrl
	private const Str:Obj	shimConfigs
	private const Str:Uri	modulePaths
	
	new make(ScriptModule[] modules, |This|in) {
		this.shimConfigs = modules.reduce(Str:Obj?[:] { ordered = true }) |config, module -> Map| { module.addToShim(config) }
		this.modulePaths = modules.reduce(Str:Obj?[:] { ordered = true }) |config, module -> Map| { module.addToPath(config, requireBaseUrl) }
		in(this)
	}
	
	Str:Obj? addConfig(Str:Obj? config) {
		if (!modulePaths.isEmpty)
			config["paths"] = modulePaths
		if (!shimConfigs.isEmpty)
			config["shim"]  = shimConfigs		
		return config
	}
}


