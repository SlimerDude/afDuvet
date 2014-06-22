
@NoDoc
mixin HtmlNode {
	abstract internal Str print(TagStyle tagStyle)
	
	@NoDoc
	override Str toStr() { print(TagStyle.html) }
}

@NoDoc
class HtmlElement : HtmlNode {
	private Str name
	private Str attr
	private HtmlNode[] nodes := [,]
	
	new make(Str name, Str attr, |This|? in := null) {
		this.name = name.trim
		this.attr = attr.trim
		in?.call(this)
	}

	@Operator
	This add(HtmlNode node) {
		nodes.add(node)
		return this
	}
	
	@NoDoc
	override internal Str print(TagStyle tagStyle) {
		str := "<${name.toXml} ${attr}" + tagStyle.tagEnding.startTag(name, nodes.isEmpty)
		str += nodes.join("\n") { it.print(tagStyle) }
		str += tagStyle.tagEnding.endTag(name, nodes.isEmpty)
		return str
	}
}

@NoDoc
class HtmlText : HtmlNode {
	private Str text
	
	new make(Str text) {
		this.text = text
	}

	@NoDoc
	override internal Str print(TagStyle tagStyle) {
		text	// need to print '' chars
//		(tagStyle == TagStyle.html) ? text : text.toXml
	}
}

@NoDoc
class HtmlConditional : HtmlNode {
	private Str condition
	private HtmlNode[] nodes := [,]
	
	new make(Str condition, |This|? in := null) {
		this.condition = condition.trim
		in?.call(this)
	}

	@Operator
	This add(HtmlNode node) {
		nodes.add(node)
		return this
	}
	
	@NoDoc
	override internal Str print(TagStyle tagStyle) {
		str := "<!--[${condition.toXml}]>"
		str += nodes.join("\n") { it.print(tagStyle) }
		str += "<![endif]-->"
		return str
	}
}

@NoDoc
class HtmlComment : HtmlNode {
	private Str comment
	
	new make(Str comment) {
		this.comment = comment
	}

	@NoDoc
	override internal Str print(TagStyle tagStyle) {
		return "<!-- ${comment.toXml} -->"
	}
}
