
internal const class ErrMsgs {
	
	static Str externalUrlsNeedHost(Uri url) {
		"External URLs should specify a host - ${url}"
	}
	
	static Str urlMustBePathOnly(Str type, Uri url, Uri example) {
		"${type} URL `${url}` must ONLY be a path. e.g. `${example}`"
	}

	static Str urlMustStartWithSlash(Str type, Uri url, Uri example) {
		"${type} URL `${url}` must start with a slash. e.g. `${example}`"
	}

	static Str urlMustEndWithSlash(Str type, Uri url, Uri example) {
		"${type} URL `${url}` must end with a slash. e.g. `${example}`"
	}

	static Str urlMustNotEndWithSlash(Str type, Uri url, Uri example) {
		"${type} URL `${url}` must NOT end with a slash. e.g. `${example}`"
	}

	static Str requireJsLibNoExist(File requireJsFile) {
		"RequireJs file '${requireJsFile.normalize}' does not exist!"
	}

	static Str requireJsTimeoutMustBePositive(Duration timeout) {
		"requireJsTimeout must be greater than zero - ${timeout}"
	}
}
