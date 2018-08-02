
import RxSwift

public final class LoadingReactor<Data>: ReactorType {
    public typealias Action = LoadingAction
    public typealias State = LoadingState<Data>
    public typealias Mutation = State
    
    private let loadingEngine: Single<Data>
    
    init(loadingEngine: Single<Data>) {
        self.loadingEngine = loadingEngine
    }
    
    public var initialState: State  {
        return .initial
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch state {
        case .initial, .failed:
            return loadingEngine
                .asObservable()
                .map { State.completed(data: $0) }
                .startWith(.inProcess)
                .catchError { .just(.failed(error: $0)) }
        case .inProcess, .completed:
            return .empty()
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        return mutation
    }
}
