import RxSwift

public struct InOut<Action, State> {
    public let action: AnyObserver<Action>
    public let state: Observable<State>
}

extension InOut: InOutType {
    public func asInOut() -> InOut<Action, State> {
        return self
    }
}
