using afIoc
using afIocConfig
using afBedSheet

internal class TestScriptInjection : DuvetTest {
	
	@Inject HtmlInjector?	injector
	@Inject @Config Str? 	requireJsUrl
	
	override Void setup() {
		startBedSheet([T_AppModule03#])
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

	Void testRequireIsInjectedBeforeCustomScripts() {
		html := client.get(`/scriptX1`).body.str
		myScript := html.index("myScript")	 ?: throw Err("Script not found")
		requireJ := html.index(requireJsUrl) ?: throw Err("Require not found")
		verify(requireJ < myScript)
	}

	Void testDoubleScripts() {
		html := client.get(`/scriptX2`).body.str
		myScript1 := html.index("myScript1")	?: throw Err("Script not found")
		myScript2 := html.index("myScript2")	?: throw Err("Script not found")
		requireJs := html.index(requireJsUrl)	?: throw Err("Require not found")
		verify(requireJs < myScript1)
		verify(requireJs < myScript2)
	}

	Void testMidScript() {
		html := client.get(`/scriptX0`).body.str
		myScript1 := html.index("myScript1")	?: throw Err("Script not found")
		myScript2 := html.index("myScript2")	?: throw Err("Script not found")
		requireJs := html.index(requireJsUrl)	?: throw Err("Require not found")
		wotever  := html.index("<p>wotever</p>")?: throw Err("Wotever not found")
		verify(myScript1 < requireJs)
		verify(wotever   < requireJs)
		verify(requireJs < myScript2)
	}

	Void testRequireIsInjectedBeforeCustomScripts2() {
		// check it still works with a plain <script> tag
		html := client.get(`/script2X1`).body.str
		myScript := html.index("<script>")	 ?: throw Err("Script not found")
		requireJ := html.index(requireJsUrl) ?: throw Err("Require not found")
		verify(requireJ < myScript)
	}
}

internal class TestDisableSmartScriptInjection : DuvetTest {
	
	@Inject HtmlInjector?	injector
	@Inject @Config Str? 	requireJsUrl
	
	override Void setup() {
		startBedSheet([T_AppModule03#, T_AppModule06#])
	}
	
	Void testRequireIsNOTinjectedBeforeCustomScripts() {
		html := client.get(`/scriptX1`).body.str
		myScript := html.index("myScript")	 ?: throw Err("Script not found")
		requireJ := html.index(requireJsUrl) ?: throw Err("Require not found")
		verify(requireJ > myScript)
	}
}

internal const class T_AppModule03 {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf) {
		conf.add(Route(`/head`,		T_AppModule03Routes#head))
		conf.add(Route(`/body`, 	T_AppModule03Routes#body))
		conf.add(Route(`/twoSame`,	T_AppModule03Routes#twoSame))
		conf.add(Route(`/twoDiff`,	T_AppModule03Routes#twoDiff))
		conf.add(Route(`/twoNoSrc`,	T_AppModule03Routes#twoNoSrc))
		conf.add(Route(`/scriptX1`,	T_AppModule03Routes#myOwnRequireScript))
		conf.add(Route(`/scriptX2`,	T_AppModule03Routes#scriptX2))
		conf.add(Route(`/scriptX0`,	T_AppModule03Routes#scriptX0))
		conf.add(Route(`/script2X1`,T_AppModule03Routes#myOwnRequireScript2))
	}
}

internal const class T_AppModule03Routes {
	@Inject const private HtmlInjector? injector
	
	new make(|This|in) { in(this) }
	
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

	Text myOwnRequireScript() {
		injector.injectRequireJs
		return Text.fromHtml("<html>
		                          <head></head>
		                          <body>
		                              <script id='myScript'>
		                                  require(['jquery'], function (\$) {
		                                      \$('p').addClass('magic');
		                                  });
		                              </script>
		                          </body>
		                      </html>")
	}

	Text scriptX2() {
		injector.injectRequireJs
		return Text.fromHtml("<html>
		                          <head></head>
		                          <body>
		                              <script id='myScript1'></script>
		                              <script id='myScript2'></script>
		                          </body>
		                      </html>")
	}

	Text scriptX0() {
		injector.injectRequireJs
		return Text.fromHtml("<html>
		                          <head></head>
		                          <body>
		                              <script id='myScript1'></script>
		                              <p>wotever</p>
		                              <script id='myScript2'></script>
		                          </body>
		                      </html>")
	}

	Text myOwnRequireScript2() {
		injector.injectRequireJs
		return Text.fromHtml("<html>
		                          <head></head>
		                          <body>
		                              <script>
		                                  require(['jquery'], function (\$) {
		                                      \$('p').addClass('magic');
		                                  });
		                              </script>
		                          </body>
		                      </html>")
	}
}

internal const class T_AppModule06 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(Configuration config) {
		config[DuvetConfigIds.disableSmartInsertion]	= true
	}
}
