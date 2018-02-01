using afIoc
using afIocConfig
using afBedSheet
using web::WebOutStream

** The [Ioc]`pod:afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class DuvetModule { 

	Void defineServices(RegistryBuilder defs) {
		defs.addService(DuvetProcessor#)
		defs.addService(HtmlInjector#)
		defs.addService(ScriptModules#)
		defs.addService(RequireJsConfigTweaks#)
		defs.addService(DuvetPrinter#)
	}

	internal Void onRegistryStartup(Configuration config, ConfigSource configSrc, DuvetPrinter printer) {
		config["afDuvet.validateConfig"] = |->| {
			DuvetConfigIds.validateConfig(configSrc)
		}
		config.set("afDuvet.logModules", |->| {
			printer.logModules
		}).after("afIoc.logServices").after("afEfanXtra.logLibraries", true).after("afPillow.logLibraries", true)
	}

	@Contribute { serviceType=StackFrameFilter# }
	Void contributeStackFrameFilter(Configuration config) {
		// remove meaningless and boring stack frames
		config.add("^afDuvet::DuvetMiddleware.+\$")
	}

	@Contribute { serviceType=ResponseProcessors# }
	internal Void contributeResponseProcessors(Configuration config, DuvetProcessor duvetProcessor) {
		config.overrideValue(Text#, duvetProcessor, "afDuvet.textProcessor")
	}

	@Contribute { serviceType=MiddlewarePipeline# }
	Void contributeMiddlewarePipeline(Configuration conf) {
		conf.set("afDuvet", conf.build(DuvetMiddleware#)).before("afBedSheet.routes")
	}
	
	@Contribute { serviceType=Routes# }
	Void contributeRoutes(Configuration config, ConfigSource configSrc) {
		tzJsUrl		 := (Uri) configSrc.get(DuvetConfigIds.tzJsUrl, Uri#)
		requireJsUrl := (Uri) configSrc.get(DuvetConfigIds.requireJsUrl, Uri#)
		config.add(Route(tzJsUrl,		 DuvetProcessor#routeTzJs))
		config.add(Route(requireJsUrl, DuvetProcessor#routeRequireJs))
	}

	@Contribute { serviceType=ScriptModules# }
	internal Void contributeScriptModules(Configuration config, ConfigSource configSrc) {
		tzJsUrl		:= (Uri) configSrc.get(DuvetConfigIds.tzJsUrl, Uri#)
		modulePaths := (ModulePaths) config.build(ModulePaths#)
		podModules	:= (PodModules)  config.build(PodModules#)
		config["afDuvet.cacheModuleUrls"]	= modulePaths.scriptModules
		config["afDuvet.podModules"] 		= podModules.scriptModules
		config["afDuvet.tzJs"] 				= ScriptModule("sysTz").atUrl(tzJsUrl)
	}

	@Contribute { serviceType=NotFoundPrinterHtml# }
	internal Void contributeNotFoundHtml(Configuration config, DuvetPrinter printer) {
		// make contribution ordering optional so we don't break should the BedSheet names change.
		config.set("afDuvet.requireJsModules",	|WebOutStream out| { printer.printModules(out) }).after("afBedSheet.routes", true)
	}

	@Contribute { serviceType=ErrPrinterHtml# }
	internal Void contributeErrorHtml(Configuration config, DuvetPrinter printer) {
		// make contribution ordering optional so we don't break should the BedSheet names change.
		config.set("afDuvet.requireJsModules",	|WebOutStream out, Err? err| { printer.printModules(out) }).after("afBedSheet.routes", true).before("afBedSheet.locals", true)
	}
	
	@Contribute { serviceType=FactoryDefaults# }
	Void contributeFactoryDefaults(Configuration config) {
		config[DuvetConfigIds.baseModuleUrl]			= `/modules/`
		config[DuvetConfigIds.tzJsUrl]					= `/scripts/tz.js`
		config[DuvetConfigIds.requireJsUrl]				= `/scripts/require-2.3.5.js`
		config[DuvetConfigIds.requireJsFile]			= `fan://afDuvet/res/require-2.3.5.js`.get	// --> ZipEntryFile
		config[DuvetConfigIds.requireJsTimeout]			= 15sec
		config[DuvetConfigIds.disableSmartInsertion]	= false
		config[DuvetConfigIds.updateCspHeader]			= true
	}
}
