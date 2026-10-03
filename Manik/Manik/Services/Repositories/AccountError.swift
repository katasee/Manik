enum AccountError: Error {
    case wrongPassword
    case weakPassword
    case requiresRecentLogin
    case profileNotFound
    case generic
}
