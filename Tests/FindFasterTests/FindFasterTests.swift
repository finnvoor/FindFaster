@testable import FindFaster
import XCTest

final class FindFasterTests: XCTestCase {
    func testSingleElementSearch() async {
        let collection = (0..<100)
        let randomElement = collection.randomElement()!

        var results: [Int] = []
        for await index in collection.fastSearch(for: randomElement) {
            results.append(index)
        }
        XCTAssertEqual(results, [randomElement])
    }

    func testMultiElementSearch() async {
        let collection = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vel lacus in risus finibus semper vel eu magna. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Quisque pulvinar gravida varius. Nulla facilisi. Nullam dignissim egestas pellentesque. Morbi nulla sem, porta eu feugiat vitae, faucibus sit amet tellus. Curabitur nunc ligula, scelerisque id rhoncus ac, facilisis quis odio. Pellentesque egestas luctus rutrum. Nam auctor, ligula auctor suscipit elementum, nunc nunc dignissim nibh, eget sollicitudin diam ligula eget ligula. Etiam sed est fermentum, fermentum leo et, vestibulum nisi. Vivamus vestibulum quam sed mattis volutpat. Suspendisse a mi gravida, placerat metus vel, euismod quam. Sed vehicula velit a justo porta eleifend. Sed fringilla auctor nisi elementum lobortis."
        let search = "et"

        var results: [Int] = []
        for await index in collection.fastSearch(for: search) {
            results.append(collection.distance(from: collection.startIndex, to: index))
            XCTAssertEqual(String(collection[index..<collection.index(index, offsetBy: search.count)]), search)
        }
        XCTAssertEqual(results, [24, 35, 142, 179, 343, 535, 565, 615, 717])
    }
}
