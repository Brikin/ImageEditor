//
//  ViewController.swift
//  ImageEditor
//
//  Created by Ruslan on 24/01/2018.
//  Copyright © 2018 Ruslan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var finalImages = [UIImage]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func rotateButtonTapped(_ sender: Any) {
        
        finalImages.append(imageView.image!)
        collectionView.reloadData()
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func tapImageView(_ sender: UITapGestureRecognizer) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = selectedPhoto
        dismiss(animated: true, completion: nil)
    }


}

extension ViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return finalImages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        cell.backgroundColor = UIColor.darkGray
        cell.cellImage.image = finalImages[indexPath.row]
        return cell
    }
    
}
















