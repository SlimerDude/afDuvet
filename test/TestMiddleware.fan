using afIoc
using afBedSheet

internal class TestMiddleware : DuvetTest {
	
	override Void setup() {
		startBedSheet(T_AppModule05#)
	}

	Void testCleanUpOnErr() {
		client.errOn5xx.enabled = false
		res := client.get(`/bang`)
		verifyEq(res.statusCode, 500)
		verifyFalse(res.asStr.contains("""<link href="//example.com/"""))
	}
	
}

internal class T_AppModule05 {
	@Inject private HtmlInjector? injector
	
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf) {
		conf.add(Route(`/bang`,		#bang))
	}
	
	Text bang() {
		injector.injectLink.fromExternalUrl(`//example.com/`)
		throw Err("Bang!")
	}	
}