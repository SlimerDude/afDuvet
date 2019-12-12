
internal const class LogMsgs {
	
	static Str canNotFindHead(Str html) {
		"Could not find '</head>' in HTML response.\n${html}"
	}

	static Str canNotFindBody(Str html) {
		"Could not find '</body>' in HTML response.\n${html}"
	}
}
