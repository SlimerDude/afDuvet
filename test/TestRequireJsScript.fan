using afIoc
using afIocConfig
using afBedSheet

internal class TestRequireJsScript : DuvetTest {
	
	@Inject @Config Uri? requireJsUrl
	
	override Void setup() {
		startBedSheet(T_AppModule02#)
	}
	
	Void testDownloadUrl() {
		requireJs := client.get(requireJsUrl).asStr
		verify(requireJs.contains("RequireJS 2.1.14 Copyright (c) 2010-2014, The Dojo Foundation All Rights Reserved."))
	}

	Void testRequireLibInHtml() {
		index := 0
		html  := client.get(`/require`).asStr
		
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
	
	@Contribute { serviceId="Routes" }
	static Void contributeRoutes(OrderedConfig conf) {
		conf.add(Route(`/require`, #require))
	}
	
	Text require() {
		injector.injectRequireCall("dude")
		return Text.fromHtml ("<html><head></head><body></body></html>")
	}
}