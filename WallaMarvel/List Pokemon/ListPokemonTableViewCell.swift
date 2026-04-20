//
//  ListPokemonTableViewCell.swift
//  WallaMarvel
//
//  Created by Laura Sales Martínez on 20/4/26.
//

import UIKit
import Kingfisher

final class ListPokemonTableViewCell: UITableViewCell {
    private let pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let pokemonName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        addSubview(pokemonImageView)
        addSubview(pokemonName)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            pokemonImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            pokemonImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 80),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 80),
            pokemonImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            pokemonName.leadingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor, constant: 12),
            pokemonName.topAnchor.constraint(equalTo: pokemonImageView.topAnchor, constant: 8),
        ])
    }

    func configure(model: Pokemon) {
        pokemonImageView.kf.setImage(with: model.imageURL)
        pokemonName.text = model.name
    }
}
