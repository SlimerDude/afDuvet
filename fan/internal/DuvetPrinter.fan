using afIoc::Inject
using web::WebOutStream

internal const class DuvetPrinter {
	@Inject private	const Log			log
	@Inject private	const ScriptModules	scriptModules
	
	new make(|This| in) { in(this) }

	Void logModules() {
		modPaths := scriptModules.modulePaths
		buf := StrBuf()
		buf.add("\nDuvet is configured with ${modPaths.size} RequireJS modules:\n\n")
		maxName	 := (Int) modPaths.keys.reduce(0) |Int size, modId| { size.max(modId.size) }
		modPaths.keys.sort.each |modId| {
			url := modPaths[modId]
			if (url is List)
				url = ((Obj[]) url).join(" --> ")
			buf.add("  ${modId.padl(maxName)} : ${url}\n")
		}
		log.info(buf.toStr)
	}
	
	Void printModules(WebOutStream out) {
		title(out, "Duvet RequireJS Modules")

		modPaths := scriptModules.modulePaths
		map := [:] { ordered=true }
		modPaths.keys.sort.each |modId| {
			url := modPaths[modId]
			if (url is List)
				url = ((Obj[]) url).join(" --> ")
			map[modId] = url
		}

		prettyPrintMap(out, map, false)
	}
	
	private Void title(WebOutStream out, Str title) {
		out.h2("id=\"${title.fromDisplayName}\"").w(title).h2End
	}
	
	private Void prettyPrintMap(WebOutStream out, Str:Obj? map, Bool sort, Str? cssClass := null) {
		if (sort) {
			newMap := Str:Obj?[:] { ordered = true } 
			map.keys.sort.each |k| { newMap[k] = map[k] }
			map = newMap
		}
		out.table(cssClass == null ? null : "class=\"${cssClass}\"")
		map.each |v, k| { w(out, k, v) } 
		out.tableEnd
	}

	private Void w(WebOutStream out, Str key, Obj? val) {
		out.tr.td.writeXml(key).tdEnd.td.writeXml(val?.toStr ?: "null").tdEnd.trEnd
	}
}
