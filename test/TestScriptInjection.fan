using afIoc
using afBedSheet

internal class TestScriptInjection : DuvetTest {
	
	@Inject HtmlInjector? injector
	
	override Void setup() {
		startBedSheet(T_AppModule03#)
	}

	Void testExternalUrls() {
		// these are fine
		injector.injectScript.fromExternalUrl(`http://example.com/wotever.css`)
		injector.injectScript.fromExternalUrl(`//example.com/wotever.css`)
		
		// these are not
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`/wotever.css`)) {
			injector.injectScript.fromExternalUrl(`/wotever.css`)
		}
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`dude/wotever.css`)) {
			injector.injectScript.fromExternalUrl(`dude/wotever.css`)
		}
	}
	
	Void testHeadBodyInjection() {
		html := client.get(`/head`).body.str
		verifyEq(html, "<html><head>\n<script type=\"text/javascript\"></script>\n</head><body></body></html>")

		html  = client.get(`/body`).body.str
		verifyEq(html, "<html><head></head><body>\n<script type=\"text/javascript\"></script>\n</body></html>")
	}
	
	Void testMultipleScripts() {
		html := client.get(`/twoDiff`).body.str
		verifyEq(html, "<html><head></head><body>\n<script type=\"text/javascript\" src=\"//example1.com/\"></script>\n<script type=\"text/javascript\" src=\"//example2.com/\"></script>\n</body></html>")

		html  = client.get(`/twoSame`).body.str
		verifyEq(html, "<html><head></head><body>\n<script type=\"text/javascript\" src=\"//example.com/\"></script>\n</body></html>")
	}

	Void testMultipleScriptsWithNoSrcAttribute() {
		html := client.get(`/twoNoSrc`).body.str
		verify(html.contains("alert(1)"))
		verify(html.contains("alert(2)"))
	}
}

internal class T_AppModule03 {
	@Inject private HtmlInjector? injector
	
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf) {
		conf.add(Route(`/head`,		#head))
		conf.add(Route(`/body`, 	#body))
		conf.add(Route(`/twoSame`,	#twoSame))
		conf.add(Route(`/twoDiff`,	#twoDiff))
		conf.add(Route(`/twoNoSrc`,	#twoNoSrc))
	}
	
	Text head() {
		injector.injectScript(true)
		return Text.fromHtml("<html><head></head><body></body></html>")
	}

	Text body() {
		injector.injectScript(false)
		return Text.fromHtml("<html><head></head><body></body></html>")
	}

	Text twoSame() {
		injector.injectScript.fromExternalUrl(`//example.com/`)
		injector.injectScript.fromExternalUrl(`//example.com/`)
		return Text.fromHtml("<html><head></head><body></body></html>")
	}

	Text twoDiff() {
		injector.injectScript.fromExternalUrl(`//example1.com/`)
		injector.injectScript.fromExternalUrl(`//example2.com/`)
		return Text.fromHtml("<html><head></head><body></body></html>")
	}

	Text twoNoSrc() {
		injector.injectScript.withScript("alert(1)")
		injector.injectScript.withScript("alert(2)")
		return Text.fromHtml("<html><head></head><body></body></html>")
	}
}