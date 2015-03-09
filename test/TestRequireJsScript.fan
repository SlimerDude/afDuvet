using afIoc
using afIocConfig
using afBedSheet

internal class TestRequireJsScript : DuvetTest {
	
	@Inject @Config Uri? requireJsUrl
	
	override Void setup() {
		startBedSheet(T_AppModule02#)
	}
	
	Void testDownloadUrl() {
		res 		:= client.get(requireJsUrl)
		requireJs	:= res.body.str
		verify(requireJs.contains("RequireJS 2.1.14 Copyright (c) 2010-2014, The Dojo Foundation All Rights Reserved."))
		
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

internal class T_AppModule02 {
	@Inject private HtmlInjector? injector
	
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf) {
		conf.add(Route(`/require`, #require))
	}
	
	Text require() {
		injector.injectRequireModule("dude")
		return Text.fromHtml ("<html><head></head><body></body></html>")
	}
}