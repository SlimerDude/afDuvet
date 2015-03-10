using afBounce

internal class DuvetTest : Test {
	
	BedClient? client
	
	override Void setup() {
		startBedSheet(null)
	}

	Void startBedSheet(Type[]? appModules) {
		bob := BedServer(DuvetModule#)
		if (appModules != null)
			bob.addModules(appModules)
		server := bob.startup
		server.injectIntoFields(this)
		client = server.makeClient
	}
	
	override Void teardown() {
		client?.shutdown
	}
}
