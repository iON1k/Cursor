
public protocol CursorConvertable {
    associatedtype Item
    
    func asCursor() -> AnyCursor<Item>
}
