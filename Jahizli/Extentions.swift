//
//  Extentions.swift
//  Jahizli
//
//  Created by Abdullah Al Dhabaib on 10/11/17.
//  Copyright © 2017 FekaTech. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    var jpeg: Data? {
        return UIImageJPEGRepresentation(self, 1)   // QUALITY min = 0 / max = 1
    }
    var png: Data? {
        return UIImagePNGRepresentation(self)
    }
}

extension Data {
    var uiImage: UIImage? {
        return UIImage(data: self)
    }
}
