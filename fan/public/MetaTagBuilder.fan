
** Defines a '<meta>' tag to be injected into the bottom of your head. Created via `HtmlInjector`.
** 
** @see `https://developer.mozilla.org/en/docs/Web/HTML/Element/meta` 
class MetaTagBuilder {
	private HtmlElement element
	
	@NoDoc
	new make() {
		this.element = HtmlElement("meta")
	}
	
	** Sets the 'name' attribute.
	** Returns 'this'.
	MetaTagBuilder withName(Str name) {
		element["name"] = name
		return this
	}
	
	** Sets the 'content' attribute.
	** Returns 'this'.
	MetaTagBuilder withContent(Str content) {
		element["content"] = content
		return this
	}
	
	** Sets the 'property' attribute.
	** Returns 'this'.
	MetaTagBuilder withProperty(Str property) {
		element["property"] = property
		return this
	}
	
	** Sets the 'lang' attribute.
	** Returns 'this'.
	MetaTagBuilder withLang(Str lang) {
		element["lang"] = lang
		return this
	}
	
	** Sets an arbitrary attribute on the '<meta>' element. 
	MetaTagBuilder setAttr(Str name, Str value) {
		element[name] = value
		return this
	}
	
	** Returns an attribute value on the '<meta>' element. 
	Str? getAttr(Str name) {
		element[name]
	}

	@NoDoc	// looks like it could be useful!
	HtmlNode htmlNode() {
		element
	}
}
