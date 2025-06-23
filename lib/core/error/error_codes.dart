enum ErrorCode {
  // Network Errors
  noInternet,
  timeout,
  networkOther,

  // Server Errors
  serverInternalError,
  apiError,
  invalidResponse,

  // Authentication Errors
  authenticationFailed, 
  unauthorized,
  
  // Cache Errors
  cacheError,

 
  unknownError,
}