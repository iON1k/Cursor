
import RxSwift

public final class AnyCursor<TItem> {
    public typealias Item = TItem
    public typealias ItemsObservableGetter = () -> Observable<[CursorResult<Item>]>
    public typealias ItemsLoader = (Int) -> Single<Item?>
    
    private let itemsObservableGetter: ItemsObservableGetter
    private let itemsLoader: ItemsLoader
    
    public var itemsObservable: Observable<[CursorResult<Item>]> {
        return itemsObservableGetter()
    }
    
    public init(itemsObservableGetter: @escaping ItemsObservableGetter,
         itemsLoader: @escaping ItemsLoader) {
        self.itemsObservableGetter = itemsObservableGetter
        self.itemsLoader = itemsLoader
    }
    
    public func loadItem(at index: Int) -> Single<Item?> {
        return itemsLoader(index)
    }
    
    public func asCursor() -> AnyCursor<Item> {
        return self
    }
}
