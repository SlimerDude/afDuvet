#Duvet v1.1.6
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![pod: v1.1.6](http://img.shields.io/badge/pod-v1.1.6-yellow.svg)](http://www.fantomfactory.org/pods/afDuvet)
![Licence: ISC Licence](http://img.shields.io/badge/licence-ISC Licence-blue.svg)

## Overview

`Duvet` is a [BedSheet](http://eggbox.fantomfactory.org/pods/afBedSheet) library that delivers Javascript to the browser.

`Duvet` provides a wrapper around [RequireJS](http://requirejs.org/) and packages up Fantom generated Javascript code. It gives clean dependency management for Javascript libraries and a means to execute Fantom code in the web browser.

### Why Duvet?

Embracing RequireJs and AMD modules is like having an IoC for Javascript; and using it gives you a warm, fuzzy feeling all over!

## Install

Install `Duvet` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afDuvet

Or install `Duvet` with [fanr](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afDuvet

To use in a [Fantom](http://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afDuvet 1.1"]

## Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afDuvet/) - the Fantom Pod Repository.

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
                BedSheetBuilder(AppModule#.qname).startWisp(8069)
            }
        }


2. Run `Example.fan` as a Fantom script from the command line. This starts the [BedSheet](http://eggbox.fantomfactory.org/pods/afBedSheet) app server:

        C:\> fan Example.fan
           ___    __                 _____        _
          / _ |  / /_____  _____    / ___/__  ___/ /_________  __ __
         / _  | / // / -_|/ _  /===/ __// _ \/ _/ __/ _  / __|/ // /
        /_/ |_|/_//_/\__|/_//_/   /_/   \_,_/__/\__/____/_/   \_, /
                   Alien-Factory BedSheet v1.5.6, IoC v3.0.6 /___/
        
        IoC Registry built in 412ms and started up in 104ms
        
        Bed App 'Example_0' listening on http://localhost:8069/


3. Visit `http://localhost:8069/`

  ![Duvet Quickstart Example - Screenshot](data:image/png;base64,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)



## HTML Injection

It is good practice to componentise your web pages (something that [efanXtra](http://eggbox.fantomfactory.org/pods/afEfanXtra) excels at).

Taking a blog website as an example, some pages show comments and others don't. If comments were encapsulated in a *CommentComponent* it would only need to be rendered on those pages that need it. And like any fully featured component it requires its own stylesheet and some javascript. But these files shouldn't be downloaded on *every* page, just the pages that render the *CommentComponent*. The *CommentComponent* itself should be responsible for referencing its support files.

*Q). But how does the CommentComponent, which is typically rendered at the bottom of a web page, specify what stylesheets should be downloaded in the `<head>` section?*

** *A). Duvet Html Injection.* **

The [HtmlInjector](http://eggbox.fantomfactory.org/pods/afDuvet/api/HtmlInjector) service lets you inject meta, scripts and stylesheets into your HTML, at any time before the page is sent to the client. The HTML tags are injected into either the bottom of the HEAD or the BODY section.

But what if the *CommentComponent* is rendered more than once on a single page? You don't want multiple copies of the same stylesheet downloaded on the same page!?

No fear, `HtmlInjector` silently rejects all stylesheet and script requests for the same URL.

`HtmlInjector` works by wrapping BedSheet's `TextResponseProcessor`. All requests for injection are queued up and then, just before the page is streamed to the browser, the HTML tags are injected.

## RequireJS Usage

Looking after countless Javascript libraries, ensuring they all get loaded quickly and in the correct order can be a pain. [RequireJS](http://requirejs.org/), an asynchronous module loader for Javascript, not only eases that pain; but gives you proper dependency management for your libraries.

*It's how Javascript should be written!*

### Javascript Modules

RequireJS requires Javascript to be packaged up into module files. A lot of popular Javascript libraries, including jQuery, already conform to this standard.

All Javascript module files need to be served from the same [baseUrl](http://eggbox.fantomfactory.org/pods/afDuvet/api/DuvetConfigIds#baseModuleUrl) which defaults to ``/modules/``, so configure BedSheet's `FileHandler` to serve these files:

```
@Contribute { serviceType=FileHandler# }
Void contributeFileHandler(Configuration config) {
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

#### Using DOM

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

#### Using DOMKIT

The core [domkit](http://fantom.org/doc/domkit/index.html) pod extends `dom` to provide a modern windowing framework for single page web applications.

To use domkit, create your container boxes and add them to the exisitng DOM tree. The example below assumes the HTML contains a element with the ID `domkit-container`:

```
using dom
using domkit

@Js
class DomkitExample {
    Void init() {
        // create your domkit boxes and elements
        box := ScrollBox() { it.text = "Chew Bubblegum!" }

        // add them to the existing DOM tree
        Win.cur.doc.elemById("domkit-container").add(box)
    }
}
```

Inject the code via `injectFantomMethod`. Note that domkit also makes use a stylesheet that you should also inject into the page:

```
// inject the domkit stylesheet
injector.injectStylesheet.fromLocalUrl(`/pod/domkit/res/css/domkit.css`)

// inject your Fantom code
injector.injectFantomMethod(DomkitExample#init)
```

#### Using FWT / WebFWT

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

For an example of what fwt is capable of in the browser, see the article [Run Fantom Code In a Browser!](http://www.alienfactory.co.uk/articles/run-fantom-code-in-a-browser).

![Duvet FWT Example - Screenshot](data:image/png;base64,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)

#### Disabling Pods

If you want to restrict access to Fantom generated Javascript, or just don't like Fantom modules cluttering up the RequireJS shim, then pods can be easily disabled. Simply remove the `afDuvet.podModules` configuration from the `ScriptModules` service:

```
@Contribute { serviceType=ScriptModules# }
Void contributeScriptModules(Configuration config) {
    config.remove("afDuvet.podModules")
}
```

### Module Config

Not all popular Javascript libraries are AMD modules, unfortunately, so these require a little configuration to get working. Configuration is done by contributing [ScriptModule](http://eggbox.fantomfactory.org/pods/afDuvet/api/ScriptModule) instances.

All `ScriptModule` data map to the RequireJS [path](http://requirejs.org/docs/api.html#config-paths) and [shim](http://requirejs.org/docs/api.html#config-shim) config options.

Here's a working example from the Fantom-Factory website:

```
@Contribute { serviceType=ScriptModules# }
Void contributeScriptModules(Configuration config) {
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
Void contributeAppDefaults(Configuration config) {
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
    <script type="text/javascript" src="/pod/sys/sys.js"></script>
    <script type="text/javascript" src="/pod/gfx/gfx.js"></script>
    <script type="text/javascript" src="/pod/web/web.js"></script>
    <script type="text/javascript" src="/pod/dom/dom.js"></script>
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

It is common to use Duvet with [Pillow](http://eggbox.fantomfactory.org/pods/afPillow) and [efanXtra](http://eggbox.fantomfactory.org/pods/afEfanXtra). As such, below is a sample Pillow page / efanXtra component component that may be useful for cut'n'paste purposes:

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

