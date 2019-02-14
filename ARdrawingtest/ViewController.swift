//
//  ViewController.swift
//  ARdrawingtest
//
//  Created by sijon thapa on 28/02/2018.
//  Copyright © 2018 sijon test. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var draw: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration() //#1 after creating IBoutlet
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints] //#3 making debug options available
        self.sceneView.showsStatistics = true //#4 shows the grey stats below
        self.sceneView.session.run(configuration) //#2 making sure it runs
        //#4 Add alert "privacy:camera usage"...in info plist 3:34
        
        //#6 And for the delegate function to be called when the scene is rendered... you need to declare the sceneView delegate to be self
        self.sceneView.delegate = self
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //#5 : adding ARSCNViewDelegate delegate beside view control at the top....WE can acess this fucntion!!!
    //this is the render function that is going to help us make the drawing app...This delegate function gets called everytime the view is about to render a scene....essentially its like a never ending loop***
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
       // print("rendering")
        //#7 to calculate the position of eveyr rendered scene you need the point of view of every scene...to calculate that...
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform // to get the transform matrix...
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33) // from the transform we are extrating orientation...later making this negative so it can be contunioulsy positive..
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let currentPostionofCamera = orientation + location
        //here we created draw outlet the highlight thing can deceted when the user is holding the button..
        DispatchQueue.main.async { // adding the dispatchQueue remvoes the old pointer and adds a new one...
            if self.draw.isHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = currentPostionofCamera
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                print("draw button is being pressed") // this helps you draw a shpere whent he draw button is being pressed!
            } else  {
                let pointer = SCNNode(geometry: SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.01/2)) //this is the pointer where you see where the app is...Here we created a box with the right dimensions and that dividing it by half creates a illusion that its a sphere...this way we enable to delete the boxes and keep the sphere
                pointer.name = "pointer"
                pointer.position = currentPostionofCamera //this will be indicating that this is where the user will be drawing....
                
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "pointer" {
                        node.removeFromParentNode() // here we remove the box and keep the sphere..
                    }
                   // node.removeFromParentNode() // Current bug is that it removes every single node....hence we need to distingusih between parent node and the child node....LATER....this was comented out and placed within the box so it removes the box and not the sphere.....
                })
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.position = currentPostionofCamera
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            }
            //print(orientation.x, orientation.y, orientation.z)
        }
       
    }

}

//with this function now the binary operator is able to take two SCNVector3(location + orientation) operator and add them....
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
