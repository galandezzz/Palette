extension Comparable {
    
    func limited(_ lowerBound: Self, _ upperBound: Self) -> Self {
        min(max(lowerBound, self), upperBound)
    }
}
