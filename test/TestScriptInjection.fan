using afIoc

internal class TestScriptInjection : DuvetTest {
	
	@Inject HtmlInjector? injector
	
	Void testExternalUrls() {
		// these are fine
		injector.injectScript.fromExternalUrl(`http://example.com/wotever.css`)
		injector.injectScript.fromExternalUrl(`//example.com/wotever.css`)
		
		// these are not
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`/wotever.css`)) {
			injector.injectScript.fromExternalUrl(`/wotever.css`)
		}
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`dude/wotever.css`)) {
			injector.injectScript.fromExternalUrl(`dude/wotever.css`)
		}
	}
}
