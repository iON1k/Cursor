
import RxSwift

public protocol LoadingStateViewType {
    var repeatLoading: Observable<Void> { get }

    func update(state: LoadingState)
}
