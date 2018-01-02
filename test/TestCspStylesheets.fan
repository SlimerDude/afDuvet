using afIoc
using afBedSheet
using afIocConfig::ApplicationDefaults

** ContentSecurityPolicy
internal class TestCspStylesheets : Test {
	Scope?					scope
	HttpResponseHeaders?	headers
	LinkTagBuilder?			linkTag
	Str:Obj					extraConfig	:= ["afDuvet.updateCspHeader":true]
	
	Void testBodyNoCsp() {
		linkTag.fromLocalUrl(`/local.js`)
		verifyEq(headers.contentSecurityPolicy, null)

		// don't add hash if there is not script / default policy
		headers.contentSecurityPolicy = ["wot":"ever"]
		linkTag.fromLocalUrl(`/local.js`)
		verifyEq(headers.contentSecurityPolicy, ["wot":"ever"])
	}
	
	Void testNoUpdate() {
		extraConfig = ["afDuvet.updateCspHeader":false]
		setup

		headers.contentSecurityPolicy = ["default-src":"'self'"]
		linkTag.fromLocalUrl(`/local.js`)
		// check that default-src gets copied down to style-src 
		verifyEq(headers.contentSecurityPolicy["default-src"], "'self'")
		verifyEq(headers.contentSecurityPolicy["style-src"], null)

		linkTag	= scope.build(LinkTagBuilder#)
		headers.contentSecurityPolicy = ["default-src":"'self'"]
		linkTag.fromLocalUrl(`/local.js`)
		// check only rel=stylesheet are updated 
		verifyEq(headers.contentSecurityPolicy["default-src"], "'self'")
		verifyEq(headers.contentSecurityPolicy["style-src"], null)
	}
	
	Void testLocalUrlCsp() {
		headers.contentSecurityPolicy = ["default-src":"'none'"]
		linkTag.fromLocalUrl(`/local.js`)
		// check that default-src gets copied down to style-src 
		verifyEq(headers.contentSecurityPolicy["style-src"], "'none' 'self'")

		headers.contentSecurityPolicy = ["default-src":"'self'", "style-src":"'none'"]
		linkTag.fromLocalUrl(`/local.js`)
		// check that default-src is NOT copied down when style-src exists 
		verifyEq(headers.contentSecurityPolicy["style-src"], "'none' 'self'")

		// check hash is only added the once
		linkTag.fromLocalUrl(`/local.js`)
		verifyEq(headers.contentSecurityPolicy["style-src"], "'none' 'self'")
	}
	
	Void testLocalUrlWithScriptSelf() {
		headers.contentSecurityPolicy = ["style-src":"'self'"]
		linkTag.fromLocalUrl(`/local.js`)
		verifyEq(headers.contentSecurityPolicy["style-src"], "'self'")
	}
	
	Void testLocalUrlWithDefaultSelf() {
		headers.contentSecurityPolicy = ["default-src":"'self'"]
		linkTag.fromLocalUrl(`/local.js`)
		verifyEq(headers.contentSecurityPolicy["default-src"], "'self'")
		verifyEq(headers.contentSecurityPolicy["style-src"], null)
	}
	
	Void testRemoteUrlCsp() {
		headers.contentSecurityPolicy = ["default-src":"'none'"]
		linkTag.fromExternalUrl(`http://example.com/anal.js`)
		// check that default-src gets copied down to style-src 
		verifyEq(headers.contentSecurityPolicy["style-src"], "'none' http://example.com")

		headers.contentSecurityPolicy = ["default-src":"'self'", "style-src":"'none'"]
		linkTag.fromExternalUrl(`http://example.com/anal.js`)
		// check that default-src is NOT copied down when style-src exists 
		verifyEq(headers.contentSecurityPolicy["style-src"], "'none' http://example.com")

		// check hash is only added the once
		linkTag.fromExternalUrl(`http://example.com/anal.js`)
		verifyEq(headers.contentSecurityPolicy["style-src"], "'none' http://example.com")
		
		// check schemeless URLs
		headers.contentSecurityPolicy = ["default-src":"'none'"]
		linkTag.fromExternalUrl(`//example.com/anal.js`)
		// check that default-src gets copied down to style-src 
		verifyEq(headers.contentSecurityPolicy["style-src"], "'none' example.com")
	}
	
	Void testRemoteUrlWithScriptSelf() {
		headers.contentSecurityPolicy = ["style-src":"http://example.com"]
		linkTag.fromExternalUrl(`http://example.com/anal.js`)
		verifyEq(headers.contentSecurityPolicy["style-src"], "http://example.com")
	}
	
	Void testRemoteUrlWithDefaultSelf() {
		headers.contentSecurityPolicy = ["default-src":"http://example.com"]
		linkTag.fromExternalUrl(`http://example.com/anal.js`)
		verifyEq(headers.contentSecurityPolicy["default-src"], "http://example.com")
		verifyEq(headers.contentSecurityPolicy["style-src"], null)
	}

	override Void setup() {
		scope = RegistryBuilder().silent {
			addModulesFromPod("afIocConfig")
			addService(HttpResponse#	).withImplType(HttpResponseStub#)
			addService(ClientAssetCache#).withImplType(ClientAssetCacheStub#)
			contributeToService(ApplicationDefaults#.qname) |Configuration config| {
				extraConfig.each |v, k| { config[k] = v }
			}
		}.build.activeScope
		headers	= ((HttpResponse) scope.serviceById(HttpResponse#.qname)).headers
		linkTag	= ((LinkTagBuilder) scope.build(LinkTagBuilder#)).withRel("stylesheet").withType(MimeType("text/css;charset=utf-8"))
	}
	
	override Void teardown() {
		scope.registry.shutdown
	}
}
