using afIoc
using afBedSheet
using afBounce
using afConcurrent

internal class TestInjection : DuvetTest {
	private static const AtomicList logs := AtomicList()
	private static const |LogRec rec| handler := |LogRec rec| { logs.add(rec) }
	
	override Void setup() {
		startBedSheet(T_AppModule01#)
		logs.clear
		Log.addHandler(handler)
	}
	
	override Void teardown() {
		Log.removeHandler(handler)
		logs.clear
	}

	Void testHtmlInjection() {
		html := client.get(`/html`).asStr
		Env.cur.err.printLine(html)
		verifyEq(html, """<html><head><title> HTML Test</title>\n<link rel="stylesheet" type="text/css" href="http://www.example.com/dude.css">\n</head><body> --body-- </body></html>""")
	}

	Void testXmlInjection() {
		html := client.get(`/xml`).asStr
		verifyEq(html, """<html><head><title> HTML Test</title>\n<link rel="stylesheet" type="text/css" href="http://www.example.com/dude.css" />\n</head><body> --body-- </body></html>""")
	}
	
	Void testNoHeadIsOkay() {
		html := client.get(`/noHead`).asStr
		verifyEq(html, "<html><body> --- </body></html>")
		
		verifyEq(logs.size, 1)
		rec := logs.list.first as LogRec
		verifyEq(rec.level,	LogLevel.warn)
		verifyEq(rec.msg, 	LogMsgs.canNotFindHead)
	}
	
	Void testNoBodyIsOkay() {
		html := client.get(`/noBody`).asStr
		verifyEq(html, "<html><head> --- </head></html>")
		
		verifyEq(logs.size, 1)
		rec := logs.list.first as LogRec
		verifyEq(rec.level,	LogLevel.warn)
		verifyEq(rec.msg, 	LogMsgs.canNotFindBody)
	}
	
}

internal class T_AppModule01 {
	@Inject private HtmlInjector? injector
	
	@Contribute { serviceId="Routes" }
	static Void contributeRoutes(OrderedConfig conf) {
		conf.add(Route(`/html`,		#getHtml))
		conf.add(Route(`/xml`,		#getXml ))
		conf.add(Route(`/noHead`,	#noHead ))
		conf.add(Route(`/noBody`,	#noBody ))
	}
	
	Text getHtml() {
		injector.injectStylesheet.fromExternalUrl(`http://www.example.com/dude.css`)
		return Text.fromHtml ("<html><head><title> HTML Test</title></head><body> --body-- </body></html>")
	}

	Text getXml() {
		injector.injectStylesheet.fromExternalUrl(`http://www.example.com/dude.css`)
		return Text.fromXhtml("<html><head><title> HTML Test</title></head><body> --body-- </body></html>")
	}

	Text noHead() {
		injector.injectScript(true)
		return Text.fromHtml("<html><body> --- </body></html>")
	}

	Text noBody() {
		injector.injectScript(false)
		return Text.fromHtml("<html><head> --- </head></html>")
	}
}