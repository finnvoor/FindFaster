import Foundation

public extension BidirectionalCollection where Element: Equatable, Element: Hashable {
    /// Returns an `AsyncStream` delivering indices where the specified value appears in the collection.
    /// - Parameter element: An element to search for in the collection.
    /// - Returns: An `AsyncStream` delivering indices where `element` is found.
    func fastSearchStream(for element: Element) -> AsyncStream<Index> {
        fastSearchStream(for: [element])
    }

    /// Returns an `AsyncStream` delivering indices where the specified sequence appears in the collection.
    /// - Parameter searchSequence: A sequence of elements to search for in the collection.
    /// - Returns: An `AsyncStream` delivering indices where `searchSequence` is found.
    func fastSearchStream(for searchSequence: some Collection<Element>) -> AsyncStream<Index> {
        AsyncStream { continuation in
            let task = Task {
                fastSearch(for: searchSequence) { index in
                    continuation.yield(index)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Returns the indices where the specified value appears in the collection.
    /// - Parameters:
    ///   - element: An element to search for in the collection.
    ///   - onSearchResult: An optional closure that is called when a matching index is found.
    /// - Returns: The indices where `element` is found. If `element` is not found in the collection, returns an empty array.
    @discardableResult func fastSearch(
        for element: Element,
        onSearchResult: ((Index) -> Void)? = nil
    ) -> [Index] {
        fastSearch(for: [element], onSearchResult: onSearchResult)
    }

    /// Returns the indices where the specified sequence appears in the collection.
    /// - Parameters:
    ///   - searchSequence: A sequence of elements to search for in the collection.
    ///   - onSearchResult: An optional closure that is called when a matching index is found.
    /// - Returns: The indices where `searchSequence` is found. If `searchSequence` is not found in the collection, returns an empty array.
    @discardableResult func fastSearch(
        for searchSequence: some Collection<Element>,
        onSearchResult: ((Index) -> Void)? = nil
    ) -> [Index] {
        switch searchSequence.count {
        case 0: return []
        case 1: return naiveSingleElementSearch(for: searchSequence.first!, onSearchResult: onSearchResult)
        default: return boyerMooreMultiElementSearch(for: searchSequence, onSearchResult: onSearchResult)
        }
    }
}

private extension BidirectionalCollection where Element: Equatable, Element: Hashable {
    @discardableResult func naiveSingleElementSearch(
        for element: Element,
        onSearchResult: ((Index) -> Void)? = nil
    ) -> [Index] {
        var indices: [Index] = []
        var currentIndex = startIndex
        while currentIndex < endIndex, !Task.isCancelled {
            if self[currentIndex] == element {
                indices.append(currentIndex)
                onSearchResult?(currentIndex)
            }
            currentIndex = index(after: currentIndex)
        }
        return indices
    }

    /// Boyer–Moore algorithm
    @discardableResult func boyerMooreMultiElementSearch(
        for searchSequence: some Collection<Element>,
        onSearchResult: ((Index) -> Void)? = nil
    ) -> [Index] {
        guard searchSequence.count <= count else { return [] }

        var indices: [Index] = []
        let skipTable: [Element: Int] = searchSequence
            .enumerated()
            .reduce(into: [:]) { $0[$1.element] = searchSequence.count - $1.offset - 1 }

        var currentIndex = index(startIndex, offsetBy: searchSequence.count - 1)
        while currentIndex < endIndex, !Task.isCancelled {
            let skip = skipTable[self[currentIndex]] ?? searchSequence.count
            if skip == 0 {
                let lowerBound = index(currentIndex, offsetBy: -searchSequence.count + 1)
                let upperBound = index(currentIndex, offsetBy: 1)
                if self[lowerBound..<upperBound].elementsEqual(searchSequence) {
                    onSearchResult?(lowerBound)
                    indices.append(lowerBound)
                }
                guard let nextIndex = index(
                    currentIndex,
                    offsetBy: Swift.max(skip, 1),
                    limitedBy: endIndex
                ) else { break }
                currentIndex = nextIndex
            } else {
                guard let nextIndex = index(
                    currentIndex,
                    offsetBy: skip,
                    limitedBy: endIndex
                ) else { break }
                currentIndex = nextIndex
            }
        }
        return indices
    }
}
