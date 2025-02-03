//
//  APIClient.swift
//  ToDoList
//
//  Created by Богдан Топорин on 29.01.2025.
//

import Foundation

class APIClient {
    private let baseURL = "https://dummyjson.com/todos"
    
    func fetchTasks(skip: Int = 0, limit: Int = 30, completion: @escaping (Result<TaskListResponse, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 400, userInfo: nil)))
                return
            }
            do {
                let response = try JSONDecoder().decode(TaskListResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
