//
//  NetworkManager.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

class NetworkManager {

    typealias CompletionHandler<T> = (NetworkResponse<T>) -> ()
    typealias ErrorHandler = (NetworkError) -> ()

    static let shared = NetworkManager()

    private let urlSession: URLSession = .shared
    private let decoder = JSONDecoder()

    private init(){}

    func performRequest(with builder: RequestBuilder,
                        success: @escaping CompletionHandler<Data>,
                        failure: @escaping ErrorHandler) {
        urlSession.dataTask(with: builder.request) { [weak self] (data, response, error) in
            let dat = builder.method == .head ? Data() : data
            self?.processResponse(data: dat, response: response, error: error,
                                  success: success, failure: failure)
        }.resume()
    }

    func performRequest<T: Decodable>(with builder: RequestBuilder,
                                      success: @escaping CompletionHandler<T>,
                                      failure: @escaping ErrorHandler) {
        performRequest(with: builder, success: { [weak self] (response: NetworkResponse<Data>) in
            self?.processReceivedData(data: response.data, headers: response.headers,
                                      success: success, failure: failure)
        }, failure: failure)
    }

    private func processResponse(data: Data?, response: URLResponse?, error: Error?,
                                 success: CompletionHandler<Data>, failure: ErrorHandler) {
        if let error = error as? URLError {
            switch error.code {
            case .networkConnectionLost, .notConnectedToInternet:
                failure(.noConnection)
            case .timedOut:
                failure(.timeout)
            default:
                failure(.unknown(error))
            }
            return
        }

        guard let response = response as? HTTPURLResponse else {
            failure(.unknown(error))
            return
        }

        guard (200...299).contains(response.statusCode) else {
            failure(.httpError(response.statusCode))
            return
        }

        guard let data = data else {
            failure(.unknown(error))
            return
        }

        var headers: [String: String] = [:]
        response.allHeaderFields.forEach {
            headers["\($0.key)"] = "\($0.value)"
        }

        success(NetworkResponse(headers: headers, data: data))
    }

    private func processReceivedData<T: Decodable>(data: Data, headers: [String: String],
                                                   success: CompletionHandler<T>, failure: ErrorHandler) {
        do {
            let dataObject = try decoder.decode(T.self, from: data)
            success(NetworkResponse(headers: headers, data: dataObject))
        } catch {
            failure(.mappingError(error))
        }
    }
}
