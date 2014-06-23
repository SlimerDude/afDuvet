using afIoc
using afBedSheet


internal class T_AppModule {
	
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
