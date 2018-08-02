
import Cursor
import RxSwift

class ViewReactor: ReactorType {
    enum Action {
        case request
    }
    
    struct State {
        let count: Int
    }
    
    var initialState: State {
        return State(count: 1)
    }
    
    func reduce(state: State, mutation: Action) -> State {
        return State(count: state.count + 1)
    }
}
