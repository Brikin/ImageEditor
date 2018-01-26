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
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func invertColorsButtonTapped(_ sender: Any) {
        let newImage = imageView.image?.convertImageToBW()
        finalImages.append(newImage!)
        collectionView.reloadData()
    }
    
    @IBAction func mirrorImageButtonTapped(_ sender: Any) {
        let newImage = imageView.image?.imageRotatedByDegrees(degrees: 0, flip: true)
        finalImages.append(newImage!)
        collectionView.reloadData()
    }
    
    
    @IBAction func rotateButtonTapped(_ sender: Any) {
        let newImage = imageView.image?.imageRotatedByDegrees(degrees: 90, flip: false)
        finalImages.append(newImage!)
        collectionView.reloadData()
    }
    
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

extension ViewController: UICollectionViewDelegate {
    
    class Base {
        func save_image(img:UIImage) {
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(Base.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            print("Photo Saved Successfully")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = finalImages[indexPath.row]
        
        let questionController = UIAlertController(title: "What u wanna do?", message: nil, preferredStyle: .alert)
        
        questionController.addAction(UIAlertAction(title: "Reuse Image", style: .default, handler: {
            
            (action:UIAlertAction!) -> Void in
            self.imageView.image = image
            
        }))
        
        questionController.addAction(UIAlertAction(title: "Save", style: .destructive, handler: {
            
            (action:UIAlertAction!) -> Void in
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            
            self.collectionView.reloadData()
        }))
        
        questionController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            
            (action:UIAlertAction!) -> Void in
            
            self.finalImages.remove(at: indexPath.row)
            self.collectionView.reloadData()
            
        }))
        
        present(questionController, animated: true, completion: nil)
    }
    
}

extension UIImage {
    
    func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat.pi)
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat.pi
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        
        //   // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(degrees))
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap?.scaleBy(x: yFlip, y: -1.0)
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        
        bitmap?.draw(cgImage!, in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func convertImageToBW() -> UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!
        let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        
        return processedImage
    }
}














