//
//  ImageLoader.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 22/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import UIKit
import CoreData

private let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
private let modifiedHeader = "Last-Modified"

class ImageLoader {

    typealias CompletionBlock = (UIImage?) -> ()

    private let network: NetworkManager = .shared
    private let managedObjectContext = CoreDataStack.shared.generatePrivateContext()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE', 'dd' 'MMM' 'YYYY' 'HH:mm:ss' GMT'"
        return formatter
    }()

    func loadImage(with partnerId: String, completion: @escaping CompletionBlock) {
        managedObjectContext.perform {
            let request = NSFetchRequest<PartnerLogo>()
            request.entity = PartnerLogo.entity()
            request.predicate = NSPredicate(format: "partnerId == %@", partnerId as NSString)

            guard let logo = (try? request.execute())?.first,
                let filename = logo.filename else {
                return
            }

            if let localData = self.localImageData(for: filename) {
                self.checkImageChanged(for: logo, localData: localData,
                                       completion: completion)
            } else {
                self.loadImageData(for: logo, localData: nil, completion: completion)
            }
        }
    }

    private func localImageData(for fileName: String) -> Data? {
        return try? Data(contentsOf: cachesUrl.appendingPathComponent(fileName))
    }

    private func loadImageData(for logo: PartnerLogo, localData: Data?, completion: @escaping CompletionBlock) {
        let filename = logo.filename ?? ""
        let builder = ImageRequestBuilder.load(filename: filename)
        network.performRequest(with: builder, success: { [weak self, dateFormatter] (resp: NetworkResponse<Data>) in
            if let headerValue = resp.headers[modifiedHeader],
                let date = dateFormatter.date(from: headerValue) {
                self?.save(date, to: logo)
            }
            DispatchQueue.global(qos: .background).async {
                self?.processImageLoaded(resp.data, filename: filename, completion: completion)
            }
        }, failure: { _ in
            completion(UIImage(data: localData ?? Data()))
        })
    }

    private func checkImageChanged(for logo: PartnerLogo, localData: Data,
                                   completion: @escaping CompletionBlock) {
        let builder = ImageRequestBuilder.check(filename: logo.filename ?? "")
        network.performRequest(with: builder, success: { [weak self, dateFormatter] (resp: NetworkResponse<Data>) in
            guard let headerValue = resp.headers[modifiedHeader],
                let date = dateFormatter.date(from: headerValue), date != logo.dateLoaded else {
                    completion(UIImage(data: localData))
                return
            }
            self?.loadImageData(for: logo, localData: localData, completion: completion)
        }, failure: { _ in
            completion(UIImage(data: localData))
        })
    }

    private func save(_ loadedDate: Date, to logo: PartnerLogo) {
        managedObjectContext.perform { [unowned managedObjectContext] in
            logo.dateLoaded = loadedDate
            try? managedObjectContext.save()
        }
    }

    private func processImageLoaded(_ data: Data, filename: String, completion: @escaping CompletionBlock) {
        guard let image = UIImage(data: data, scale: UIScreen.main.scale) else {
            return
        }
        let size = CGSize(width: 25, height: 25)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        completion(resizedImage)

        if let resizedImage = resizedImage {
            try? UIImagePNGRepresentation(resizedImage)?.write(to: cachesUrl.appendingPathComponent(filename))
        }
    }
}
