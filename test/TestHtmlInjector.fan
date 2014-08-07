using afIoc

internal class TestHtmlInjector : DuvetTest {
	
	@Inject HtmlInjector? injector
	
	Void testFantomMethodsHaveJsFacet() {
		// sad case
		verifyErrMsg(ArgErr#, ErrMsgs.htmlInjector_noJsFacet(T_Fan01#)) {
			injector.injectFantomMethod(T_Fan01#main)
		}
		
		// happy case
		injector.injectFantomMethod(T_Fan02#main)
	}

}

internal class T_Fan01 {
	Void main() { }
}

@Js
internal class T_Fan02 {
	Void main() { }	
}