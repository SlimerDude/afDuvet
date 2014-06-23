using afIoc
using afConcurrent
using afBedSheet
using util

const class Require {
	@Inject private const HtmlInjector	injector
	@Inject private const LocalList		requires
	
	new make(|This|in) { in(this) }

	Void invokeFunc(Str moduleId, Str? funcName := null, Obj?[]? funcArgs := null) {
		// FIXME: adding require script
		injector.injectScript.fromClientUrl(`/scripts/require-2.1.14.js`)
		
//		invoker := ScriptInvoker(moduleId) {
//			it.funcName = funcName
//			it.funcArgs = funcArgs
//		}
//		requires.add(invoker)
//		return invoker
	}

	Void require(Str:Str scriptParams, Str script) {
		
		// FIXME: adding require script
		injector.injectScript.fromClientUrl(`/scripts/require-2.1.14.js`)
		
		invoker := ScriptInvoker(scriptParams, script)
		requires.add(invoker)
//		return invoker
	}
	
	internal Str printBody(TagStyle tagStyle) {
		script	:= requires.list.join("\n") { it->toScript }
//		element := HtmlElement("script", """type="text/javascript" """).add(HtmlText(script))
//		return element.print(tagStyle)
		return ""
	}
}


class ScriptInvoker {
	private Str:Str scriptParams
	private Str		script

	internal new make(Str:Str scriptParams, Str script) {
		this.scriptParams	= scriptParams
		this.script			= script
	}
	
	Str toScript() {
		params 	:= scriptParams.keys.join(", ") { "\"${it}\"" }
		args	:= scriptParams.vals.join(", ")
//		fCall := Str.defVal
//		if (funcName != null || funcArgs != null) {
//			fName := (funcName == null) ? Str.defVal : "." + funcName
//			fArgs := (funcArgs == null) ? Str.defVal : funcArgs.join(", ") { JsonOutStream.writeJsonToStr(it) }
//			fCall  = "module${fName}(${fArgs});"
//		}
		return """require([${params}], function(${args}){\n${script}\n});"""
	}


//	Str toScript() {
//		fCall := Str.defVal
//		if (funcName != null || funcArgs != null) {
//			fName := (funcName == null) ? Str.defVal : "." + funcName
//			fArgs := (funcArgs == null) ? Str.defVal : funcArgs.join(", ") { JsonOutStream.writeJsonToStr(it) }
//			fCall  = "module${fName}(${fArgs});"
//		}
//		return """require(["${moduleId}"], function(module){ ${fCall} });"""
//	}
}