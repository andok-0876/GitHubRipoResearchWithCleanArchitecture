import Foundation

protocol WebClientProtocol {
    func fetch(using keywords: [String], completion: @escaping (Result<[GitHubRepo]>) -> Void)
}

class ReposGateway: ReposGatewayProtocol {
    
    private weak var useCase: ReposLikesUseCaseProtocol!
    var webClient: WebClientProtocol!
    var dataStore: DataStoreProtocol!
    
    init(useCase: ReposLikesUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func fetch(using keywords: [String], completion: @escaping (Result<[GitHubRepo]>) -> Void) {
        // Restore the data as cache and send the functions to the outLayer of Gateway
        webClient.fetch(using: keywords) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let repos):
                self.dataStore.save(repos: repos, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetch(using ids: [GitHubRepo.ID], completion: @escaping (Result<[GitHubRepo]>) -> Void) {
        //Send the functions to the outLayer of Gateway
        dataStore.fetch(using: ids, completion: completion)
    }
}
