//
//  UICollectionViewLayout+Layouts.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.03.2026.
//

import UIKit

extension UICollectionViewLayout {
    static func lessonLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .estimated(110))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .estimated(110)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 16,
                                      leading: 16,
                                      bottom: 16,
                                      trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static func studentLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .estimated(80))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .estimated(80)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 16,
                                      leading: 16,
                                      bottom: 16,
                                      trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static func homeworkLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .estimated(100))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .estimated(100)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 16,
                                      leading: 16,
                                      bottom: 16,
                                      trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static func paymentLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(110)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize,
                                                     subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8,
                                                        leading: 16,
                                                        bottom: 8,
                                                        trailing: 16)
        section.interGroupSpacing = 8
        return UICollectionViewCompositionalLayout(section: section)
    }
}
