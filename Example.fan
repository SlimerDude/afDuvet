    using afIoc
    using afBedSheet
    using afDuvet

    class Example {
        @Inject HtmlInjector? injector

        Text duvetExample() {
            // inject meta tags and stylesheets into your HTML
            injector.injectMeta.withName("author").withContent("Fantom-Factory")

            // inject a RequireJS script snippet
            // this ensures all dependencies are loaded before execution
            injector.injectRequireScript(["jquery":"\$"],
                "alert('jQuery v' + \$().jquery);"
            )

            // let Duvet inject all it needs into a plain HTML shell
            return Text.fromHtml(
                "<html><head></head><body><h1>Duvet by Alien-Factory</h1></body></html>"
            )
        }
    }

    @SubModule { modules=[DuvetModule#] }
    const class AppModule {
        @Contribute { serviceType=Routes# }
        Void contributeRoutes(Configuration conf) {
            conf.add(Route(`/`, Example#duvetExample))
        }

        @Contribute { serviceType=ScriptModules# }
        Void contributeScriptModules(Configuration config) {
            // configure any non-standard AMD modules
            config.add(
                ScriptModule("jquery").atUrl(`//code.jquery.com/jquery-2.1.1.min.js`)
            )
        }
    }

    class Main {
        Int main() {
            BedSheetBuilder(AppModule#.qname).startWisp(8080)
        }
    }
