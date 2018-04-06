
import RxSwift

public enum ReactorStateTransition<State, Mutation> {
    case initial(state: State)
    case update(state: State, mutation: Mutation)
    
    var state: State {
        switch self {
        case let .initial(state):
            return state
        case let .update(state, _):
            return state
        }
    }
}

public protocol Reactor: class, AssociatedObjectStore {
    associatedtype Action
    
    associatedtype Mutation = Action
    
    associatedtype State
    
    typealias StateTransition = ReactorStateTransition<State, Mutation>
    
    var initialState: State { get }
    
    var workingScheduler: SerialDispatchQueueScheduler { get }
    
    func transform(action: Observable<Action>) -> Observable<Action>
    
    func mutate(action: Action) -> Observable<Mutation>
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation>
    
    func reduce(state: State, mutation: Mutation) -> State
    
    func transform(stateTransition: Observable<StateTransition>) -> Observable<StateTransition>
}
