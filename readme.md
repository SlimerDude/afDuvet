#Duvet v1.0.6
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v1.0.6](http://img.shields.io/badge/pod-v1.0.6-yellow.svg)](http://www.fantomfactory.org/pods/afDuvet)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

`Duvet` is a [BedSheet](http://www.fantomfactory.org/pods/afBedSheet) library that injects HTML into your web page after it has been rendered, but before it is streamed to the browser.

`Duvet` is a wrapper around [RequireJS](http://requirejs.org/), giving you clean dependency management for your Javascript libraries.

`Duvet` also gives a simple means of executing Fantom code in your web browser!

### Why Duvet?

Embracing RequireJs and AMD modules is like having an IoC for Javascript; and using it gives you a warm, fuzzy feeling all over!

## Install

Install `Duvet` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afDuvet

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afDuvet 1.0"]

## Documentation

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afDuvet/).

## Quick Start

1). Create a text file called `Example.fan`:

```
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
            "alert('jQuery v' + \$().jquery);")

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
        afBedSheet::Main().main([AppModule#.qname, "8080"])
    }
}
```

2). Run `Example.fan` as a Fantom script from the command line. This starts the [BedSheet](http://www.fantomfactory.org/pods/afBedSheet) app server:

```
C:\> fan Example.fan
   ___    __                 _____        _
  / _ |  / /_____  _____    / ___/__  ___/ /_________  __ __
 / _  | / // / -_|/ _  /===/ __// _ \/ _/ __/ _  / __|/ // /
/_/ |_|/_//_/\__|/_//_/   /_/   \_,_/__/\__/____/_/   \_, /
          Alien-Factory BedSheet v1.3.16, IoC v2.0.0 /___/

IoC Registry built in 612ms and started up in 104ms

Bed App 'Unknown' listening on http://localhost:8080/
```

3). Visit `http://localhost:8080/`

![Duvet Example - Screenshot](http://static.alienfactory.co.uk/fantom-docs/afDuvet.exampleScreenshot.png)

## Usage

### HTML Injection

It is good practice to componentise your web pages (something that [efanXtra](http://www.fantomfactory.org/pods/afEfanXtra) excels at).

Taking an example blog website, on some pages you want to show comments, on others you don't. So you make a Comment Component which you only render on those pages that need it. Like a good self-contained component, it requires it's own stylesheet and some javascript. As you don't want to download them on *every* page, just the comment pages, you let the component download what it needs.

> Q). But how does the component, which is typically rendered at the bottom of the web page, specify what stylesheets should be downloaded in the `<head>` section?

> A). Duvet Html Injection.

The [HtmlInjector](http://repo.status302.com/doc/afDuvet/HtmlInjector.html) service lets you inject meta, scripts and stylesheets into your HTML, at any time before the page is sent to the client. The HTML tags are injected into either the bottom of the HEAD or the BODY section.

What if you want to render the Comment Component more than once on a single page? You don't want multiple copies of the same stylesheet downloaded on the same page!?

No fear, `HtmlInjector` silently rejects all stylesheet and script requests for the same URL.

`HtmlInjector` works by wrapping BedSheet's `TextResponseProcessor`. All requests for injection are queued up and then, just before the page is streamed to the browser, the HTML tags are injected.

### RequireJS

Looking after countless Javascript libraries, ensuring they all get loaded quickly and in the correct order can be a pain. [RequireJS](http://requirejs.org/), an asynchronous module loader for Javascript, not only eases that pain; but gives you proper dependency management for your libraries.

*It's how Javascript should be written!*

All your Javascript modules need to be served from the same [baseUrl](http://repo.status302.com/doc/afDuvet/DuvetConfigIds.html#baseModuleUrl) which defaults to ``/modules/``, so configure BedSheet's `FileHandler` to serve these files:

```
@Contribute { serviceType=FileHandler# }
static Void contributeFileHandler(Configuration config) {
    config[`/modules/`] = `etc/web/modules/or/wherever`
}
```

Now you can use `HtmlInjector.injectRequireScript()` to inject and run small scripts. The scripts are wrapped up in a `require()` function call to ensure proper dependency management.

Remember, most of your code should be in modules. The modules should then expose a mini-API (well, return an object!) that you can call with `HtmlInjector.injectRequireModule()`. This is a handy method that converts all given arguments into JSON.

### Module Config

Not all popular Javascript libraries are AMD modules, unfortunately, so these require a little configuration to get working. Configuration is done by contributing [ScriptModule](http://repo.status302.com/doc/afDuvet/ScriptModule.html) instances.

All `ScriptModule` data map to the RequireJs [path](http://requirejs.org/docs/api.html#config-paths) and [shim](http://requirejs.org/docs/api.html#config-shim) config options.

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

## Run Fantom Code

Duvet also lets you require Fantom pods and run Fantom code directly in the browser.

Fantom compiles all classes in a pod annotated with the `@Js` facet into a Javascript file that is saved in the pod. These javascript pod files may then be served up with BedSheet's `PodHandler` service.

Duvet builds a dependency tree of these pods with Javascript files and turns them into RequireJs modules of the same name. Example, the `sys` module relates to the Fantom `sys` pod, and the `fwt` module relates to the Fantom `fwt` pod.

From there it is a small step to require the Fantom modules and execute Fantom code in the browser. Do this by calling `HtmlInjector.injectFantomMethod(...)`.

### Browser API

Use the core Fantom [dom](http://fantom.org/doc/dom/index.html) pod to write code that interacts with the browser's Window, Document and DOM objects. Example, the following code fires up a browser alert - note the `@Js` annotation on the class.

```
using dom

@Js
class Example {
    Void info() {
        Win.cur.alert("Chew Bubblegum!")
    }
}
```

You would inject it into a web page with the following:

    htmlInjector.injectFantomMethod(Example#info)

### FWT GUI

You can also use fully featured FWT windows and graphics by using the core Fantom [fwt](http://fantom.org/doc/fwt/index.html) and [webfwt](http://fantom.org/doc/webfwt/index.html) pods.

```
using fwt

@Js
class Example {
    Void info() {
        Window {
            Label { text = "Chew Bubblegum!"; halign = Halign.center },
        }.open
    }
}
```

Note that when you instantiate an FWT window, it attaches itself to the whole browser window by default. If you wish to constrain the window to a particular element on the page, pass in the follow environment variable:

    "fwt.window.root" : "<element-id>"

Where `<element-id>` is the html ID of an element on the page.

Note that the element needs to specify a width, height and give a CSS `position` of `relative`. This may either be done in CSS or defined on the element directly:

    <div id="fwt-window" style="width: 640px; height:480px; position:relative;"></div>

### Disable Pod Modules

If you don't want to give access to your Fantom generated Javascript, or just don't like the Fantom modules cluttering up your RequireJS shim, then you can easily disable this feature. Just remove the `afDuvet.podModules` configuration from the `ScriptModules` service:

    Contribute { serviceType=ScriptModules# }
    static Void contributeScriptModules(Configuration config) {
        config.remove("afDuvet.podModules")
    }

