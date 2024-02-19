//
//  ViewController.swift
//  PlaneDetection
//
//  Created by student on 2/19/24.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. fire off plane detection
        startPlaneDetection()
        
        // 2. 2d point
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        
        
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer)  {
        // user touch location
        let tapLocation = recognizer.location(in: arView)
        
        // raycast: 2D -> 3D
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            // 3d point (x, y, z)
            let worldPos = simd_make_float3(firstResult.worldTransform.columns.3)
            
            // create sphere
            let sphere = createSphere()
            
            // place the sphere
            placeSphereObject(object: sphere, at: worldPos)
            
        }
    }
    
    // func to fire off horizontal plane detection
    func startPlaneDetection() {
        
        arView.automaticallyConfigureSession = true
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
        
    }
    func createSphere() -> ModelEntity {
        // mesh
        let sphere = MeshResource.generateSphere(radius: 0.5)
        
        // assign material
        let sphereMaterial = SimpleMaterial(color: .brown, isMetallic: true)
        
        // model entity
        let sphereEntity = ModelEntity(mesh: sphere, materials: [sphereMaterial])
        
        return sphereEntity
    }
    
    func placeSphereObject(object:ModelEntity, at location: SIMD3<Float>) {
        
        // 1. anchor (locks a specific object at a specific location
        
        let objectAnchor = AnchorEntity(world: location)
        
        //2. tie 3d model to anchor
        objectAnchor.addChild(object)
        
        // 3. add anchor to scene
        arView.scene.addAnchor(objectAnchor)
        
    }
}
