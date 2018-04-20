
import RxSwift

public protocol InOutType: InOutConvertibleType {
    var action: AnyObserver<Action> { get }
    var state: Observable<State> { get }
}

