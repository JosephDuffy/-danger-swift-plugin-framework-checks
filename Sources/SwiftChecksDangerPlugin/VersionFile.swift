import Foundation
import Danger

public struct VersionFile: File {

    public enum Interpreter {
        case regex(String)
        case closure((String) -> String?)
    }

    public let path: String
    public let interpreter: Interpreter
    private let fileManager: FileManager

    public init(path: String, interpreter: Interpreter) {
        self.init(path: path, interpreter: interpreter, fileManager: .default)
    }

    internal init(path: String, interpreter: Interpreter, fileManager: FileManager) {
        self.path = path
        self.interpreter = interpreter
        self.fileManager = fileManager
    }

    public func getVersions() -> [String] {
        guard let data = fileManager.contents(atPath: path) else {
            warn("Unable to find file at " + path)
            return []
        }
        guard let content = String(data: data, encoding: .utf8) else {
            warn("Could not decode data at " + path + " as UTF8")
            return []
        }

        switch interpreter {
        case .regex(let regex):
            do {
                let regex = try NSRegularExpression(pattern: regex, options: [])
                let matches = regex.matches(
                    in: content,
                    options: [],
                    range: NSRange(location: 0, length: content.count)
                )
                return matches.compactMap { match in
                    guard match.numberOfRanges > 1 else {
                        warn("Failed to find capture group for match \(match)")
                        return nil
                    }
                    let range = match.range(at: 1)
                    let startIndex = content.index(content.startIndex, offsetBy: range.location)
                    let indexPastEnd = content.index(content.startIndex, offsetBy: range.location + range.length)
                    return String(content[startIndex..<indexPastEnd])
                }
            } catch {
                warn("Error creating version check regex from \(regex): \(error.localizedDescription)")
                return []
            }
        case .closure(let closure):
            guard let version = closure(content) else { return [] }
            return [version]
        }
    }
}
