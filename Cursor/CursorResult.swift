//
//  CursorResult.swift
//  Cursor
//
//  Created by Apple on 29.03.2018.
//  Copyright © 2018 iON1k. All rights reserved.
//

public enum CursorResult<Item> {
    case notLoaded
    case item(Item)
}
