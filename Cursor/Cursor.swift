
import RxSwift

public final class Cursor<TItem>: CursorType {
    public typealias Item = TItem
    public typealias SourceFactory = (Int) -> Observable<Item?>
    
    private let sourceFactory: SourceFactory
    private let scheduler: SerialDispatchQueueScheduler
    private var activeSources: [Int: Observable<Item?>] = [:]
    private let itemsVariable: Variable<[CursorResult<Item>]>
    
    public var itemsObservable: Observable<[CursorResult<Item>]> {
        return itemsVariable.asObservable()
    }
    
    public init(items: [CursorResult<Item>] = [],
         scheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(qos: .default),
         sourceFactory: @escaping SourceFactory) {
        itemsVariable = Variable(items)
        self.sourceFactory = sourceFactory
        self.scheduler = scheduler
    }
    
    public func loadItem(at index: Int) -> Single<Item?> {
        return Observable.deferred {
            let source: Observable<Item?>
            if let activeSource = self.activeSources[index] {
                source = activeSource
            } else {
                source = self.createSource(for: index)
                    .do(onDispose: { [weak self] in
                        self?.activeSources.removeValue(forKey: index)
                    })
                    .takeLast(1)
                    .share(replay: 1)
                
                self.activeSources[index] = source
            }
            
            return source
        }
        .subscribeOn(scheduler)
        .asSingle()
    }
    
    private func createSource(for index: Int) -> Observable<Item?> {
        return sourceFactory(index)
            .observeOn(scheduler)
            .do(onNext: { [weak self] item in
                guard let strongSelf = self else {
                    return
                }
                
                if let item = item {
                    strongSelf.add(item: item, at: index)
                } else {
                    strongSelf.removeItems(from: index)
                }
            })
    }
    
    private func add(item: Item, at index: Int) {
        var items = itemsVariable.value
        while items.count < index {
            items.append(.notLoaded)
        }
        
        items.append(.item(item))
        itemsVariable.value = items
    }
    
    private func removeItems(from index: Int) {
        var items = itemsVariable.value
        guard items.indices.contains(index) else {
            return
        }
        
        items.removeLast(items.count - index)
        itemsVariable.value = items
    }
}
