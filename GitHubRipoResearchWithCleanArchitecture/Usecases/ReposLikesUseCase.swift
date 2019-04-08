import Foundation

// Input from Interface Adapters
protocol ReposLikesUseCaseProtocol: AnyObject {
    // search with keywords
    func startFetch(using keywords: [String])
    // collect the list of likes Repo
    func collectLikedRepos()
    //  add or delete the likes
    func set(liked: Bool, for repo: GitHubRepo.ID)

    //set outlayer object as property 
    var output: ReposLikesUseCaseOutput! { get set }
    var reposGateway: ReposGatewayProtocol! { get set }
    var likesGateway: LikesGatewayProtocol! { get set }
}

protocol ReposLikesUseCaseOutput {
    // this func is called when likes switch changes in Github Repo
    func useCaseDidUpdateStatuses(_ repoStatuses: [GitHubRepoStatus])
    // this func is called when the list of likes status is updated
    func useCaseDidUpdateLikesList(_ likesList: [GitHubRepoStatus])
    // this func is called when erorr occurs in Use Case
    func useCaseDidReceiveError(_ error: Error)
}

protocol ReposGatewayProtocol {
    // Return the result of search by keyword in completion handler
    func fetch(using keywords: [String],
               completion: @escaping (Result<[GitHubRepo]>) -> Void)

    // Return the result of search by ID  in completion handler
    func fetch(using ids: [GitHubRepo.ID],
               completion: @escaping (Result<[GitHubRepo]>) -> Void)
}

protocol LikesGatewayProtocol {
    // Return the likes of search by keyword in completion handler
    func fetch(ids: [GitHubRepo.ID],
               completion: @escaping (Result<[GitHubRepo.ID: Bool]>) -> Void)
    // Restore liked status with IDfa
    func save(liked: Bool,
              for id: GitHubRepo.ID,
              completion: @escaping (Result<Bool>) -> Void)
    // Return the list of all Likes in completion handler
    func allLikes(completion: @escaping (Result<[GitHubRepo.ID: Bool]>) -> Void)
}

// Use Case implementation
final class ReposLikesUseCase: ReposLikesUseCaseProtocol {

    var output: ReposLikesUseCaseOutput!

    var reposGateway: ReposGatewayProtocol!
    var likesGateway: LikesGatewayProtocol!

    private var statusList = GitHubRepoStatusList(repos: [], likes: [:])
    private var likesList = GitHubRepoStatusList(repos: [], likes: [:])

    // Search with keyword in Repo and Return the result and likes status
    func startFetch(using keywords: [String]) {

        reposGateway.fetch(using: keywords) { [weak self] reposResult in
            guard let self = self else { return }

            switch reposResult {
            case .failure(let e):
                self.output
                    .useCaseDidReceiveError(FetchingError.failedToFetchRepos(e))
            case .success(let repos):
                let ids = repos.map { $0.id }
                self.likesGateway
                    .fetch(ids: ids) { [weak self] likesResult in
                        guard let self = self else { return }
                        
                        switch likesResult {
                        case .failure(let e):
                            self.output
                                .useCaseDidReceiveError(
                                    FetchingError.failedToFetchLikes(e))
                        case .success(let likes):
                            // restore the result
                            let statusList = GitHubRepoStatusList(
                                repos: repos, likes: likes
                            )
                            self.statusList = statusList
                            self.output.useCaseDidUpdateStatuses(statusList.statuses)
                        }
                }
            }
        }
    }
    // Collect the Liked list in Git Repo
    func collectLikedRepos() {
        likesGateway.allLikes { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let e):
                self.output
                    .useCaseDidReceiveError(
                        FetchingError.failedToFetchLikes(e))
            case .success(let allLikes):
                let ids = Array(allLikes.keys)
                self.reposGateway.fetch(using: ids) { [weak self] reposResult in
                    guard let self = self else { return }

                    switch reposResult {
                    case .failure(let e):
                        self.output
                            .useCaseDidReceiveError(
                                FetchingError.failedToFetchLikes(e))
                    case .success(let repos):
                        // restore the result
                        let likesList = GitHubRepoStatusList(
                            repos: repos,
                            likes: allLikes,
                            trimmed: true
                        )
                        self.likesList = likesList
                        self.output.useCaseDidUpdateLikesList(likesList.statuses)
                    }
                }
            }

        }
    }

    func set(liked: Bool, for id: GitHubRepo.ID) {
        // お気に入りの状態を保存し、更新の結果を伝える
        likesGateway.save(liked: liked, for: id)
        { [weak self] likesResult in
            guard let self = self else { return }

            switch likesResult {
            case .failure:
                self.output
                    .useCaseDidReceiveError(SavingError.failedToSaveLike)
            case .success(let isLiked):
                do {
                    try self.statusList.set(isLiked: isLiked, for: id)
                    try self.likesList.set(isLiked: isLiked, for: id)
                    self.output
                        .useCaseDidUpdateStatuses(self.statusList.statuses)
                    self.output
                        .useCaseDidUpdateLikesList(self.likesList.statuses)
                } catch {
                    self.output
                        .useCaseDidReceiveError(SavingError.failedToSaveLike)
                }
            }
        }
    }
}
