using afIoc
using afBedSheet

internal class TestLinkInjection : DuvetTest {
	
	@Inject HtmlInjector? injector
	
	override Void setup() {
		startBedSheet([T_AppModule04#])
	}
	
	Void testExternalUrls() {
		// these are fine
		injector.injectStylesheet.fromExternalUrl(`http://example.com/wotever.css`)
		injector.injectStylesheet.fromExternalUrl(`//example.com/wotever.css`)
		
		// these are not
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`/wotever.css`)) {
			injector.injectStylesheet.fromExternalUrl(`/wotever.css`)
		}
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`dude/wotever.css`)) {
			injector.injectStylesheet.fromExternalUrl(`dude/wotever.css`)
		}
	}
	
	Void testMultipleLinks() {
		html := client.get(`/twoDiff`).body.str
		verifyEq(html, "<html><head>\n<link href=\"//example1.com/\">\n<link href=\"//example2.com/\">\n</head><body></body></html>")

		html  = client.get(`/twoSame`).body.str
		verifyEq(html, "<html><head>\n<link href=\"//example.com/\">\n</head><body></body></html>")
	}
	
	Void testConditional() {
		html := client.get(`/conditional`).body.str
		verifyEq(html, "<html><head>\n<!--[if IE]><link href=\"//example.com/\"><![endif]-->\n</head><body></body></html>")
	}
}

internal const class T_AppModule04 {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf) {
		conf.add(Route(`/twoSame`,		T_AppModule04Routes#twoSame))
		conf.add(Route(`/twoDiff`,		T_AppModule04Routes#twoDiff))
		conf.add(Route(`/conditional`,	T_AppModule04Routes#conditional))
	}
}
	
internal const class T_AppModule04Routes {
	@Inject private const HtmlInjector? injector
	
	new make(|This|in) { in(this) }

	Text conditional() {
		injector.injectLink.fromExternalUrl(`//example.com/`).ifIe("if IE")
		return Text.fromHtml("<html><head></head><body></body></html>")
	}
	
	Text twoSame() {
		injector.injectLink.fromExternalUrl(`//example.com/`)
		injector.injectLink.fromExternalUrl(`//example.com/`)
		return Text.fromHtml("<html><head></head><body></body></html>")
	}

	Text twoDiff() {
		injector.injectLink.fromExternalUrl(`//example1.com/`)
		injector.injectLink.fromExternalUrl(`//example2.com/`)
		return Text.fromHtml("<html><head></head><body></body></html>")
	}
}