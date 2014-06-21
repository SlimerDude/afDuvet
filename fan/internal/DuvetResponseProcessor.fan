using afIoc
using afBedSheet

internal const class DuvetResponseProcessor : ResponseProcessor {

	@Inject private const HtmlInjector	htmlInjector
	@Inject private const HttpResponse 	httpResponse
	
	new make(|This|in) { in(this) }
	
	override Obj process(Obj response) {
		text := (Text) response
		html := StrBuf(text.text.size).add(text.text)
		
		tagStyle := (TagStyle?) null
		switch (text.contentType.noParams) {
			case MimeType("text/html"):
				tagStyle = TagStyle.html
			case MimeType("application/xml"):
				tagStyle = TagStyle.xml
			case MimeType("application/xhtml+xml"):
				tagStyle = TagStyle.xhtml
		}
		
		if (tagStyle != null) {
			matcher := "(?i)</head>".toRegex.matcher(html.toStr)
			if (!matcher.find)
				throw Err("Got no head")	// TODO:
			index := matcher.start(0)
			html.insert(index, htmlInjector.printHead(tagStyle))
			
			// TODO: make sure it finds the *last* occurrence
			matcher = "(?i)</body>".toRegex.matcher(html.toStr)
			if (!matcher.find)
				throw Err("Got no body")	// TODO:
			index = matcher.start(0)
			html.insert(index, htmlInjector.printBody(tagStyle))
		}

		httpResponse.headers.contentType = text.contentType
		httpResponse.out.print(html.toStr)
		return true
	}
}
