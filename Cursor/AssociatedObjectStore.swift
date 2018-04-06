
import ObjectiveC

public protocol AssociatedObjectStore { }

extension AssociatedObjectStore {
    func associatedObject<T>(forKey key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(self, key) as? T
    }

    func associatedObject<T>(forKey key: UnsafeRawPointer,
                             default: @autoclosure () -> T,
                             policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> T {
        guard let object: T = self.associatedObject(forKey: key) else {
            let object = `default`()
            setAssociatedObject(object, forKey: key, policy: policy)
            return object
        }

        return object
    }

    func setAssociatedObject<T>(_ object: T?,
                                forKey key: UnsafeRawPointer,
                                policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        objc_setAssociatedObject(self, key, object, policy)
    }
}
