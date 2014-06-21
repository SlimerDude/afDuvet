using afIoc
using afConcurrent
using afBedSheet

const class ScriptInjector {
	@Inject private const HtmlInjector	htmlInjector
	@Inject private const FileHandler	fileHandler
	@Inject private const LocalList		keys
	
	new make(|This|in) { in(this) }
	
	This addScript(Str script, Str? type := null) {
		type 	= type ?: "text/javascript"
		attr 	:= """type="${type.toXml}" """ 
		element := HtmlElement("script", attr) 
		
		htmlInjector.appendToHead(element)
		return this		
	}
	
	This addScriptFromExternalUrl(Uri scriptUrl) {
		// TODO: assert url has scheme
		addScriptFile(scriptUrl)
	}

	This addScriptFromClientUrl(Uri scriptUrl) {
		scriptFile := fileHandler.fromClientUrl(scriptUrl)
		return addScriptFromServerFile(scriptFile)		
	}

	This addScriptFromServerFile(File scriptFile) {
		scriptUrl := fileHandler.fromServerFile(scriptFile)	// this add any ColdFeet digests
		return addScriptFile(scriptUrl)		
	}
	
	private This addScriptFile(Uri scriptUrl) {
		if (keys.contains(scriptUrl))
			return this
		keys.add(scriptUrl)
		
		attr 	:= """type="text/javascript" src="${scriptUrl}" """ 
		element := HtmlElement("script", attr) 
		
		htmlInjector.appendToHead(element)
		return this
	}
}
