import RxSwift
import RxCocoa

fileprivate enum ReactorAssociatedKeys {
    static var action = "action"
    static var state = "state"
    static var disposeBag = "disposeBag"
}

public extension ReactorType {
    var action: AnyObserver<Action> {
        return actionSubject
            .asObserver()
    }
    
    var stateObservable: Observable<State> {
        return stateRelay.asObservable()
    }

    var state: State {
        return stateRelay.value
    }
    
    var workingScheduler: SerialDispatchQueueScheduler {
        return MainScheduler.instance
    }
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        return action
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }

    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return mutation
    }
    
    private var disposeBag: DisposeBag {
        return associatedObject(forKey: &ReactorAssociatedKeys.disposeBag, default: .init())
    }

    private var stateRelay: BehaviorRelay<State> {
        return associatedObject(forKey: &ReactorAssociatedKeys.state, default: createStateRelay())
    }
    
    private var actionSubject: PublishSubject<Action> {
        return associatedObject(forKey: &ReactorAssociatedKeys.action, default: .init())
    }

    private func createStateRelay() -> BehaviorRelay<State> {
        let mutation = transform(action: actionSubject.asObservable())
            .observeOn(workingScheduler)
            .flatMap { [weak self] action -> Observable<Mutation> in
                guard let strongSelf = self else { return .empty() }
                return strongSelf
                    .mutate(action: action)
                    .catchError { _ in .empty() }
            }

        let resultRealay = BehaviorRelay(value: initialState)
        transform(mutation: mutation)
            .observeOn(workingScheduler)
            .withLatestFrom(resultRealay) { ($0, $1) }
            .map { [weak self] mutation, state -> State in
                guard let strongSelf = self else { return state }
                return strongSelf.reduce(state: state, mutation: mutation)
            }
            .catchError { _ in .empty() }
            .bind(to: resultRealay)
            .disposed(by: disposeBag)
        
        return resultRealay
    }
}

public extension ReactorType {
    func asInOut() -> InOut<Action, State> {
        return InOut(action: action, state: stateObservable)
    }
}

public extension ReactorType where Action == Mutation {
    func mutate(action: Action) -> Observable<Mutation> {
        return .just(action)
    }
}
