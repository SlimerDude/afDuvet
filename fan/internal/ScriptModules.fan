using afIoc
using afIocConfig
using afBedSheet

@NoDoc	// Don't overwhelm the masses! 
const class ScriptModules {
	@Inject @Config 
	private const Uri			baseModuleUrl
	private const Str:Obj		shimConfigs
	private const Str:Uri		modulePaths
	@Inject
	private const FileHandler	fileHandler
	
	new make(Obj[] objs, |This|in) {
		in(this)
		modules := (ScriptModule[]) objs.flatten
		this.shimConfigs = modules.reduce(Str:Obj?[:] { ordered = true }) |config, module -> Map| { module.addToShim(config) }
		this.modulePaths = modules.reduce(Str:Obj?[:] { ordered = true }) |config, module -> Map| { module.addToPath(config, baseModuleUrl, fileHandler) }
	}
	
	Str:Obj? addConfig(Str:Obj? config) {
		if (!modulePaths.isEmpty)
			config["paths"] = modulePaths
		if (!shimConfigs.isEmpty)
			config["shim"]  = shimConfigs		
		return config
	}
}
