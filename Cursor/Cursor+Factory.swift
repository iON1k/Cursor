
import RxSwift

public extension Cursor {
    convenience init(
        items: [Item],
        scheduler: SerialDispatchQueueScheduler = MainScheduler.instance) {
        self.init(
            items: items.map { .item($0) },
            scheduler: scheduler) {
                Observable.just(items[safe: $0])
            }
    }
}
