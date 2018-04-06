
import RxSwift

fileprivate enum ReactorAssociatedKeys {
    static var action = "action"
    static var state = "state"
    static var disposeBag = "disposeBag"
}

public extension Reactor {
    public var action: PublishSubject<Action> {
        return associatedObject(forKey: &ReactorAssociatedKeys.action, default: .init())
    }
    
    var stateTransition: Observable<StateTransition> {
        return associatedObject(forKey: &ReactorAssociatedKeys.state, default: createStateTransitionObservable())
    }
    
    var state: Observable<State> {
        return stateTransition.map { return $0.state }
    }
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        return action
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return mutation
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
    
    func transform(stateTransition: Observable<StateTransition>) -> Observable<StateTransition> {
        return stateTransition
    }
    
    private var disposeBag: DisposeBag {
        return associatedObject(forKey: &ReactorAssociatedKeys.disposeBag, default: .init())
    }

    private func createStateTransitionObservable() -> Observable<StateTransition> {
        let transformedAction = self.transform(action: action.asObservable())
        
        let mutation = transformedAction
            .flatMap { [weak self] action -> Observable<Mutation> in
                guard let strongSelf = self else { return .empty() }
                return strongSelf
                    .mutate(action: action)
                    .catchError { _ in .empty() }
            }
        let transformedMutation = transform(mutation: mutation)
        
        let initialStateTransition = StateTransition.initial(state: createInitialState())
        let stateTransition = transformedMutation
            .scan(initialStateTransition) { [weak self] stateTransition, mutation -> StateTransition in
                guard let strongSelf = self else { return stateTransition }
                let newState = strongSelf
                    .reduce(state: stateTransition.state, mutation: mutation)
                
                return .update(state: newState, mutation: mutation)
            }
            .catchError { _ in .empty() }
            .startWith(initialStateTransition)
        
        let transformedStateTransition = transform(stateTransition: stateTransition)
            .replay(1)
        
        transformedStateTransition
            .connect()
            .disposed(by: disposeBag)
        
        return transformedStateTransition
    }
}

public extension Reactor where Action == Mutation {
    func mutate(action: Action) -> Observable<Mutation> {
        return .just(action)
    }
}
