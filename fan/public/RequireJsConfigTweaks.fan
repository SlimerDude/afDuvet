using afIoc
using afIocConfig

** (Service) - 
** Contribute functions to make last minute tweaks to the RequireJs config. 
** After the tweaks are applied, the config is serialised as JSON and added to the page.
** 
** Example, to define multiple modules in one '.js' file use the [RequireJS bundles]`http://requirejs.org/docs/api.html#config-bundles` config property: 
** 
** pre>
** syntax: fantom
** 
** @Contribute { serviceType=RequireJsConfigTweaks# }
** static Void contributeRequireJsConfigTweaks(Configuration conf) {
**     conf["app.bundles"] = |Str:Obj? config| {
**         bundles := (Str:Str[]) config.getOrAdd("bundles") { [Str:Str[]][:] }
**         bundles["myModules"] = "moduleId1 moduleId2 moduleId3".split
**     }
** }
** <pre
** 
** Note that when doing so, your module define() functions need to specify their module name:
** 
**   syntax: fantom
** 
**   define("moduleId", ["jquery"], function($) { ... }
** 
const mixin RequireJsConfigTweaks {
	internal abstract HtmlNode tweakConfig(TagStyle tagStyle)
}

internal const class RequireJsConfigTweaksImpl : RequireJsConfigTweaks {
	
			@Inject private const ScriptModules	scriptModules
	@Inject @Config private const Uri			baseModuleUrl
	@Inject @Config private const Duration?		requireJsTimeout
					private const |Str:Obj?|[]	manipulators

	new make(|Str:Obj?|[] manipulators, |This| in) {
		in(this)
		this.manipulators = manipulators
	}

	override HtmlNode tweakConfig(TagStyle tagStyle) {
		config := Str:Obj?[:] { ordered = true }
		
		// all these could be tweaks themselves - but why?
		// if you don't like them, just tweak it!
		config["baseUrl"] 		= baseModuleUrl.toStr
		config["waitSeconds"]	= requireJsTimeout?.toSec ?: 0
		config["xhtml"] 		= (tagStyle != TagStyle.html)
		config["skipDataMain"]	= true
		
		scriptModules.addConfig(config)
		
		manipulators.each |func| {
			func(config)
		}
		
		args	:= util::JsonOutStream.writeJsonToStr(config)
		script	:= "requirejs.config(${args});"
		return HtmlElement("script").set("type", "text/javascript").add(HtmlText(script))
	}
}
