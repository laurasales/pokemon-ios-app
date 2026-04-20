//
//  SceneDelegate.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let presenter = ListPokemonPresenter()
        let listHeroesViewController = ListPokemonViewController()
        listHeroesViewController.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: listHeroesViewController)
        window.rootViewController = navigationController
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}

