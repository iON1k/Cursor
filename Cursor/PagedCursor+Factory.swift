
import RxSwift

public enum PagedCursorConstants {
    public static let defaultPageSize = 100
}

public extension PagedCursor {
    convenience init<Anchor>(
        pageSize: Int = PagedCursorConstants.defaultPageSize,
        pages: [CursorResult<[Item]>] = [],
        anchor: Anchor? = nil,
        scheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(qos: .default),
        sourceFactory: @escaping PagedCursorEngine<Item, Anchor>.SourceFactory) {
        
        self.init(
            pageSize: pageSize,
            scheduler: scheduler,
            sourceCursor: Cursor(
                items: pages,
                scheduler: scheduler,
                sourceFactory: PagedCursorEngine(
                    pageSize: pageSize,
                    anchor: anchor,
                    scheduler: scheduler,
                    sourceFactory: sourceFactory
                    )
                    .loadPage
            )
        )
    }
    
    convenience init(
        pageSize: Int = PagedCursorConstants.defaultPageSize,
        pages: [CursorResult<[Item]>] = [],
        scheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(qos: .default),
        sourceFactory: @escaping (Range<Int>) -> Observable<[Item]>) {
        
        self.init(
            pageSize: pageSize,
            scheduler: scheduler,
            sourceCursor: Cursor(
                items: pages,
                scheduler: scheduler,
                sourceFactory: PagedCursorEngine(
                    pageSize: pageSize,
                    anchor: Void(),
                    scheduler: scheduler,
                    sourceFactory: { range, _ in
                        return sourceFactory(range)
                            .map {
                                return PagedCursorEngineResult(
                                    items: $0,
                                    anchor: Void()
                                )
                        }
                }
                    )
                    .loadPage
            )
        )
    }
}
