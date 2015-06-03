#Duvet v1.0.10
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v1.0.10](http://img.shields.io/badge/pod-v1.0.10-yellow.svg)](http://www.fantomfactory.org/pods/afDuvet)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

`Duvet` is a [BedSheet](http://pods.fantomfactory.org/pods/afBedSheet) library that delivers Javascript to the browser.

`Duvet` provides a wrapper around [RequireJS](http://requirejs.org/) and packages up Fantom generated Javascript code. It gives clean dependency management for Javascript libraries and a means to execute Fantom code in the web browser.

### Why Duvet?

Embracing RequireJs and AMD modules is like having an IoC for Javascript; and using it gives you a warm, fuzzy feeling all over!

## Install

Install `Duvet` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afDuvet

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afDuvet 1.0"]

## Documentation

Full API & fandocs are available on the [Fantom Pod Repository](http://pods.fantomfactory.org/pods/afDuvet/).

## Quick Start

1. Create a text file called `Example.fan`

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
        class AppModule {
            @Contribute { serviceType=Routes# }
            static Void contributeRoutes(Configuration conf) {
                conf.add(Route(`/`, Example#duvetExample))
            }
        
            @Contribute { serviceType=ScriptModules# }
            static Void contributeScriptModules(Configuration config) {
                // configure any non-standard AMD modules
                config.add(
                    ScriptModule("jquery").atUrl(`//code.jquery.com/jquery-2.1.1.min.js`)
                )
            }
        }
        
        class Main {
            Int main() {
                BedSheetBuilder(AppModule#.qname).startWisp(8069)
            }
        }


2. Run `Example.fan` as a Fantom script from the command line. This starts the [BedSheet](http://pods.fantomfactory.org/pods/afBedSheet) app server:

        C:\> fan Example.fan
           ___    __                 _____        _
          / _ |  / /_____  _____    / ___/__  ___/ /_________  __ __
         / _  | / // / -_|/ _  /===/ __// _ \/ _/ __/ _  / __|/ // /
        /_/ |_|/_//_/\__|/_//_/   /_/   \_,_/__/\__/____/_/   \_, /
                   Alien-Factory BedSheet v1.4.8, IoC v2.0.6 /___/
        
        IoC Registry built in 612ms and started up in 104ms
        
        Bed App 'Example_0' listening on http://localhost:8069/


3. Visit `http://localhost:8069/`

  ![Duvet Quickstart Example - Screenshot](quickstartScreenshot.png)



## HTML Injection

It is good practice to componentise your web pages (something that [efanXtra](http://pods.fantomfactory.org/pods/afEfanXtra) excels at).

Taking a blog website as an example, some pages show comments and others don't. If comments were encapsulated in a *CommentComponent* it would only need to be rendered on those pages that need it. And like any fully featured component it requires its own stylesheet and some javascript. But these files shouldn't be downloaded on *every* page, just the pages that render the *CommentComponent*. The *CommentComponent* itself should be responsible for referencing its support files.

*Q). But how does the CommentComponent, which is typically rendered at the bottom of a web page, specify what stylesheets should be downloaded in the `<head>` section?*

** *A). Duvet Html Injection.* **

The [HtmlInjector](http://pods.fantomfactory.org/pods/afDuvet/api/HtmlInjector) service lets you inject meta, scripts and stylesheets into your HTML, at any time before the page is sent to the client. The HTML tags are injected into either the bottom of the HEAD or the BODY section.

But what if the *CommentComponent* is rendered more than once on a single page? You don't want multiple copies of the same stylesheet downloaded on the same page!?

No fear, `HtmlInjector` silently rejects all stylesheet and script requests for the same URL.

`HtmlInjector` works by wrapping BedSheet's `TextResponseProcessor`. All requests for injection are queued up and then, just before the page is streamed to the browser, the HTML tags are injected.

## RequireJS Usage

Looking after countless Javascript libraries, ensuring they all get loaded quickly and in the correct order can be a pain. [RequireJS](http://requirejs.org/), an asynchronous module loader for Javascript, not only eases that pain; but gives you proper dependency management for your libraries.

*It's how Javascript should be written!*

### Javascript Modules

RequireJS requires Javascript to be packaged up into module files. A lot of popular Javascript libraries, including jQuery, already conform to this standard.

All Javascript module files need to be served from the same [baseUrl](http://pods.fantomfactory.org/pods/afDuvet/api/DuvetConfigIds#baseModuleUrl) which defaults to ``/modules/``, so configure BedSheet's `FileHandler` to serve these files:

```
@Contribute { serviceType=FileHandler# }
static Void contributeFileHandler(Configuration config) {
    config[`/modules/`] = `etc/web-static/modules/`
}
```

Javascript module files should have the same name as the module. So, using the directory above, to define jQuery as a module it would should be saved as:

    etc/web-static/modules/jQuery.js

`HtmlInjector.injectRequireScript()` may now be used to inject and run small scripts:

```
htmlInjector.injectRequireScript( ["jQuery" : "jq"],
    "alert('jQuery v' + jq().jquery);"
)
```

All injected scripts are wrapped up in a `require()` function call to ensure proper dependency management.

If a module is to be downloaded from a differnt URL, like a CDN as used in the Quick Start example, then it may be defined in the `AppModule` by contributing to the `ScriptModules` service.

To write your own module, create a Javascript file and save it in the `modules/` directory. All modules should start with a standard definition function, see the [RequireJS API](http://requirejs.org/docs/api.html#defdep) for details. It is common for modules to return a object, which is akin to exposing a mini-API.

An example `modules/MyModule.js` file:

```
define(["jquery"], function($) {
    return {
        doStuff: function() {
            alert("Doing stuff with jQuery v" + $().jquery);
        },
        doOtherStuff: function(stuff) {
            alert("Doing " + stuff);
        }
    }
});
```

We could then invoke the exposed methods on the module with `HtmlInjector.injectRequireModule(...)`.

```
htmlInjector.injectRequireModule("myModule", "doStuff")

htmlInjector.injectRequireModule("myModule", "doOtherStuff", ["Emma!"])
```

### Fantom Pod Modules

Duvet lets Fantom code be run directly in the browser by converting pod `.js` files into RequireJS modules.

Fantom compiles all classes in a pod annotated with the `@Js` facet into a Javascript file that is saved in the pod. These javascript pod files can then be served up with BedSheet's `PodHandler` service.

Duvet builds a dependency tree of pods with Javascript files and converts them into RequireJS modules of the same name. For example, the Fantom `sys` pod is converted into a RequireJS module called `sys`.

From there it is a small step to require the Fantom modules and execute Fantom code in the browser. Simply call `HtmlInjector.injectFantomMethod(...)`.

#### Using the DOM Pod

The Fantom [dom](http://fantom.org/doc/dom/index.html) pod is used to interact with the browser's Window, Document and DOM objects. For example, the following code fires up a browser alert - note the `@Js` annotation on the class.

```
using dom

@Js
class DomExample {
    Void info() {
        Win.cur.alert("Chew Bubblegum!")
    }
}
```

To execute the above code, inject it into a web page with the following:

    htmlInjector.injectFantomMethod(DomExample#info)

#### Using the FWT Pod

Fantom's [fwt](http://fantom.org/doc/fwt/index.html) and [webfwt](http://fantom.org/doc/webfwt/index.html) pods can be used to generate fully featured FWT windows and graphics in the browser. Example:

```
using fwt

@Js
class FwtExample {
    Void info() {
        Window {
            Label { text = "Chew Bubblegum!"; halign = Halign.center },
        }.open
    }
}
```

Again, this can be executed with:

    htmlInjector.injectFantomMethod(FwtExample#info)

Note that when you instantiate an FWT window, it attaches itself to the whole browser window by default. If you wish to constrain the window to a particular element on the page, pass in the following environment variable:

    "fwt.window.root" : "<element-id>"

Where `<element-id>` is the html ID of an element on the page.

Note that the element needs to specify a width, height and give a CSS `position` of `relative`. This may either be done in CSS or defined on the element directly:

    <div id="fwt-window" style="width: 640px; height:480px; position:relative;"></div>

For an example of what fwt is capable of in the browser, see the article [Run Fantom Code In a Browser!](http://www.fantomfactory.org/articles/run-fantom-code-in-a-browser).

![Duvet FWT Example - Screenshot](fwtScreenshot.png)

#### Disabling Pods

If you want to restrict access to Fantom generated Javascript, or just don't like Fantom modules cluttering up the RequireJS shim, then pods can be easily disabled. Simply remove the `afDuvet.podModules` configuration from the `ScriptModules` service:

    Contribute { serviceType=ScriptModules# }
    static Void contributeScriptModules(Configuration config) {
        config.remove("afDuvet.podModules")
    }

### Module Config

Not all popular Javascript libraries are AMD modules, unfortunately, so these require a little configuration to get working. Configuration is done by contributing [ScriptModule](http://pods.fantomfactory.org/pods/afDuvet/api/ScriptModule) instances.

All `ScriptModule` data map to the RequireJS [path](http://requirejs.org/docs/api.html#config-paths) and [shim](http://requirejs.org/docs/api.html#config-shim) config options.

Here's a working example from the Fantom-Factory website:

```
@Contribute { serviceType=ScriptModules# }
static Void contributeScriptModules(Configuration config) {
    config.add(
        ScriptModule("jquery")
            .atUrl(`//code.jquery.com/jquery-2.1.1.min.js`)
            .fallbackToUrl(`/scripts/jquery-2.1.1.min.js`)
    )
    config.add(
        ScriptModule("bootstrap")
            .atUrl(`/scripts/bootstrap.min.js`)
            .requires("jquery")
    )
}
```

### Custom Require Scripts

Sometimes, for quick wins in development, it is handy to write your own script tags directly in the HTML. This is still possible, even when it calls RequireJS. Example:

```
<html>
<body>
    <h1>Hello!</h1>
    <script>
        require(['jquery'], function($) {
            // ... wotever...
        });
    </script>
</body>
</html>
```

To make the above work, make a call to `HtmlInjector.injectRequireJs()`. That will ensure that RequireJS, and any corresponding config, is injected into the HTML.

Note that by default, Duvet will try to be a little smart about inserting RequireJS (and other script tags) into the body. It will insert them *before* the last `<script>` tag in the HTML. That is, the last script tag immediately before `</body>`.

Inevitably this *smart* insertion will fail at some point, especially if your script contains the character sequence `</script>` in a comment or similar; it is after all, just regular expression matching.

So to disable this *(ahem)* *smart* insertion and bang all scripts in just before the closing `</body>` tag, add the following to your `AppModule`:

```
@Contribute { serviceType=ApplicationDefaults# }
static Void contributeAppDefaults(Configuration config) {
    config[DuvetConfigIds.disableSmartInsertion]    = true
}
```

## Non-RequireJS Usage

Sometimes an old skool approach is more convenient when executing Fantom code on a page.

For this you don't actually need Duvet at all, instead you just rely on BedSheet's `PodHandler` service to serve up the pod `.js` files. Here is an example that calls `alert()` via Fantom's DOM pod; just serve it up in BedSHeet as static HTML:

```
<!DOCTYPE html>
<html>
<head>
    <script type="text/javascript" src="/pods/sys/sys.js"></script>
    <script type="text/javascript" src="/pods/gfx/gfx.js"></script>
    <script type="text/javascript" src="/pods/web/web.js"></script>
    <script type="text/javascript" src="/pods/dom/dom.js"></script>
</head>
<body>
    <h1>Old Skool Example</h1>

    <script type="text/javascript">
        fan.dom.Win.cur().alert("Hello Mum!");
    </script>
</body>
</html>
```

Note that the order in which the pod `.js` files are listed is very important; each pod's dependencies must be listed before the pod itself.

Fantom code may also be executed via the [web::WebUtil.jsMain()](http://fantom.org/doc/web/WebUtil.html#jsMain) method.

## Pillow & efanExtra Example

It is common to use Duvet with [Pillow](http://pods.fantomfactory.org/pods/afPillow) and [efanXtra](http://pods.fantomfactory.org/pods/afEfanXtra). As such, below is a sample Pillow page / efanXtra component component that may be useful for cut'n'paste purposes:

```
using afIoc::Inject
using afEfanXtra::EfanComponent
using afEfanXtra::InitRender
using afPillow::Page
using afDuvet::HtmlInjector

@Page { contentType=MimeType("text/html") }
const mixin PooPage : EfanComponent {

    @Inject abstract HtmlInjector htmlInjector

    @InitRender
    Void initRender() {

        // inject meta tags and stylesheets into your HTML
        htmlInjector.injectMeta.withName("author").withContent("Fantom-Factory")

        // inject a RequireJS script snippet
        // this ensures all dependencies are loaded before execution
        htmlInjector.injectRequireScript(
            ["jquery" : "jq"],
            "alert('jQuery v' + jq().jquery);"
        )
    }

    // This is usually an external template file - overridden here for visibility.
    override Str renderTemplate() {
        "<html><head></head><body><h1>Duvet by Alien-Factory</h1></body></html>"
    }
}
```

