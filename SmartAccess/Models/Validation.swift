//
//  Validation.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 03/04/25.
//

import Foundation

struct Validation {
    var valid: Bool?
    var error: String?
    init(valid: Bool, error:String) {
        self.valid = valid
        self.error = error
    }
}
