//
//  Created by Tapash Majumder on 2/28/19.
//  Copyright © 2019 Iterable. All rights reserved.
//

import Foundation

protocol InAppFetcherProtocol {
    // Fetch from server and sync
    func fetch() -> Future<[IterableInAppMessage], Error>
}

/// For callbacks when silent push notifications arrive
protocol InAppNotifiable {
    func scheduleSync() -> Future<Bool, Error>
    func onInAppRemoved(messageId: String)
}

extension IterableInAppTriggerType {
    static let defaultTriggerType = IterableInAppTriggerType.immediate // default is what is chosen by default
    static let undefinedTriggerType = IterableInAppTriggerType.never // undefined is what we select if payload has new trigger type
}

struct IterableInAppMessageMetadata {
    let message: IterableInAppMessage
    let location: InAppLocation
}

class InAppFetcher: InAppFetcherProtocol {
    init(apiClient: ApiClientProtocol) {
        ITBInfo()
        self.apiClient = apiClient
    }
    
    func fetch() -> Future<[IterableInAppMessage], Error> {
        ITBInfo()
        
        guard let apiClient = apiClient else {
            ITBError("Invalid state: expected ApiClient")
            return Promise(error: IterableError.general(description: "Invalid state: expected InternalApi"))
        }
        
        return InAppHelper.getInAppMessagesFromServer(apiClient: apiClient, number: numMessages).mapFailure { $0 }
    }
    
    private weak var apiClient: ApiClientProtocol?
    
    deinit {
        ITBInfo()
    }
    
    // how many messages to fetch
    private let numMessages = 100
}

struct InAppMessageContext {
    let messageId: String
    let saveToInbox: Bool
    let silentInbox: Bool
    let location: InAppLocation
    let deviceMetadata: DeviceMetadata
    
    static func from(message: IterableInAppMessage, location: InAppLocation, deviceMetadata: DeviceMetadata) -> InAppMessageContext {
        return InAppMessageContext(messageId: message.messageId,
                                   saveToInbox: message.saveToInbox,
                                   silentInbox: message.silentInbox,
                                   location: location,
                                   deviceMetadata: deviceMetadata)
    }
    
    // For backward compatibility, assume .inApp
    static func from(messageId: String, deviceMetadata: DeviceMetadata) -> InAppMessageContext {
        return InAppMessageContext(messageId: messageId,
                                   saveToInbox: false,
                                   silentInbox: false,
                                   location: .inApp,
                                   deviceMetadata: deviceMetadata)
    }
    
    func toMessageContextDictionary() -> [AnyHashable: Any] {
        var context = [AnyHashable: Any]()
        
        context.setValue(for: .saveToInbox, value: saveToInbox)
        
        context.setValue(for: .silentInbox, value: silentInbox)
        
        context.setValue(for: .inAppLocation, value: location)
        
        context.setValue(for: .deviceInfo, value: deviceMetadata.asDictionary())
        
        return context
    }
}