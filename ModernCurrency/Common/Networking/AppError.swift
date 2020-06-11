//
//  AppError.swift
//  ModernCurrency
//
//  Created by TuffyTian on 2020/6/11.
//  Copyright © 2020 Tengfei Tian. All rights reserved.
//

import Foundation

enum AppError: Error {
    case responseError(error: URLError)
    case other(Error)
}
