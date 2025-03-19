//
//  OraApp.swift
//  Ora
//
//  Created by Theresa Nguyen on 4/24/23.
//

import SwiftUI

@main
struct OraApp: App {
    @State private var didConfigureProject: Bool = false
    
    // MARK: - Main rendering function
    var body: some Scene {
        //configureProject()
        //return
        WindowGroup {
            Homepage()
        }
    }
    
    /// One time configuration when the app launches
    //private func configureProject() {
        //DispatchQueue.main.async {
            //if didConfigureProject == false {
                //didConfigureProject = true
            //}
        //}
    //}
}

/// Present auth error alert
func presentAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    var root = UIApplication.shared.windows.first?.rootViewController
    if let presenter = root?.presentedViewController {
        root = presenter
    }
    root?.present(alert, animated: true, completion: nil)
}
