using afIoc
using afBedSheet

class T_AppModule {
	
	@Inject private StylesheetInjector? cssInjector
	
	@Contribute { serviceId="Routes" }
	static Void contributeRoutes(OrderedConfig conf) {
		conf.add(Route(`/html`, #getHtml))
		conf.add(Route(`/xml`,  #getXml ))
	}
	
	Text getHtml() {
		cssInjector.addStylesheetFromExternalUrl(`http://www.example.com/dude.css`)
		return Text.fromHtml ("<html><head><title> HTML Test</title></head><body>body body body</body></html>")
	}

	Text getXml() {
		cssInjector.addStylesheetFromExternalUrl(`http://www.example.com/dude.css`)
		return Text.fromXhtml("<html><head><title> HTML Test</title></head><body>body body body</body></html>")
	}
}
