using afBedSheet

** Module configuration for those that do not conform to AMD specification. 
** Contribute instances to 'ScriptModules'.
** Example:
** 
** pre>
** syntax: fantom
** 
** @Contribute { serviceType=ScriptModules# }
** static Void contributeScriptModules(OrderedConfig config) {
**     jqueryModule := ScriptModule("jquery").atUrl(`/scripts/jquery-2.1.1.min.js`).exports("jQuery") 
**     config.add(jqueryModule)
** }
** <pre
** 
** 'ScriptModule' instances are used to create a ['shim' for RequireJS modules]`http://requirejs.org/docs/api.html#config-shim`.
class ScriptModule {
	private Str 	moduleId
	private Uri?	_primaryUrl
	private Uri?	_fallabackUrl
	private Str[]?	_requires
	private Str?	_exports
	private Str?	_init
	
	** Creates a 'ScriptModule' for the given 'moduleId'.
	new make(Str moduleId) {
		this.moduleId = moduleId
	}
	
	** A list of other module names the shim depends on.
	** Multiple module names should be split by whitespace. Example:
	** 
	**   ScriptModule("myModule").requires("jquery bootstrap")
	This requires(Str moduleIds) {
		if (moduleIds.trim.isEmpty)	return this
		this._requires = moduleIds.split
		return this
	}

	** The name of a global variable exported by the module. 
	** This will be the value injected into modules that depend on the shim.
	This exports(Str exports) {
		this._exports = exports
		return this
	}
	
	** If the module can not be found under the [baseUrl]`DuvetConfigIds.baseModuleUrl` then this dictates where it can be downloaded from.
	** May be an external or local URL.
	This atUrl(Uri moduleUrl) {
		this._primaryUrl = moduleUrl
		return this
	}
	
	** Dictates an [alternative location for the module]`http://requirejs.org/docs/api.html#pathsfallbacks` should the primary download fail. 
	** May be an external or local URL.
	This fallbackToUrl(Uri moduleUrl) {
		this._fallabackUrl = moduleUrl
		return this
	}
	
	** An alternative to 'exports', this allows the module to be initialised with a short expression.
	** 
	** @see `http://requirejs.org/docs/api.html#config-shim` for details.
	This initWith(Str expression) {
		this._init = expression
		return this
	}

	internal Str:Obj? addToShim(Str:Obj? shim) {
		module := Str:Obj[:] { ordered = true }
		if (_exports != null)
			module["exports"] = _exports
		if (_init != null)
			module["init"] = _init
		if (_requires != null)
			if (module.isEmpty)
				shim[moduleId] = _requires
			else
				module["deps"] = _requires
		if (!module.isEmpty)
			shim[moduleId] = module
		return shim
	}

	internal Void cacheUrls(ClientAssetCache assetCache) {
		if (isLocal(_primaryUrl))
			_primaryUrl = assetCache.getAndUpdateOrProduce(_primaryUrl)?.clientUrl ?: _primaryUrl
		if (isLocal(_fallabackUrl))
			_fallabackUrl = assetCache.getAndUpdateOrProduce(_fallabackUrl)?.clientUrl ?: _fallabackUrl
	}
	
	internal Str:Obj? addToPath(Str:Obj? paths) {
		urls := [_primaryUrl, _fallabackUrl].exclude { it == null }. map { removeJsExt(it).toStr }
		if (urls.size == 1)
			paths[moduleId] = urls.first
		if (urls.size == 2)
			paths[moduleId] = urls
		return paths
	}
	
	private Uri removeJsExt(Uri url) {
		if (url.ext == "js")
			url = url.toStr[0..<-3].toUri
		return url
	}
	
	private Bool isLocal(Uri? url) {
		url != null && url.isRel && url.isPathOnly && url.isPathAbs
	}
}
