using afBounce

internal class DuvetTest : Test {
	
	BedClient? client
	
	override Void setup() {
		startBedSheet(null)
	}

	Void startBedSheet(Type? appModule) {
		bob := BedServer(DuvetModule#)
		if (appModule != null)
			bob.addModule(appModule)
		server := bob.startup
		server.injectIntoFields(this)
		client = server.makeClient
	}
	
	override Void teardown() {
		client?.shutdown
	}
}
