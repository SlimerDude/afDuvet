using build
using afIoc
using afBedSheet
using afDuvet
using fwt::Dialog
using fwt::Window

** This class is compiled, delivered and run in the browser.
@Js
class MyJavascript {
	Void greet(Str name) {
		Dialog.openInfo(Window(), "Fantom says, '${name}'")
	}
}

class IndexPage {
	@Inject HtmlInjector? injector

	Text render() {
		// inject Fantom code into the web page 
		injector.injectFantomMethod(MyJavascript#greet, ["Hello Mum!"])
		
		// let Duvet inject all it needs into a plain HTML shell
		return Text.fromHtml("<html><head></head><body><h1>Duvet by Alien-Factory</h1></body></html>")
	}
}

class AppModule {
	@Contribute { serviceType=Routes# }
	static Void contributeRoutes(Configuration conf) {
		conf.add(Route(`/`, IndexPage#render))
	}
}

class Build : BuildPod {
	new make() {
		podName = "duvetDemo"
		summary = "Run Fantom code in your browser!"

		meta = [
			"proj.name"		: "Duvet Demo",
			"afIoc.module"	: "duvetDemo::AppModule",
		]

		depends = [
			"sys 1.0",
			"fwt 1.0",
			"build 1.0",
			"afIoc 1.7.6+",
			"afBedSheet 1.3.14+",
			"afDuvet 0.1.0+"
		]
		
		srcDirs = [`DuvetDemo.fan`]
	}
}
