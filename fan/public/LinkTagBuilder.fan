using afIoc::Inject
using afIocConfig::Config
using afBedSheet

** Defines a '<link>' tag to be injected into the bottom of your head. Created via `HtmlInjector`.
** 
** If defining a stylesheet, note that any 'Content-Security-Policy' response header will be updated to ensure it can be loaded.
** 
** @see `https://developer.mozilla.org/en/docs/Web/HTML/Element/link` 
class LinkTagBuilder {
	
	@Inject private	HttpResponse		httpRes
	@Inject private	ClientAssetCache	clientAssets
	@Inject { optional=true }			// nullable for testing
			private	BedSheetServer?		bedServer
	@Inject { optional=true }			// nullable for testing
			private	FileHandler?		fileHandler
			private	HtmlElement			element
			private	HtmlConditional		ieConditional
	@Config private	Bool				updateCspHeader

	internal new make(|This|in) {
		in(this)
		this.element = HtmlElement("link")
		ieConditional = HtmlConditional() { element, }
	}
	
	** Sets the 'href' attribute to an external URL.
	** Returns 'this'.
	LinkTagBuilder fromExternalUrl(Uri externalUrl) {
		if (externalUrl.host == null)
			throw ArgErr(ErrMsgs.externalUrlsNeedHost(externalUrl))
		element["href"] = externalUrl.encode
		
		if (updateCsp) {
			host := (externalUrl + `/`).encode
			if (host.endsWith("/"))
				host = host[0..<-1]
			if (host.startsWith("//"))
				host = host[2..-1]
			csp  := httpRes.headers.contentSecurityPolicy
			if (addCsp(csp, host))
				httpRes.headers.contentSecurityPolicy = csp

			cspro := httpRes.headers.contentSecurityPolicyReportOnly
			if (addCsp(cspro, host))
				httpRes.headers.contentSecurityPolicyReportOnly = cspro
		}

		return this
	}

	** Sets the 'href' attribute to a local URL. 
	** The URL **must** be mapped by BedSheet's 'ClientAsset' cache service.
	** The URL may be rebuilt to take advantage of any asset caching strategies, such as [Cold Feet]`http://eggbox.fantomfactory.org/pods/afColdFeet`.
	** Returns 'this'.
	LinkTagBuilder fromLocalUrl(Uri localUrl) {
		// ClientAssets adds ColdFeet digests, BedServer does not
		clientUrl := clientAssets.getAndUpdateOrProduce(localUrl)?.clientUrl ?: bedServer.toClientUrl(localUrl)	
		element["href"] = clientUrl.encode
		
		if (updateCsp) {
			csp := httpRes.headers.contentSecurityPolicy
			if (addCsp(csp, "'self'"))
				httpRes.headers.contentSecurityPolicy = csp

			cspro := httpRes.headers.contentSecurityPolicyReportOnly
			if (addCsp(cspro, "'self'"))
				httpRes.headers.contentSecurityPolicyReportOnly = cspro
		}
		
		return this		
	}

	** Creates a 'href' URL attribute from the given file. 
	** The file **must** exist on the file system and be mapped by BedSheet's 'FileHandler' service.
	** The URL is built to take advantage of any asset caching strategies, such as [Cold Feet]`http://eggbox.fantomfactory.org/pods/afColdFeet`.
	** Returns 'this'.
	LinkTagBuilder fromServerFile(File serverFile) {
		fileAsset := fileHandler.fromServerFile(serverFile, true)	// this add any ColdFeet digests
		element["href"] = fileAsset.clientUrl.encode
		
		if (updateCsp) {
			csp := httpRes.headers.contentSecurityPolicy
			if (addCsp(csp, "'self'"))
				httpRes.headers.contentSecurityPolicy = csp

			cspro := httpRes.headers.contentSecurityPolicyReportOnly
			if (addCsp(cspro, "'self'"))
				httpRes.headers.contentSecurityPolicyReportOnly = cspro
		}

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

	@NoDoc	// looks like it could be useful!
	HtmlNode htmlNode() {
		ieConditional
	}
	
	private Bool updateCsp() {
		if (!updateCspHeader) return false 
		type := MimeType(element["type"] ?: "", false)?.noParams?.toStr
		rel  := element["rel"]
		return type == "text/css" || rel == "stylesheet" 
	}
	
	private static Bool addCsp([Str:Str]? csp, Str newDir) {
		if (csp == null)
			return false

		directive	:= csp["style-src"]?.trimToNull ?: csp["default-src"]?.trimToNull
		if (directive == null)
			return false

		directives	:= directive.split
		if (directives.contains(newDir))	// e.g. 'self'
			return false
		
		csp["style-src"] = directive + " " + newDir
		return true
	}
}
