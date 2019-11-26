import Danger

public struct SwiftChecks {

    public static func check(fileProviders: [FileProvider] = [], files: [File] = [], versionKind: String) {
        let files = fileProviders.flatMap { $0.getFiles() } + files
        let versions = files.reduce(Set<String>(), { versions, file in
            do {
                var versions = versions

                for fileVersion in try file.getVersions() {
                    if let first = versions.first, !versions.contains(fileVersion) {
                        warn("Found mismatched version. Expected " + first + ", found " + fileVersion + " in " + file.path)
                        versions.insert(fileVersion)
                    } else if versions.isEmpty {
                        versions.insert(fileVersion)
                    }
                }

                return versions
            } catch {
                fail("Failed to versions from file" + error.localizedDescription)
                return []
            }
        })

        let paths = files.map { $0.path }

        if versions.isEmpty {
            warn("Found no \(versionKind) versions in files: \(paths)")
        }
    }

}
