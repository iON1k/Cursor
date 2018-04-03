
import Cursor
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cursor = PagedCursor { range in
            return Observable.just((range.lowerBound..<range.upperBound).map { $0 })
                .delay(3, scheduler: MainScheduler.instance)
        }
        
        _ = cursor.itemsObservable
            .debug("itemsObservable", trimOutput: true)
            .subscribe()
        
        _ = cursor.loadItems(in: 0..<20)
            .debug("loadItems", trimOutput: true)
            .subscribe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

