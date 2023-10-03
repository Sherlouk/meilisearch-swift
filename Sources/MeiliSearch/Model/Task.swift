import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
 `Task` instances represent the current transaction status, use the `uid` value to
  verify the status of your transaction.
 */
public struct Task: Codable, Equatable {

  // MARK: Properties

  /// Unique ID for the current `Task`.
  public let uid: Int

  /// Unique ID for the current `Task`.
  public let indexUid: String?

  /// Returns if the task has been successful or not.
  public let status: Task.Status

  /// Type of the task.
  public let type: String

  /// Details of the task.
  public let details: Details?

  /// Duration of the task process.
  public let duration: String?

  /// Date when the task has been enqueued.
  public let enqueuedAt: String

  /// Date when the task has been processed.
  public let processedAt: Date?

  /// Type of `Task`.
  public struct Details: Codable, Equatable {

    // MARK: Properties

    /// Number of documents sent
    public let receivedDocuments: Int?

    /// Number of documents successfully indexed/updated in Meilisearch
    public let indexedDocuments: Int?

    /// Number of deleted documents
    public let deletedDocuments: Int?

    /// Primary key on index creation
    public let primaryKey: String?

    /// Ranking rules on settings actions
    public let rankingRules: [String]?

    /// Searchable attributes on settings actions
    public let searchableAttributes: [String]?

    /// Displayed attributes on settings actions
    public let displayedAttributes: [String]?

    /// Filterable attributes on settings actions
    public let filterableAttributes: [String]?

    /// Sortable attributes on settings actions
    public let sortableAttributes: [String]?

    /// Stop words on settings actions
    public let stopWords: [String]?

    /// Synonyms on settings actions
    public let synonyms: [String: [String]]?

    /// Distinct attribute on settings actions
    public let distinctAttribute: String?

    /// List of tokens that will be considered as word separators by Meilisearch.
    public let separatorTokens: [String]?

    /// List of tokens that will not be considered as word separators by Meilisearch.
    public let nonSeparatorTokens: [String]?

    /// List of words on which the segmentation will be overridden.
    public let dictionary: [String]?

    /// Settings for index level pagination rules
    public let pagination: Pagination?

    /// Typo tolerance on settings actions
    public let typoTolerance: TypoTolerance?
  }
  /// Error information in case of failed update.
  public let error: MeiliSearch.MSErrorResponse?

  public enum Status: Codable, Equatable {
    /// When a task was successfully enqueued and is waiting to be processed.
    case enqueued
    /// When a task is still being processed.
    case processing
    /// When a task was successfully processed.
    case succeeded
    /// When a task had an error  and could not be completed for some reason.
    case failed

    public enum StatusError: Error {
      case unknown
    }

    public init(from decoder: Decoder) throws {
      let container: SingleValueDecodingContainer = try decoder.singleValueContainer()
      let rawStatus: String = try container.decode(String.self)

      switch rawStatus {
      case "enqueued":
        self = Status.enqueued
      case "processing":
        self = Status.processing
      case "succeeded":
        self = Status.succeeded
      case "failed":
        self = Status.failed
      default:
        throw StatusError.unknown
      }
    }

    public func encode(to encoder: Encoder) throws { }
  }
}
