using afIoc
using afIocConfig
using afBedSheet
using afConcurrent

internal const class DuvetProcessor : ResponseProcessor {

	@Inject private const RequireJsConfigTweaks requireJsConfig
	@Inject private const HttpResponse 			httpResponse
	@Inject private const LocalList				headTags
	@Inject private const LocalList				bodyTags
	@Inject private const LocalRef				requireRequired
	@Inject private const LocalList				scriptSrcs
	@Inject private const LocalList				linkHrefs
	@Inject private const Log					log
	@Inject @Config private const Uri			requireJsUrl
	@Inject @Config private const File			requireJsFile
	@Inject @Config private const Uri			baseModuleUrl
	@Inject @Config private const Duration?		requireJsTimeout
	@Inject @Config private const Bool			disableSmartInsertion
	
	private static const Regex 					headRegex	:= "(?i)</head>".toRegex
	private static const Regex 					bodyRegex	:= "(?i)</body>".toRegex
	private static const Regex 					jsRegex		:= "(?is)<script ((?!</script>).)*?</script>\\s*\$".toRegex
	
	new make(|This|in) {
		in(this)
		requireRequired = LocalRef(requireRequired.name, |->Bool| { false })
	}
	
	override Obj process(Obj response) {
		headTags.list = headTags.list.exclude { isDup(it) }
		bodyTags.list = bodyTags.list.exclude { isDup(it) }
		
		text 		:= (Text) response
		html 		:= StrBuf(text.text.size).add(text.text)
		tagStyle	:= findTagStyle(text.contentType)
		endOfHead	:= headTags.isEmpty ? null : findEndOfHead(text.text)
		endOfBody	:= bodyTags.isEmpty && !requireRequired.val ? null : findEndOfBody(text.text)
		
		if (tagStyle != null) {
			if (!headTags.isEmpty && endOfHead != null) {
				headTags := "\n" + headTags.list.join("\n") |HtmlNode node->Str| { node.print(tagStyle) } + "\n"
				html.insert(endOfHead, headTags)
				
				// recalculate where the body ends
				if (endOfBody != null)
					endOfBody += headTags.size
			}
			
			if (endOfBody != null && (bodyTags.size > 0 || requireRequired.val)) {
				
				if (requireRequired.val) {
					config := requireJsConfig.tweakConfig(tagStyle)
					bodyTags.list.insert(0, config)
					
					// can't use FileHandler / ColdFeet for requireJs because it is served up directly, not mapped to the file system.
					requireJs := HtmlElement("script").set("type", "text/javascript").set("src", requireJsUrl.toStr)
					bodyTags.list.insert(0, requireJs)
				}
				
				bodyTags := "\n" + bodyTags.list.join("\n") |HtmlNode node->Str| { node.print(tagStyle) } + "\n"
				html.insert(endOfBody, bodyTags)
			}
		}

		httpResponse.headers.contentType = text.contentType
		httpResponse.out.print(html.toStr)
		return true
	}

	File routeRequireJs() {
		// let it expire in 1 year, as per http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.21
		expiry := 365day
		httpResponse.headers.expires = DateTime.now + expiry 
		httpResponse.headers.cacheControl = "max-age=${expiry.toSec}" 
		return requireJsFile
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
		switch (contentType.noParams) {
			case MimeType("text/html"):
				return TagStyle.html
			case MimeType("application/xml"):
				return TagStyle.xml
			case MimeType("application/xhtml+xml"):
				return TagStyle.xhtml
		}
		return null
	}
	
	private Int? findEndOfHead(Str html) {
		headMatcher := headRegex.matcher(html)
		if (!headMatcher.find) {
			log.warn(LogMsgs.canNotFindHead)
			return null
		}
		return headMatcher.start(0)		
	}

	private Int? findEndOfBody(Str html) {
		bodyMatcher := bodyRegex.matcher(html)
		if (!bodyMatcher.find) {
			log.warn(LogMsgs.canNotFindBody)
			return null
		}
		bodyEnd := bodyMatcher.start(0)

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
			src := element["src"]
			if (src == null)
				return false
			if (scriptSrcs.list.contains(src))
				return true
			scriptSrcs.add(src)
			return false
		}
		
		if (element.name.lower == "link") {
			href := element["href"]
			if (href == null)
				return false
			if (linkHrefs.list.contains(href))
				return true
			linkHrefs.add(href)
			return false
		}
		
		return false
	}
}
