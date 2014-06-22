using afIoc

internal class TestStylesheetInjector : DuvetTest {
	
	@Inject StylesheetInjector? stylesheetInjector
	
	Void testExternalUrls() {
		// these are fine
		stylesheetInjector.addFromExternalUrl(`http://example.com/wotever.css`)
		stylesheetInjector.addFromExternalUrl(`//example.com/wotever.css`)
		
		// these are not
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`/wotever.css`)) {
			stylesheetInjector.addFromExternalUrl(`/wotever.css`)
		}
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`dude/wotever.css`)) {
			stylesheetInjector.addFromExternalUrl(`dude/wotever.css`)
		}
	}
}
