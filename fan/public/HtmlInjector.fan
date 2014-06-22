using afIoc
using afConcurrent
using afBedSheet

** (Service) - Injects HTML into your page.
const mixin HtmlInjector {
	
//	injectStylesheet.fromExternalUrl(...).withMedia().withIeConditional().withType(text/css)
//	injectIntoHead(HtmlElement) - @NoDoc
//	injectMeta.withName().withContent()
//	injectScript.fromClientUrl.withScript(...)
//	
//	require(
	
	abstract HtmlInjector addMeta(Str name, Str content) 
	abstract HtmlInjector addMetaEquiv(Str httpEquiv, Str content) 
	abstract HtmlInjector appendToHead(HtmlElement element) 
	abstract HtmlInjector appendToBody(HtmlElement element) 
	
	internal abstract Str printHead(TagStyle tagStyle) 
	internal abstract Str printBody(TagStyle tagStyle) 
}

internal const class HtmlInjectorImpl : HtmlInjector {

	@Inject private const LocalList		toAppendToHead
	@Inject private const LocalList		toAppendToBody
	
	new make(|This|in) { in(this) }
	
	override HtmlInjector addMeta(Str name, Str content) {
		attr := """name="${name.toXml}" content="${content.toXml}" """
		toAppendToHead.add(HtmlElement("meta", attr))
		return this
	}

	override HtmlInjector addMetaEquiv(Str httpEquiv, Str content) {
		attr := """http-equiv="${httpEquiv.toXml}" content="${content.toXml}" """
		toAppendToHead.add(HtmlElement("meta", attr))
		return this
	}
	
	override HtmlInjector appendToHead(HtmlElement element) {
		toAppendToHead.add(element)
		return this
	}
	
	override HtmlInjector appendToBody(HtmlElement element) {
		toAppendToBody.add(element)		
		return this
	}
	
	override Str printHead(TagStyle tagStyle) {
		toAppendToHead.list.join("\n") |HtmlNode node->Str| { node.print(tagStyle) }
	}

	override Str printBody(TagStyle tagStyle) {
		toAppendToBody.list.join("\n") |HtmlNode node->Str| { node.print(tagStyle) }
	}
}
