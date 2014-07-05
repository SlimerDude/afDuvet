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
	}

	@Contribute { serviceType=ResponseProcessors# }
	internal static Void contributeResponseProcessors(MappedConfig config, DuvetProcessor duvetProcessor) {
		config.setOverride(Text#, duvetProcessor, "afDuvet.TextProcessor")
	}

	@Contribute { serviceType=MiddlewarePipeline# }
	static Void contributeMiddlewarePipeline(OrderedConfig conf) {
		conf.addOrdered("Duvet", conf.autobuild(DuvetMiddleware#), ["before: Routes"])
	}
	
	@Contribute { serviceId="Routes" }
	static Void contributeRoutes(OrderedConfig conf, IocConfigSource iocConfig) {
		requireJsUrl := (Uri)  iocConfig.get(DuvetConfigIds.requireJsUrl,  Uri#)
		conf.add(Route(requireJsUrl, DuvetProcessor#routeRequireJs))
	}

	@Contribute { serviceType=ScriptModules# }
	static Void contributeScriptModules(OrderedConfig config) {
		modulePaths := (ModulePaths) config.autobuild(ModulePaths#)
		mods := modulePaths.scriptModules
		config.addOrdered("ModulePathOptimizations", mods)
	}

	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(MappedConfig config) {
		config[DuvetConfigIds.requireBaseUrl]	= `/modules/`
		config[DuvetConfigIds.requireJsUrl]		= `/scripts/require-2.1.14.js`
		config[DuvetConfigIds.requireJsFile]	= `fan://afDuvet/res/require-2.1.14.js`.get	// --> ZipEntryFile
		config[DuvetConfigIds.requireTimeout]	= 15sec
	}

	@Contribute { serviceType=RegistryStartup# }
	static Void contributeRegistryStartup(OrderedConfig conf, IocConfigSource iocConfig) {
		conf.addOrdered("afDuvet.validateConfig") |->| {
			DuvetConfigIds.validateConfig(iocConfig)
		}
	}
}
