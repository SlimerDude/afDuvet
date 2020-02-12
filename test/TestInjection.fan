using afIoc
using afBedSheet
using afBounce
using afConcurrent

internal class TestInjection : DuvetTest {
	private static const AtomicList logs := AtomicList()
	private static const |LogRec rec| handler := |LogRec rec| { logs.add(rec) }
	
	override Void setup() {
		startBedSheet([T_AppModule01#])
		logs.clear
		Log.addHandler(handler)
	}
	
	override Void teardown() {
		Log.removeHandler(handler)
		logs.clear
	}

	Void testHtmlInjection() {
		html := client.get(`/html`).body.str
		verifyEq(html, """<html><head><title> HTML Test</title>\n<link rel="stylesheet" type="text/css" href="http://www.example.com/dude.css">\n</head><body> --body-- </body></html>""")
	}

	Void testXmlInjection() {
		html := client.get(`/xml`).body.str
		verifyEq(html, """<html><head><title> HTML Test</title>\n<link rel="stylesheet" type="text/css" href="http://www.example.com/dude.css" />\n</head><body> --body-- </body></html>""")
	}
	
	Void testNoHeadIsOkay() {
		html := client.get(`/noHead`).body.str
		verifyEq(html, "<html><body> --- </body></html>")
		
		logs := (logs.val as LogRec[]).findAll { it.logName == "afDuvet" }
		
		verifyEq(logs.size, 1)
		rec := logs.first
		verifyEq(rec.level,	LogLevel.warn)
		verifyEq(rec.msg, 	"Could not find '</head>' in HTML response.\n<html><body> --- </body></html>")
	}
	
	Void testNoBodyIsOkay() {
		html := client.get(`/noBody`).body.str
		verifyEq(html, "<html><head> --- </head></html>")

		logs := (logs.val as LogRec[]).findAll { it.logName == "afDuvet" }
		
		verifyEq(logs.size, 1)
		rec := logs.first as LogRec
		verifyEq(rec.level,	LogLevel.warn)
		verifyEq(rec.msg, 	"Could not find '</body>' in HTML response.\n<html><head> --- </head></html>")
	}
	
}

internal const class T_AppModule01 {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf) {
		conf.add(Route(`/html`,		T_AppModule01Routes#getHtml))
		conf.add(Route(`/xml`,		T_AppModule01Routes#getXml ))
		conf.add(Route(`/noHead`,	T_AppModule01Routes#noHead ))
		conf.add(Route(`/noBody`,	T_AppModule01Routes#noBody ))
	}
}

internal const class T_AppModule01Routes {
	@Inject private const HtmlInjector? injector
	
	new make(|This|in) { in(this) }
	
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