//
//  main.swift
//  Singleton Pattern Implementation
//
//  Created by almat saparov on 06.04.2024.
//

import Foundation

class DatabaseConnection {
    private static var instance: DatabaseConnection?
    private static let lock = NSLock()

    var hostname: String?
    var username: String?
    var password: String?
    var databaseName: String?

    private init() {
        loadConfig()
    }

    static func getInstance() -> DatabaseConnection {
        lock.lock()
        defer {
            lock.unlock()
        }

        if instance == nil {
            instance = DatabaseConnection()
        }
        return instance!
    }

    func executeQuery(_ query: String) {
        print("Executing query: \(query)")
    }

    func getConnectionInfo() -> [String: String] {
        return [
            "hostname": hostname ?? "",
            "username": username ?? "",
            "password": password ?? "",
            "databaseName": databaseName ?? ""
        ]
    }

    private func loadConfig() {
        guard let configFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("config.json") else {
            print("Failed to get configuration file URL.")
            return
        }

        if !FileManager.default.fileExists(atPath: configFileURL.path) {
            
            let defaultConfig = DatabaseConfig(hostname: "default_host", username: "default_user", password: "default_password", databaseName: "default_database")

            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(defaultConfig)
                try data.write(to: configFileURL)
                print("Default configuration file created.")
            } catch {
                print("Error creating default configuration: \(error)")
                return
            }
        }

        do {
            let data = try Data(contentsOf: configFileURL)
            let decoder = JSONDecoder()
            let config = try decoder.decode(DatabaseConfig.self, from: data)

            hostname = config.hostname
            username = config.username
            password = config.password
            databaseName = config.databaseName
        } catch {
            print("Error loading configuration: \(error)")
        }
    }
}

struct DatabaseConfig: Codable {
    let hostname: String
    let username: String
    let password: String
    let databaseName: String
}

let dbConnection1 = DatabaseConnection.getInstance()
let dbConnection2 = DatabaseConnection.getInstance()

print("Are both instances the same object?", dbConnection1 === dbConnection2)

let connectionInfo = dbConnection1.getConnectionInfo()
print("Connection Information:")
print(connectionInfo)
