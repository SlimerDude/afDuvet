using afIoc
using afIocConfig
using afBedSheet

** To disable this feature, remove the 'ModulePathOptimizations' contribution.
internal const class ModulePaths {
	
	@Config { id="afDuvet.requireBaseUrl" }
	@Inject private const Uri 			requireBaseUrl
	@Inject private const FileHandler	fileHandler
	
	new make(|This|in) { in(this) }
	
	ScriptModule[] scriptModules() {
		// if there's something wrong with the base module dir, skip out and let the config verifyer handle it
		if (!requireBaseUrl.isPathOnly)	return ScriptModule#.emptyList
		if (!requireBaseUrl.isPathAbs)	return ScriptModule#.emptyList
		if (!requireBaseUrl.isDir)		return ScriptModule#.emptyList

		// TODO: enhance FileHandler to to this for us - findMapping()?
		prefixes:= fileHandler.directoryMappings.keys.findAll { requireBaseUrl.toStr.startsWith(it.toStr) }
		prefix 	:= prefixes.size == 1 ? prefixes.first : prefixes.sort |u1, u2 -> Int| { u1.path.size <=> u2.path.size }.last
		if (prefix == null)				return ScriptModule#.emptyList
		baseDir := fileHandler.directoryMappings[prefix]
		
		return moduleMap(requireBaseUrl, baseDir).reduce([,]) |ScriptModule[] modules, localUrl, moduleId| {
			clientUrl 	:= fileHandler.fromLocalUrl(localUrl).clientUrl
			module		:= ScriptModule(moduleId).atUrl(localUrl)	// let the paths service convert localUrls into clientUrls
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
