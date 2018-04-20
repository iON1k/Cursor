
import RxSwift
import RxCocoa

fileprivate enum LoadingBindableAssociatedKeys {
    static var disposeBag = "disposeBag"
}

public protocol LoadingBindable: AssociatedObjectStore {
    func bind(loader: InOut<LoadingAction, LoadingState>, disposeBag: DisposeBag)
}

public extension LoadingBindable {
    func bind<Loader: InOutConvertibleType>(loader: Loader) where Loader.Action == LoadingAction, Loader.State == LoadingState {
        let disposeBag: DisposeBag = associatedObject(forKey: &LoadingBindableAssociatedKeys.disposeBag, default: .init())
        return bind(loader: loader.asInOut(), disposeBag: disposeBag)
    }
}

public extension LoadingBindable where Self: LoadingControllerType, Self: UIViewController {
    func bind(loader: InOut<LoadingAction, LoadingState>, disposeBag: DisposeBag) {
        let firtLoading = rx.viewWillAppear
            .take(1)
            .map { _ in LoadingAction.load }
            
        let repeatLoading = loadingStateView.repeatLoading.map { _ in LoadingAction.load }
            
        Observable.merge(firtLoading, repeatLoading)
            .bind(to: loader.action)
            .disposed(by: disposeBag)
        
        loader.state
            .subscribe(onNext: { [weak self] state in
                self?.loadingStateView.update(state: state)
            })
            .disposed(by: disposeBag)
    }
}
