
import RxSwift

public struct PagedCursorEngineResult<TItem, TAnchor> {
    let items: [TItem]
    let anchor: TAnchor
}

public final class PagedCursorEngine<TItem, TAnchor> {
    public typealias SourceFactory = (Range<Int>, TAnchor?) -> Observable<PagedCursorEngineResult<TItem, TAnchor>>
    
    private let pageSize: Int
    private var anchor: TAnchor?
    private let scheduler: SerialDispatchQueueScheduler
    private let sourceFactory: SourceFactory
    private let isFirstPageLoading = Variable(false)
    
    public init(pageSize: Int,
                anchor: TAnchor? = nil,
                scheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(qos: .default),
                sourceFactory: @escaping SourceFactory) {
        self.pageSize = pageSize
        self.anchor = anchor
        self.scheduler = scheduler
        self.sourceFactory = sourceFactory
    }
    
    public func loadPage(at index: Int) -> Observable<[TItem]?> {
        return Observable.deferred {
            if self.isFirstPageLoading.value {
                return self.isFirstPageLoading
                    .asObservable()
                    .filter { $0 == false }
                    .flatMap { _ in
                        self.loadPage(at: index)
                    }
            } else {
                let source: Observable<PagedCursorEngineResult<TItem, TAnchor>>
                let range: Range = index * self.pageSize..<(index + 1) * self.pageSize
                
                if let anchor = self.anchor {
                    source = self.sourceFactory(range, anchor)
                } else {
                    source = self.sourceFactory(range, nil)
                        .do(onNext: { result in
                            self.anchor = result.anchor
                        }, onSubscribe: {
                            self.isFirstPageLoading.value = true
                        }, onDispose: {
                            self.isFirstPageLoading.value = false
                        })
                }
                
                return source
                    .map { $0.items }
            }
        }
        .subscribeOn(scheduler)
    }
}
