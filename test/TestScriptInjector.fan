using afIoc

internal class TestScriptInjector : DuvetTest {
	
	@Inject ScriptInjector? scriptInjector
	
	Void testExternalUrls() {
		// these are fine
		scriptInjector.addFromExternalUrl(`http://example.com/wotever.css`)
		scriptInjector.addFromExternalUrl(`//example.com/wotever.css`)
		
		// these are not
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`/wotever.css`)) {
			scriptInjector.addFromExternalUrl(`/wotever.css`)
		}
		verifyErrMsg(ArgErr#, ErrMsgs.externalUrlsNeedHost(`dude/wotever.css`)) {
			scriptInjector.addFromExternalUrl(`dude/wotever.css`)
		}
	}
}
