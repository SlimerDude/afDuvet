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
	** 
	** Note that by default the script is injected at the bottom of the '<body>' tag.
	abstract ScriptTagBuilder injectScript(Bool appendToHead := false)

	** Ensures that the RequireJS script and corresponding config is injected into the page.
	** 
	** A call to this is only required when you want to hard code require calls in the HTML. 
	** For example, if your HTML looked like this:
	** 
	** pre>
	** <html>
	** <body>
	**     <h1>Hello!</h1>
	**     <script>
	**         require(['jquery'], function($) {
	**             // ... wotever...
	**         });
	**     </script>
	** </body>
	** </html>
	** <pre
	** 
	** Then a call to 'injectRequireJs()' would be required to ensure RequireJS was loaded before the script call.
	abstract Void injectRequireJs()

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
	**   injectRequireModule("my/shirt", "addToCart", ["shirt", 1.99f])
	** 
	** will generate:
	** 
	**   <script type="text/javascript">
	**     require(["my/shirt"], function (module) { module.addToCart("shirt", 1.99); });
	**   </script>
	** 
	** Or, if the [RequireJS module returns a function as its module definition]`http://requirejs.org/docs/api.html#funcmodule` then it may be invoked directly by passing 'null' as the 'funcName'.
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
	abstract ScriptTagBuilder injectRequireModule(Str moduleId, Str? funcName := null, Obj?[]? funcArgs := null)

	** Injects a call to a Fantom method. That's right, this method lets you run Fantom code in your web browser!
	** 
	** Because Fantom only compiles classes with the '@Js' facet into Javascript, ensure the method's class has it! 
	** 
	** All method arguments must be '@Serializable' as they are serialised into Strings and embedded into the Javascript.
	** 
	** 'env' are environment variables passed into the Fantom Javascript runtime.
	** 
	** Note that when instantiating an FWT window, by default it takes up the whole browser window. 
	** To constrain the FWT window to a particular element on the page, pass in the follow environment variable:
	** 
	**   "fwt.window.root" : "<element-id>"
	** 
	** Where '<element-id>' is the html ID of an element on the page. The FWT window will attach itself to this element.
	** 
	** Note that the element needs to specify a width, height and give a CSS position of 'relative'. 
	** This may either be done in CSS or defined on the element directly:
	** 
	**   <div id="fwt-window" style="width: 640px; height:480px; position:relative;"></div>    
	abstract ScriptTagBuilder injectFantomMethod(Method method, Obj?[]? args := null, [Str:Str]? env := null)
	
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
	@Inject private const Scope				scope
	@Inject private const DuvetProcessor	duvetProcessor
	@Inject private const PodHandler		podHandler
	
	new make(|This|in) { in(this) }
	
	override MetaTagBuilder injectMeta() {
		bob := MetaTagBuilder()
		appendToHead(bob.htmlNode)
		return bob
	}

	override LinkTagBuilder injectLink() {
		bob := (LinkTagBuilder) scope.build(LinkTagBuilder#)
		appendToHead(bob.htmlNode)
		return bob
	}

	override LinkTagBuilder injectStylesheet() {
		injectLink.withRel("stylesheet").withType(MimeType("text/css"))
	}

	override ScriptTagBuilder injectScript(Bool inHead := false) {
		bob := (ScriptTagBuilder) scope.build(ScriptTagBuilder#)
		if (inHead)
			appendToHead(bob.htmlNode)
		else
			appendToBody(bob.htmlNode)
		return bob
	}
	
	override Void injectRequireJs() {
		duvetProcessor.addRequireJs		
	}
	
	override ScriptTagBuilder injectRequireScript(Str:Str scriptParams, Str script) {
		duvetProcessor.addRequireJs
		params 	:= scriptParams.keys.join(", ") { "\"${it}\"" }
		args	:= scriptParams.vals.join(", ")
		script	=  script.trim.isEmpty ? " " : "\n" + script + "\n"
		body	:= """require([${params}], function (${args}) {${script}});"""
		return injectScript.withScript(body)
	}
	
	override ScriptTagBuilder injectRequireModule(Str moduleId, Str? funcName := null, Obj?[]? funcArgs := null) {
		fCall := Str.defVal
		if (funcName != null || funcArgs != null) {
			fName := (funcName == null) ? Str.defVal : "." + funcName
			fArgs := (funcArgs == null) ? Str.defVal : funcArgs.join(", ") { JsonOutStream.writeJsonToStr(it) }
			fCall  = "module${fName}(${fArgs});"
		}
		return injectRequireScript([moduleId:"module"], fCall)
	}
 
	override ScriptTagBuilder injectFantomMethod(Method method, Obj?[]? args := null, [Str:Str]? env := null) {
		if (!method.parent.hasFacet(Js#))
			throw ArgErr(ErrMsgs.htmlInjector_noJsFacet(method.parent))

		podName := method.parent.pod.name
		jsParam	:= [podName:"_${podName}"]
		
		argStrs	:= args == null ? Str#.emptyList : args.map { Buf().writeObj(it).flip.readAllStr }
		jargs	:= argStrs.map |Str arg->Str| { "args.add(fan.sys.Str.toBuf(${arg.toCode}).readObj());" }

		envs	:= env?.rw ?: Str:Str[:] 
		if (!envs.containsKey("sys.uriPodBase") && podHandler.baseUrl != null)
			envs["sys.uriPodBase"] = podHandler.baseUrl.toStr

		envStr := StrBuf()
		if (envs?.size > 0) {
			envStr.add("var env = fan.sys.Map.make(fan.sys.Str.\$type, fan.sys.Str.\$type);\n")
			envStr.add("env.caseInsensitive\$(true);\n")
			envs.each |v, k| {
				v = v.toCode('\'')
				if (k == "sys.uriPodBase")
					envStr.add("fan.sys.UriPodBase = $v;\n")
				else
					envStr.add("env.set('$k', $v);\n")
			}
			envStr.add("fan.sys.Env.cur().\$setVars(env);\n")
		}
		
		script := 
		"
		 // default the TimeZone to a sensible default that doesn't cause errors
		 // see http://fantom.org/forum/topic/2548
		 if (fan.sys.TimeZone.m_cur == null)
		     fan.sys.TimeZone.m_cur = fan.sys.TimeZone.fromStr('UTC');

		 // inject env vars
		 $envStr.toStr
		 // construct method args
		 var args = fan.sys.List.make(fan.sys.Obj.\$type);
		 ${jargs.join('\n'.toChar)}
		
		 // find main
		 var qname = '$method.qname';
		 var main = fan.sys.Slot.findMethod(qname);

		 // invoke main
		 if (main.isStatic()) main.call(args);
		 else main.callOn(main.parent().make(), args);"

		return injectRequireScript(jsParam, script)
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

