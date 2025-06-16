extension Collection where Index: Strideable {
    
    func chunk(into size: Index.Stride) -> [[Element]] {
        stride(from: startIndex, to: endIndex, by: size).map {
            Array(self[$0 ..< Swift.min($0.advanced(by: size), endIndex)])
        }
    }
}
