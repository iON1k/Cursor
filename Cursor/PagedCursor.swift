
import RxSwift

public final class PagedCursor<TItem>: CursorType {
    public typealias Item = TItem
    typealias Page = [TItem]
    
    private let scheduler: SerialDispatchQueueScheduler
    private let sourceCursor: Cursor<Page>
    private let pageSize: Int
    private let disposeBag = DisposeBag()
    private let itemsSubject = ReplaySubject<[CursorResult<Item>]>.create(bufferSize: 1)
    
    public var itemsObservable: Observable<[CursorResult<Item>]> {
        return itemsSubject.asObservable()
    }
    
    init(pageSize: Int,
         scheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(qos: .default),
         sourceCursor: Cursor<Page>) {
        self.pageSize = pageSize
        self.scheduler = scheduler
        self.sourceCursor = sourceCursor
        
        sourceCursor.itemsObservable
            .observeOn(scheduler)
            .map { [weak self] pages in
                guard let strongSelf = self else {
                    return []
                }
                
                return pages.reduce([]) { (result, pageResult) -> [CursorResult<Item>] in
                    return result + strongSelf.unwrap(result: pageResult)
                }
            }
            .multicast(itemsSubject)
            .connect()
            .disposed(by: disposeBag)
    }
    
    public func loadItem(at index: Int) -> Single<Item?> {
        return Single.deferred {
            let pageIndex = index / self.pageSize
            return self.sourceCursor
                .loadItem(at: pageIndex)
                .observeOn(self.scheduler)
                .map { page in
                    let itemOnPageIndex = index % self.pageSize
                    return page?[safe: itemOnPageIndex]
                }
        }
        .subscribeOn(scheduler)
    }
    
    private func unwrap(page: Page) -> [Item?] {
        return (0..<pageSize)
            .map { page[safe: $0] }
    }
    
    private func unwrap(result: CursorResult<Page>) -> [CursorResult<Item>] {
        switch result {
        case .notLoaded:
            return Array(repeating: .notLoaded, count: pageSize)
        case let .item(page):
            return unwrap(page: page)
                .map { item in
                    guard let item = item else {
                        return .notLoaded
                    }
                    
                    return .item(item)
            }
        }
    }
}
