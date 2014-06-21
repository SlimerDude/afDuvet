
@NoDoc
mixin HtmlNode {
	abstract Str print(TagStyle tagStyle)
	
	override Str toStr() { print(TagStyle.html) }
}

@NoDoc
class HtmlElement : HtmlNode {
	Str name
	Str attr
	HtmlNode[] nodes := [,]
	
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
	
	override Str print(TagStyle tagStyle) {
		str := "<${name.toXml} ${attr}" + tagStyle.tagEnding.startTag(name, nodes.isEmpty)
		str += nodes.join("\n") { it.print(tagStyle) }
		str += tagStyle.tagEnding.endTag(name, nodes.isEmpty)
		return str
	}
}

@NoDoc
class HtmlText : HtmlNode {
	Str text
	
	new make(Str text) {
		this.text = text
	}

	override Str print(TagStyle tagStyle) {
		(tagStyle == TagStyle.html) ? text : text.toXml
	}
}

@NoDoc
class HtmlConditional : HtmlNode {
	Str condition
	HtmlNode[] nodes := [,]
	
	new make(Str condition, |This|? in := null) {
		this.condition = condition.trim
		in?.call(this)
	}

	@Operator
	This add(HtmlNode node) {
		nodes.add(node)
		return this
	}
	
	override Str print(TagStyle tagStyle) {
		str := "<!--[${condition.toXml}]>"
		str += nodes.join("\n") { it.print(tagStyle) }
		str += "<![endif]-->"
		return str
	}
}

@NoDoc
class HtmlComment : HtmlNode {
	Str comment
	
	new make(Str comment) {
		this.comment = comment
	}

	override Str print(TagStyle tagStyle) {
		return "<!-- ${comment.toXml} -->"
	}
}
