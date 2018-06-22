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
    func removeAnnotation(with id: String)
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
            guard let coordinate = point.coordinate, let id = point.id else {
                return nil
            }

            return Annotation(id: id, coordinate: coordinate,
                              partnerId: point.logo?.partnerId)
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
            let coordinate = point.coordinate,
            let id = point.id,
            type != .move else {
            return
        }

        let annotation = Annotation(id: id, coordinate: coordinate,
                                    partnerId: point.partnerId)

        switch type {
        case .insert:
            consumer?.add([annotation])
        case .update:
            consumer?.reload(annotation)
        case .delete:
            consumer?.removeAnnotation(with: id)
        default:
            break
        }
    }
}
