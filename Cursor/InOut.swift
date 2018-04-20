
import RxSwift

public struct InOut<Action, State> {
    let action: AnyObserver<Action>
    let state: Observable<State>
}

public extension InOut {
    func asInOut() -> InOut<Action, State> {
        return self
    }
}
