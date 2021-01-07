//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation

struct ServerResponse: Codable {
    let isMatch: Bool
    let destinationUrl: String?
    let campaignId: String?
    let templateId: String?
    let messageId: String?
}
