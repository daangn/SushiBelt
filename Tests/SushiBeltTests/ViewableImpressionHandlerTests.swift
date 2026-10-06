import Testing
import UIKit

@testable import KarrotImpression

@MainActor
struct ViewableImpressionHandlerTests {
  private final class TableView: UITableView {
    var cells: [UITableViewCell] = []
    override var visibleCells: [UITableViewCell] { cells }
  }

  @Test
  func test_factory_should_map_impressions_and_viewability_independently_for_the_same_cell() {
    let tableView = TableView()
    let cell = UITableViewCell()
    tableView.cells = [cell]
    let factory = DefaultDetectorItemFactory(
      mapper: { VisibleStateDetectorItem(id: "item", target: $0, ratio: 0.1) },
      viewabilityMapper: { ViewabilityItem(id: "item", target: $0, ratio: 0.5) }
    )

    let impressions = factory.makeVisibleDetectorItems(view: tableView)
    let viewabilityItems = factory.makeViewabilityItems(view: tableView)

    #expect(impressions.count == 1)
    #expect(viewabilityItems.count == 1)
    #expect(impressions.first?.ratio == 0.1)
    #expect(viewabilityItems.first?.ratio == 0.5)
    #expect(impressions.first?.target as? UITableViewCell === cell)
    #expect(viewabilityItems.first?.target as? UITableViewCell === cell)
  }

  @Test
  func test_existing_factory_initializers_and_conformances_should_default_to_no_viewability_items() {
    let tableView = TableView()
    tableView.cells = [UITableViewCell()]
    let factory = DefaultDetectorItemFactory { cell in
      VisibleStateDetectorItem(id: "item", target: cell, ratio: 0.1)
    }
    let customFactory = DetectorItemFactoryStub()

    #expect(factory.makeVisibleDetectorItems(view: tableView).count == 1)
    #expect(factory.makeViewabilityItems(view: tableView).isEmpty)
    #expect(customFactory.makeViewabilityItems(view: tableView).isEmpty)
  }

  @Test
  func test_manual_tracking_should_deliver_the_typed_factory_viewability_items_without_impressions() {
    let detector = VisibleStateDetector(
      sushiBeltTracker: SushiBeltTracker(),
      sushiBeltDebugger: SushiBeltDebuggerSpy()
    )
    let tracker = ImpressionEventTracker(
      detector: detector,
      application: UIApplication.self,
      cooltimeCache: InMemoryImpressionCooltimeCacheImpl(dateProvider: { Date() }),
      usesInitialVisibility: false
    )
    let tableView = TableView()
    let cell = UITableViewCell()
    cell.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    tableView.cells = [cell]
    let factory = DefaultDetectorItemFactory(
      mapper: { _ in nil },
      viewabilityMapper: { ViewabilityItem(id: "item", target: $0, ratio: 0.5) }
    )
    var events: [String] = []
    tracker.subscribeViewability {
      switch $0 {
      case .entered: events.append("enter")
      case .exited: events.append("exit")
      }
    }
    tracker.register(scrollView: tableView, detectorItemFactory: factory) {
      CGRect(x: 0, y: 0, width: 100, height: 100)
    }

    #expect(cell.frameInWindow == CGRect(x: 0, y: 0, width: 100, height: 100))
    tracker.trackManually(shouldResetCache: false)
    tracker.clearCache()

    #expect(events == ["enter", "exit"])
  }

  @Test
  func test_duplicate_viewability_ids_should_create_one_session_with_the_first_registration() {
    let detector = VisibleStateDetector(
      sushiBeltTracker: SushiBeltTracker(),
      sushiBeltDebugger: SushiBeltDebuggerSpy()
    )
    let tracker = ImpressionEventTracker(
      detector: detector,
      application: UIApplication.self,
      cooltimeCache: InMemoryImpressionCooltimeCacheImpl(dateProvider: { Date() }),
      usesInitialVisibility: false
    )
    let target = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let first = ViewabilityItem(id: "item", target: target, ratio: 0.5, userInfo: ["marker": "first"])
    let duplicate = ViewabilityItem(id: "item", target: target, ratio: 1, userInfo: ["marker": "duplicate"])
    var events: [String] = []
    tracker.subscribeViewability {
      switch $0 {
      case .entered(let item): events.append("enter:\(item.userInfo?["marker"] as? String ?? "missing")")
      case .exited(let item): events.append("exit:\(item.userInfo?["marker"] as? String ?? "missing")")
      }
    }

    detector.detect(items: [], viewabilityItems: [first, duplicate]) {
      CGRect(x: 0, y: 0, width: 100, height: 60)
    }
    tracker.clearCache()

    #expect(events == ["enter:first", "exit:first"])
  }
}
