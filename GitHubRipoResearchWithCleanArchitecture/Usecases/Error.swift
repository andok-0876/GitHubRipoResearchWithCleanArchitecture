import Foundation

enum FetchingError: Error {
    case failedToFetchRepos(Error)
    case failedToFetchLikes(Error)
    case otherError
}

enum SavingError: Error {
    case failedToSaveLike
}
