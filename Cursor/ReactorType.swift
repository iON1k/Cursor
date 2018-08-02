import RxSwift

public protocol ReactorType: class, AssociatedObjectStore, InOutConvertibleType {
    associatedtype Mutation = Action
    
    var initialState: State { get }
    
    var workingScheduler: SerialDispatchQueueScheduler { get }
    
    func transform(action: Observable<Action>) -> Observable<Action>
    
    func mutate(action: Action) -> Observable<Mutation>
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation>
    
    func reduce(state: State, mutation: Mutation) -> State
}
