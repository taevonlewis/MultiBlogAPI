//
//  PlatformPoster.swift
//  MultiBlogAPI
//
//  Created by TaeVon Lewis on 10/24/24.
//

import Foundation

class PlatformPoster {
  func postToMedium(
    token: String, title: String, content: String, canonicalUrl: String,
    completion: @escaping (Bool) -> Void
  ) {
    fetchMediumUserId(token: token) { fetchedAuthorId in
      guard let fetchedAuthorId = fetchedAuthorId else {
        print("Error: Could not fetch Medium user ID.")
        completion(false)
        return
      }
      self.postArticleToMedium(
        token: token, authorId: fetchedAuthorId, title: title, content: content,
        canonicalUrl: canonicalUrl, completion: completion)
    }
  }

  private func postArticleToMedium(
    token: String, authorId: String, title: String, content: String, canonicalUrl: String,
    completion: @escaping (Bool) -> Void
  ) {
    let url = URL(string: "https://api.medium.com/v1/users/\(authorId)/posts")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let body: [String: Any] = [
      "title": title,
      "contentFormat": "markdown",
      "content": content,
      "canonicalUrl": canonicalUrl,
      "publishStatus": "public",
    ]

    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error posting to Medium: \(error.localizedDescription)")
        completion(false)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        print("Failed to get response for Medium.")
        completion(false)
        return
      }

      if (200...299).contains(httpResponse.statusCode) {
        print("Successfully posted to Medium.")
        completion(true)
      } else {
        if let data = data,
          let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        {
          print(
            "Failed with status code \(httpResponse.statusCode) for Medium. Response: \(responseJSON)"
          )
        }
        completion(false)
      }
    }.resume()
  }

  private func fetchMediumUserId(token: String, completion: @escaping (String?) -> Void) {
    let url = URL(string: "https://api.medium.com/v1/me")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error fetching Medium userId: \(error.localizedDescription)")
        completion(nil)
        return
      }

      guard let data = data else {
        print("No data returned from Medium /me request.")
        completion(nil)
        return
      }

      do {
        if let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
          as? [String: Any],
          let dataField = responseJSON["data"] as? [String: Any],
          let userId = dataField["id"] as? String
        {
          completion(userId)
        } else {
          print("Failed to fetch or parse userId from Medium response.")
          completion(nil)
        }
      } catch {
        print("Error parsing Medium /me response: \(error.localizedDescription)")
        completion(nil)
      }
    }.resume()
  }

  func postToDev(
    token: String, title: String, content: String, completion: @escaping (Bool) -> Void
  ) {
    let url = URL(string: "https://dev.to/api/articles")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "api-key")

    let body: [String: Any] = [
      "article": [
        "title": title,
        "published": true,
        "body_markdown": content,
        "tags": ["programming", "swift", "blogging"],
      ]
    ]

    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error posting to Dev.to: \(error.localizedDescription)")
        completion(false)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        print("Failed to get response for Dev.to.")
        completion(false)
        return
      }

      if (200...299).contains(httpResponse.statusCode) {
        print("Successfully posted to Dev.to.")
        completion(true)
      } else {
        if let data = data,
          let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        {
          print(
            "Failed with status code \(httpResponse.statusCode) for Dev.to. Response: \(responseJSON)"
          )
        }
        completion(false)
      }
    }.resume()
  }

  func postToHashnode(
    token: String, title: String, contentMarkdown: String, tagIDs: [[String: String]], host: String,
    completion: @escaping (Bool) -> Void
  ) {
    fetchPublicationId(token: token, host: host) { publicationId in
      guard let publicationId = publicationId else {
        print("Failed to fetch publication ID.")
        completion(false)
        return
      }

      let url = URL(string: "https://gql.hashnode.com")!
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

      let query = """
        mutation PublishPost($input: PublishPostInput!) {
            publishPost(input: $input) {
                post {
                    id
                    title
                    slug
                    url
                }
            }
        }
        """

      let body: [String: Any] = [
        "query": query,
        "variables": [
          "input": [
            "title": title,
            "publicationId": publicationId,
            "contentMarkdown": contentMarkdown,
            "tags": tagIDs,
          ]
        ],
      ]

      request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

      URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          print("Error posting to Hashnode: \(error.localizedDescription)")
          completion(false)
          return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
          print("Failed to get response for Hashnode.")
          completion(false)
          return
        }

        if (200...299).contains(httpResponse.statusCode) {
          if let data = data {
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
              as? [String: Any]
            {
              if let errors = jsonResponse["errors"] as? [[String: Any]] {
                print("Errors: \(errors)")
                completion(false)
                return
              }
              print("Successfully posted to Hashnode.")
              completion(true)
            } else {
              print("Failed to parse response.")
              completion(false)
            }
          }
        } else {
          if let data = data,
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
          {
            print("Failed with status code \(httpResponse.statusCode). Response: \(responseJSON)")
          }
          completion(false)
        }
      }.resume()
    }
  }

  private func fetchPublicationId(
    token: String, host: String, completion: @escaping (String?) -> Void
  ) {
    let url = URL(string: "https://gql.hashnode.com")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let query = """
      query {
        publication(host: "\(host)") {
          id
          title
        }
      }
      """

    let body: [String: Any] = [
      "query": query
    ]

    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error fetching publication ID: \(error.localizedDescription)")
        completion(nil)
        return
      }

      guard let data = data else {
        print("No data returned.")
        completion(nil)
        return
      }

      if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
        let dataField = json["data"] as? [String: Any],
        let publication = dataField["publication"] as? [String: Any],
        let publicationId = publication["id"] as? String
      {
        completion(publicationId)
      } else {
        print("Failed to parse publication ID.")
        completion(nil)
      }
    }.resume()
  }

  func testAllAPIs() {
    let postManager = PostManager()
    guard let mediumToken = postManager.getTokenFromKeychain(key: "MediumToken") else {
      print("Error: Medium token is required.")
      return
    }
    guard let devToken = postManager.getTokenFromKeychain(key: "DevToken") else {
      print("Error: Dev.to token is required.")
      return
    }
    guard let hashnodeToken = postManager.getTokenFromKeychain(key: "HashnodeToken") else {
      print("Error: Hashnode token is required.")
      return
    }

    let dispatchGroup = DispatchGroup()

    // Test Medium API
    dispatchGroup.enter()
    testMediumAPI(token: mediumToken) { success in
      print("Medium API test success: \(success)")
      dispatchGroup.leave()
    }

    // Test Dev.to API
    dispatchGroup.enter()
    testDevAPI(token: devToken) { success in
      print("Dev.to API test success: \(success)")
      dispatchGroup.leave()
    }

    // Test Hashnode API
    dispatchGroup.enter()
    testHashnodeAPI(token: hashnodeToken) { success in
      print("Hashnode API test success: \(success)")
      dispatchGroup.leave()
    }

    // Notify when all tests are complete
    dispatchGroup.notify(queue: .main) {
      print("All API tests completed.")
    }
  }

  private func testMediumAPI(token: String, completion: @escaping (Bool) -> Void) {
    let url = URL(string: "https://api.medium.com/v1/me")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error testing Medium API: \(error.localizedDescription)")
        completion(false)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        print("Failed to get response for Medium API.")
        completion(false)
        return
      }

      if (200...299).contains(httpResponse.statusCode) {
        print("Medium API is working properly.")
        completion(true)
      } else {
        print("Failed with status code \(httpResponse.statusCode) for Medium API.")
        completion(false)
      }
    }.resume()
  }

  private func testDevAPI(token: String, completion: @escaping (Bool) -> Void) {
    let url = URL(string: "https://dev.to/api/articles/me")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "api-key")

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error testing Dev.to API: \(error.localizedDescription)")
        completion(false)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        print("Failed to get response for Dev.to API.")
        completion(false)
        return
      }

      if (200...299).contains(httpResponse.statusCode) {
        print("Dev.to API is working properly.")
        completion(true)
      } else {
        print("Failed with status code \(httpResponse.statusCode) for Dev.to API.")
        completion(false)
      }
    }.resume()
  }

  private func testHashnodeAPI(token: String, completion: @escaping (Bool) -> Void) {
    let url = URL(string: "https://gql.hashnode.com")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let query = """
      {
          user {
              name
          }
      }
      """

    let body: [String: Any] = [
      "query": query
    ]

    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error testing Hashnode API: \(error.localizedDescription)")
        completion(false)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        print("Failed to get response for Hashnode API.")
        completion(false)
        return
      }

      if (200...299).contains(httpResponse.statusCode) {
        print("Hashnode API is working properly.")
        completion(true)
      } else {
        print("Failed with status code \(httpResponse.statusCode) for Hashnode API.")
        completion(false)
      }
    }.resume()
  }
}
