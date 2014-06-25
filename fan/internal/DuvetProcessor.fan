using afIoc
using afIocConfig
using afBedSheet
using afConcurrent

internal const class DuvetProcessor : ResponseProcessor {

	@Inject private const HttpResponse 	httpResponse
	@Inject private const ScriptModules	scriptModules
	@Inject private const LocalList		headTags
	@Inject private const LocalList		bodyTags
	@Inject private const LocalRef		requireRequired
	@Inject private const LocalList		scriptSrcs
	@Inject private const LocalList		linkHrefs
	@Inject private const Log			log
	@Inject @Config private const Uri		requireJsUrl
	@Inject @Config private const Uri		requireBaseUrl
	@Inject @Config private const Duration?	requireTimeout
	
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
		endOfBody	:= bodyTags.isEmpty ? null : findEndOfBody(text.text)
		
		if (tagStyle != null) {
			if (!headTags.isEmpty && endOfHead != null) {
				headTags := "\n" + headTags.list.join("\n") |HtmlNode node->Str| { node.print(tagStyle) } + "\n"
				html.insert(endOfHead, headTags)
				
				// recalculate where the body ends
				if (endOfBody != null)
					endOfBody += headTags.size
			}
			
			if (!bodyTags.isEmpty && endOfBody != null) {
				
				if (requireRequired.val) {
					config := requireJsConfig(tagStyle)
					bodyTags.list.insert(0, config)
					
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
		matcher := "(?i)</head>".toRegex.matcher(html.toStr)
		if (!matcher.find) {
			log.warn(LogMsgs.canNotFindHead)
			return null
		}
		return matcher.start(0)		
	}

	private Int? findEndOfBody(Str html) {
		matcher := "(?i)</body>".toRegex.matcher(html.toStr)
		if (!matcher.find) {
			log.warn(LogMsgs.canNotFindBody)
			return null
		}
		return matcher.start(0)		
	}
	
	private HtmlNode requireJsConfig(TagStyle tagStyle) {
		config := Str:Obj?[:] { ordered = true }
		
		config["baseUrl"] 		= requireBaseUrl.toStr
		config["waitSeconds"]	= requireTimeout?.toSec ?: 0
		config["xhtml"] 		= (tagStyle != TagStyle.html)
		config["skipDataMain"]	= true
		
		scriptModules.addConfig(config)
		
		args	:= util::JsonOutStream.writeJsonToStr(config)
		script	:= "requirejs.config(${args});"
		return HtmlElement("script").set("type", "text/javascript").add(HtmlText(script))		
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
			if (scriptSrcs.list.contains(src))
				return true
			scriptSrcs.add(src)
			return false
		}
		
		if (element.name.lower == "link") {
			href := element["href"]
			if (linkHrefs.list.contains(href))
				return true
			linkHrefs.add(href)
			return false
		}
		
		return false
	}
}
