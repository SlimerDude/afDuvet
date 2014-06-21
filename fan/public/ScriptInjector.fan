using afIoc
using afConcurrent
using afBedSheet

** (Service) - Injects Script tags into your page.
const mixin ScriptInjector {
	
	abstract ScriptInjector addScript(Str script, Str? type := null)
	abstract ScriptInjector addScriptFromExternalUrl(Uri scriptUrl)
	abstract ScriptInjector addScriptFromClientUrl(Uri scriptUrl)
	abstract ScriptInjector addScriptFromServerFile(File scriptFile)
}

internal const class ScriptInjectorImpl : ScriptInjector {
	@Inject private const HtmlInjector	htmlInjector
	@Inject private const FileHandler	fileHandler
	@Inject private const LocalList		keys
	
	new make(|This|in) { in(this) }
	
	override ScriptInjector addScript(Str script, Str? type := null) {
		type 	= type ?: "text/javascript"
		attr 	:= """type="${type.toXml}" """ 
		element := HtmlElement("script", attr) 
		
		htmlInjector.appendToHead(element)
		return this		
	}
	
	override ScriptInjector addScriptFromExternalUrl(Uri scriptUrl) {
		// TODO: assert url has scheme
		addScriptFile(scriptUrl)
	}

	override ScriptInjector addScriptFromClientUrl(Uri scriptUrl) {
		scriptFile := fileHandler.fromClientUrl(scriptUrl)
		return addScriptFromServerFile(scriptFile)		
	}

	override ScriptInjector addScriptFromServerFile(File scriptFile) {
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
