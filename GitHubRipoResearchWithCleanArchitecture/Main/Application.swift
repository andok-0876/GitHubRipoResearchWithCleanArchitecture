import UIKit

class Application {
    
    /// Shared instance
    static let shared = Application()
    private init() {}
    
    // restore Use case as public property
    private(set) var useCase: ReposLikesUseCase!
    
    func configure(with window: UIWindow) {
        buildLayer()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
    }
    
    private func buildLayer() {
        
        // -- Use Case
        useCase = ReposLikesUseCase()
        
        // -- Interface Adapters
        let reposGateway = ReposGateway(useCase: useCase)
        let likesGateway = LikesGateway(useCase: useCase)
        
        // bind with Use Case
        useCase.reposGateway = reposGateway
        useCase.likesGateway = likesGateway
        
        // -- Framework & Drivers
        let webClient = GitHubRepos()
        let likesDataStore = UserDefaultsDataStore(userDefaults: UserDefaults.standard)
        
        // binding with Interface Adapters
        reposGateway.webClient = webClient
        reposGateway.dataStore = likesDataStore
        likesGateway.dataStore = likesDataStore
        
        // create Presenter and binding in each ViewController
        // but in this this project, awakeFromNib() of TabBarController creates and bind it
    }
}

protocol ReposPresenterInjectable {
    func inject(reposPresenter: ReposPresenterProtocol)
}
