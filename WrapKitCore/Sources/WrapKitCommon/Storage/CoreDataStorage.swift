//
//  CoreDataStorage.swift
//
//
//  Created by Stanislav Li on 5/8/24.
//

import CoreData
import Combine

public protocol CoreDataConvertible {
    associatedtype DomainModel

    func toDomainModel() -> DomainModel
    static func fromDomainModel(_ model: DomainModel, context: NSManagedObjectContext) -> Self
    
    static func find(in context: NSManagedObjectContext) throws -> [Self]
    static func deleteCache(in context: NSManagedObjectContext) throws
}

public extension CoreDataConvertible where Self: NSManagedObject {
    static func find(in context: NSManagedObjectContext) throws -> [Self] {
        let request = NSFetchRequest<Self>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request)
    }
    
    static func deleteCache(in context: NSManagedObjectContext) throws {
        let existingRecords = try find(in: context)
        existingRecords.forEach { context.delete($0) }
        try context.save()
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

extension NSPersistentContainer {
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }
        
        return container
    }
}

public class CoreDataStorage<Model, CoreDataModel: NSManagedObject & CoreDataConvertible>: Storage where CoreDataModel.DomainModel == Model {
    private let entityName: String
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private var subject = CurrentValueSubject<Model?, Never>(nil)
    private var cancellables: Set<AnyCancellable> = []

    public var publisher: AnyPublisher<Model?, Never> {
        subject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public init?(storeURL: URL, entityName: String, bundle: Bundle? = nil) {
        self.entityName = entityName
        
        guard let model = NSManagedObjectModel.with(name: entityName, in: bundle ?? Bundle(for: CoreDataModel.self)) else {
            return nil
        }
        
        do {
            container = try NSPersistentContainer.load(name: entityName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            return nil
        }
        
        context.perform {
            do {
                if let coreDataModel = try CoreDataModel.find(in: self.context).first {
                    let model = coreDataModel.toDomainModel()
                    self.subject.send(model)
                }
            } catch {

            }
        }
    }

    public func get() -> Model? {
        var model: Model?
        context.performAndWait {
            do {
                if let coreDataModel = try CoreDataModel.find(in: self.context).first {
                    model = coreDataModel.toDomainModel()
                }
            } catch {
                
            }
        }
        return model
    }

    @discardableResult
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        Future<Bool, Never> { promise in
            self.context.perform {
                do {
                    // Delete all existing records
                    try CoreDataModel.deleteCache(in: self.context)

                    if let model = model {
                        _ = CoreDataModel.fromDomainModel(model, context: self.context)
                    }
                    try self.context.save()
                    self.subject.send(model)
                    promise(.success(true))
                } catch {
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    @discardableResult
    public func clear() -> AnyPublisher<Bool, Never> {
        set(model: nil)
    }

    public static func == (lhs: CoreDataStorage, rhs: CoreDataStorage) -> Bool {
        return lhs.entityName == rhs.entityName
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(entityName)
    }
}
