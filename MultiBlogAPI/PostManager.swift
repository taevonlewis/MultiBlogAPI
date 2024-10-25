//
//  PostManager.swift
//  MultiBlogAPI
//
//  Created by TaeVon Lewis on 10/24/24.
//

import Foundation

class PostManager {
  let platformPoster = PlatformPoster()
  let markdownManager = MarkdownManager()

  func promptForMissingToken(key: String) -> String? {
    print("Token for \(key) not found. Please enter your \(key) token:")
    let userInput = readLine()

    if let input = userInput, !input.isEmpty {
      let saveSuccessful = KeychainManager.save(key: key, data: input)
      if saveSuccessful {
        return input
      } else {
        print("Error: Failed to save the token for \(key) in Keychain.")
        return nil
      }
    } else {
      print("Error: Invalid token input.")
      return nil
    }
  }

  func getTokenFromKeychain(key: String) -> String? {
    if let token = KeychainManager.retrieve(key: key) {
      return token
    } else {
      return promptForMissingToken(key: key)
    }
  }

  func postArticleToAllPlatforms(articleTitle: String, markdownFilePath: String, host: String) {
    guard let mediumToken = getTokenFromKeychain(key: "MediumToken") else {
      print("Error: Medium token is required.")
      return
    }
    guard let devToken = getTokenFromKeychain(key: "DevToken") else {
      print("Error: Dev.to token is required.")
      return
    }
    guard let hashnodeToken = getTokenFromKeychain(key: "HashnodeToken") else {
      print("Error: Hashnode token is required.")
      return
    }

    guard let content = markdownManager.readMarkdownFile(atPath: markdownFilePath) else {
      print("Error: Could not read markdown content")
      return
    }

    let dispatchGroup = DispatchGroup()
    var failureMessages: [String] = []

    // Post to Medium
    dispatchGroup.enter()
    platformPoster.postToMedium(
      token: mediumToken, title: articleTitle, content: content, canonicalUrl: ""
    ) { success in
      if success {
        print("Successfully posted to Medium.")
      } else {
        failureMessages.append("Medium post failed.")
      }
      dispatchGroup.leave()
    }

    // Post to Dev.to
    dispatchGroup.enter()
    platformPoster.postToDev(token: devToken, title: articleTitle, content: content) { success in
      if success {
        print("Successfully posted to Dev.to.")
      } else {
        failureMessages.append("Dev.to post failed.")
      }
      dispatchGroup.leave()
    }

    // Post to Hashnode
    let hashnodeTags = ["swift", "ios", "programming"]

    dispatchGroup.enter()
    fetchTagsForHashnode(token: hashnodeToken, tags: hashnodeTags) { tagIDs in
      if let tagIDs = tagIDs {
        self.platformPoster.postToHashnode(
          token: hashnodeToken, title: articleTitle, contentMarkdown: content, tagIDs: tagIDs,
          host: host
        ) { success in
          if success {
            print("Successfully posted to Hashnode.")
          } else {
            failureMessages.append("Hashnode post failed.")
          }
          dispatchGroup.leave()
        }
      } else {
        failureMessages.append("Failed to fetch tags for Hashnode.")
        dispatchGroup.leave()
      }
    }

    // Notify when all posts are complete
    dispatchGroup.notify(queue: .main) {
      if failureMessages.isEmpty {
        print("Successfully posted to all platforms.")
      } else {
        print("Some posts failed:")
        failureMessages.forEach { print($0) }
      }
    }
  }

  func fetchTagsForHashnode(
    token: String, tags: [String], completion: @escaping ([[String: String]]?) -> Void
  ) {
    let dispatchGroup = DispatchGroup()
    var tagIDs: [[String: String]] = []

    let url = URL(string: "https://gql.hashnode.com")!

    for slug in tags {
      dispatchGroup.enter()

      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

      let query = """
        query Tag($slug: String!) {
          tag(slug: $slug) {
            id
            name
            slug
          }
        }
        """

      let body: [String: Any] = [
        "query": query,
        "variables": ["slug": slug.lowercased()],  // Normalize slug to lowercase
      ]

      request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

      URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          print("Error fetching tag for slug \(slug): \(error.localizedDescription)")
          dispatchGroup.leave()
          return
        }

        guard let data = data else {
          print("No data returned for slug \(slug)")
          dispatchGroup.leave()
          return
        }

        do {
          if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
            as? [String: Any],
            let dataField = jsonResponse["data"] as? [String: Any],
            let tag = dataField["tag"] as? [String: Any],
            let id = tag["id"] as? String,
            let name = tag["name"] as? String
          {
            tagIDs.append(["id": id, "name": name, "slug": slug.lowercased()])
          } else {
            print("Failed to parse tag for slug \(slug)")
          }
        } catch {
          print("Error parsing response for tag slug \(slug): \(error.localizedDescription)")
        }

        dispatchGroup.leave()
      }.resume()
    }

    dispatchGroup.notify(queue: .main) {
      if tagIDs.isEmpty {
        print("No valid tag IDs found.")
        completion(nil)
      } else {
        completion(tagIDs)
      }
    }
  }
}
