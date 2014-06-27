using afIoc
using afBedSheet

** Defines a '<link>' tag to be injected into the bottom of your head.
** 
** @see `https://developer.mozilla.org/en/docs/Web/HTML/Element/link` 
class LinkTagBuilder {
	
	@Inject private	FileHandler		fileHandler
			private	HtmlElement		element
			private	HtmlConditional	ieConditional
	
	internal new make(|This|in) {
		in(this)
		this.element = HtmlElement("link")
		ieConditional = HtmlConditional() { element, }
	}
	
	** Sets the 'href' attribute to an external URL.
	** Returns 'this'.
	LinkTagBuilder fromExternalUrl(Uri scriptUrl) {
		if (scriptUrl.host == null)
			throw ArgErr(ErrMsgs.externalUrlsNeedHost(scriptUrl))
		element["href"] = scriptUrl.toStr
		return this
	}

	** Sets the 'href' attribute to a local URL. 
	** The URL **must** be mapped by BedSheet's 'FileHandler' service.
	** The URL is rebuilt to take advantage of any asset caching strategies, such as [Cold Feet]`http://www.fantomfactory.org/pods/afColdFeet`.
	** Returns 'this'.
	LinkTagBuilder fromLocalUrl(Uri scriptUrl) {
		fileAsset := fileHandler.fromLocalUrl(scriptUrl)	// this adds any ColdFeet digests
		element["href"] = fileAsset.clientUrl.toStr
		return this		
	}

	** Creates a 'href' URL attribute from the given file. 
	** The file **must** exist on the file system and be mapped by BedSheet's 'FileHandler' service.
	** The URL is built to take advantage of any asset caching strategies, such as [Cold Feet]`http://www.fantomfactory.org/pods/afColdFeet`.
	** Returns 'this'.
	LinkTagBuilder fromServerFile(File scriptFile) {
		fileAsset := fileHandler.fromServerFile(scriptFile)	// this add any ColdFeet digests
		element["href"] = fileAsset.clientUrl.toStr
		return this		
	}
	
	** Sets the 'type' attribute.
	** Returns 'this'.
	LinkTagBuilder withType(MimeType type) {
		element["type"] = type.toStr
		return this
	}
	
	** Sets the 'media' attribute.
	** Returns 'this'.
	LinkTagBuilder withMedia(Str media) {
		element["media"] = media
		return this
	}
	
	** Wraps the '<link>' element in a [conditional IE comment]`http://www.quirksmode.org/css/condcom.html`. 
	** The given 'condition' should be everything in the square brackets. Example:
	** 	
	**   ifIe("if gt IE 6")
	** 
	** would render:
	** 
	**   <!--[if gt IE 6]>
	**     <link src="..." >
	**   <![endif]-->
	LinkTagBuilder ifIe(Str condition) {
		ieConditional.condition = condition 
		return this
	}
	
	** Sets the 'rel' attribute.
	** Returns 'this'.
	LinkTagBuilder withRel(Str rel) {
		element["rel"] = rel
		return this
	}
	
	** Sets the 'title' attribute.
	** Returns 'this'.
	LinkTagBuilder withTitle(Str title) {
		element["title"] = title
		return this
	}
	
	** Sets an arbitrary attribute on the '<link>' element. 
	LinkTagBuilder setAttr(Str name, Str value) {
		element[name] = value
		return this
	}
	
	** Returns an attribute value on the '<link>' element. 
	Str? getAttr(Str name) {
		element[name]
	}	

	internal HtmlNode htmlNode() {
		ieConditional
	}
}

