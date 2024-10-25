//
//  KeychainManager.swift
//  MultiBlogAPI
//
//  Created by TaeVon Lewis on 10/23/24.
//

import Foundation
import Security

class KeychainManager {
  static func save(key: String, data: String) -> Bool {
    guard let dataFromString = data.data(using: .utf8) else {
      print("Error converting string to data for key \(key).")
      return false
    }

    let query =
      [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: key,
      ] as CFDictionary
    SecItemDelete(query)

    let addQuery =
      [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: key,
        kSecValueData: dataFromString,
      ] as CFDictionary

    let status = SecItemAdd(addQuery, nil)
    if status != errSecSuccess {
      print("Error: Could not save \(key) to Keychain. Status code: \(status)")
    }
    return status == errSecSuccess
  }

  static func retrieve(key: String) -> String? {
    let query =
      [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: key,
        kSecReturnData: kCFBooleanTrue!,
        kSecMatchLimit: kSecMatchLimitOne,
      ] as CFDictionary

    var result: AnyObject?
    let status = SecItemCopyMatching(query, &result)

    if status == errSecSuccess {
      if let retrievedData = result as? Data {
        return String(data: retrievedData, encoding: .utf8)
      }
    }
    return nil
  }

  static func delete(key: String) {
    let query =
      [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: key,
      ] as CFDictionary

    SecItemDelete(query)
  }
}
