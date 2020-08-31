import Foundation

// MARK: - Tweet
struct Tweet: Codable {
    let createdAt: String
    let id: Double
    let text: String
    let extendedEntities: ExtendedEntities
    let user: User
    let videoUrl: String
    let previewUrl: String
    var postUrl: String
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id, text
        case extendedEntities = "extended_entities"
        case user
        case postUrl
    }

    init(from decoder: Decoder) throws {
        let decoderContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.postUrl = ""
        self.createdAt = (try? decoderContainer.decode(String.self, forKey: .createdAt)) ?? ""
        self.id = (try? decoderContainer.decode(Double.self, forKey: .id)) ?? 0
        self.text = (try? decoderContainer.decode(String.self, forKey: .text)) ?? ""
        self.extendedEntities = (try? decoderContainer.decode(ExtendedEntities.self, forKey: .extendedEntities)) ?? ExtendedEntities.init(media: [])
        self.user = (try? decoderContainer.decode(User.self, forKey: .user)) ?? User.def

        if let previewMedia = extendedEntities.media.first(where: { (media) -> Bool in
            return media.mediaURL.contains(".jpg")
        }) {
            self.previewUrl = previewMedia.mediaURLHTTPS
        }else {
            self.previewUrl = ""
        }

        if let fMedia = extendedEntities.media.first {
            let videos = fMedia.videoInfo.variants
            var bitrate = 0
            var videoURL = ""
            var previewURL = ""
            for video in videos {
                if video.contentType == "video/mp4" {
                    if  (video.bitrate ?? 0) > bitrate {
                        bitrate = video.bitrate ?? 0
                        videoURL = video.url

                    }
                }
            }
            self.videoUrl = videoURL
        }else {
            self.videoUrl = ""
        }
    }

}

// MARK: - ExtendedEntities
struct ExtendedEntities: Codable {
    let media: [Media]
}

// MARK: - Media
struct Media: Codable {
    let id: Double
    let idStr: String
    let indices: [Int]
    let mediaURL: String
    let mediaURLHTTPS: String
    let url: String
    let displayURL: String
    let expandedURL: String
    let type: String
    let sizes: Sizes
    let videoInfo: VideoInfo
    let additionalMediaInfo: AdditionalMediaInfo

    enum CodingKeys: String, CodingKey {
        case id
        case idStr = "id_str"
        case indices
        case mediaURL = "media_url"
        case mediaURLHTTPS = "media_url_https"
        case url
        case displayURL = "display_url"
        case expandedURL = "expanded_url"
        case type, sizes
        case videoInfo = "video_info"
        case additionalMediaInfo = "additional_media_info"
    }
}

// MARK: - AdditionalMediaInfo
struct AdditionalMediaInfo: Codable {
    let monetizable: Bool
}

// MARK: - Sizes
struct Sizes: Codable {
    let thumb, large, small, medium: Large
}

// MARK: - Large
struct Large: Codable {
    let w, h: Int
    let resize: String
}

// MARK: - VideoInfo
struct VideoInfo: Codable {
    let aspectRatio: [Int]
    let durationMillis: Int
    let variants: [Variant]

    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case durationMillis = "duration_millis"
        case variants
    }
}

// MARK: - Variant
struct Variant: Codable {
    let bitrate: Int?
    let contentType: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case bitrate
        case contentType = "content_type"
        case url
    }
}

// MARK: - User
struct User: Codable {
    let id: Double
    let idStr, name, screenName, location: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case idStr = "id_str"
        case name
        case screenName = "screen_name"
        case location
        case imageUrl = "profile_image_url_https"
    }
}

extension User {
    static var def: User {
        User(id: 0, idStr: "", name: "", screenName: "", location: "", imageUrl: "")
    }
}

// MARK: - Entities
struct Entities: Codable {
    let url, entitiesDescription: Description

    enum CodingKeys: String, CodingKey {
        case url
        case entitiesDescription = "description"
    }
}

// MARK: - Description
struct Description: Codable {
    let urls: [URLElement]
}

// MARK: - URLElement
struct URLElement: Codable {
    let url: String
    let expandedURL: String
    let displayURL: String
    let indices: [Int]

    enum CodingKeys: String, CodingKey {
        case url
        case expandedURL = "expanded_url"
        case displayURL = "display_url"
        case indices
    }
}
