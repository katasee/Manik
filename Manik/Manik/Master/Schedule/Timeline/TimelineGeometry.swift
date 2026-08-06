import CoreGraphics

struct TimelineGeometry {
    let hourHeight: CGFloat
    let firstHour: Int

    var totalHeight: CGFloat {
        CGFloat(SalonHours.working.count) * hourHeight
    }

    func offset(forHour hour: Int) -> CGFloat {
        CGFloat(hour - firstHour) * hourHeight
    }

    func offset(for block: Block) -> CGFloat {
        CGFloat(block.startMinutes - firstHour * 60) / 60 * hourHeight
    }

    func height(for block: Block, minimum: CGFloat) -> CGFloat {
        let proportional = CGFloat(block.endMinutes - block.startMinutes) / 60 * hourHeight

        return max(proportional, minimum)
    }
}
