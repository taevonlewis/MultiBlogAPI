//
//  main.swift
//  MultiBlogAPI
//
//  Created by TaeVon Lewis on 10/23/24.
//

import Foundation

let postManager = PostManager()

func checkForSavedItemsAndManage() {
  let keys = ["MediumToken", "DevToken", "HashnodeToken", "MarkdownFilePath", "Host"]
  var savedItems: [String: String] = [:]

  for key in keys {
    if let value = KeychainManager.retrieve(key: key) {
      savedItems[key] = value
    }
  }

  if !savedItems.isEmpty {
    print("Saved tokens and settings found in Keychain:")
    for (index, key) in savedItems.keys.enumerated() {
      print("\(index + 1). \(key)")
    }

    print("Do you want to delete any of them before proceeding? (yes/no)")
    if let input = readLine(), input.lowercased() == "yes" {
      print("Enter the numbers of the items you want to delete, separated by commas (e.g., 1,3):")
      if let itemsToDelete = readLine() {
        let indices = itemsToDelete.split(separator: ",").compactMap {
          Int($0.trimmingCharacters(in: .whitespaces))
        }
        for index in indices {
          if index > 0 && index <= savedItems.keys.count {
            let key = Array(savedItems.keys)[index - 1]
            KeychainManager.delete(key: key)
            print("Deleted \(key) from Keychain.")
          } else {
            print("Invalid selection: \(index)")
          }
        }
      }
    }
  }
}

checkForSavedItemsAndManage()

var articleTitle: String?
var markdownFilePath: String?
var host: String?

if CommandLine.argc > 1 {
  let args = CommandLine.arguments.dropFirst()
  var iterator = args.makeIterator()
  while let arg = iterator.next() {
    switch arg {
    case "--title":
      articleTitle = iterator.next()
    case "--file":
      markdownFilePath = iterator.next()
    case "--host":
      host = iterator.next()
    case "--help":
      print(
        """
        Usage:
        \(CommandLine.arguments[0]) --title "Your Article Title" --file /path/to/article.md --host yourblog.hashnode.dev

        Options:
        --title    The title of the article.
        --file     The path to the markdown file containing the article content.
        --host     Your Hashnode blog domain (e.g., yourblog.hashnode.dev).
        --help     Show this help message.

        If you omit any arguments, the script will prompt you to enter them.
        """)
      exit(0)
    default:
      print("Unknown argument: \(arg)")
      print("Use --help to see available options.")
      exit(1)
    }
  }
}

func getValueFromKeychainOrPrompt(key: String, promptMessage: String) -> String? {
  if let value = KeychainManager.retrieve(key: key) {
    print("Using saved \(key): \(value)")
    return value
  } else {
    print(promptMessage)
    if let input = readLine(), !input.isEmpty {
      print("Do you want to save this value in the Keychain for future use? (yes/no)")
      if let saveInput = readLine(), saveInput.lowercased() == "yes" {
        let saveSuccessful = KeychainManager.save(key: key, data: input)
        if saveSuccessful {
          print("Value saved in Keychain.")
        } else {
          print("Failed to save value in Keychain.")
        }
      }
      return input
    } else {
      return nil
    }
  }
}

if articleTitle == nil {
  print("Enter the article title:")
  articleTitle = readLine()
}

if markdownFilePath == nil {
  markdownFilePath = getValueFromKeychainOrPrompt(
    key: "MarkdownFilePath", promptMessage: "Enter the markdown file path:")
}

if host == nil {
  host = getValueFromKeychainOrPrompt(
    key: "Host", promptMessage: "Enter the host (Hashnode blog domain):")
}

guard let title = articleTitle, !title.isEmpty else {
  print("Error: Article title is required.")
  print("Press Enter to exit...")
  _ = readLine()
  exit(1)
}

guard let filePath = markdownFilePath, !filePath.isEmpty else {
  print("Error: Markdown file path is required.")
  print("Press Enter to exit...")
  _ = readLine()
  exit(1)
}

let fileManager = FileManager.default
if !fileManager.fileExists(atPath: filePath) {
  print("Error: Markdown file not found at path \(filePath)")
  print("Press Enter to exit...")
  _ = readLine()
  exit(1)
}

guard let blogHost = host, !blogHost.isEmpty else {
  print("Error: Host is required.")
  print("Press Enter to exit...")
  _ = readLine()
  exit(1)
}

postManager.postArticleToAllPlatforms(
  articleTitle: title, markdownFilePath: filePath, host: blogHost)

print("Press Enter to exit...")
_ = readLine()
