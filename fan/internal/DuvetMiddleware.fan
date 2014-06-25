using afIoc
using afBedSheet

internal const class DuvetMiddleware : Middleware {
	
	@Inject private const DuvetProcessor duvetProcessor
	
	new make(|This|in) { in(this) }
	
	override Bool service(MiddlewarePipeline pipeline) {
		try {
			return pipeline.service
			
		} catch (Err err) {
			duvetProcessor.clear
			throw err
		}
	}
}
