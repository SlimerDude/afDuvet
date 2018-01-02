using afIoc::Inject
using afIocConfig::Config
using afBedSheet::BedSheetServer
using afBedSheet::ClientAssetCache
using afBedSheet::FileHandler
using afBedSheet::HttpResponse

** Defines a '<script>' tag to be injected into the bottom of your body. Created via `HtmlInjector`.
** 
** Note that any 'Content-Security-Policy' response header will be updated to ensure the script can be executed.
** 
** @see `https://developer.mozilla.org/en/docs/Web/HTML/Element/script` 
class ScriptTagBuilder {
	
	@Inject private	HttpResponse		httpRes
	@Inject private	ClientAssetCache	clientAssets
	@Inject { optional=true }			// nullable for testing
			private	BedSheetServer?		bedServer
	@Inject { optional=true }			// nullable for testing
			private	FileHandler?		fileHandler
	@Config private	Bool				updateCspHeader
			private	HtmlElement			element
	
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
		element["src"] = scriptUrl.encode
		
		if (updateCspHeader) {
			host := (scriptUrl + `/`).encode
			if (host.endsWith("/"))
				host = host[0..<-1]
			if (host.startsWith("//"))
				host = host[2..-1]
			csp  := httpRes.headers.contentSecurityPolicy
			if (addCsp(csp, host, null))
				httpRes.headers.contentSecurityPolicy = csp

			cspro := httpRes.headers.contentSecurityPolicyReportOnly
			if (addCsp(cspro, host, null))
				httpRes.headers.contentSecurityPolicyReportOnly = cspro
		}
	
		return this
	}

	** Sets the 'src' attribute to a local URL. 
	** The URL may be rebuilt to take advantage of any asset caching strategies, such as [Cold Feet]`http://eggbox.fantomfactory.org/pods/afColdFeet`.
	** Returns 'this'.
	ScriptTagBuilder fromLocalUrl(Uri scriptUrl) {
		// ClientAssets adds ColdFeet digests, BedServer does not
		clientUrl := clientAssets.getAndUpdateOrProduce(scriptUrl)?.clientUrl ?: bedServer.toClientUrl(scriptUrl)	
		element["src"] = clientUrl.encode
		
		if (updateCspHeader) {
			csp := httpRes.headers.contentSecurityPolicy
			if (addCsp(csp, "'self'", null))
				httpRes.headers.contentSecurityPolicy = csp

			cspro := httpRes.headers.contentSecurityPolicyReportOnly
			if (addCsp(cspro, "'self'", null))
				httpRes.headers.contentSecurityPolicyReportOnly = cspro
		}

		return this		
	}

	** Creates a 'src' URL attribute from the given file. 
	** The file **must** exist on the file system and be mapped by BedSheet's 'FileHandler' service.
	** The URL is built to take advantage of any asset caching strategies, such as [Cold Feet]`http://eggbox.fantomfactory.org/pods/afColdFeet`.
	** Returns 'this'.
	ScriptTagBuilder fromServerFile(File scriptFile) {
		fileAsset := fileHandler.fromServerFile(scriptFile)	// this adds any ColdFeet digests
		element["src"] = fileAsset.clientUrl.encode
		
		if (updateCspHeader) {
			csp := httpRes.headers.contentSecurityPolicy
			if (addCsp(csp, "'self'", null))
				httpRes.headers.contentSecurityPolicy = csp

			cspro := httpRes.headers.contentSecurityPolicyReportOnly
			if (addCsp(cspro, "'self'", null))
				httpRes.headers.contentSecurityPolicyReportOnly = cspro
		}

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
		
		if (updateCspHeader) {
			csp := httpRes.headers.contentSecurityPolicy
			if (addCsp(csp, "'unsafe-inline'") |->Str| { "'sha256-" + script.toBuf.toDigest("SHA-256").toBase64 + "'" })
				httpRes.headers.contentSecurityPolicy = csp

			cspro := httpRes.headers.contentSecurityPolicyReportOnly
			if (addCsp(cspro, "'unsafe-inline'") |->Str| { "'sha256-" + script.toBuf.toDigest("SHA-256").toBase64 + "'" })
				httpRes.headers.contentSecurityPolicyReportOnly = cspro
		}

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

	@NoDoc	// looks like it could be useful!
	HtmlNode htmlNode() {
		element
	}

	private static Bool addCsp([Str:Str]? csp, Str altDir, |->Str|? dirFn) {
		if (csp == null)
			return false

		directive	:= csp["script-src"]?.trimToNull ?: csp["default-src"]?.trimToNull
		if (directive == null)
			return false

		directives	:= directive.split
		if (directives.contains(altDir))	// e.g. 'unsafe-inline'
			return false
		
		newDir := dirFn != null ? dirFn() : altDir
		if (directives.contains(newDir))
			return false
		
		csp["script-src"] = directive + " " + newDir
		return true
	}
}

