using afIoc
using afIocConfig
using afBedSheet
using web::WebOutStream

** The [Ioc]`pod:afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class DuvetModule { 

	static Void defineServices(RegistryBuilder defs) {
		defs.addService(DuvetProcessor#)	.withRootScope
		defs.addService(HtmlInjector#)		.withRootScope
		defs.addService(ScriptModules#)		.withRootScope
		defs.addService(RequireJsConfigTweaks#).withRootScope
		defs.addService(DuvetPrinter#)		.withRootScope
	}

	internal static Void onRegistryStartup(Configuration config, ConfigSource configSrc, DuvetPrinter printer) {
		config["afDuvet.validateConfig"] = |->| {
			DuvetConfigIds.validateConfig(configSrc)
		}
		config.set("afDuvet.logModules", |->| {
			printer.logModules
		}).after("afIoc.logServices").after("afEfanXtra.logLibraries", true).after("afPillow.logLibraries", true)
	}

	@Contribute { serviceType=StackFrameFilter# }
	static Void contributeStackFrameFilter(Configuration config) {
		// remove meaningless and boring stack frames
		config.add("^afDuvet::DuvetMiddleware.+\$")
	}

	@Contribute { serviceType=ResponseProcessors# }
	internal static Void contributeResponseProcessors(Configuration config, DuvetProcessor duvetProcessor) {
		config.overrideValue(Text#, duvetProcessor, "afDuvet.textProcessor")
	}

	@Contribute { serviceType=MiddlewarePipeline# }
	static Void contributeMiddlewarePipeline(Configuration conf) {
		conf.set("afDuvet", conf.build(DuvetMiddleware#)).before("afBedSheet.routes")
	}
	
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf, ConfigSource configSrc) {
		requireJsUrl := (Uri) configSrc.get(DuvetConfigIds.requireJsUrl, Uri#)
		conf.add(Route(requireJsUrl, DuvetProcessor#routeRequireJs))
	}

	@Contribute { serviceType=ScriptModules# }
	internal static Void contributeScriptModules(Configuration config) {
		modulePaths := (ModulePaths) config.build(ModulePaths#)
		podModules	:= (PodModules)  config.build(PodModules#)

		config["afDuvet.cacheModuleUrls"]	= modulePaths.scriptModules
		config["afDuvet.podModules"] 		= podModules.scriptModules
	}

	@Contribute { serviceType=NotFoundPrinterHtml# }
	internal static Void contributeNotFoundHtml(Configuration config, DuvetPrinter printer) {
		// make contribution ordering optional so we don't break should the BedSheet names change.
		config.set("afDuvet.requireJsModules",	|WebOutStream out| { printer.printModules(out) }).after("afBedSheet.routes", true)
	}

	@Contribute { serviceType=ErrPrinterHtml# }
	internal static Void contributeErrorHtml(Configuration config, DuvetPrinter printer) {
		// make contribution ordering optional so we don't break should the BedSheet names change.
		config.set("afDuvet.requireJsModules",	|WebOutStream out, Err? err| { printer.printModules(out) }).after("afBedSheet.routes", true).before("afBedSheet.locals", true)
	}
	
	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(Configuration config) {
		config[DuvetConfigIds.baseModuleUrl]	= `/modules/`
		config[DuvetConfigIds.requireJsUrl]		= `/scripts/require-2.1.14.js`
		config[DuvetConfigIds.requireJsFile]	= `fan://afDuvet/res/require-2.1.14.js`.get	// --> ZipEntryFile
		config[DuvetConfigIds.requireJsTimeout]	= 15sec
		config[DuvetConfigIds.disableSmartInsertion]	= false
	}
}
