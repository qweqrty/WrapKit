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
    
    static func find(in context: NSManagedObjectContext) throws -> Self?
    static func deleteCache(in context: NSManagedObjectContext) throws
}

extension CoreDataConvertible where Self: NSManagedObject {
    static func find(in context: NSManagedObjectContext) throws -> Self? {
        let request = NSFetchRequest<Self>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func deleteCache(in context: NSManagedObjectContext) throws {
        try find(in: context).map(context.delete).map(context.save)
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
        return subject.eraseToAnyPublisher()
    }
    
    public init?(storeURL: URL, entityName: String) {
        self.entityName = entityName
        
        guard let model = NSManagedObjectModel.with(name: entityName, in: Bundle(for: Self.self)) else {
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
                if let coreDataModel = try CoreDataModel.find(in: self.context) {
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
                if let coreDataModel = try CoreDataModel.find(in: self.context) {
                    model = coreDataModel.toDomainModel()
                }
            } catch {
                print("Failed to fetch data: \(error)")
            }
        }
        return model
    }

    @discardableResult
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        Future<Bool, Never> { promise in
            self.context.perform {
                do {
                    if let model = model {
                        _ = CoreDataModel.fromDomainModel(model, context: self.context)
                    } else {
                        try CoreDataModel.deleteCache(in: self.context)
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

    public static func == (lhs: CoreDataStorage, rhs: CoreDataStorage) -> Bool {
        return lhs.entityName == rhs.entityName
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(entityName)
    }
}
