using afIoc

internal class TestLinkInjection : DuvetTest {
	
	@Inject HtmlInjector? injector
	
	Void testExternalUrls() {
		// these are fine
		injector.injectStylesheet.fromExternalUrl(`http://example.com/wotever.css`)
		injector.injectStylesheet.fromExternalUrl(`//example.com/wotever.css`)
		
		// these are not
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`/wotever.css`)) {
			injector.injectStylesheet.fromExternalUrl(`/wotever.css`)
		}
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`dude/wotever.css`)) {
			injector.injectStylesheet.fromExternalUrl(`dude/wotever.css`)
		}
	}
}
