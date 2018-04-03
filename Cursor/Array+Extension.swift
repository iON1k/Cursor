
public extension Array {
    subscript (safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    subscript<R> (safe genericRange: R) -> ArraySlice<Element> where R : RangeExpression, Array.Index == R.Bound {
        return self[safe: genericRange.relative(to: self)]
    }
    
    subscript (safe range: Range<Int>) -> ArraySlice<Element> {
        guard indices.contains(range.lowerBound) else {
            return []
        }
        
        let normalizedRange: Range<Int>
        
        if indices.contains(range.upperBound) {
            normalizedRange = range
        } else {
            normalizedRange = range.lowerBound..<count
        }
        
        return self[normalizedRange]
    }
}
