//
//  AnnotationProvider.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import MapKit
import CoreData

protocol AnnotationConsumer: class {
    func add(_ annotations: [Annotation])
    func remove(_ annotation: Annotation)
    func reload(_ annotation: Annotation)
}

class AnnotationProvider: NSObject {
    private let cacheName = UUID().uuidString
    private let managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.mainQueueContext
    private lazy var frc = self.buildFetchedResultsController()

    weak var consumer: AnnotationConsumer?

    func start() {
        try? frc.performFetch()
        consumer?.add(frc.fetchedObjects?.compactMap { point in
            guard let coordinate = point.coordinate else {
                return nil
            }

            return Annotation(coordinate: coordinate,
                              imageName: point.logo?.filename)
        } ?? [])
    }

    private func buildFetchedResultsController() -> NSFetchedResultsController<Point> {
        let fetchRequest = NSFetchRequest<Point>()
        fetchRequest.entity = Point.entity()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: managedObjectContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: cacheName)
        frc.delegate = self
        return frc
    }
}

extension AnnotationProvider: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let point = anObject as? Point,
            let coordinate = point.coordinate, type != .move else {
            return
        }

        let annotation = Annotation(coordinate: coordinate,
                                    imageName: point.logo?.filename)

        switch type {
        case .insert:
            consumer?.add([annotation])
        case .update:
            consumer?.reload(annotation)
        case .delete:
            consumer?.remove(annotation)
        default:
            break
        }
    }
}
