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
		Env.cur.err.printLine(res.asStr)
		verifyFalse(res.asStr.contains("""<link href="//example.com/"""))
	}
	
}

internal class T_AppModule05 {
	@Inject private HtmlInjector? injector
	
	@Contribute { serviceId="Routes" }
	static Void contributeRoutes(OrderedConfig conf) {
		conf.add(Route(`/bang`,		#bang))
	}
	
	Text bang() {
		injector.injectLink.fromExternalUrl(`//example.com/`)
		throw Err("Bang!")
	}	
}