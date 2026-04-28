//
//  Network.swift
//  iOS-Common-Libraries
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation
import Combine
import SwiftUI
import SystemConfiguration
import os

// MARK: - Network

public final class Network {
    
    // MARK: - Properties
    
    private lazy var imageCache = Cache<URL, Image>()
    private lazy var session = URLSession(configuration: .multiPathEnabled)
    
    private var reachability: SCNetworkReachability?
    
    // MARK: Public Init
    
    public init(_ host: String) {
        reachability = SCNetworkReachabilityCreateWithName(nil, host)
    }
}

// MARK: - API

public extension Network {
    
    // MARK: - Reachability
    
    func getReachabilityPublisher() -> AnyPublisher<Bool, Error> {
        return CurrentValueSubject<Bool, Error>(isReachable())
            .tryMap { isReachable in
                guard isReachable else {
                    throw URLError(.cannotFindHost)
                }
                return true
            }
            .eraseToAnyPublisher()
    }
    
    func isReachable() -> Bool {
        guard let reachability = reachability else {
            logError("\(#function): Nil reachability property.")
            return false
        }
        
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)

        let isReachable = flags.contains(.reachable)
        let connectionRequired = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutIntervention = canConnectAutomatically && !flags.contains(.interventionRequired)
        let result = isReachable && (!connectionRequired || canConnectWithoutIntervention)
        logDebug("\(#function): \(result)")
        return isReachable && (!connectionRequired || canConnectWithoutIntervention)
    }
    
    // MARK: perform(_:HTTPRequest)
    
    /**
     - Returns: a ``NetworkResponse`` if the task completes, returning a valid ``HTTPURLResponse`` whose status code abides by the 2__ prefix. Any other status code will be resolved by throwing a ``URLError``.
     */
    func perform(_ request: HTTPRequest) -> AnyPublisher<NetworkResponse, Error> {
        let sessionRequestPublisher = session.dataTaskPublisher(for: request)
            .tryMap() { [unowned self] element -> NetworkResponse in
                #if DEBUG
                logDebug("\(element.response)")
                #endif
                
                guard let httpResponse = element.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                switch httpResponse.statusCode {
                case 200...299: // Successful Response.
                    return NetworkResponse(code: httpResponse.statusCode, data: element.data)
                case 401:
                    throw URLError(.userAuthenticationRequired)
                default: // Assume Error.
                    if let responseDataAsString = String(data: element.data, encoding: .utf8) {
                        #if DEBUG
                        logDebug("\(request): \(responseDataAsString)")
                        #endif
                        throw URLError(.unknown, userInfo: [
                            "httpStatusCode": httpResponse.statusCode,
                            "httpResponse": HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode),
                            "response": responseDataAsString
                        ])
                    } else {
                        throw URLError(.cannotParseResponse)
                    }
                }
            }
            .eraseToAnyPublisher()
        
        return getReachabilityPublisher()
            .flatMap { _ -> AnyPublisher<NetworkResponse, Error> in
                return sessionRequestPublisher
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: perform<T>(_:HTTPRequest)
    
    func perform<T: Codable>(_ request: HTTPRequest, responseType: T.Type = T.self) -> AnyPublisher<T, Error> {
        return perform(request)
            .flatMap { (response: NetworkResponse) -> AnyPublisher<T, Error> in
                let decoder = JSONDecoder()
                if let response = try? decoder.decode(T.self, from: response.data) {
                    return Just(response).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                do {
                    let errorResponse = try decoder.decode(BasicHTTPResponse.self, from: response.data)
                    return Fail(error: errorResponse)
                        .eraseToAnyPublisher()
                } catch (let error) {
                    guard let stringResponse = String(data: response.data, encoding: .utf8) else {
                        return Fail(error: error)
                            .eraseToAnyPublisher()
                    }
                    if stringResponse.contains("session expired") {
                        return Fail(error: URLError(.userAuthenticationRequired))
                            .eraseToAnyPublisher()
                    } else  {
                        return Fail(error: BasicHTTPResponse(success: false, error: "Unknown Server Error Received."))
                            .eraseToAnyPublisher()
                    }
                }
            }
            .tryCatch { error -> AnyPublisher<T, Error> in
                if let urlError = error as? URLError, urlError.errorCode == -1200 {
                    return Fail(error: URLError(.appTransportSecurityRequiresSecureConnection))
                        .eraseToAnyPublisher()
                }
                throw error
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: downloadImage(for:)
    
    func downloadImage(for url: URL) -> AnyPublisher<Image?, Never> {
        if let cachedImage = imageCache[url] {
            return Just(cachedImage)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .map { response -> Image? in
                let image: Image?
                #if os(OSX)
                guard let nsimage = NSImage(data: response.data) else { return nil }
                image = Image(nsImage: nsimage)
                #elseif os(iOS)
                guard let uiimage = UIImage(data: response.data) else { return nil }
                image = Image(uiImage: uiimage)
                #endif
                return image
            }
            .replaceError(with: nil)
            .map { [imageCache] image in
                imageCache[url] = image
                return image
            }
            .eraseToAnyPublisher()
    }
}

// MARK: Logging

internal extension Network {
    
    func logDebug(_ string: String) {
        guard #available(iOS 14.0, macCatalyst 14.0, macOS 11.0, *) else { return }
        let logger = NordicLog(Self.self, subsystem: NordicLog.iOSCommonLibrarySubsystem)
        logger.debug(string)
    }
    
    func logError(_ string: String) {
        guard #available(iOS 14.0, macCatalyst 14.0, macOS 11.0, *) else { return }
        let logger = NordicLog(Self.self, subsystem: NordicLog.iOSCommonLibrarySubsystem)
        logger.error(string)
    }
}

// MARK: - BasicHTTPResponse

public struct BasicHTTPResponse: HTTPResponse, LocalizedError {
    
    public let success: Bool
    public let error: String?
    
    public var errorDescription: String? { error }
    public var recoverySuggestion: String? { error }
    public var helpAnchor: String? { "Try Postman or ask Roshee for help." }
}
