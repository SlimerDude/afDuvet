using afIoc
using afBedSheet

internal class TestModulePaths : DuvetTest {
	
	override Void setup() { }
	
	Void testNestedModuleIds() {
		moduleMap := ModulePaths.moduleMap(`/modules/`, `test/`.toFile)
		
		verifyEq(moduleMap["basic"],	`/modules/basic.js`)
		verifyEq(moduleMap["my/horse"],	`/modules/my/horse.js`)
		verifyEq(moduleMap["my/cart"],	`/modules/my/cart.js`)
	}

}
