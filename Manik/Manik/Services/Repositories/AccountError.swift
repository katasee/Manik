enum AccountError: Error {
    case profileNotFound
    case wrongPassword
    case weakPassword
    case requiresRecentLogin
    case invalidEmail
    case tooManyRequests
    case network
    case generic
}
