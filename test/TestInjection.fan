using afIoc
using afBedSheet
using afBounce

internal class TestInjection : DuvetTest {
	
	override Void setup() {
		startBedSheet(T_AppModule01#)
	}
	
	Void testHtmlInjection() {
		html := client.get(`/html`).asStr
		Env.cur.err.printLine(html)
		verifyEq(html, """<html><head><title> HTML Test</title><link rel="stylesheet" type="text/css" href="http://www.example.com/dude.css"></head><body>body body body</body></html>""")
	}

	Void testXmlInjection() {
		html := client.get(`/xml`).asStr
		verifyEq(html, """<html><head><title> HTML Test</title><link rel="stylesheet" type="text/css" href="http://www.example.com/dude.css" /></head><body>body body body</body></html>""")
	}
	
}

internal class T_AppModule01 {
	@Inject private HtmlInjector? injector
	
	@Contribute { serviceId="Routes" }
	static Void contributeRoutes(OrderedConfig conf) {
		conf.add(Route(`/html`, #getHtml))
		conf.add(Route(`/xml`,  #getXml ))
	}
	
	Text getHtml() {
		injector.injectStylesheet.fromExternalUrl(`http://www.example.com/dude.css`)
		return Text.fromHtml ("<html><head><title> HTML Test</title></head><body>body body body</body></html>")
	}

	Text getXml() {
		injector.injectStylesheet.fromExternalUrl(`http://www.example.com/dude.css`)
		return Text.fromXhtml("<html><head><title> HTML Test</title></head><body>body body body</body></html>")
	}
}