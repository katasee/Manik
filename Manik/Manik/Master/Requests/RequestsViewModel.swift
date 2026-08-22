import Foundation
import Observation

@MainActor
@Observable
final class RequestsViewModel {
    private static let refreshInterval = 60

    private(set) var requests: [BookingRequest] = []
    private(set) var hasLoaded = false
    var hasFailed = false

    private let blockRepository: BlockRepository
    private let serviceRepository: ServiceRepository
    private let userRepository: UserRepository

    private var hasBlocks = false
    private var hasServices = false
    private var inFlightNames: Set<String> = []
    private var running: RunningAction?

    private var blocks: [Block] = [] {
        didSet { rebuild() }
    }

    private var services: [Service] = [] {
        didSet { rebuild() }
    }

    private var clientNames: [String: String] = [:] {
        didSet { rebuild() }
    }

    private var unreadableClientIds: Set<String> = [] {
        didSet { rebuild() }
    }

    private struct RunningAction {
        let requestId: String
        let action: BlockAction
    }

    init(
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        serviceRepository: ServiceRepository = FirestoreServiceRepository(),
        userRepository: UserRepository = FirestoreUserRepository()
    ) {
        self.blockRepository = blockRepository
        self.serviceRepository = serviceRepository
        self.userRepository = userRepository
    }

    var isBusy: Bool {
        running != nil
    }

    func runningAction(on requestId: String) -> BlockAction? {
        guard let running, running.requestId == requestId else { return nil }

        return running.action
    }

    func observeBlocks() async {
        for await updatedBlocks in blockRepository.observeBlocks() {
            hasBlocks = true
            blocks = updatedBlocks

            Task { [weak self] in
                await self?.loadMissingNames()
            }
        }
    }

    func observeServices() async {
        for await updatedServices in serviceRepository.observeServices() {
            hasServices = true
            services = updatedServices
        }
    }

    func refreshRequests() async {
        while Task.isCancelled == false {
            rebuild()
            await loadMissingNames()

            try? await Task.sleep(for: .seconds(Self.refreshInterval))
        }
    }

    func perform(_ action: BlockAction, on requestId: String) async -> Bool {
        guard running == nil else { return false }

        running = RunningAction(requestId: requestId, action: action)
        defer { running = nil }

        do {
            switch action {
            case .confirm:
                try await blockRepository.confirm(blockId: requestId)
            case .decline:
                try await blockRepository.decline(blockId: requestId)
            case .cancelBooking:
                return false
            }

            return true
        } catch {
            hasFailed = true
            return false
        }
    }

    private func loadMissingNames() async {
        let wanted = RequestsList.pendingClientIds(in: blocks, now: .now)
        let missing = wanted.subtracting(clientNames.keys).subtracting(inFlightNames)

        guard missing.isEmpty == false else { return }

        inFlightNames.formUnion(missing)
        defer { inFlightNames.subtract(missing) }

        let loaded = await fetchNames(for: missing)

        unreadableClientIds.formUnion(missing.subtracting(loaded.keys))

        guard loaded.isEmpty == false else { return }

        unreadableClientIds.subtract(loaded.keys)
        clientNames.merge(loaded) { _, new in new }
    }

    private func fetchNames(for uids: Set<String>) async -> [String: String] {
        await withTaskGroup(of: (String, String)?.self) { group in
            for uid in uids {
                group.addTask { [userRepository] in
                    guard let profile = try? await userRepository.fetchProfile(uid: uid) else {
                        return nil
                    }

                    return (uid, profile.name)
                }
            }

            var names: [String: String] = [:]

            for await loaded in group {
                guard let loaded else { continue }

                names[loaded.0] = loaded.1
            }

            return names
        }
    }

    private func rebuild() {
        let now = Date.now

        requests = RequestsList.requests(
            blocks: blocks,
            services: services,
            clientNames: clientNames,
            unreadableClientIds: unreadableClientIds,
            now: now
        )

        guard hasLoaded == false else { return }

        hasLoaded = hasBlocks && hasServices && hasResolvedNames(now: now)
    }

    private func hasResolvedNames(now: Date) -> Bool {
        RequestsList.pendingClientIds(in: blocks, now: now).allSatisfy {
            clientNames[$0] != nil || unreadableClientIds.contains($0)
        }
    }
}
