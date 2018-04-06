
import Cursor
import RxSwift

class ViewReactor: Reactor {
    enum Action {
        case request
    }
    
    struct State {
        let count: Int
    }
    
    func createInitialState() -> ViewReactor.State {
        return State(count: 1)
    }
    
    func reduce(state: ViewReactor.State, mutation: ViewReactor.Action) -> ViewReactor.State {
        return State(count: state.count + 1)
    }
}
