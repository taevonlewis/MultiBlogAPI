//
//  MarkdownManager.swift
//  MultiBlogAPI
//
//  Created by TaeVon Lewis on 10/23/24.
//

import Foundation

class MarkdownManager {
  func readMarkdownFile(atPath path: String) -> String? {
    do {
      let content = try String(contentsOfFile: path, encoding: .utf8)
      return content
    } catch {
      print("Failed to read file at \(path): \(error.localizedDescription)")
      return nil
    }
  }
}
