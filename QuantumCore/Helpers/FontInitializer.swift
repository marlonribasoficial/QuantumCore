//
//  FontInitializer.swift
//  SubatomicExperience
//
//  Created by Marlon Ribas on 25/02/26.
//

import CoreText
import Foundation

func registerFont(named fontName: String) {
    guard
        let url = Bundle.main.url(forResource: fontName, withExtension: nil),
        CTFontManagerRegisterFontsForURL(url as CFURL, CTFontManagerScope.process, nil)
    else {
        print(":x: Failed to load font:", fontName)
        return
    }
}
