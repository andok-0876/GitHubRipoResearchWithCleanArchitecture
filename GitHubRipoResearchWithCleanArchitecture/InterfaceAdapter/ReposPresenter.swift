import Foundation

// the data for View
struct GitHubRepoViewData {
    let id: String
    let fullName: String
    let description: String
    let language: String
    let stargazersCount: Int
    let isLiked: Bool
}

// the interface that present in the outlayer such as View
protocol ReposPresenterProtocol: AnyObject {
    // search with keyword
    func startFetch(using keywords: [String])
    // collect the list of Liked in Git Repo
    func collectLikedRepos()
    
    // set or reset liked
    func set(liked: Bool, for id: String)
    
    var reposOutput: ReposPresenterOutput? { get set }
    var likesOutput: LikesPresenterOutput? { get set }
}

// output interface for the view of search in GitHub repo
protocol ReposPresenterOutput {
    // send notification from Presenter to outLayer while data for view is updated
    func update(by viewDataArray: [GitHubRepoViewData])
}

// output interface for the view of the list of Likes in GitHub repo
protocol LikesPresenterOutput {
    // send notification from Presenter to outLayer while data for view is updated
    func update(by viewDataArray: [GitHubRepoViewData])
}

// implementation of Presenter
class ReposPresenter: ReposPresenterProtocol, ReposLikesUseCaseOutput {
    
    private weak var useCase: ReposLikesUseCaseProtocol!
    var reposOutput: ReposPresenterOutput?
    var likesOutput: LikesPresenterOutput?
    
    init(useCase: ReposLikesUseCaseProtocol) {
        self.useCase = useCase
        self.useCase.output = self
    }
    
    func startFetch(using keywords: [String]) {
        // delegate Use Case to search
        useCase.startFetch(using: keywords)
    }
    
    func collectLikedRepos() {
        useCase.collectLikedRepos()
    }
    
    func set(liked: Bool, for id: String) {
        useCase.set(liked: liked, for: GitHubRepo.ID(rawValue: id))
    }
    
    func useCaseDidUpdateStatuses(_ repoStatus: [GitHubRepoStatus]) {
        // format the data from Use Case and return it to outLayer
        let viewDataArray = Array.init(repoStatus: repoStatus)
        
        DispatchQueue.main.async { [weak self] in
            self?.reposOutput?.update(by: viewDataArray)
        }
    }
    
    func useCaseDidUpdateLikesList(_ likesList: [GitHubRepoStatus]) {
        // format the data from Use Case and return it to outLayer
        let viewDataArray = Array.init(repoStatus: likesList)
        
        DispatchQueue.main.async { [weak self] in
            self?.likesOutput?.update(by: viewDataArray)
        }
    }
    
    func useCaseDidReceiveError(_ error: Error) {
        // <#code#>
    }
}

extension Array where Element == GitHubRepoViewData {
    init(repoStatus: [GitHubRepoStatus]) {
        self = repoStatus.map {
            return GitHubRepoViewData(
                id: $0.repo.id.rawValue,
                fullName: $0.repo.fullName,
                description: $0.repo.description,
                language: $0.repo.language,
                stargazersCount: $0.repo.stargazersCount,
                isLiked: $0.isLiked)
        }
    }
}
