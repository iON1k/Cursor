
public protocol CursorConvertableType {
    associatedtype Item
    
    func asCursor() -> AnyCursor<Item>
}
