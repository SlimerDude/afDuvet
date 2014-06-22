using afBounce

internal class DuvetTest : Test {
	
	BedClient? client
	
	override Void setup() {
		server := BedServer(T_AppModule#).addModule(DuvetModule#).startup
		server.injectIntoFields(this)
		client = server.makeClient
	}
	
	override Void teardown() {
		client.shutdown
	}
	
	Void verifyErrMsg(Type errType, Str errMsg, |Test| c) {
		try {
			c.call(this)
		} catch (Err e) {
			if (!e.typeof.fits(errType)) 
				verifyEq(errType, e.typeof)
			verifyEq(errMsg, e.msg)
			return
		}
		fail("$errType not thrown")
	}
}
