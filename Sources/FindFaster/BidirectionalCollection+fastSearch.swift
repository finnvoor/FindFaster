import Foundation

public extension BidirectionalCollection where Element: Equatable, Element: Hashable {
    func fastSearchStream(for element: Element) -> AsyncStream<Index> {
        fastSearchStream(for: [element])
    }

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

    @discardableResult func fastSearch(
        for element: Element,
        onSearchResult: ((Index) -> Void)? = nil
    ) -> [Index] {
        fastSearch(for: [element], onSearchResult: onSearchResult)
    }

    @discardableResult func fastSearch(
        for searchSequence: some Collection<Element>,
        onSearchResult: ((Index) -> Void)? = nil
    ) -> [Index] {
        switch searchSequence.count {
        case 0: []
        case 1: naiveSingleElementSearch(for: searchSequence.first!, onSearchResult: onSearchResult)
        default: boyerMooreMultiElementSearch(for: searchSequence, onSearchResult: onSearchResult)
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
