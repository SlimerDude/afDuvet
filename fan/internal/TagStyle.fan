
** Defines the ending style rendered tags should have: HTML, XHTML or XML.
** 
** Nicked from 'Slim'. 
internal enum class TagStyle {
	
	** Dictates that all [void elements]`http://www.w3.org/html/wg/drafts/html/master/syntax.html#void-elements` such as 
	** 'meta', 'br' and 'input' are printed without an end tag:
	** 
	**   <input type="submit">
	**   <br>
	** 
	** All non [void elements]`http://www.w3.org/html/wg/drafts/html/master/syntax.html#void-elements` are *NOT* 
	** rendered as self closing, even when empty:
	** 
	**   <script></script>
	** 
	** Serve up HTML documents with a MimeType of 'text/html'.
	html	(TagEndingHtml()),
	

	** Dictates that all [void elements]`http://www.w3.org/html/wg/drafts/html/master/syntax.html#void-elements` such as 
	** 'meta', 'br' and 'input' are printed as self closing tags:
	** 
	**   <input type="submit" />
	**   <br />
	** 
	** All non [void elements]`http://www.w3.org/html/wg/drafts/html/master/syntax.html#void-elements` are *NOT* 
	** rendered as self closing, even when empty.
	** 
	**   <script></script>
	** 
	** Serve up HTML documents with a MimeType of 'application/xhtml+xml'.
	xhtml	(TagEndingXhtml()),

	** Dictates that *ALL* empty tags are self-closing and void tags have no special meaning: 
	** 
	**   <input type="submit" />
	**   <script />
	** 
	** Serve up XML documents with a MimeType of 'text/xml' or 'application/xml' 
	** [depending on usage]`http://stackoverflow.com/questions/4832357/whats-the-difference-between-text-xml-vs-application-xml-for-webservice-respons`
	xml		(TagEndingXml());
	
	internal const TagEnding tagEnding
	
	private new make(TagEnding tagEnding) {
		this.tagEnding = tagEnding
	}
}

internal const abstract class TagEnding {
	static const Str[] voidTags := "area, base, br, col, embed, hr, img, input, keygen, link, menuitem, meta, param, source, track, wbr".split(',')
	
	Bool isVoid(Str tag) {
		voidTags.contains(tag.lower)
	}
	
	abstract Str startTag(Str tag, Bool isEmpty)

	abstract Str endTag(Str tag, Bool isEmpty)
	
	internal static Str voidTagsMustNotHaveContent(Str tag) {
		"Void tag '${tag}' *MUST NOT* have content!"
	}
}

** @see http://www.w3.org/html/wg/drafts/html/master/syntax.html#void-elements
internal const class TagEndingHtml : TagEnding {	
	private static const Log log := TagEnding#.pod.log

	override Str startTag(Str tag, Bool isEmpty) {
		if (isVoid(tag) && !isEmpty)
			log.warn(voidTagsMustNotHaveContent(tag)) 
		return ">"
	}

	override Str endTag(Str tag, Bool isEmpty) {
		if (isVoid(tag) && isEmpty)
			return ""
		return "</${tag.toXml}>"
	}
}

internal const class TagEndingXhtml : TagEnding {
	private static const Log log := TagEnding#.pod.log
	
	override Str startTag(Str tag, Bool isEmpty) {
		if (isVoid(tag) && isEmpty)
			return " />"
		if (isVoid(tag) && !isEmpty)
			log.warn(voidTagsMustNotHaveContent(tag)) 
		return ">"
	}

	override Str endTag(Str tag, Bool isEmpty) {
		if (isVoid(tag) && isEmpty)
			return ""
		return "</${tag.toXml}>"
	}
}

internal const class TagEndingXml : TagEndingXhtml {
	override Str startTag(Str tag, Bool isEmpty) {
		isEmpty ? " />" : ">"
	}

	override Str endTag(Str tag, Bool isEmpty) {
		isEmpty ? "" : "</${tag.toXml}>"
	}
}
