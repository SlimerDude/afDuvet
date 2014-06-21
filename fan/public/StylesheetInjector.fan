using afIoc
using afConcurrent
using afBedSheet

const class StylesheetInjector {
	@Inject private const HtmlInjector	htmlInjector
	@Inject private const FileHandler	fileHandler
	@Inject private const LocalList		keys
	
	new make(|This|in) { in(this) }
	
	
	This addStylesheetFromExternalUrl(Uri cssUrl, Str? media := null, Str? ieConditional := null) {
		// TODO: assert url has scheme
		return addStylesheet(cssUrl, media, ieConditional)
	}

	** @see http://www.quirksmode.org/css/condcom.html
	This addStylesheetFromClientUrl(Uri clientUrl, Str? media := null, Str? ieConditional := null) {
		cssFile := fileHandler.fromClientUrl(clientUrl)
		return addStylesheetFromServerFile(cssFile, media, ieConditional)
	}
	
	This addStylesheetFromServerFile(File cssFile, Str? media := null, Str? ieConditional := null) {
		cssUrl := fileHandler.fromServerFile(cssFile)	// this add any ColdFeet digests
		return addStylesheet(cssUrl, media, ieConditional)
	}
	
	
	private This addStylesheet(Uri cssUrl, Str? media := null, Str? ieConditional := null) {
		if (keys.contains(cssUrl))
			return this
		keys.add(cssUrl)
		
		attr 	:= """rel="stylesheet" type="text/css" href="${cssUrl}" """ + ((media == null) ? Str.defVal : """media="${media}" """) 
		element := (HtmlNode) HtmlElement("link", attr) 
		
		if (ieConditional != null) 
			element = HtmlConditional(ieConditional) { add(element) }

		htmlInjector.appendToHead(element)
		return this
	}
}
