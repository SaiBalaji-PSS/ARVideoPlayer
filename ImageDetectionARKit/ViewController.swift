//
//  ViewController.swift
//  ImageDetectionARKit
//
//  Created by Sai Balaji on 31/08/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController{

    @IBOutlet var sceneView: ARSCNView!
    private var videoPlayer = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
       
        // Set the scene to the view
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func createPlane(anchor: ARImageAnchor,node: SCNNode,name: String){
        
        
        
        
        let planeGeometry = SCNPlane(width: 0.6, height: 0.3)
   
        planeGeometry.materials.first?.isDoubleSided = true
        
        
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y + 0.2, anchor.transform.columns.3.z - 0.2)
//        planeNode.eulerAngles = SCNVector3(x: Float(Double.pi / 2), y: 0.0, z: 0.0)
        
        
        self.videoPlayer = AVPlayer(url: Bundle.main.url(forResource: name.lowercased(), withExtension: "mp4")!)
        planeGeometry.materials.first?.diffuse.contents = self.videoPlayer
        
        self.videoPlayer.play()
        
        
        
        node.addChildNode(planeNode)
        
        
        let thumbNailBoxGeometry = SCNBox(width: 0.3, height: 0.6, length: 0.02, chamferRadius: 0.08)
        
                    if name == "yourname"{
                        thumbNailBoxGeometry.materials.first?.diffuse.contents = UIImage(named: "yournamE")
                    }
        else if name.lowercased() == "veg"{
                        thumbNailBoxGeometry.materials.first?.diffuse.contents = UIImage(named: "veg")
                    }
        else if name == "prr"{
            thumbNailBoxGeometry.materials.first?.diffuse.contents = UIImage(named: "pr")
        }
        
       
        let thumbNailNode = SCNNode(geometry: thumbNailBoxGeometry)
        thumbNailNode.position = SCNVector3(x: planeNode.position.x - 0.2, y: planeNode.position.y - 0.02, z: planeNode.position.z + 0.2)
        thumbNailNode.scale = SCNVector3(0.2, 0.2, 0.2)
        thumbNailNode.runAction(SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 5)))
        node.addChildNode(thumbNailNode)
        
        
    }

    

}



extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else{return }
        print(imageAnchor.referenceImage.name)
        if let name = imageAnchor.referenceImage.name{
            self.createPlane(anchor: imageAnchor, node: node,name: name)
        }
      
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let pov = self.sceneView.pointOfView{
            let isVisibleToCamera = sceneView.isNode(node, insideFrustumOf: pov)
            
            if !isVisibleToCamera{
                videoPlayer.pause()
                videoPlayer.replaceCurrentItem(with: nil)
                self.sceneView.session.remove(anchor: anchor)
            }
            else{
                //visible to camera
                if let imageAnchor = anchor as? ARImageAnchor{
                    if imageAnchor.isTracked == false{
                        self.sceneView.session.remove(anchor: imageAnchor)
                    }
                }
                
            }
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("REMOVED")
        self.videoPlayer.replaceCurrentItem(with: nil)
        self.sceneView.session.remove(anchor: anchor)
    }
    
}

