
public enum LoadingState {
    case initial
    case inProcess
    case completed
    case failed(error: Error)
}
