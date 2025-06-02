//
//  ARViewController.swift
//  ToDoFIRE
//
//  Created by Zhanibek Bakyt on 02.06.2025.
//

import UIKit
import ARKit
import SceneKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)

        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true

        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.red
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0, 0, -0.5)

        sceneView.scene.rootNode.addChildNode(boxNode)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }
}
