import Foundation

extension BidirectionalCollection where Element: Equatable, Element: Hashable {
    public func fastSearch(for element: Self.Element) -> AsyncStream<Index> {
        singleElementSearch(for: element)
    }

    public func fastSearch(for searchSequence: some Collection<Element>) -> AsyncStream<Index> {
        switch searchSequence.count {
        case 0: AsyncStream { $0.finish() }
        case 1: singleElementSearch(for: searchSequence[searchSequence.startIndex])
        default: multiElementSearch(for: searchSequence)
        }
    }

    private func singleElementSearch(for element: Element) -> AsyncStream<Index> {
        AsyncStream { continuation in
            var currentIndex = startIndex
            while currentIndex < endIndex {
                if self[currentIndex] == element {
                    continuation.yield(currentIndex)
                }
                currentIndex = index(after: currentIndex)
            }
            continuation.finish()
        }
    }

    /// Boyer–Moore algorithm
    private func multiElementSearch(for searchSequence: some Collection<Element>) -> AsyncStream<Index> {
        AsyncStream { continuation in
            guard !searchSequence.isEmpty, searchSequence.count <= count else {
                continuation.finish()
                return
            }

            let skipTable: [Element: Int] = searchSequence
                .enumerated()
                .reduce(into: [:]) { $0[$1.element] = searchSequence.count - $1.offset - 1 }

            var currentIndex = index(startIndex, offsetBy: searchSequence.count - 1)
            while currentIndex < endIndex {
                let skip = skipTable[self[currentIndex]] ?? searchSequence.count
                if skip == 0 {
                    let lowerBound = index(currentIndex, offsetBy: -searchSequence.count + 1)
                    let upperBound = index(currentIndex, offsetBy: 1)
                    if self[lowerBound..<upperBound].elementsEqual(searchSequence) {
                        continuation.yield(lowerBound)
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
            continuation.finish()
        }
    }
}
