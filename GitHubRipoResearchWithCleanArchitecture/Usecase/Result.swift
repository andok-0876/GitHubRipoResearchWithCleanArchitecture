//
//  Result.swift
//  GitHubRipoResearchWithCleanArchitecture
//
//  Created by 安藤 on 2019/04/05.
//  Copyright © 2019 kazando. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}
