public protocol File {
    var path: String { get }
    func getVersions() throws -> [String]
}
