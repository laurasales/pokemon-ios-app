//
//  ListPokemonViewController.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import UIKit

final class ListPokemonViewController: UIViewController {
    var mainView: ListPokemonView { return view as! ListPokemonView }

    var presenter: ListPokemonPresenterProtocol?
    var listPokemonProvider: ListPokemonAdapter?

    override func loadView() {
        view = ListPokemonView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listPokemonProvider = ListPokemonAdapter(tableView: mainView.pokemonTableView)
        mainView.pokemonTableView.delegate = self
        title = presenter?.screenTitle()
        // Set ui before triggering data load so the callback has a target
        presenter?.ui = self
        presenter?.getPokemon()
    }
}

extension ListPokemonViewController: ListPokemonUI {
    func update(pokemon: [Pokemon]) {
        listPokemonProvider?.pokemon = pokemon
    }
}

extension ListPokemonViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Navigate to Pokémon detail screen
    }
}
