//
//  FavoritePhoto.swift
//  Photo Gallery
//
//  Created by Никита Горьковой on 01.03.26.
//

internal import CoreData

@objc(FavoritePhoto)
final class FavoritePhoto: NSManagedObject {
    @NSManaged var photoID: String
    @NSManaged var slug: String?
    @NSManaged var photoDescription: String?
    @NSManaged var altDescription: String?
    @NSManaged var thumbURL: String?
    @NSManaged var regularURL: String?
    @NSManaged var authorName: String?
    @NSManaged var authorUsername: String?
    @NSManaged var addedAt: Date?
}
