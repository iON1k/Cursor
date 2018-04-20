
import RxSwift

public final class LoadingReactor: ReactorType {
    public typealias Action = LoadingAction
    public typealias State = LoadingState
    
    public enum Mutation {
        case update(state: State)
    }
    
    private let loadingObservable: Completable
    
    init(loadingObservable: Completable) {
        self.loadingObservable = loadingObservable
    }
    
    public var initialState: State {
        return .initial
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        return state
            .take(1)
            .flatMap { [weak self] state -> Observable<Mutation> in
                guard let strongSelf = self else {
                    return Observable.empty()
                }
                
                switch state {
                case .initial, .failed:
                    return strongSelf
                        .loadingObservable
                        .andThen(Observable.just(.update(state: .completed)))
                        .startWith(.update(state: .inProcess))
                        .catchError { error in
                            return Observable.just(.update(state: .failed(error: error)))
                        }
                case .inProcess, .completed:
                    return Observable.empty()
                }
            }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .update(newState):
            return newState
        }
    }
}
