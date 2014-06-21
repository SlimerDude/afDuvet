using afIoc
using afConcurrent
using afBedSheet

** (Service) - Injects HTML into your page.
const class HtmlInjector {

	@Inject private const LocalList		toAppendToHead
	@Inject private const LocalList		toAppendToBody
	
	new make(|This|in) { in(this) }
	
	Void addMeta(Str name, Str content) {
		attr := """name="${name.toXml}" content="${content.toXml}" """
		toAppendToHead.add(HtmlElement("meta", attr))
	}

	Void addMetaEquiv(Str httpEquiv, Str content) {
		attr := """http-equiv="${httpEquiv.toXml}" content="${content.toXml}" """
		toAppendToHead.add(HtmlElement("meta", attr))
	}
	
	Void appendToHead(HtmlElement element) {
		toAppendToHead.add(element)
	}
	
	Void appendToBody(HtmlElement element) {
		toAppendToBody.add(element)		
	}
	
	internal Str printHead(TagStyle tagStyle) {
		toAppendToHead.list.join("\n") |HtmlNode node->Str| { node.print(tagStyle) }
	}

	internal Str printBody(TagStyle tagStyle) {
		toAppendToBody.list.join("\n") |HtmlNode node->Str| { node.print(tagStyle) }
	}
}
