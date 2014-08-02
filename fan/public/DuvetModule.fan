using afIoc
using afIocConfig
using afBedSheet

** The [Ioc]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class DuvetModule { 

	static Void bind(ServiceBinder binder) {
		binder.bind(DuvetProcessor#)
		binder.bind(HtmlInjector#)
		binder.bind(ScriptModules#)

		binder.bind(PodModules#)	// only used in startup
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
	static Void contributeRoutes(Configuration conf, IocConfigSource iocConfig) {
		requireJsUrl := (Uri)  iocConfig.get(DuvetConfigIds.requireJsUrl,  Uri#)
		conf.add(Route(requireJsUrl, DuvetProcessor#routeRequireJs))
	}

	@Contribute { serviceType=FileHandler# }
	internal static Void contributeFileHandler(Configuration config, IocConfigSource cfgSrc, PodModules podModules) {
		basePodUrl := (Uri) cfgSrc.get(DuvetConfigIds.basePodUrl, Uri#)
		config[basePodUrl] = podModules.podDir
	}

	@Contribute { serviceType=ScriptModules# }
	internal static Void contributeScriptModules(Configuration config, PodModules podModules) {
		modulePaths := (ModulePaths) config.autobuild(ModulePaths#)

		config["afDuvet.modulePathOptimizations"]	= modulePaths.scriptModules
		config["afDuvet.fantomPods"] 				= podModules.scriptModules
	}

	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(Configuration config) {
		config[DuvetConfigIds.baseModuleUrl]	= `/modules/`
		config[DuvetConfigIds.basePodUrl]		= `/duvet/pods/`	// FIXME: validate basePodUrl
		config[DuvetConfigIds.requireJsUrl]		= `/scripts/require-2.1.14.js`
		config[DuvetConfigIds.requireJsFile]	= `fan://afDuvet/res/require-2.1.14.js`.get	// --> ZipEntryFile
		config[DuvetConfigIds.requireJsTimeout]	= 15sec
	}

	@Contribute { serviceType=RegistryStartup# }
	static Void contributeRegistryStartup(Configuration conf, IocConfigSource iocConfig) {
		conf["afDuvet.validateConfig"] = |->| {
			DuvetConfigIds.validateConfig(iocConfig)
		}
	}
}
