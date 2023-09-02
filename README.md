# FindFaster

```swift
import FindFaster

let text = "Lorem ipsum dolor sit amet"
let search = "or"

for await index in text.fastSearch(for: search) {
    print("Found match at: \(index)")
}

// Prints:
//  Found match at: 1
//  Found match at: 15
```

Fast asynchronous swift collection search using the [_Boyer–Moore string-search algorithm_](https://en.wikipedia.org/wiki/Boyer%E2%80%93Moore_string-search_algorithm).  `fastSearch` can be used with any `BidirectionalCollection` where `Element` is `Equatable` and `Hashable`, and is especially useful for searching large amounts of data or long strings and displaying the results as they come in.

FindFaster is used for find and replace in [HextEdit](https://apps.apple.com/app/apple-store/id1557247094?pt=120542042&ct=github&mt=8), a fast and native macOS hex editor.
