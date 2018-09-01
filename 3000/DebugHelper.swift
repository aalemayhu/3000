//
//  DebugHelper.swift
//  3000
//
//  Created by Live coding on 01/09/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

func debug_print(_ msg: String) {
    #if DEBUG
    print("DEBUG: \(msg)")
    #endif
}
