//
//  CoreDataStack.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

    static let shared = CoreDataStack()

    let persistentStoreCoordinator: NSPersistentStoreCoordinator
    let mainQueueContext: NSManagedObjectContext

    private init() {
        let managedObjectModel = NSManagedObjectModel(contentsOf: Configuration.Storage.modelUrl)!
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        mainQueueContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        setupPersistentStore()
        mainQueueContext.persistentStoreCoordinator = persistentStoreCoordinator
        subscribeContextToChanges(mainQueueContext)
    }

    func generatePrivateContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        subscribeContextToChanges(context)
        return context
    }

    private func setupPersistentStore() {
        if let url = FileManager.default
            .urls(for: .libraryDirectory, in: .userDomainMask).first?
            .appendingPathComponent(Configuration.Storage.storeFilename) {
            _ = try? persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                   configurationName: nil,
                                                                   at: url,
                                                                   options: nil)
        } else {
            //somehow we can't find directory to write, using in-memory storage instead
            _ = try? persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                                                   configurationName: nil,
                                                                   at: nil,
                                                                   options: nil)
        }
    }

    private func subscribeContextToChanges(_ context: NSManagedObjectContext) {
        let callback: (Notification) -> () = { [weak context] notification in
            guard (notification.object as AnyObject?) !== context else {
                return
            }
            context?.perform {
                context?.mergeChanges(fromContextDidSave: notification)
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: nil, queue: nil, using: callback)
    }

//    private func fillup
}
