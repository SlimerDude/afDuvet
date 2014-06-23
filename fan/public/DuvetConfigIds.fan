
** [IocConfig]`http://www.fantomfactory.org/pods/afIocConfig` values for 'Duvet'.
const class DuvetConfigIds {
	
	** The base URL from where [RequireJS]`http://requirejs.org/` / AMD modules are loaded. 
	** It should be mapped by BedSheet's 'FileHandler' service as this is where you save your Javascript modules.
	**   
	** Override this URL should it conflict with an existing BedSheet Route.
	** 
	** Defaults to '`/modules/`'.
	static const Str requireBaseUrl	:= "afDuvet.requireBaseUrl"
	
	** The URL that the [RequireJS]`http://requirejs.org/` library will be served under. 
	** Override it should it conflict with an existing BedSheet Route.
	** 
	** Defaults to '`/scripts/require.js`'.
	static const Str requireJsUrl	:= "afDuvet.requireJsUrl"
	
	** The file that will be served under the [RequireJS]`http://requirejs.org/` URL. 
	** Override it should you wish to serve a custom / updated version of [RequireJS]`http://requirejs.org/`.
	** 
	** Defaults to '`fan://afDuvet/res/require-2.1.14.js`.get'.
	static const Str requireJsFile	:= "afDuvet.requireJsFile"
	
}
