using afIoc
using afBedSheet

internal class TestMiddleware : DuvetTest {
	
	override Void setup() {
		startBedSheet([T_AppModule05#])
	}

	Void testCleanUpOnErr() {
		client.errOn5xx.enabled = false
		res := client.get(`/bang`)
		verifyEq(res.statusCode, 500)
		verifyFalse(res.body.str.contains("""<link href="//example.com/"""))
	}
	
}

internal const class T_AppModule05 {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf) {
		conf.add(Route(`/bang`,		T_AppModule05Routes#bang))
	}
}

internal const class T_AppModule05Routes {
	@Inject private const HtmlInjector? injector
	
	new make(|This|in) { in(this) }
	
	Text bang() {
		injector.injectLink.fromExternalUrl(`//example.com/`)
		throw Err("Bang!")
	}	
}