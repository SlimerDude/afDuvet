
@NoDoc
mixin HtmlNode {
	abstract internal Str print(TagStyle tagStyle)
	
	@NoDoc
	override Str toStr() { print(TagStyle.html) }
}

@NoDoc
class HtmlElement : HtmlNode {
	private Str name
	private Str:Str attrs
	private HtmlNode[] nodes := [,]
	
	new make(Str name, |This|? in := null) {
		this.name = name.trim
		in?.call(this)
	}

	** Adds a 'HtmlNode'
	@Operator
	This add(HtmlNode node) {
		nodes.add(node)
		return this
	}
	
	** Gets an attribue value
	@Operator
	Str? get(Str attr) {
		attrs[attr]
	}

	** Sets an attribute value
	@Operator
	HtmlElement set(Str attr, Str val) {
		attrs[attr] = val
		return this
	}
	
	@NoDoc
	override internal Str print(TagStyle tagStyle) {
		att := attrs.join(" ") |v, k->Str| { k.toXml + "=" + v.toCode }
		str := "<${name.toXml} ${att}" + tagStyle.tagEnding.startTag(name, nodes.isEmpty)
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
	Str? condition
	private HtmlNode[] nodes := [,]
	
	new make(|This| f) { f(this) }

	new makeWithCondition(Str? condition, |This|? in := null) {
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
		str := Str.defVal
		
		if (condition == null)
			str += "<!--[${condition.toXml}]>\n"
		
		str += nodes.join("\n") { it.print(tagStyle) }
		
		if (condition == null)
			str += "<![endif]-->\n"

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
