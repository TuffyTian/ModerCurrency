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
    case parseError
    case other(Error)
}

extension AppError {
    var description: String {
        switch self {
        case .parseError:
            return "can't parese data."
        case .responseError(let error):
            return error.localizedDescription
        case .other(_):
            return "unkonwn error."
        }
    }
}
