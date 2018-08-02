
public enum LoadingState<Data> {
    case initial
    case inProcess
    case completed(data: Data)
    case failed(error: Error)
}
