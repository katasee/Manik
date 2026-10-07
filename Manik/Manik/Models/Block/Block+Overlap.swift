extension Block {
    func overlaps(startMinutes start: Int, endMinutes end: Int) -> Bool {
        startMinutes < end && endMinutes > start
    }

    func overlaps(_ other: Block) -> Bool {
        overlaps(startMinutes: other.startMinutes, endMinutes: other.endMinutes)
    }
}
