using afIoc
using afConcurrent
using afBedSheet

** (Service) - Injects HTML into your page.
const mixin HtmlInjector {
	
	** Injects a '<meta>' element into the bottom of your head. Example:
	** 
	**   injectMeta.withName("viewport").withContent("initial-scale=1")
	** 
	** will render the following tag:
	** 
	**   <meta name="viewport" content="initial-scale=1">
	abstract MetaTagBuilder injectMeta()

	** Injects a '<link>' element into the bottom of your head. Example:
	** 
	**   injectLink.fromClientUrl(`/css/styles.css`)
	** 
	** will render the following tag:
	** 
	**   <link href="/css/styles.css">
	abstract LinkTagBuilder injectLink()
	
	** Injects a '<link>' element, defaulted for CSS stylesheets, into the bottom of your head. Example:
	** 
	**   injectStylesheet.fromClientUrl(`/css/styles.css`)
	** 
	** will render the following tag:
	** 
	**   <link type="text/css" rel="stylesheet" href="/css/styles.css">
	abstract LinkTagBuilder injectStylesheet()

	** Injects a '<script>' element into the bottom of your body. Example:
	** 
	**   injectScript.fromExternalUrl(`//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js`)
	** 
	** will render the following tag:
	** 
	**   <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
	abstract ScriptTagBuilder injectScript()

	** Appends the given 'HtmlNode' to the bottom of the head section.
	** Returns 'this'.
	@NoDoc
	abstract HtmlInjector appendToHead(HtmlNode node)
	
	** Appends the given 'HtmlNode' to the bottom of the body section.
	** Returns 'this'.
	@NoDoc
	abstract HtmlInjector appendToBody(HtmlNode node)
	
//	require(Str module).invokeFunc().withArgs()
//	require(Str:Str funcParams, Str scriptBody)
	
	
	internal abstract Str printHead(TagStyle tagStyle) 
	internal abstract Str printBody(TagStyle tagStyle) 
}
	** Stylesheets are listed in the HTML in the order they are added; duplicate URLs are ignored.

internal const class HtmlInjectorImpl : HtmlInjector {

	@Inject private const Registry	registry
	@Inject private const LocalList	toAppendToHead
	@Inject private const LocalList	toAppendToBody
	
	new make(|This|in) { in(this) }
	
	override MetaTagBuilder injectMeta() {
		bob := MetaTagBuilder()
		toAppendToHead.add(bob.htmlNode)
		return bob
	}

	override LinkTagBuilder injectLink() {
		bob := (LinkTagBuilder) registry.autobuild(LinkTagBuilder#)
		toAppendToHead.add(bob.htmlNode)
		return bob
	}

	override LinkTagBuilder injectStylesheet() {
		injectLink.withType(MimeType("text/css")).withRel("stylesheet")
	}

	override ScriptTagBuilder injectScript() {
		bob := (ScriptTagBuilder) registry.autobuild(ScriptTagBuilder#)
		toAppendToHead.add(bob.htmlNode)
		return bob
	}
	
	override HtmlInjector appendToHead(HtmlNode node) {
		toAppendToHead.add(node)
		return this
	}
	
	override HtmlInjector appendToBody(HtmlNode node) {
		toAppendToBody.add(node)		
		return this
	}
	
	override Str printHead(TagStyle tagStyle) {
		toAppendToHead.list.join("\n") |HtmlNode node->Str| { node.print(tagStyle) }
	}

	override Str printBody(TagStyle tagStyle) {
		toAppendToBody.list.join("\n") |HtmlNode node->Str| { node.print(tagStyle) }
	}
}

