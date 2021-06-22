import ProcessPretty
import Foundation
import TSCBasic
import ArgumentParser

extension AbsolutePath: ExpressibleByArgument {
    public init?(argument: String) {
        do {
            self = try AbsolutePath(validating: argument)
        } catch {
            print("❌ \(argument) is not a valid path.")
            return nil
        }
    }
}
public struct SSHInstallCommand: ParsableCommand {
    @Argument
    var privateKey: AbsolutePath
    
    @Argument
    var publicKey: AbsolutePath
    
    @Argument
    var config: AbsolutePath
    
    public init() {}
    
    public func run() throws {
        print("starting ssh-install ...")
        try runWith(privateKey: privateKey, publicKey: publicKey, config: config)
        print("✅ ssh-install")
    }
}

private func runWith(privateKey: AbsolutePath, publicKey: AbsolutePath, config: AbsolutePath) throws {
    
    let sshPath = AbsolutePath(".ssh", relativeTo: localFileSystem.homeDirectory)
    if localFileSystem.exists(sshPath) {
        try localFileSystem.removeFileTree(sshPath)
        try localFileSystem.createDirectory(sshPath)
    }
    
    try localFileSystem.move(from: privateKey, to: sshPath.appending(.init(privateKey.basename)))
    try localFileSystem.move(from: publicKey, to: sshPath.appending(.init(publicKey.basename)))
    try localFileSystem.move(from: config, to: sshPath.appending(.init(config.basename)))
    
    let keyscan = try ProcessPretty(executable: "ssh-keyscan", arguments: ["-H", "github.com,140.82.121.4"])
    
    let output = try keyscan.run(in: #function, at: #filePath)
    
    let known_hosts = try output.utf8Output()
    
    let known_hostsPath = AbsolutePath("known_hosts", relativeTo: sshPath)
    
    try localFileSystem.writeFileContents(known_hostsPath, bytes: .init(encodingAsUTF8: known_hosts))
    
    /*
     Chmod 600 (chmod a+rwx,u-x,g-rwx,o-rwx) sets permissions so that, (U)ser / owner can read, can write and can't execute. (G)roup can't read, can't write and can't execute. (O)thers can't read, can't write and can't execute.
     */
    let chmodUserReadWriteOnly = try ProcessPretty(executable: "chmod", arguments: ["600", "\(localFileSystem.homeDirectory.pathString)/.ssh/\(privateKey.basename)"])
    try chmodUserReadWriteOnly.run(in: #function, at: #filePath)
}
