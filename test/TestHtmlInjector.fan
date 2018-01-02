using afIoc
using afIocConfig::ApplicationDefaults

internal class TestHtmlInjector : DuvetTest {
	
	@Inject HtmlInjector? injector
	
	override Void setup() {
		startBedSheet([T_TestHtmlInjectorMod#])
	}

	Void testFantomMethodsHaveJsFacet() {
		// sad case
		verifyErrMsg(ArgErr#, ErrMsgs.htmlInjector_noJsFacet(T_Fan01#)) {
			injector.injectFantomMethod(T_Fan01#main)
		}
		
		// happy case
		injector.injectFantomMethod(T_Fan02#main)
	}
}

internal const class T_TestHtmlInjectorMod {
	@Contribute { serviceType=ApplicationDefaults# }
	Void contributeAppDefaults(Configuration config) {
		config[DuvetConfigIds.updateCspHeader] = false
	}
}

internal class T_Fan01 {
	Void main() { }
}

@Js
internal class T_Fan02 {
	Void main() { }	
}
