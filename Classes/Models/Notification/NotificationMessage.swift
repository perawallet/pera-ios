//
//  Notification.swift

import Magpie

class NotificationMessage: Model {
    let id: Int
    let account: Int?
    let notificationType: NotificationType?
    let date: Date?
    let message: String?
    let detail: NotificationDetail?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        account = try container.decodeIfPresent(Int.self, forKey: .account)
        notificationType = try container.decodeIfPresent(NotificationType.self, forKey: .notificationType)
        if let stringDate = try container.decodeIfPresent(String.self, forKey: .date) {
            date = stringDate.toDate()?.date
        } else {
            date = nil
        }
        message = try container.decodeIfPresent(String.self, forKey: .message)
        detail = try container.decodeIfPresent(NotificationDetail.self, forKey: .detail)
    }
}

extension NotificationMessage {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case account = "account"
        case notificationType = "type"
        case date = "creation_datetime"
        case message = "message"
        case detail = "metadata"
    }
}
