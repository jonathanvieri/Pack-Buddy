//
//  Constants.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 19/09/24.
//

import Foundation

struct K {
    
    // Custom Cell Constants
    static let packingNibName = "PackingCell"
    static let packingCellIdentifier = "CustomPackingCell"
    
    static let addPackingNibName = "PackingCollectionViewCell"
    static let addPackingCellIdentifier = "AddPackingCell"
    
    static let itemNibName = "ItemCell"
    static let itemCellIdentifier = "CustomItemCell"
    
    static let addItemNibName = "AddItemCell"
    static let addItemCellIdentifier = "CustomAddItemCell"
    
    static let symbolNibName = "SymbolCollectionViewCell"
    static let symbolCellIdentifier = "SymbolCell"
    
    // Custom color palette
    struct MainColors {
        static let background = "MainBackground"
        static let white = "MainWhite"
        static let black = "MainBlack"
        static let gray = "MainGray"
        static let grayLower = "MainGrayLowerOpacity"
    }
    
    struct SecondaryColors {
        static let white = "SecondaryWhite"
        static let gray = "SecondaryGray"
    }
    
    struct AlternativeColors {
        static let gray = "AlternateGray"
    }
    
    struct AdditionalColors {
        static let red = "AdditionalRed"
        static let orange = "AdditionalOrange"
        static let yellow = "AdditionalYellow"
        static let green = "AdditionalGreen"
        static let blue = "AdditionalBlue"
        static let pink = "AdditionalPink"
        static let purple = "AdditionalPurple"
    }
}
