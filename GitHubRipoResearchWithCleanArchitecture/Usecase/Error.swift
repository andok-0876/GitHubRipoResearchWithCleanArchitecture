//
//  Error.swift
//  GitHubRipoResearchWithCleanArchitecture
//
//  Created by 安藤 on 2019/04/05.
//  Copyright © 2019 kazando. All rights reserved.
//

import Foundation

enum FetchingError: Error {
    case failedToFetchRepos(Error)
    case failedToFetchLikes(Error)
    case otherError
}

enum SavingError: Error {
    case failedToSaveLike
}
