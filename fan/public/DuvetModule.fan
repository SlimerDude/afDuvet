using afIoc
using afBedSheet

@NoDoc
const class DuvetModule { 

	static Void bind(ServiceBinder binder) {
		
		binder.bind(HtmlInjector#).withoutProxy		// got internal methods
		binder.bind(ScriptInjector#).withoutProxy
		binder.bind(StylesheetInjector#)
		binder.bind(ScriptModules#)

		binder.bind(Require#)
		
	}

//	@Contribute { serviceType=MiddlewarePipeline# }
//	static Void contributeMiddleware(OrderedConfig config) {
//		config.addOrdered("DuvetMiddleware", config.autobuild(DuvetMiddleware#))
//	}
	
	@Contribute { serviceType=ResponseProcessors# }
	static Void contributeResponseProcessors(MappedConfig config) {
		config.setOverride(Text#, config.autobuild(DuvetResponseProcessor#), "afDuvet.TextProcessor")
	}

}
