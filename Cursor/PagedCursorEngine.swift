
import RxSwift

public struct PagedCursorEngineResult<Item, Anchor> {
    let items: [Item]
    let anchor: Anchor
}

public final class PagedCursorEngine<Item, Anchor> {
    public typealias SourceFactory = (Range<Int>, Anchor?) -> Observable<PagedCursorEngineResult<Item, Anchor>>
    
    private let pageSize: Int
    private var anchor: Anchor?
    private let scheduler: SerialDispatchQueueScheduler
    private let sourceFactory: SourceFactory
    private let isFirstPageLoading = Variable(false)
    
    public init(pageSize: Int,
                anchor: Anchor? = nil,
                scheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(qos: .default),
                sourceFactory: @escaping SourceFactory) {
        self.pageSize = pageSize
        self.anchor = anchor
        self.scheduler = scheduler
        self.sourceFactory = sourceFactory
    }
    
    public func loadPage(at index: Int) -> Observable<[Item]?> {
        return Observable.deferred {
            if self.isFirstPageLoading.value {
                return self.isFirstPageLoading
                    .asObservable()
                    .filter { $0 == false }
                    .flatMap { _ in
                        self.loadPage(at: index)
                    }
            } else {
                let source: Observable<PagedCursorEngineResult<Item, Anchor>>
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
