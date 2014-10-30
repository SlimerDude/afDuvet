using afIoc
using afIocConfig
using afBedSheet

@NoDoc	// Don't overwhelm the masses! 
const class ScriptModules {
	internal const Str:Obj		shimConfigs	// val may be Str or ...anything!
	internal const Str:Obj		modulePaths // val may be Uri or Uri[]
	
	new make(Obj[] objs, |This|in) {
		in(this)
		modules := (ScriptModule[]) objs.flatten
		this.shimConfigs = modules.reduce(Str:Obj?[:] { ordered = true }) |config, module -> Map| { module.addToShim(config) }
		this.modulePaths = modules.reduce(Str:Obj?[:] { ordered = true }) |config, module -> Map| { module.addToPath(config) }
	}
	
	Str:Obj? addConfig(Str:Obj? config) {
		if (!modulePaths.isEmpty)
			config["paths"] = modulePaths
		if (!shimConfigs.isEmpty)
			config["shim"]  = shimConfigs		
		return config
	}
}
