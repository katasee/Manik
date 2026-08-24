import Foundation

struct AccountStats {
    let visitCount: Int
    let favoriteServiceName: String?

    static let empty = AccountStats(visitCount: 0, favoriteServiceName: nil)

    static func make(
        blocks: [Block],
        clientId: String,
        now: Date
    ) -> AccountStats {
        let visits = blocks.filter { $0.clientId == clientId && $0.isCompleted(now: now) }

        return AccountStats(
            visitCount: visits.count,
            favoriteServiceName: favorite(among: visits)
        )
    }

    private static func favorite(among visits: [Block]) -> String? {
        var tally: [String: (visits: Int, latest: Date)] = [:]

        for visit in visits {
            guard let name = visit.bookedServiceName,
                  let startsAt = visit.startsAt else { continue }

            let counted = tally[name]
            tally[name] = (
                visits: (counted?.visits ?? 0) + 1,
                latest: max(counted?.latest ?? startsAt, startsAt)
            )
        }

        return tally
            .max { ($0.value.visits, $0.value.latest) < ($1.value.visits, $1.value.latest) }?
            .key
    }
}
