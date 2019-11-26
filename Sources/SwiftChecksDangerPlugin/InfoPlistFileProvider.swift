import Foundation

public struct InfoPlistFileProvider: FileProvider {

    public enum DiscoveryMethod {
        case fileURLs([URL])
        case searchDirectory(_ rootPath: String, fileNames: [String])
    }

    public let discoveryMethod: DiscoveryMethod
    public let plistKey: InfoPlistFile.PlistKey
    public let projectFilePath: String
    private let fileManager: FileManager

    public init(discoveryMethod: DiscoveryMethod, plistKey: InfoPlistFile.PlistKey, projectFilePath: String) {
        self.init(
            discoveryMethod: discoveryMethod,
            plistKey: plistKey,
            projectFilePath: projectFilePath,
            fileManager: .default
        )
    }

    public init(
        discoveryMethod: DiscoveryMethod,
        plistKey: InfoPlistFile.PlistKey,
        projectFilePath: String,
        fileManager: FileManager
    ) {
        self.discoveryMethod = discoveryMethod
        self.plistKey = plistKey
        self.projectFilePath = projectFilePath
        self.fileManager = fileManager
    }

    public func getFiles() -> [File] {
        return fileURLs()
            .map {
                InfoPlistFile(
                    path: $0.path,
                    plistKey: plistKey,
                    projectFilePath: projectFilePath,
                    fileManager: fileManager
                )
        }
    }

    private func fileURLs() -> [URL] {
        switch discoveryMethod {
        case .fileURLs(let urls):
            return urls
        case .searchDirectory(let rootPath, let fileNames):
            let rootURL = URL(fileURLWithPath: rootPath)

            guard
                let enumerator = fileManager.enumerator(
                    at: rootURL,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )
                else { return [] }

            var versions: [URL] = []
            for case let fileURL as URL in enumerator {
                guard let fileName = fileURL.pathComponents.last else { continue }
                guard fileNames.contains(fileName) else { continue}
                versions.append(fileURL)
            }
            return versions
        }
    }

}
