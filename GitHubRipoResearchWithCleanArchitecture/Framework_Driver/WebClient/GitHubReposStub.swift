import Foundation

class GitHubReposStub: WebClientProtocol {
    
    func fetch(using keywords: [String], completion: @escaping (Result<[GitHubRepo]>) -> Void) {
        // create dummy and return it
        let repos = (0..<5).map{
            GitHubRepo(id: GitHubRepo.ID(rawValue: "repos/\($0)"),
                       fullName: "repos/\($0)",
                description: "my awesome project",
                language: "swift",
                stargazersCount: $0)
        }
        completion(.success(repos))
    }
}
