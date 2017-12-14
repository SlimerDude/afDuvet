using afIoc
using afIocConfig
using afBedSheet

internal class TestRequireJsScript : DuvetTest {
	
	@Inject @Config Uri? requireJsUrl
	
	override Void setup() {
		startBedSheet([T_AppModule02#])
	}
	
	Void testDownloadUrl() {
		res 		:= client.get(requireJsUrl)
		requireJs	:= res.body.str
		verify(requireJs.contains("@license RequireJS 2.3.5 Copyright jQuery Foundation and other contributors."))
		
		// don't care so much for when it expires, just that it does.
		verify(res.headers.expires > DateTime.now)
	}

	Void testRequireLibInHtml() {
		index := 0
		html  := client.get(`/require`).body.str
		
		index = html.index("<script type=\"text/javascript\" src=\"${requireJsUrl}\"></script>", index)
		verifyNotNull(index)
		
		index = html.index("<script type=\"text/javascript\">requirejs.config(")
		verifyNotNull(index)

		index = html.index("<script type=\"text/javascript\">require([\"dude\"], function (module) { });</script>", index)
		verifyNotNull(index)
	}
}

internal const class T_AppModule02 {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf) {
		conf.add(Route(`/require`, T_AppModule02Routes#require))
	}
}

internal const class T_AppModule02Routes {
	@Inject private const HtmlInjector? injector
	
	new make(|This|in) { in(this) }

	Text require() {
		injector.injectRequireModule("dude")
		return Text.fromHtml ("<html><head></head><body></body></html>")
	}
}