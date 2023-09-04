@testable import FindFaster
import XCTest

final class FindFasterTests: XCTestCase {
    let collection1 = (0..<100)
    let collection2 = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lacus in risus finibus semper vel eu magna. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Quisque pulvinar gravida varius. Nulla facilisi. Nullam dignissim egestas pellentesque. Morbi nulla sem, porta eu feugiat vitae, faucibus sit amet tellus. Curabitur nunc ligula, scelerisque id rhoncus ac, facilisis quis odio. Pellentesque egestas luctus rutrum. Nam auctor, ligula auctor suscipit elementum, nunc nunc dignissim nibh, eget sollicitudin diam ligula eget ligula. Etiam sed est fermentum, fermentum leo et, vestibulum nisi. Vivamus vestibulum quam sed mattis volutpat. Suspendisse a mi gravida, placerat metus vel, euismod quam. Sed vehicula velit a justo porta eleifend. Sed fringilla auctor nisi elementum lobortis."

    func testSingleElementSearchSync() {
        let search = collection1.randomElement()!
        let results = collection1.fastSearch(for: search)
        XCTAssertEqual(results, [search])
    }

    func testMultiElementSearchSync() {
        let search = "et"
        let results = collection2
            .fastSearch(for: search)
            .map { collection2.distance(from: collection2.startIndex, to: $0) }
        XCTAssertEqual(results, [24, 35, 142, 179, 343, 535, 565, 615, 717])
    }

    func testSingleElementSearchClosure() {
        let search = collection1.randomElement()!
        var results: [Int] = []
        collection1.fastSearch(for: search) { index in
            results.append(index)
        }
        XCTAssertEqual(results, [search])
    }

    func testMultiElementSearchClosure() {
        let search = "et"
        var results: [Int] = []
        collection2.fastSearch(for: search) { index in
            results.append(self.collection2.distance(from: self.collection2.startIndex, to: index))
        }
        XCTAssertEqual(results, [24, 35, 142, 179, 343, 535, 565, 615, 717])
    }

    func testSingleElementSearchAsync() async {
        let search = collection1.randomElement()!
        var results: [Int] = []
        for await index in collection1.fastSearchStream(for: search) {
            results.append(index)
        }
        XCTAssertEqual(results, [search])
    }

    func testMultiElementSearchAsync() async {
        let search = "et"
        var results: [Int] = []
        for await index in collection2.fastSearchStream(for: search) {
            results.append(collection2.distance(from: collection2.startIndex, to: index))
            XCTAssertEqual(String(collection2[index..<collection2.index(index, offsetBy: search.count)]), search)
        }
        XCTAssertEqual(results, [24, 35, 142, 179, 343, 535, 565, 615, 717])
    }
}
