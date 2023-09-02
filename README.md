# FindFaster

```swift
let text = "Lorem ipsum dolor sit amet"
let search = "or"

for await index in text.fastSearch(for: search) {
    print("Found match at: \(index)")
}

// Prints:
//  Found match at: 1
//  Found match at: 15
```
