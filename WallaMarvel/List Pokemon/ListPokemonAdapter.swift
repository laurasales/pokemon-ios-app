//
//  ListPokemonAdapter.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import UIKit

final class ListPokemonAdapter: NSObject, UITableViewDataSource {
    var pokemon: [Pokemon] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    private let tableView: UITableView

    init(tableView: UITableView, pokemon: [Pokemon] = []) {
        self.tableView = tableView
        self.pokemon = pokemon
        super.init()
        self.tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pokemon.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListPokemonTableViewCell", for: indexPath) as! ListPokemonTableViewCell
        cell.configure(model: pokemon[indexPath.row])
        return cell
    }
}
