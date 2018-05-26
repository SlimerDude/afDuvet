using afIoc
using afBedSheet
using afIocConfig::ApplicationDefaults

** ContentSecurityPolicy
internal class TestCspScripts : Test {
	Scope?					scope
	HttpResponseHeaders?	headers
	ScriptTagBuilder?		scriptTag
	Str						sha256Hash	:= "'sha256-" + "alert('The Pain Train!');".toBuf.toDigest("SHA-256").toBase64 + "'"
	Str:Obj					extraConfig	:= ["afDuvet.updateCspHeader":true]
	
	Void testBodyNoCsp() {
		scriptTag.withScript("alert('The Pain Train!');")
		verifyEq(headers.contentSecurityPolicy, null)

		// don't add hash if there is not script / default policy
		headers.contentSecurityPolicy = ["wot":"ever"]
		scriptTag.withScript("alert('The Pain Train!');")
		verifyEq(headers.contentSecurityPolicy, ["wot":"ever"])
	}
	
	Void testBodyCsp() {
		headers.contentSecurityPolicy = ["default-src":"'self'"]
		scriptTag.withScript("alert('The Pain Train!');")
		// check that default-src gets copied down to script-src 
		verifyEq(headers.contentSecurityPolicy["script-src"], "'self' ${sha256Hash}")

		headers.contentSecurityPolicy = ["default-src":"'self'", "script-src":"'none'"]
		scriptTag.withScript("alert('The Pain Train!');")
		// check that default-src is NOT copied down when script-src exists 
		verifyEq(headers.contentSecurityPolicy["script-src"], "'none' ${sha256Hash}")

		// check hash is only added the once
		scriptTag.withScript("alert('The Pain Train!');")
		verifyEq(headers.contentSecurityPolicy["script-src"], "'none' ${sha256Hash}")
	}
	
	Void testBodyCspReportOnly() {
		headers.contentSecurityPolicyReportOnly = ["default-src":"'self'"]
		scriptTag.withScript("alert('The Pain Train!');")
		// check that default-src gets copied down to script-src 
		verifyEq(headers.contentSecurityPolicyReportOnly["script-src"], "'self' ${sha256Hash}")

		headers.contentSecurityPolicyReportOnly = ["default-src":"'self'", "script-src":"'none'"]
		scriptTag.withScript("alert('The Pain Train!');")
		// check that default-src is NOT copied down when script-src exists 
		verifyEq(headers.contentSecurityPolicyReportOnly["script-src"], "'none' ${sha256Hash}")

		// check hash is only added the once
		scriptTag.withScript("alert('The Pain Train!');")
		verifyEq(headers.contentSecurityPolicyReportOnly["script-src"], "'none' ${sha256Hash}")
	}
	
	Void testNoUpdate() {
		extraConfig = ["afDuvet.updateCspHeader":false]
		setup

		headers.contentSecurityPolicy = ["default-src":"'self'"]
		scriptTag.withScript("alert('The Pain Train!');")
		// check that default-src gets copied down to script-src 
		verifyEq(headers.contentSecurityPolicy["default-src"], "'self'")
		verifyEq(headers.contentSecurityPolicy["script-src"], null)
	}
	
	Void testBodyWithScriptInline() {
		headers.contentSecurityPolicy = ["script-src":"'unsafe-inline'"]
		scriptTag.withScript("alert('The Pain Train!');")
		verifyEq(headers.contentSecurityPolicy["script-src"], "'unsafe-inline'")
	}
	
	Void testBodyWithDefaultInline() {
		headers.contentSecurityPolicy = ["default-src":"'unsafe-inline'"]
		scriptTag.withScript("alert('The Pain Train!');")
		verifyEq(headers.contentSecurityPolicy["default-src"], "'unsafe-inline'")
		verifyEq(headers.contentSecurityPolicy["script-src"], null)
	}
	
	Void testLocalUrlCsp() {
		headers.contentSecurityPolicy = ["default-src":"'none'"]
		scriptTag.fromLocalUrl(`/local.js`)
		// check that default-src gets copied down to script-src 
		verifyEq(headers.contentSecurityPolicy["script-src"], "'none' 'self'")

		headers.contentSecurityPolicy = ["default-src":"'self'", "script-src":"'none'"]
		scriptTag.fromLocalUrl(`/local.js`)
		// check that default-src is NOT copied down when script-src exists 
		verifyEq(headers.contentSecurityPolicy["script-src"], "'none' 'self'")

		// check hash is only added the once
		scriptTag.fromLocalUrl(`/local.js`)
		verifyEq(headers.contentSecurityPolicy["script-src"], "'none' 'self'")
	}
	
	Void testLocalUrlWithScriptSelf() {
		headers.contentSecurityPolicy = ["script-src":"'self'"]
		scriptTag.fromLocalUrl(`/local.js`)
		verifyEq(headers.contentSecurityPolicy["script-src"], "'self'")
	}
	
	Void testLocalUrlWithDefaultSelf() {
		headers.contentSecurityPolicy = ["default-src":"'self'"]
		scriptTag.fromLocalUrl(`/local.js`)
		verifyEq(headers.contentSecurityPolicy["default-src"], "'self'")
		verifyEq(headers.contentSecurityPolicy["script-src"], null)
	}
	
	Void testRemoteUrlCsp() {
		headers.contentSecurityPolicy = ["default-src":"'none'"]
		scriptTag.fromExternalUrl(`http://example.com/anal.js`)
		// check that default-src gets copied down to script-src 
		verifyEq(headers.contentSecurityPolicy["script-src"], "'none' http://example.com")

		headers.contentSecurityPolicy = ["default-src":"'self'", "script-src":"'none'"]
		scriptTag.fromExternalUrl(`http://example.com/anal.js`)
		// check that default-src is NOT copied down when script-src exists 
		verifyEq(headers.contentSecurityPolicy["script-src"], "'none' http://example.com")

		// check hash is only added the once
		scriptTag.fromExternalUrl(`http://example.com/anal.js`)
		verifyEq(headers.contentSecurityPolicy["script-src"], "'none' http://example.com")
		
		// check schemeless URLs
		headers.contentSecurityPolicy = ["default-src":"'none'"]
		scriptTag.fromExternalUrl(`//example.com/anal.js`)
		// check that default-src gets copied down to script-src 
		verifyEq(headers.contentSecurityPolicy["script-src"], "'none' example.com")
	}
	
	Void testRemoteUrlWithScriptSelf() {
		headers.contentSecurityPolicy = ["script-src":"http://example.com"]
		scriptTag.fromExternalUrl(`http://example.com/anal.js`)
		verifyEq(headers.contentSecurityPolicy["script-src"], "http://example.com")
	}
	
	Void testRemoteUrlWithDefaultSelf() {
		headers.contentSecurityPolicy = ["default-src":"http://example.com"]
		scriptTag.fromExternalUrl(`http://example.com/anal.js`)
		verifyEq(headers.contentSecurityPolicy["default-src"], "http://example.com")
		verifyEq(headers.contentSecurityPolicy["script-src"], null)
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
		headers 	= ((HttpResponse) scope.serviceById(HttpResponse#.qname)).headers
		scriptTag	= (ScriptTagBuilder) scope.build(ScriptTagBuilder#)		
	}
	
	override Void teardown() {
		scope.registry.shutdown
	}
}

internal const class ClientAssetCacheStub : ClientAssetCache {
	override ClientAsset? getAndUpdateOrProduce(Uri localUrl) { ClientAssetStub(localUrl) }
	override ClientAsset? getAndUpdateOrMake(Uri localUrl, |Uri->ClientAsset?| makeFunc) { null }
	override Void remove(Uri? localUrl) { }
	override Void clear() { }
	override Int size() { 0 }
	override Uri toClientUrl(Uri localUrl, ClientAsset asset) { localUrl }
}

internal const class HttpResponseStub : HttpResponse {
	const	 Unsafe _headers
	new 	 make() 			 	 			 { this._headers = Unsafe(HttpResponseHeaders([:]))	} 
	override HttpResponseHeaders headers()		 { _headers.val }
	override Bool isCommitted() 				 { false }
	override OutStream out() 					 { throw UnsupportedErr() }
	override Void saveAsAttachment(Str fileName) { throw UnsupportedErr() }
	override Void onCommit(|HttpResponse| fn)	 { throw UnsupportedErr() }
	override Void reset()						 { throw UnsupportedErr() }
	override Bool disableGzip {
		get { throw UnsupportedErr() }
		set { throw UnsupportedErr() }
	}
	override Bool disableBuffering {
		get { throw UnsupportedErr() }
		set { throw UnsupportedErr() }
	}
	override Int statusCode {
		get { throw UnsupportedErr() }
		set { throw UnsupportedErr() }
	}
}

internal const class ClientAssetStub : ClientAsset {
	override const Uri?			localUrl
	override const Int?			size
	override const DateTime?	modified
	override const MimeType?	contentType
	new make(Uri url) : super(null) {
		this.localUrl = url
	}
	override InStream?	in() { null }
	override Uri? clientUrl() { localUrl }
}
