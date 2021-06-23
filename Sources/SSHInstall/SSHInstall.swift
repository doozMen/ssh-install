import ProcessPretty
import Foundation
import TSCBasic
import ArgumentParser
import UnifiedLogging

extension AbsolutePath: ExpressibleByArgument {
    public init?(argument: String) {
        do {
            self = try AbsolutePath(validating: argument)
        } catch {
            do {
                guard let currentWorkingDirectory =  localFileSystem.currentWorkingDirectory else {
                    throw Error.missingCurrentWorkingDirectory
                }
                let path = AbsolutePath(argument, relativeTo: currentWorkingDirectory)
                
                guard localFileSystem.exists(path) else {
                    throw Error.noFileInCurrentWorkingDirectoryNamed(argument)
                }
                
                self = path
            } catch {
                logger.error("absolute path init failed", metadata: ["path": .string(argument), "error": .string("\(error)")])
                return nil
            }
        }
    }
}

public enum Error: Swift.Error {
    case missingCurrentWorkingDirectory
    case noFileInCurrentWorkingDirectoryNamed(String)
}

public struct SSHInstallCommand: ParsableCommand {
    @Argument
    var privateKey: AbsolutePath
    
    @Argument
    var publicKey: AbsolutePath
    
    @Argument
    var config: AbsolutePath
    
    @Option(help: "by default files are added with their name to `~/.ssh`, but if you set this to true then the .ssh folder is deleted and then added again.")
    var cleanSSHFolder: Bool = false
    
    public init() {}
    
    public func run() throws {
        try runWith(cleanSSHFolder: cleanSSHFolder, privateKey: privateKey, publicKey: publicKey, config: config)
    }
}

private func log(text: String, color: TerminalController.Color, bold: Bool) {
    logger.info("SSHInstallCommand", metadata: ["output": .string(text)])
}

private func runWith(cleanSSHFolder: Bool, privateKey: AbsolutePath, publicKey: AbsolutePath, config: AbsolutePath) throws {
    
    let sshPath = AbsolutePath(".ssh", relativeTo: localFileSystem.homeDirectory)
    if localFileSystem.exists(sshPath), cleanSSHFolder {
        try localFileSystem.removeFileTree(sshPath)
        try localFileSystem.createDirectory(sshPath)
    }
    
    try localFileSystem.move(from: privateKey, to: sshPath.appending(.init(privateKey.basename)))
    try localFileSystem.move(from: publicKey, to: sshPath.appending(.init(publicKey.basename)))
    try localFileSystem.move(from: config, to: sshPath.appending(.init(config.basename)))
    
    let keyscan = try ProcessPretty(
        executable: "ssh-keyscan",
        arguments: ["-H", "github.com,140.82.121.4"],
        output: log
    )
    
    let output = try keyscan.run(in: #function, at: #filePath)
    
    let known_hosts = try output.utf8Output()
    
    let known_hostsPath = AbsolutePath("known_hosts", relativeTo: sshPath)
    
    try localFileSystem.writeFileContents(known_hostsPath, bytes: .init(encodingAsUTF8: known_hosts))
    
    /*
     Chmod 600 (chmod a+rwx,u-x,g-rwx,o-rwx) sets permissions so that, (U)ser / owner can read, can write and can't execute. (G)roup can't read, can't write and can't execute. (O)thers can't read, can't write and can't execute.
     */
    let chmodUserReadWriteOnly = try ProcessPretty(
        executable: "chmod",
        arguments: ["600", "\(localFileSystem.homeDirectory.pathString)/.ssh/\(privateKey.basename)"],
        output: log
    )
    try chmodUserReadWriteOnly.run(in: #function, at: #filePath)
}
