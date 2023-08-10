protocol CoreDataModelBuilding {

    // It would be good if we could constrain this to be an NSManagedObject
    associatedtype Model

    init(_ context: NSManagedObjectContext)

    func build() -> Model
}
