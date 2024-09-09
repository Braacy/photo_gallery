//
//  ViewController.swift
//  photo-gallery-ios
//
//  Created by Владислав  on 07.07.2024.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPhotoPermission { (isAuthorized) in
                    if isAuthorized {
                        //Если авторизованы в галереи то выводим вытащенную картинку из галереи
                        self.imageView.image = self.loadImage()
                    }
                }
    }
    
    
    private func getPhotoPermission(comletion: @escaping (Bool) -> ()) {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            comletion(true)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            comletion(status == .authorized)
        }
    }
    
    private func loadImage() -> UIImage? {
            
            //PHImageManager выполняет роль сервиса, как мы видим это синглтон .default() подсвечивает нам это, manager отрабатывает методы requestImage или requesLivePhoto или requestAVAsset (video asset)
            let manager = PHImageManager.default()
            
            //PHAssetMediatype — enum который позваляет установить тип ассета (audio, video, image, unknown)
            //PHFetchOptions — predicate позволяет нам написать свой запрос на фильтрацию (filter) данных, sortDescriptors — сделать сортировку данных по полю
            //PHRFetchResult — массив хранящий объекты PHAsset
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions())
            
            //Создадим опциональный контейнер для хранения картинки
            var resultImage: UIImage? = nil
            
            //Делаем запрос на получение фотографии
            manager.requestImage(for: fetchResult.object(at: 0), targetSize: CGSize(width: 647, height: 375), contentMode: .aspectFill, options: requestOptions()) { (image, error) in
                
                //Распаковываем опционал
                guard let image = image else { return }
                
                resultImage = image
            }
            return resultImage
        }
    //PHFetchOptions — настройки извлечения (fetch), как будем извлекать? (в нашем случае  по 1 объект (fetchLimit) сортируем по дате создания (creationDate) — самая свежая дата)
    private func fetchOptions() -> PHFetchOptions {
        
        let fetchOptions = PHFetchOptions()
        
        //Вытаскиваем по лимиту только 1 фотографию. 0 — означает что лимита нет
        //fetchOptions.fetchLimit = 1
        
        //ascending = false означает что сортируем по возрастающей (от большего к меньшему), значит здесь самая свежая дата будет первым элементом выборки
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return fetchOptions
    }
    
    //Request Options (Настройки запроса), что будем извлекать (image, live photo, video)
        private func requestOptions() -> PHImageRequestOptions {
            
            //PHImageRequestOptions означает что будем вытаскивать image
            let requestOptions = PHImageRequestOptions()
            
            //Вытаскивать (delivery) изображение будем синхронно (тоесть последовательно)
            requestOptions.isSynchronous = true
            
            //PHImageRequestOptionsDeliveryMode — посволяет установить режим доставки (highQualityFormat — 1 объект самый лучший по качеству, opportunistic — несколько объектов, fastFormat — 1 объект самый оптимальный/быстрый)
            requestOptions.deliveryMode = .highQualityFormat
            
            return requestOptions
        }
    
}
