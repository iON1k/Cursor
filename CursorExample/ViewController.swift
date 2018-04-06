
import Cursor
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    @IBOutlet private var countButton: UIButton!
    @IBOutlet private var countLabel: UILabel!
    
    private let reactor = ViewReactor()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindActions()
        bindState()
    }
    
    func bindActions() {
        countButton.rx
            .controlEvent(.touchUpInside)
            .map { ViewReactor.Action.request }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState() {
        reactor.state
            .map { String($0.count) }
            .distinctUntilChanged()
            .bind(to: countLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

