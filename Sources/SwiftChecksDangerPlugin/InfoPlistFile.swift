import Foundation

public struct InfoPlistFile: File {

    public struct PlistKey: RawRepresentable, ExpressibleByStringLiteral {
        public static var versionNumber: PlistKey = "CFBundleShortVersionString"
        public static var buildNumber: PlistKey = "CFBundleVersion"

        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: String) {
            self.rawValue = value
        }
    }

    public enum GetVersionsError: Error {
        case noVersionFound
        /// Multiple values for the provided key were found
        case multipleVersionsFound(foundVersions: [String])
        /// A build variable was found but no project file was provided
        /// to allow the variable to be resolved
        case projectFileNotProvided
    }

    public let path: String
    public let plistKey: PlistKey

    /// The path to an `.xcodeproj` file. If this is
    /// set and the value in the info plist file is a build variable
    /// the contents of the project file will be searched
    public let projectFilePath: String?

    private let fileManager: FileManager

    public init(path: String, plistKey: PlistKey, projectFilePath: String? = nil) {
        self.init(path: path, plistKey: plistKey, projectFilePath: projectFilePath, fileManager: .default)
    }

    public init(path: String, plistKey: PlistKey, projectFilePath: String? = nil, fileManager: FileManager) {
        self.path = path
        self.plistKey = plistKey
        self.projectFilePath = projectFilePath
        self.fileManager = fileManager
    }

    public func getVersions() throws -> [String] {
        let plistFile = VersionFile(
            path: path,
            interpreter: .regex(
                "<key>\(plistKey.rawValue)</key>\\s*<string>(.*)</string>"
            ),
            fileManager: fileManager
        )
        let plistVersions = plistFile.getVersions()
        guard let plistVersion = plistVersions.first else {
            throw GetVersionsError.noVersionFound
        }
        guard plistVersions.count == 1 else {
            throw GetVersionsError.multipleVersionsFound(foundVersions: plistVersions)
        }

        if plistVersion.hasPrefix("$("), plistVersion.hasSuffix(")") {
            // This is a build variable
            guard let projectFilePath = projectFilePath else {
                throw GetVersionsError.projectFileNotProvided
            }
            let buildVarible: String = {
                let startIndex = plistVersion.index(plistVersion.indices.startIndex, offsetBy: 2)
                let buildVarible = plistVersion[startIndex...].dropLast()
                return String(buildVarible)
            }()
            let projectFile = VersionFile(
                path: projectFilePath + "/project.pbxproj",
                interpreter: .regex(
                    "\(buildVarible) = (.*);"
                ),
                fileManager: .default
            )
            return projectFile.getVersions()
        } else {
            return [plistVersion]
        }
    }

}
