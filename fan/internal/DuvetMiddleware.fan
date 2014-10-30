using afIoc
using afBedSheet

internal const class DuvetMiddleware : Middleware {
	
	@Inject private const DuvetProcessor duvetProcessor
	
	new make(|This|in) { in(this) }
	
	override Void service(MiddlewarePipeline pipeline) {
		try {
			pipeline.service
			
		} catch (Err err) {
			duvetProcessor.clear
			throw err
		}
	}
}
