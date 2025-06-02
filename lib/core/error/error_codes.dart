enum ErrorCode {
  // Network Errors
  noInternet,
  timeout,
  networkOther,

  // Server Errors
  serverInternalError, // 5xx errors or general server issues
  apiError,            // Specific error message from API (4xx, 5xx)
  invalidResponse,     // Response format is not as expected

  // Authentication Errors
  authenticationFailed, // e.g., wrong NIK/password
  unauthorized,         // Missing or invalid token for protected resources (not for login)
  
  // Cache Errors
  cacheError,

  // Input Validation / Client-side Errors (jika diperlukan)
  // validationError, 

  // Unknown/Generic Error
  unknownError,
}