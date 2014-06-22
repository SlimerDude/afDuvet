using afIoc
using afConcurrent
using afBedSheet

** (Service) - Injects Script tags into your page.
const mixin ScriptInjector {
	
	abstract ScriptInjector add(Str script, Str? type := null)
	abstract ScriptInjector addFromExternalUrl(Uri scriptUrl)
	abstract ScriptInjector addFromClientUrl(Uri scriptUrl)
	abstract ScriptInjector addFromServerFile(File scriptFile)
}

internal const class ScriptInjectorImpl : ScriptInjector {
	@Inject private const HtmlInjector	htmlInjector
	@Inject private const FileHandler	fileHandler
	@Inject private const LocalList		keys
	
	new make(|This|in) { in(this) }
	
	override ScriptInjector add(Str script, Str? type := null) {
		type 	= type ?: "text/javascript"
		attr 	:= """type="${type.toXml}" """ 
		element := HtmlElement("script", attr) 
		
		htmlInjector.appendToHead(element)
		return this		
	}
	
	override ScriptInjector addFromExternalUrl(Uri scriptUrl) {
		if (scriptUrl.host == null)
			throw ArgErr(ErrMsgs.externalUrlsNeedHost(scriptUrl))
		return addScriptFile(scriptUrl)
	}

	override ScriptInjector addFromClientUrl(Uri scriptUrl) {
		scriptFile := fileHandler.fromClientUrl(scriptUrl)
		return addFromServerFile(scriptFile)		
	}

	override ScriptInjector addFromServerFile(File scriptFile) {
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
