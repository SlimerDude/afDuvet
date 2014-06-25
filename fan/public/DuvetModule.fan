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
		requireJsUrl	:= (Uri)  iocConfig.get(DuvetConfigIds.requireJsUrl,  Uri#)
		requireJsFile	:= (File) iocConfig.get(DuvetConfigIds.requireJsFile, File#)
		conf.add(Route(requireJsUrl, requireJsFile))
	}
	
	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(MappedConfig config) {
		config[DuvetConfigIds.requireBaseUrl]	= `/modules/`
		config[DuvetConfigIds.requireJsUrl]		= `/scripts/require.js`
		config[DuvetConfigIds.requireJsFile]	= `fan://afDuvet/res/require-2.1.14.js`.get	// --> ZipEntryFile
		config[DuvetConfigIds.requireTimeout]	= 15sec
	}
	
	@Contribute { serviceType=RegistryStartup# }
	static Void contributeRegistryStartup(OrderedConfig conf, IocConfigSource iocConfig) {
		conf.addOrdered("afDuvet.validateConfig") |->| {

			requireBaseUrl := (Uri) iocConfig.get(DuvetConfigIds.requireBaseUrl, Uri#)
			if (!requireBaseUrl.isPathOnly)
				throw ParseErr(ErrMsgs.urlMustBePathOnly("Module Base", requireBaseUrl, `/modules/`))
			if (!requireBaseUrl.isPathAbs)
				throw ParseErr(ErrMsgs.urlMustStartWithSlash("Module Base", requireBaseUrl, `/modules/`))
			if (!requireBaseUrl.isDir)
				throw ParseErr(ErrMsgs.urlMustNotEndWithSlash("Module Base", requireBaseUrl, `/modules/`))
			
			requireJsUrl := (Uri) iocConfig.get(DuvetConfigIds.requireJsUrl, Uri#)
			if (!requireJsUrl.isPathOnly)
				throw ParseErr(ErrMsgs.urlMustBePathOnly("RequireJS", requireJsUrl, `/scripts/require.js`))
			if (!requireJsUrl.isPathAbs)
				throw ParseErr(ErrMsgs.urlMustStartWithSlash("RequireJS", requireJsUrl, `/scripts/require.js`))
			if (requireJsUrl.isDir)
				throw ParseErr(ErrMsgs.urlMustEndWithSlash("RequireJS", requireJsUrl, `/scripts/require.js`))
			
			requireJsFile := (File) iocConfig.get(DuvetConfigIds.requireJsFile, File#)
			if (!requireJsFile.exists)
				throw ParseErr(ErrMsgs.requireJsLibNoExist(requireJsFile))
			
			requireTimeout := (Duration?) iocConfig.get(DuvetConfigIds.requireTimeout, Duration?#)
			if (requireTimeout != null && requireTimeout < 0ms)
				throw ParseErr(ErrMsgs.requireTimeoutMustBePositive(requireTimeout))
		}
	}
}
