using afIoc
using afIocConfig
using afBedSheet
using afConcurrent

internal const class DuvetProcessor : ResponseProcessor {

	@Inject private const RequireJsConfigTweaks requireJsConfig
	@Inject private const HttpRequest 			httpRequest
	@Inject private const HttpResponse 			httpResponse
	@Inject private const LocalList				headTags
	@Inject private const LocalList				bodyTags
	@Inject private const LocalRef				requireRequired
	@Inject private const LocalList				scriptSrcs
	@Inject private const LocalList				scriptCode
	@Inject private const LocalList				linkHrefs
	@Inject private const Log					log
	@Inject @Config private const Uri			requireJsUrl
	@Inject @Config private const File			requireJsFile
	@Inject @Config private const Uri			baseModuleUrl
	@Inject @Config private const Duration?		requireJsTimeout
	@Inject @Config private const Bool			disableSmartInsertion
	
	private static const Regex 					jsRegex		:= "(?is)<script[ >]((?!</script>).)*?</script>\\s*\$".toRegex

	
	new make(|This|in) {
		in(this)
		requireRequired = LocalRef(requireRequired.name, |->Bool| { false })
	}
	
	override Obj process(Obj response) {
		headTags.val = headTags.val.exclude { isDup(it) }
		bodyTags.val = bodyTags.val.exclude { isDup(it) }
		
		text 		:= (Text) response
		html 		:= StrBuf(text.text.size).add(text.text)
		tagStyle	:= findTagStyle(text.contentType)
		endOfHead	:= (headTags.isEmpty 						) ? null : findEndOfHead(text.text, headTags.first?.toStr)		
		endOfBody	:= (bodyTags.isEmpty && !requireRequired.val) ? null : findEndOfBody(text.text, bodyTags.first?.toStr)
		
		if (tagStyle != null) {
			if (endOfHead != null && headTags.size > 0) {
				headTags := "\n" + headTags.val.join("\n") |HtmlNode node->Str| { node.print(tagStyle) } + "\n"
				html.insert(endOfHead, headTags)
				
				// recalculate where the body ends
				if (endOfBody != null)
					endOfBody += headTags.size
			}
			
			if (endOfBody != null && (bodyTags.size > 0 || requireRequired.val)) {
				
				if (requireRequired.val) {
					config := requireJsConfig.tweakConfig(tagStyle)
					bodyTags.val.insert(0, config)
					
					// can't use FileHandler / ColdFeet for requireJs because it is served up directly, not mapped to the file system.
					requireJs := HtmlElement("script").set("type", "text/javascript").set("src", requireJsUrl.toStr)
					bodyTags.val.insert(0, requireJs)
				}
				
				bodyTags := "\n" + bodyTags.val.join("\n") |HtmlNode node->Str| { node.print(tagStyle) } + "\n"
				html.insert(endOfBody, bodyTags)
			}
		}

		// ...copied from afBedSheet::TextProcessor...
		// use toBuf so we only (UTF-8) encode the text the once
		buf := html.toStr.toBuf(text.contentType.charset)
		httpResponse.headers.contentType 	= text.contentType
		httpResponse.headers.contentLength	= buf.size
		if (httpRequest.httpMethod != "HEAD")
			httpResponse.out.writeBuf(buf)

		return true
	}

	File routeRequireJs() {
		// let it expire in 1 year, as per http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.21
		expiry := 365day
		httpResponse.headers.expires = DateTime.now + expiry 
		httpResponse.headers.cacheControl = "max-age=${expiry.toSec}" 
		return requireJsFile
	}
	
	File routeTzJs() {
		// let it expire in 1 year, as per http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.21
		expiry := 365day
		httpResponse.headers.expires = DateTime.now + expiry 
		httpResponse.headers.cacheControl = "max-age=${expiry.toSec}" 
		return Env.cur.findFile(`etc/sys/tz.js`)
	}
	
	Void clear() {
		headTags.clear
		bodyTags.clear
		requireRequired.cleanUp
		scriptSrcs.clear
		linkHrefs.clear
	}

	This appendToHead(HtmlNode node) {
		headTags.add(node)
		return this
	}
	
	This appendToBody(HtmlNode node) {
		bodyTags.add(node)		
		return this
	}

	This addRequireJs() {
		requireRequired.val = true		
		return this
	}
	
	private TagStyle? findTagStyle(MimeType contentType) {
		switch (contentType.noParams.toStr) {
			case "text/html":
				return TagStyle.html
			case "application/xml":
				return TagStyle.xml
			case "application/xhtml+xml":
				return TagStyle.xhtml
		}
		return null
	}
	
	private Int? findEndOfHead(Str html, Str? tag) {
		headEnd := html.indexIgnoreCase("</head>")
		if (headEnd == null)
			log.warn(
				tag == null
					? "Could not find '</head>' in HTML response.\n${html}"
					: "Could not find '</head>' in HTML response.\nCan not inject: ${tag}\ninto: ${html}"
			)
		return headEnd
	}

	private Int? findEndOfBody(Str html, Str? tag) {
		bodyEnd := html.indexrIgnoreCase("</body>")
		if (bodyEnd == null) {
			log.warn(
				tag == null
					? "Could not find '</body>' in HTML response.\n${html}"
					: "Could not find '</body>' in HTML response.\nCan not inject: ${tag}\ninto: ${html}"
			)
			return null
		}

		if (disableSmartInsertion)
			return bodyEnd
		
		// now search backwards looking for the last script tag
		jsEnd   := bodyEnd
		subHtml := html[0..<bodyEnd]
		enough	:= false
		while (!enough) {
			jsMatcher := jsRegex.matcher(subHtml)
			if (jsMatcher.find) {
				jsEnd = jsMatcher.start(0)
				subHtml = subHtml[0..<jsEnd]
			} else
				enough = true
		}
		return jsEnd
	}
	
	private Bool isDup(HtmlNode? node) {
		if (node is HtmlConditional) {
			cond := (HtmlConditional) node
			node = cond.content
		}

		if (node isnot HtmlElement)
			return false
		
		element := (HtmlElement) node
		
		if (element.name.lower == "script") {
			code := element.text
			src  := element["src"]

			if (code != null && src == null) {
				if (scriptCode.val.contains(code))
					return true
				scriptCode.add(code)
				return false
			}
			
			if (src == null)
				return false
			if (scriptSrcs.val.contains(src))
				return true
			scriptSrcs.add(src)
			return false
		}
		
		if (element.name.lower == "link") {
			href := element["href"]
			if (href == null)
				return false
			if (linkHrefs.val.contains(href))
				return true
			linkHrefs.add(href)
			return false
		}
		
		return false
	}
}
