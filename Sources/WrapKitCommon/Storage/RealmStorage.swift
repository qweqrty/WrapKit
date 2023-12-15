//
//  RealmStorage.swift
//  WrapKit
//
//  Created by Stanislav Li on 14/12/23.
//

#if canImport(RealmSwift)
import Foundation
import RealmSwift

public protocol ObjectDTO<Object> where Object == RealmSwift.Object {
    associatedtype Object
    var object: Object { get }
}

public class RealmStorage<Object: RealmSwift.Object & ViewModelDTO, Model: ObjectDTO>: Storage where Model == Object.ViewModel {
    private let realmQueue = DispatchQueue(label: "com.wrapkit.storage.realmQueue")
    private var observers = [ObserverWrapper]()
    
    private var model: Model? {
        didSet {
            notifyObservers()
        }
    }
    
    init() {
        realmQueue.async {
            let realm = try! Realm()
            let result = realm.objects(Object.self).first?.viewModel
            self.model = result
        }
    }
    
    public func addObserver(for client: AnyObject, observer: @escaping Observer) {
        let wrapper = ObserverWrapper(client: client, observer: observer)
        wrapper.observer(model)
        observers.append(wrapper)
    }
    
    public func get() -> Model? {
        return model
    }
    
    public func set(model: Model?, completion: ((Bool) -> Void)?) {
        realmQueue.async {
            do {
                let realm = try Realm()
                try realm.write {
                    if let model = model {
                        realm.add(model.object, update: .modified)
                    } else {
                        realm.delete(realm.objects(Object.self))
                    }
                    DispatchQueue.main.async {
                        completion?(true)
                    }
                }
            } catch {
                print("Error setting object in Realm: \(error)")
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
    }

    public func clear(completion: ((Bool) -> Void)?) {
        realmQueue.async {
            do {
                let realm = try Realm()
                try realm.write {
                    realm.delete(realm.objects(Object.self))
                    DispatchQueue.main.async {
                        completion?(true)
                    }
                }
            } catch {
                print("Error clearing Realm: \(error)")
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
    }
    
    private func notifyObservers() {
        observers = observers.filter { $0.client != nil }
        for observerWrapper in observers {
            observerWrapper.observer(model)
        }
    }
    
    class ObserverWrapper {
        weak var client: AnyObject?
        let observer: Observer
        
        init(client: AnyObject, observer: @escaping Observer) {
            self.client = client
            self.observer = observer
        }
    }
}

#endif
