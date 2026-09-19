import XCTest
@testable import CoffeeTaper

final class TaperStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suite: String!

    override func setUp() {
        super.setUp()
        suite = "CoffeeTaperTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
        defaults = nil
        super.tearDown()
    }

    func testFirstLaunchStartsFull() {
        let store = TaperStore(defaults: defaults)
        XCTAssertEqual(store.eighths, 8)
        XCTAssertEqual(store.label, "1")
    }

    func testTargetSurvivesNewStoreIncludingZero() {
        let store = TaperStore(defaults: defaults)
        for target in [7, 6, 4, 1, 0, 8] {
            store.setEighths(target)
            let reopened = TaperStore(defaults: UserDefaults(suiteName: suite)!)
            XCTAssertEqual(reopened.eighths, target)
        }
    }

    func testDragPositionsAndOutOfBounds() {
        XCTAssertEqual(TaperStore.level(at: -50, height: 400), 8)
        XCTAssertEqual(TaperStore.level(at: 0, height: 400), 8)
        XCTAssertEqual(TaperStore.level(at: 50, height: 400), 7)
        XCTAssertEqual(TaperStore.level(at: 100, height: 400), 6)
        XCTAssertEqual(TaperStore.level(at: 200, height: 400), 4)
        XCTAssertEqual(TaperStore.level(at: 400, height: 400), 0)
        XCTAssertEqual(TaperStore.level(at: 500, height: 400), 0)
    }

    func testInvalidSavedLevelIsClamped() {
        defaults.set(-3, forKey: TaperStore.storageKey)
        XCTAssertEqual(TaperStore(defaults: defaults).eighths, 0)
        defaults.set(15, forKey: TaperStore.storageKey)
        XCTAssertEqual(TaperStore(defaults: defaults).eighths, 8)
    }

    func testAccessibilityStepsStopAtBounds() {
        let store = TaperStore(defaults: defaults)
        store.setEighths(9)
        XCTAssertEqual(store.eighths, 8)
        store.setEighths(-1)
        XCTAssertEqual(store.eighths, 0)
    }
}
