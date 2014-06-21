using afIoc
using afBedSheet

@NoDoc
const class DuvetModule { 

	static Void bind(ServiceBinder binder) {
		
		binder.bind(HtmlInjector#)
		binder.bind(ScriptInjector#)
		binder.bind(StylesheetInjector#)
		
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
