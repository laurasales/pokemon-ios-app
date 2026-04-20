//
//  ListPokemonTableView.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import UIKit

final class ListPokemonView: UIView {
    enum Constant {
        static let estimatedRowHeight: CGFloat = 120
    }

    let pokemonTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ListPokemonTableViewCell.self, forCellReuseIdentifier: "ListPokemonTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constant.estimatedRowHeight
        return tableView
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubviews()
        addConstraints()
    }

    private func addSubviews() {
        addSubview(pokemonTableView)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            pokemonTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pokemonTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pokemonTableView.topAnchor.constraint(equalTo: topAnchor),
            pokemonTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
