using afIoc
using afBedSheet

** Defines a '<script>' tag to be injected into the bottom of your body.
** 
** @see `https://developer.mozilla.org/en/docs/Web/HTML/Element/script` 
class ScriptTagBuilder {
	
	@Inject private	FileHandler	fileHandler
			private	HtmlElement	element
	
	internal new make(|This|in) {
		in(this)
		this.element = HtmlElement("script")
		this.element["type"] = "text/javascript"
	}
	
	** Sets the 'src' attribute to an external URL.
	** Returns 'this'.
	ScriptTagBuilder fromExternalUrl(Uri scriptUrl) {
		if (scriptUrl.host == null)
			throw ArgErr(ErrMsgs.externalUrlsNeedHost(scriptUrl))
		element["src"] = scriptUrl.toStr
		return this
	}

	** Sets the 'src' attribute to a local URL. 
	** The URL **must** be mapped by BedSheet's 'FileHandler' service.
	** The URL is rebuilt to take advantage of any asset caching strategies, such as [Cold Feet]`http://www.fantomfactory.org/pods/afColdFeet`.
	** Returns 'this'.
	ScriptTagBuilder fromLocalUrl(Uri scriptUrl) {
		fileAsset := fileHandler.fromLocalUrl(scriptUrl)	// this adds any ColdFeet digests
		element["src"] = fileAsset.clientUrl.toStr
		return this		
	}

	** Creates a 'src' URL attribute from the given file. 
	** The file **must** exist on the file system and be mapped by BedSheet's 'FileHandler' service.
	** The URL is built to take advantage of any asset caching strategies, such as [Cold Feet]`http://www.fantomfactory.org/pods/afColdFeet`.
	** Returns 'this'.
	ScriptTagBuilder fromServerFile(File scriptFile) {
		fileAsset := fileHandler.fromServerFile(scriptFile)	// this adds any ColdFeet digests
		element["src"] = fileAsset.clientUrl.toStr
		return this		
	}
	
	** Sets the 'type' attribute.
	** Returns 'this'.
	ScriptTagBuilder withType(MimeType type) {
		element["type"] = type.toStr
		return this
	}
	
	** Sets the 'id' attribute.
	** Returns 'this'.
	ScriptTagBuilder withId(Str id) {
		element["id"] = id
		return this
	}

	** Sets the contents of the script tag.
	** Returns 'this'.
	ScriptTagBuilder withScript(Str script) {
		element.add(HtmlText(script))
		return this
	}
	
	** Sets the 'async' attribute to 'async'; the XHTML value, accepted by HTML.
	** Returns 'this'.
	ScriptTagBuilder async() {
		element["async"] = "async"
		return this
	}
	
	** Sets the 'defer' attribute to 'true'.
	** Returns 'this'.
	ScriptTagBuilder defer() {
		element["defer"] = "true"
		return this
	}
	
	** Sets an arbitrary attribute on the '<script>' element. 
	ScriptTagBuilder setAttr(Str name, Str value) {
		element[name] = value
		return this
	}
	
	** Returns an attribute value on the '<script>' element. 
	Str? getAttr(Str name) {
		element[name]
	}	

	internal HtmlNode htmlNode() {
		element
	}
}

