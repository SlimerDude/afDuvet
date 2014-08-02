using afIoc
using afBedSheet
using util

** (Service) - Injects HTML elements into your page.
** Elements are queued up and injected just before the page is sent to the browser.
** 
** Elements are listed in the HTML in the order they are added.
** Duplicate elements are ignored. 
** So if a component adds a stylesheet link, that component may be used many times on a page but, only ONE link to that stylesheet will be rendered.
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
	**   injectScript.fromExternalUrl(`//code.jquery.com/jquery-2.1.1.min.js`)
	** 
	** will render the following tag:
	** 
	**   <script type="text/javascript" src="//code.jquery.com/jquery-2.1.1.min.js"></script>
	** 
	** *Consider using [RequireJS]`http://requirejs.org/` AMD modules instead!*
	abstract ScriptTagBuilder injectScript(Bool appendToHead := false)

	** Wraps the 'script' in a function call to [RequireJS]`http://requirejs.org/`, ensuring the given module dependencies are available.  
	** 
	** 'functionParams' is a map of 'RequireJs' module names to function parameter names.
	** Example:
	** 
	**   injectRequireScript(["jquery":"\$"], "\$('p').addClass('magic');")
	** 
	** will generate:
	** 
	**   <script type="text/javascript">
	**     require(["jquery"], function ($) {
	**        $('p').addClass('magic');
	**     });
	**   </script>
	abstract ScriptTagBuilder injectRequireScript(Str:Str functionParams, Str script)

	** Injects a call to a [RequireJS]`http://requirejs.org/` module. 
	** 
	** If the [RequireJS module exposes an object]`http://requirejs.org/docs/api.html#defdep` then a function may be invoked using 'funcName' and 'funcArgs'. 
	** Example:
	** 
	**   injectRequireCall("my/shirt", "addToCart", ["shirt", 1.99f])
	** 
	** will generate:
	** 
	**   <script type="text/javascript">
	**     require(["my/shirt"], function (module) { module.addToCart("shirt", 1.99); });
	**   </script>
	** 
	** Or, if the [RequireJS module returns function as its module definition]`http://requirejs.org/docs/api.html#funcmodule` then it may be invoked directly by passing 'null' as the 'funcName'.
	** Example:
	** 
	**   injectRequireCall("my/title", null, ["Reduced to Clear!"])
	** 
	** will generate:
	** 
	**   <script type="text/javascript">
	**     require(["my/title"], function (module) { module("Reduced to Clear!"); });
	**   </script>
	** 
	** Note that 'funcArgs' are converted into JSON; which is really useful, as it means *you* don't have to!
	abstract ScriptTagBuilder injectRequireCall(Str moduleId, Str? funcName := null, Obj?[]? funcArgs := null)

	
//	abstract ScriptTagBuilder[] injectFantomPods(Str pods)
	// TODO: func args?
	abstract ScriptTagBuilder injectFantomMethod(Method method, Obj?[]? args := null)
	
	** Appends the given 'HtmlNode' to the bottom of the head section.
	** Returns 'this'.
	@NoDoc
	abstract HtmlInjector appendToHead(HtmlNode node)
	
	** Appends the given 'HtmlNode' to the bottom of the body section.
	** Returns 'this'.
	@NoDoc
	abstract HtmlInjector appendToBody(HtmlNode node)
}

internal const class HtmlInjectorImpl : HtmlInjector {
	@Inject private const Registry			registry
	@Inject private const DuvetProcessor	duvetProcessor
	@Inject private const FileHandler		fileHandler
	
	new make(|This|in) { in(this) }
	
	override MetaTagBuilder injectMeta() {
		bob := MetaTagBuilder()
		appendToHead(bob.htmlNode)
		return bob
	}

	override LinkTagBuilder injectLink() {
		bob := (LinkTagBuilder) registry.autobuild(LinkTagBuilder#)
		appendToHead(bob.htmlNode)
		return bob
	}

	override LinkTagBuilder injectStylesheet() {
		injectLink.withRel("stylesheet").withType(MimeType("text/css"))
	}

	override ScriptTagBuilder injectScript(Bool inHead := false) {
		bob := (ScriptTagBuilder) registry.autobuild(ScriptTagBuilder#)
		if (inHead)
			appendToHead(bob.htmlNode)
		else
			appendToBody(bob.htmlNode)
		return bob
	}
	
	override ScriptTagBuilder injectRequireScript(Str:Str scriptParams, Str script) {
		duvetProcessor.addRequireJs
		params 	:= scriptParams.keys.join(", ") { "\"${it}\"" }
		args	:= scriptParams.vals.join(", ")
		script	=  script.trim.isEmpty ? " " : "\n" + script + "\n"
		body	:= """require([${params}], function (${args}) {${script}});"""
		return injectScript.withScript(body)
	}
	
	// FIXME: rename --> injectRequireModule()
	override ScriptTagBuilder injectRequireCall(Str moduleId, Str? funcName := null, Obj?[]? funcArgs := null) {
		fCall := Str.defVal
		if (funcName != null || funcArgs != null) {
			fName := (funcName == null) ? Str.defVal : "." + funcName
			fArgs := (funcArgs == null) ? Str.defVal : funcArgs.join(", ") { JsonOutStream.writeJsonToStr(it) }
			fCall  = "module${fName}(${fArgs});"
		}
		return injectRequireScript([moduleId:"module"], fCall)
	}
	
	
//	override ScriptTagBuilder[] injectFantomPods(Str pods) {
//		return pods.split.map |podName->ScriptTagBuilder| {
//			return injectRequireCall(podName)
//		}
//	}
	override ScriptTagBuilder injectFantomMethod(Method method, Obj?[]? args := null) {
		podName := method.parent.pod.name
		params := [podName:"_${podName}"]
		
		script := 
		"// find main
		 var qname = '$method.qname';
		 var dot = qname.indexOf('.');
		 if (dot < 0) qname += '.main';
		 var main = fan.sys.Slot.findMethod(qname);

		 // invoke main
		 if (main.isStatic()) main.call();
		 else main.callOn(main.parent().make());"

		return injectRequireScript(params, script)
	}
	
	override HtmlInjector appendToHead(HtmlNode node) {
		duvetProcessor.appendToHead(node)
		return this
	}
	
	override HtmlInjector appendToBody(HtmlNode node) {
		duvetProcessor.appendToBody(node)
		return this
	}	
}

