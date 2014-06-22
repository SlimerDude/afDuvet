using afIoc
using afConcurrent
using afBedSheet

** (Service) - Injects Stylesheet links into your page.
const mixin StylesheetInjector {
	
	** Injects a stylesheet from a full URL (complete with scheme).
	** Stylesheets are listed in the HTML in the order they are added; duplicate URLs are ignored.
	** 
	** If required, the [conditional IE comment]`http://www.quirksmode.org/css/condcom.html` should 
	** be everything in the square brackets. Example:
	** 
	**   addFromExternalUrl(`http://example.com/wotever.css`, null, "if gt IE 6")
	abstract StylesheetInjector addFromExternalUrl(Uri cssUrl, Str? media := null, Str? ieConditional := null)
	
	** Injects a stylesheet from a local URL. 
	** The URL **must** be mapped by BedSheet's 'FileHandler' service.
	** The URL printed will include any asset caching strategy (if defined). 
	** 
	** Stylesheets are listed in the HTML in the order they are added; duplicate URLs are ignored.
	** 
	** If required, the [conditional IE comment]`http://www.quirksmode.org/css/condcom.html` should 
	** be everything in the square brackets. Example:
	** 	
	**   addFromClientUrl(`/css/wotever.css`, null, "if gt IE 6")
	abstract StylesheetInjector addFromClientUrl(Uri clientUrl, Str? media := null, Str? ieConditional := null)
	
	** Injects a stylesheet from the given file. 
	** The file **must** exist on the file system and be mapped by BedSheet's'FileHandler' service.
	** The URL printed will include any asset caching strategy (if defined).
	**  
	** If required, the [conditional IE comment]`http://www.quirksmode.org/css/condcom.html` should 
	** be everything in the square brackets. Example:
	** 	
	**   addFromClientUrl(`etc/wotever.css`.toFile, "print", "if gt IE 6")
	abstract StylesheetInjector addFromServerFile(File cssFile, Str? media := null, Str? ieConditional := null)
}

internal const class StylesheetInjectorImpl : StylesheetInjector {
	@Inject private const HtmlInjector	htmlInjector
	@Inject private const FileHandler	fileHandler
	@Inject private const LocalList		keys
	
	new make(|This|in) { in(this) }
	
	override StylesheetInjector addFromExternalUrl(Uri cssUrl, Str? media := null, Str? ieConditional := null) {
		if (cssUrl.host == null)
			throw ArgErr(ErrMsgs.externalUrlsNeedHost(cssUrl))
		return addStylesheet(cssUrl, media, ieConditional)
	}

	override StylesheetInjector addFromClientUrl(Uri clientUrl, Str? media := null, Str? ieConditional := null) {
		cssFile := fileHandler.fromClientUrl(clientUrl)
		return addFromServerFile(cssFile, media, ieConditional)
	}
	
	override StylesheetInjector addFromServerFile(File cssFile, Str? media := null, Str? ieConditional := null) {
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
