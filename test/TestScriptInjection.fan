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
		echo(html)
		myScript1 := html.index("myScript1")	?: throw Err("Script not found")
		myScript2 := html.index("myScript2")	?: throw Err("Script not found")
		requireJs := html.index(requireJsUrl)	?: throw Err("Require not found")
		verify(requireJs < myScript1)
		verify(requireJs < myScript2)
	}

	Void testMidScript() {
		html := client.get(`/scriptX0`).body.str
		echo(html)
		myScript1 := html.index("myScript1")	?: throw Err("Script not found")
		myScript2 := html.index("myScript2")	?: throw Err("Script not found")
		requireJs := html.index(requireJsUrl)	?: throw Err("Require not found")
		wotever  := html.index("<p>wotever</p>")?: throw Err("Wotever not found")
		verify(myScript1 < requireJs)
		verify(wotever   < requireJs)
		verify(requireJs < myScript2)
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

internal class T_AppModule03 {
	@Inject private HtmlInjector? injector
	
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf) {
		conf.add(Route(`/head`,		#head))
		conf.add(Route(`/body`, 	#body))
		conf.add(Route(`/twoSame`,	#twoSame))
		conf.add(Route(`/twoDiff`,	#twoDiff))
		conf.add(Route(`/twoNoSrc`,	#twoNoSrc))
		conf.add(Route(`/scriptX1`,	#myOwnRequireScript))
		conf.add(Route(`/scriptX2`,	#scriptX2))
		conf.add(Route(`/scriptX0`,	#scriptX0))
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
}

internal class T_AppModule06 {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(Configuration config) {
		config[DuvetConfigIds.disableSmartInsertion]	= true
	}
}
