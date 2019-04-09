import Foundation

public struct RepositoryRequest: Request {
    public typealias Response = Repository

    public let method: HttpMethod = .get
    public var path: String {
        return "/users/\(username)/\(repositoryName)"
    }

    public let username: String
    public let repositoryName: String

    public init(username: String, repositoryName: String) {
        self.username = username
        self.repositoryName = repositoryName
    }
}
