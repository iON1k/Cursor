
import RxSwift

public protocol CursorType: CursorConvertable {
    var itemsObservable: Observable<[CursorResult<Item>]> { get }
    
    func loadItem(at index: Int) -> Single<Item?>
}

public extension CursorType {
    func loadItems(in range: Range<Int>) -> Single<[Item?]> {
        return Observable.from(Array(range.lowerBound..<range.upperBound))
            .flatMap({ (index) -> Single<(item: Item?, index: Int)> in
                return self.loadItem(at: index)
                    .map { (item: $0, index: index) }
            })
            .toArray()
            .map { result in
                return result
                    .sorted { $0.index < $1.index }
                    .map { $0.item }
            }
            .asSingle()
    }
}

public extension CursorType {
    func asCursor() -> AnyCursor<Item> {
        return AnyCursor(
            itemsObservableGetter: { self.itemsObservable },
            itemsLoader: loadItem
        )
    }
}
