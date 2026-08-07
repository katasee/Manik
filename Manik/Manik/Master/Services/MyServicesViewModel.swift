import Foundation
import Observation

@MainActor
@Observable
final class MyServicesViewModel {
    private(set) var services: [Service] = []
    private(set) var hasLoaded = false

    private let serviceRepository: ServiceRepository

    init(serviceRepository: ServiceRepository = FirestoreServiceRepository()) {
        self.serviceRepository = serviceRepository
    }

    func observeServices() async {
        for await updatedServices in serviceRepository.observeServices() {
            services = updatedServices.sorted(by: Self.byName)
            hasLoaded = true
        }
    }

    func makeAddServiceViewModel() -> AddServiceViewModel {
        AddServiceViewModel(serviceRepository: serviceRepository)
    }

    private static func byName(_ lhs: Service, _ rhs: Service) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
