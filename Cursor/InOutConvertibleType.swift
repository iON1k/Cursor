
import RxSwift

public protocol InOutConvertibleType {
    associatedtype Action
    associatedtype State
    
    func asInOut() -> InOut<Action, State>
}
