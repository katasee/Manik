protocol UserDataRepository {
    /// Deletes everything the signed-in master stored: every collection under `users/{uid}/` and
    /// the user document itself. Safe to call again after a partial failure.
    func deleteAllData() async throws
}
