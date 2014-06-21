using afBounce

internal class TestInjection : Test {
	
	Void testHtmlInjection() {
		client := BedServer(T_AppModule#).addModule(DuvetModule#).startup.makeClient

		html := client.get(`/html`).asStr
		
		verifyEq(html, """<html><head><title> HTML Test</title><link rel="stylesheet" type="text/css" href="http://www.example.com/dude.css"></head><body>body body body</body></html>""")
		
		client.shutdown
	}

	Void testXmlInjection() {
		client := BedServer(T_AppModule#).addModule(DuvetModule#).startup.makeClient

		html := client.get(`/xml`).asStr
		
		verifyEq(html, """<html><head><title> HTML Test</title><link rel="stylesheet" type="text/css" href="http://www.example.com/dude.css" /></head><body>body body body</body></html>""")
		
		client.shutdown
	}
	
}
