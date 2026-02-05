//
//  GraphQLQueries.swift
//  MergeDeck
//

import Foundation

enum GraphQLQueries {
    static let myPullRequests = """
    query GetMyPullRequests($first: Int = 20) {
      viewer {
        login
        pullRequests(first: $first, states: OPEN, orderBy: {field: UPDATED_AT, direction: DESC}) {
          nodes {
            id
            number
            title
            url
            isDraft
            createdAt
            updatedAt
            repository {
              name
              owner {
                login
              }
            }
            commits(last: 1) {
              nodes {
                commit {
                  statusCheckRollup {
                    state
                    contexts(first: 50) {
                      nodes {
                        __typename
                        ... on CheckRun {
                          id
                          name
                          status
                          conclusion
                          detailsUrl
                        }
                        ... on StatusContext {
                          id
                          context
                          state
                          targetUrl
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    """

    static let viewerLogin = """
    query GetViewerLogin {
      viewer {
        login
      }
    }
    """
}
