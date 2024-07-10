import Foundation
import CoreData


extension CDEmergencyContacts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDEmergencyContacts> {
        return NSFetchRequest<CDEmergencyContacts>(entityName: "CDEmergencyContacts")
    }

    @NSManaged public var name: String?
    @NSManaged public var mobile: String?

}

extension CDEmergencyContacts : Identifiable {

}
