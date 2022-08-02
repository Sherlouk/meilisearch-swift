import Foundation

/**
  Tasks contains information related to asynchronous tasks in MeiliSearch
 */
struct Tasks {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  // Get on client
  func get(
    taskUid: Int,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      get(path: "/tasks/\(taskUid)", completion)
  }

  private func get (
    path: String,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      self.request.get(api: path) { result in
        switch result {
        case .success(let data):
          do {
            let task: Result<Task, Swift.Error>  = try Constants.resultDecoder(data: data)
            completion(task)
          } catch {
            completion(.failure(error))
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }

  // get all on client
  func getAll(
    params: TasksQuery? = nil,
    _ completion: @escaping (Result<Results<Task>, Swift.Error>) -> Void) {
      getAll(path: "/tasks", params: params, completion)
  }

  // get all on index
  func getAll(
    uid: String,
    params: TasksQuery? = nil,
    _ completion: @escaping (Result<Results<Task>, Swift.Error>) -> Void) {
      var query: TasksQuery?

      if params != nil {
        params?.indexUid.append(uid)

        query = params
      } else {
        query = TasksQuery(indexUid: [uid])
      }

      getAll(path: "/tasks", params: query, completion)
  }

  private func getAll(
    path: String,
    params: TasksQuery? = nil,
    _ completion: @escaping (Result<Results<Task>, Swift.Error>) -> Void) {
    self.request.get(api: path, param: params?.toQuery()) { result in
      switch result {
      case .success(let data):
        do {
          let task: Result<Results<Task>, Swift.Error>  = try Constants.resultDecoder(data: data)
          completion(task)
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  private func checkStatus(
    _ taskUid: Int,
    _ options: WaitOptions,
    _ startingDate: Date,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      self.get(taskUid: taskUid) { result in
        switch result {
        case .success(let status):
          if status.status == Task.Status.succeeded || status.status == Task.Status.failed {
            completion(.success(status))
          } else if 0 - startingDate.timeIntervalSinceNow > options.timeOut {
            completion(.failure(MeiliSearch.Error.timeOut(timeOut: options.timeOut)))
          } else {
            usleep(useconds_t(options.interval * 1000000))
            self.checkStatus(taskUid, options, startingDate, completion)
          }
        case .failure(let error):
          completion(.failure(error))
          return
        }
      }
  }

  // wait for task using task structure
  func waitForTask(
    task: Task,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      waitForTask(taskUid: task.uid, options: options, completion)
  }

  // wait for task using taskUid
  func waitForTask(
    taskUid: Int,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      do {
        let currentDate = Date()
        let waitOptions = options ?? WaitOptions()

        self.checkStatus(taskUid, waitOptions, currentDate) { result in
          switch result {
          case .success(let status):
            completion(.success(status))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
  }
}
