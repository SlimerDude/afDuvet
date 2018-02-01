using afIoc
using afIocConfig
using afBedSheet

** To disable this feature, remove the 'afDuvet.cacheModuleUrls' contribution from the 'ScriptModules' service.
internal const class ModulePaths {
	
	@Config	private const Uri 			baseModuleUrl
	@Inject private const FileHandler	fileHandler
	
	new make(|This|in) { in(this) }
	
	ScriptModule[] scriptModules() {
		// if there's something wrong with the base module dir, skip out and let the config verifier handle it
		if (!baseModuleUrl.isPathOnly)	return ScriptModule#.emptyList
		if (!baseModuleUrl.isPathAbs)	return ScriptModule#.emptyList
		if (!baseModuleUrl.isDir)		return ScriptModule#.emptyList

		prefix 	:= fileHandler.findMappingFromLocalUrl(baseModuleUrl)
		if (prefix == null)				return ScriptModule#.emptyList
		baseDir := fileHandler.directoryMappings[prefix]
		
		return moduleMap(baseModuleUrl, baseDir).reduce([,]) |ScriptModule[] modules, localUrl, moduleId| {
			clientUrl 	:= fileHandler.fromLocalUrl(localUrl).clientUrl
			module		:= ScriptModule(moduleId).atUrl(clientUrl)	// create the module just in case
			return (clientUrl == localUrl) ? modules : modules.add(module)
		}
	}

	** Returns a map of ModuleIDs to local URLs of all modules
	static Str:Uri moduleMap(Uri modulesUrl, File baseDir) {
		baseDirUrl		:= baseDir.normalize.uri
		modulesDir		:= baseDir.normalize.plus(modulesUrl.relTo(`/`))
		modulesDirUrl	:= modulesDir.normalize.uri
		moduleMap		:= Str:Uri[:]
		modulesDir.walk |File moduleFile| {
			if (moduleFile.isDir) return
			
			moduleFileUrl	:= moduleFile.normalize.uri
			moduleId		:= moduleFileUrl.relTo(modulesDirUrl).toStr
			localUrl		:= moduleFileUrl.relTo(baseDirUrl)

			if (moduleId.endsWith(".js"))
				moduleId = moduleId[0..<-3]
			if (!localUrl.isPathAbs)
				localUrl = `/${localUrl}`
			
			moduleMap[moduleId] = localUrl
		}
		return moduleMap
	}
	
}
