using afBounce

internal class DuvetTest : Test {
	
	BedClient? client
	
	override Void setup() {
		startBedSheet(null)
	}
	
	Void startBedSheet(Type[]? appModules) {
		setLogLevels
		bob := BedServer(DuvetModule#)
		if (appModules != null)
			bob.addModules(appModules)
		server := bob.startup
		server.inject(this)
		client = server.makeClient
	}
	
	private Void setLogLevels() {
		Log.get("afIoc").level		= LogLevel.warn
		Log.get("afIocEnv").level	= LogLevel.warn
		Log.get("afBedSheet").level	= LogLevel.warn
		Log.get("afDuvet").level	= LogLevel.warn		
	}

	override Void teardown() {
		client?.shutdown
	}
}
