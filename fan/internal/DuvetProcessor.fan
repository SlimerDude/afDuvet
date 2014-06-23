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
	@Inject private const Log			log
	@Inject @Config private const Uri	requireJsUrl
	@Inject @Config private const Uri	requireBaseUrl
	
	new make(|This|in) {
		in(this)
		requireRequired = LocalRef(requireRequired.name, |->Bool| { false })
	}
	
	override Obj process(Obj response) {
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
			log.warn(LogMsgs.canNotFindEndOfHead)
			return null
		}
		return matcher.start(0)		
	}

	private Int? findEndOfBody(Str html) {
		matcher := "(?i)</body>".toRegex.matcher(html.toStr)
		if (!matcher.find) {
			log.warn(LogMsgs.canNotFindEndOfBody)
			return null
		}
		return matcher.start(0)		
	}
	
	private HtmlNode requireJsConfig(TagStyle tagStyle) {
		config := Str:Obj?[:] { ordered = true }
		
		config["baseUrl"] 		= requireBaseUrl.toStr
		config["waitSeconds"]	= 300
		config["xhtml"] 		= (tagStyle != TagStyle.html)
		config["skipDataMain"]	= true
		
		scriptModules.addConfig(config)
		
		args	:= util::JsonOutStream.writeJsonToStr(config)
		script	:= "requirejs.config(${args});"
		return HtmlElement("script").set("type", "text/javascript").add(HtmlText(script))		
	}
}
