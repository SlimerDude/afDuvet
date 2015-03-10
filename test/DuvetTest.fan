using afBounce

internal class DuvetTest : Test {
	
	BedClient? client
	
	override Void setup() {
		Log.get("afIoc").level		= LogLevel.warn
		Log.get("afIocEnv").level	= LogLevel.warn
		Log.get("afBedSheet").level	= LogLevel.warn
		Log.get("afDuvet").level	= LogLevel.warn
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
