import Foundation

protocol DataStoreProtocol: AnyObject {
    // Search for or restore the Likes status
    func fetch(ids: [GitHubRepo.ID],
               completion: @escaping (Result<[GitHubRepo.ID: Bool]>) -> Void)
    func save(liked: Bool,
              for id: GitHubRepo.ID,
              completion: @escaping (Result<Bool>) -> Void)
    func allLikes(completion: @escaping (Result<[GitHubRepo.ID: Bool]>) -> Void)
    
    // search for or restore the data in Github repo
    func save(repos: [GitHubRepo],
              completion: @escaping (Result<[GitHubRepo]>) -> Void)
    func fetch(using ids: [GitHubRepo.ID],
               completion: @escaping (Result<[GitHubRepo]>) -> Void)
}

class LikesGateway: LikesGatewayProtocol {
    
    private weak var useCase: ReposLikesUseCaseProtocol!
    var dataStore: DataStoreProtocol!
    
    init(useCase: ReposLikesUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func fetch(ids: [GitHubRepo.ID],
               completion: @escaping (Result<[GitHubRepo.ID: Bool]>) -> Void) {
        dataStore.fetch(ids: ids, completion: completion)
    }
    
    func save(liked: Bool,
              for id: GitHubRepo.ID,
              completion: @escaping (Result<Bool>) -> Void) {
        dataStore.save(liked: liked, for: id, completion: completion)
    }
    
    func allLikes(completion: @escaping (Result<[GitHubRepo.ID : Bool]>) -> Void) {
        dataStore.allLikes(completion: completion)
    }
}
