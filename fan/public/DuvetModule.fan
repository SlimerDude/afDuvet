using afIoc
using afIocConfig
using afBedSheet
using web::WebOutStream

** The [Ioc]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class DuvetModule { 

	static Void defineServices(ServiceDefinitions defs) {
		defs.add(DuvetProcessor#)
		defs.add(HtmlInjector#)
		defs.add(ScriptModules#)		
		defs.add(RequireJsConfigTweaks#)
		defs.add(DuvetPrinter#)
	}

	@Contribute { serviceType=ResponseProcessors# }
	internal static Void contributeResponseProcessors(Configuration config, DuvetProcessor duvetProcessor) {
		config.overrideValue(Text#, duvetProcessor, "afDuvet.textProcessor")
	}

	@Contribute { serviceType=MiddlewarePipeline# }
	static Void contributeMiddlewarePipeline(Configuration conf) {
		conf.set("afDuvet", conf.autobuild(DuvetMiddleware#)).before("afBedSheet.routes")
	}
	
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf, ConfigSource configSrc) {
		requireJsUrl := (Uri) configSrc.get(DuvetConfigIds.requireJsUrl, Uri#)
		conf.add(Route(requireJsUrl, DuvetProcessor#routeRequireJs))
	}

	@Contribute { serviceType=ScriptModules# }
	internal static Void contributeScriptModules(Configuration config) {
		modulePaths := (ModulePaths) config.autobuild(ModulePaths#)
		podModules	:= (PodModules)  config.autobuild(PodModules#)

		config["afDuvet.cacheModuleUrls"]	= modulePaths.scriptModules
		config["afDuvet.podModules"] 		= podModules.scriptModules
	}

	@Contribute { serviceType=NotFoundPrinterHtml# }
	internal static Void contributeNotFoundHtml(Configuration config, DuvetPrinter printer) {
		config.set("afDuvet.requireJsModules",	|WebOutStream out| { printer.printModules(out) }).after("afPillow.pillowPages").before("afBedSheet.routes")
	}

	@Contribute { serviceType=ErrPrinterHtml# }
	internal static Void contributeErrorHtml(Configuration config, DuvetPrinter printer) {
		config.set("afDuvet.requireJsModules",	|WebOutStream out, Err? err| { printer.printModules(out) }).after("afPillow.pillowPages").before("afBedSheet.routes")
	}
	
	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(Configuration config) {
		config[DuvetConfigIds.baseModuleUrl]	= `/modules/`
		config[DuvetConfigIds.requireJsUrl]		= `/scripts/require-2.1.14.js`
		config[DuvetConfigIds.requireJsFile]	= `fan://afDuvet/res/require-2.1.14.js`.get	// --> ZipEntryFile
		config[DuvetConfigIds.requireJsTimeout]	= 15sec
	}

	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(Configuration config, ConfigSource configSrc, DuvetPrinter printer) {
		config["afDuvet.validateConfig"] = |->| {
			DuvetConfigIds.validateConfig(configSrc)
		}
		config["afDuvet.logModules"] = |->| {
			printer.logModules
		}
	}
}
