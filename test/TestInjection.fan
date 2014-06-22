using afBounce

internal class TestInjection : DuvetTest {
	
	Void testHtmlInjection() {
		html := client.get(`/html`).asStr
		verifyEq(html, """<html><head><title> HTML Test</title><link rel="stylesheet" type="text/css" href="http://www.example.com/dude.css"></head><body>body body body</body></html>""")
	}

	Void testXmlInjection() {
		html := client.get(`/xml`).asStr
		verifyEq(html, """<html><head><title> HTML Test</title><link rel="stylesheet" type="text/css" href="http://www.example.com/dude.css" /></head><body>body body body</body></html>""")
	}
	
}
