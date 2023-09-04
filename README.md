# FindFaster

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FFinnvoor%2FFindFaster%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Finnvoor/FindFaster) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FFinnvoor%2FFindFaster%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Finnvoor/FindFaster)

Fast asynchronous swift collection search using the [_Boyer–Moore string-search algorithm_](https://en.wikipedia.org/wiki/Boyer%E2%80%93Moore_string-search_algorithm).  `fastSearch` can be used with any `BidirectionalCollection` where `Element` is `Hashable`, and is especially useful for searching large amounts of data or long strings and displaying the results as they come in.

FindFaster is used for find and replace in [HextEdit](https://apps.apple.com/app/apple-store/id1557247094?pt=120542042&ct=github&mt=8), a fast and native macOS hex editor.

## Usage
### Async 
```swift
import FindFaster

let text = "Lorem ipsum dolor sit amet"
let search = "or"

for await index in text.fastSearchStream(for: search) {
    print("Found match at: \(index)")
}

// Prints:
//  Found match at: 1
//  Found match at: 15
```

### Sync
```swift
import FindFaster

let text = "Lorem ipsum dolor sit amet"
let search = "or"

let results = text.fastSearch(for: search)
print("Results: \(results)")

// Prints:
//  Results: [1, 15]
```

### Closure-based
```swift
import FindFaster

let text = "Lorem ipsum dolor sit amet"
let search = "or"

text.fastSearch(for: search) { index in
    print("Found match at: \(index)")
}

// Prints:
//  Found match at: 1
//  Found match at: 15
```
