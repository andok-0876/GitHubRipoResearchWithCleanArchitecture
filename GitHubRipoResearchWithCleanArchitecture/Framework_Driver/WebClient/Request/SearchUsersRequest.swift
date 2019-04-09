public struct SearchUsersRequest: Request {
    public typealias Response = ItemsResponse<User>

    public let method: HttpMethod = .get
    public let path = "/search/users"

    public var queryParameters: [String : String]? {
        var params: [String: String] = ["q": query]
        if let page = page {
            params["page"] = "\(page)"
        }
        if let perPage = perPage {
            params["per_page"] = "\(perPage)"
        }
        if let sort = sort {
            params["sort"] = sort.rawValue
        }
        if let order = order {
            params["order"] = order.rawValue
        }
        return params
    }

    public let query: String
    public let sort: Sort?
    public let order: Order?
    public let page: Int?
    public let perPage: Int?

    public init(query: String, sort: Sort?, order: Order?, page: Int?, perPage: Int?) {
        self.query = query
        self.sort = sort
        self.order = order
        self.page = page
        self.perPage = perPage
    }
}

extension SearchUsersRequest {
    public enum Sort: String {
        case followers
        case repositories
        case joined
    }

    public enum Order: String {
        case asc
        case desc
    }
}
