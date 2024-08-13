//
//  DBManager.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/6.
//

import Foundation
import SQLite

enum DBDatabaseError: Error {
    case connectionError
    case createTableError
    case insertError
    case updateError
}

typealias PhotoInfoTuple = (name: String, imageData: Data, movData: Data?)

class DBManager {
    
    let timeRow = Expression<String>("timeRow")
    let createTime = Expression<String>("createTime")
    let updateTime = Expression<String>("updateTime")
    let itemCount = Expression<Int>("itemCount")
    let totalByte = Expression<Int>("totalByte")
    
    let shootDate = Expression<String>("shootDate")
    let shootTime = Expression<String>("shootTime")
    let modifyTime = Expression<String>("modifyTime")
    let photoName = Expression<String>("photoName")
    let photoData = Expression<Data>("photoData")
    let liveMovData = Expression<Data?>("liveMovData")
    let bytes = Expression<Int>("bytes")
    
    static let manager = DBManager()
    
    private let dbName = "TakePhoto.db"
    
    private let timeTable = Table("timeTable")
    private let photoTable = Table("photoTable")
    
    var db: Connection?
    
    private init() {
        objc_sync_enter(self)
        openDataBase()
        try? createTimeTable()
        try? createSubTable()
        objc_sync_exit(self)
    }
    
    private func openDataBase() {
        let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/" + dbName
        
        if !FileManager.default.fileExists(atPath: dbPath) {
            FileManager.default.createFile(atPath: dbPath, contents: nil)
        }
        db = try? Connection(dbPath)
        db?.userVersion = 1
        db?.busyTimeout = 5
    }
    
    private func createTimeTable() throws {
        guard let db else {
            throw DBDatabaseError.connectionError
        }
        do {
            try db.run(timeTable.create(ifNotExists: true, withoutRowid: false, block: { builder in
                builder.column(timeRow, primaryKey: true)
                builder.column(createTime)
                builder.column(itemCount)
                builder.column(updateTime)
                builder.column(totalByte)
            }))
        } catch _ {
            throw DBDatabaseError.createTableError
        }
    }
    
    private func createSubTable() throws {
        guard let db else {
            throw DBDatabaseError.connectionError
        }
        do {
            try db.run(photoTable.create(ifNotExists: true, withoutRowid: false, block: { builder in
                builder.column(shootDate)
                builder.column(shootTime, primaryKey: true)
                builder.column(modifyTime)
                builder.column(photoName)
                builder.column(photoData)
                builder.column(liveMovData)
                builder.column(bytes)
            }))
        } catch _ {
            throw DBDatabaseError.createTableError
        }
    }
    
    static func insert(photo datas: PhotoInfoTuple...) {
        DispatchQueue.global().async {
            guard let db = manager.db else {
                return
            }
            var dateItemCount = 0
            var dateTotalByte = 0
            let queryTotalCount = manager.timeTable.filter(manager.timeRow == Date().toString())
            if let item = try? db.pluck(queryTotalCount) {
                dateItemCount = item[manager.itemCount]
                dateTotalByte = item[manager.totalByte]
            }else{
                let dateInsert = manager.timeTable.insert(manager.timeRow <- Date().toString(),
                                                          manager.createTime <- "\(Date().timeIntervalSince1970)",
                                                          manager.updateTime <- "\(Date().timeIntervalSince1970)",
                                                          manager.itemCount <- 0,
                                                          manager.totalByte <- 0)
                _ = try? db.run(dateInsert)
            }
            
            for data in datas {
                let insert = manager.photoTable.insert(
                    manager.shootDate <- Date().toString(),
                    manager.shootTime <- "\(Date().timeIntervalSince1970)",
                    manager.modifyTime <- "\(Date().timeIntervalSince1970)",
                    manager.photoName <- data.name,
                    manager.photoData <- data.imageData,
                    manager.liveMovData <- data.movData,
                    manager.bytes <- (data.imageData.count + (data.movData?.count ?? 0))
                )
                do {
                    try db.run(insert)
                    dateTotalByte += (data.imageData.count + (data.movData?.count ?? 0))
                    dateItemCount += 1
                } catch _ { }
            }
            let dateUpdate = manager.timeTable.filter(manager.timeRow == Date().toString()).update(
                manager.itemCount <- dateItemCount,
                manager.totalByte <- dateTotalByte
            )
            _ = try? db.run(dateUpdate)
        }
    }
    
    static func update(_ name: String, data: Data) {
        DispatchQueue.global().async {
            guard let db = manager.db else {
                return
            }
            
            let update = manager.photoTable.filter(manager.photoName == name).update(
                manager.photoData <- data,
                manager.modifyTime <- "\(Date().timeIntervalSince1970)",
                manager.bytes <- data.count
            )
            _ = try? db.run(update)
            let dateQuery = manager.photoTable.filter(manager.photoName == name)
            if let item = try? db.pluck(dateQuery) {
                let date = item[manager.shootDate]
                let total = manager.photoTable.filter(manager.shootDate == date)
                if let items = try? db.prepare(total) {
                    var dateTotalByte = 0
                    for item in items {
                        dateTotalByte += item[manager.bytes]
                    }
                    let updateQuery = manager.timeTable.filter(manager.timeRow == date).update(
                        manager.updateTime <- "\(Date().timeIntervalSince1970)",
                        manager.totalByte <- dateTotalByte
                    )
                    _ = try? db.run(updateQuery)
                }
            }
        }
    }
    
    static func delete(_ names: String...) {
        DispatchQueue.global().async {
            guard let db = manager.db else { return }
            for name in names {
                var date = ""
                let dateQuery = manager.photoTable.filter(manager.photoName == name)
                if let item = try? db.pluck(dateQuery) {
                    date = item[manager.shootDate]
                }
                let delete = manager.photoTable.filter(manager.photoName == name).delete()
                if let success = try? db.run(delete), success > 0 {
                    let total = manager.photoTable.filter(manager.shootDate == date)
                    if let items = try? db.prepare(total) {
                        var dateTotalByte = 0
                        var count = 0
                        for item in items {
                            dateTotalByte += item[manager.bytes]
                            count += 1
                        }
                        if count != 0 {
                            let updateQuery = manager.timeTable.filter(manager.timeRow == date).update(
                                manager.updateTime <- "\(Date().timeIntervalSince1970)",
                                manager.totalByte <- dateTotalByte,
                                manager.itemCount <- count
                            )
                            _ = try? db.run(updateQuery)
                        }else{
                            let updateQuery = manager.timeTable.filter(manager.timeRow == date).delete()
                            _ = try? db.run(updateQuery)
                        }
                    }
                }
            }
        }
    }
    
    static func delete(_ names: [String]) {
        DispatchQueue.global().async {
            guard let db = manager.db else { return }
            for name in names {
                var date = ""
                let dateQuery = manager.photoTable.filter(manager.photoName == name)
                if let item = try? db.pluck(dateQuery) {
                    date = item[manager.shootDate]
                }
                let delete = manager.photoTable.filter(manager.photoName == name).delete()
                if let success = try? db.run(delete), success > 0 {
                    let total = manager.photoTable.filter(manager.shootDate == date)
                    if let items = try? db.prepare(total) {
                        var dateTotalByte = 0
                        var count = 0
                        for item in items {
                            dateTotalByte += item[manager.bytes]
                            count += 1
                        }
                        if count != 0 {
                            let updateQuery = manager.timeTable.filter(manager.timeRow == date).update(
                                manager.updateTime <- "\(Date().timeIntervalSince1970)",
                                manager.totalByte <- dateTotalByte,
                                manager.itemCount <- count
                            )
                            _ = try? db.run(updateQuery)
                        }else{
                            let updateQuery = manager.timeTable.filter(manager.timeRow == date).delete()
                            _ = try? db.run(updateQuery)
                        }
                    }
                }
            }
        }
    }
    
    static func select(with date: String) -> [PhotoDataModel] {
        guard let db = manager.db else { return [] }
        var array: [PhotoDataModel] = []
        
        if let items = try? db.prepare(manager.photoTable.filter(manager.shootDate == date)) {
            for item in items {
                do {
                    let photoName = try item.get(manager.photoName)
                    let shootDate = try item.get(manager.shootDate)
                    let shootTime = try item.get(manager.shootTime)
                    let modifyTime = try item.get(manager.modifyTime)
                    let photoData = try item.get(manager.photoData)
                    let liveMovData = try item.get(manager.liveMovData)
                    let bytes = try item.get(manager.bytes)
                    let dataModel = PhotoDataModel(photoName: photoName,
                                                   shootDate: shootDate,
                                                   shootTime: shootTime,
                                                   modifyTime: modifyTime,
                                                   photoData: photoData,
                                                   movData: liveMovData,
                                                   bytes: bytes)
                    array.append(dataModel)
                } catch _ { }
            }
        }
        return array.sorted(by: { $0.shootTime < $1.shootTime })
    }
    
    static func selectTimeList() -> [PhotoDateModel] {
        guard let db = manager.db else { return [] }
        var array: [PhotoDateModel] = []
        
        if let items = try? db.prepare(manager.timeTable) {
            for item in items {
                do {
                    let timeRow = try item.get(manager.timeRow)
                    let createTime = try item.get(manager.createTime)
                    let updateTime = try item.get(manager.updateTime)
                    let itemCount = try item.get(manager.itemCount)
                    let totalBytes = try item.get(manager.totalByte)
                    let dateModel = PhotoDateModel(timeRow: timeRow, createTime: createTime, updateTime: updateTime, itemCount: itemCount, totalBytes: totalBytes)
                    array.append(dateModel)
                } catch _ { }
            }
        }
        return array.sorted(by: { $0.timeRow < $1.timeRow })
    }
}

extension DBManager {
    
    struct PhotoDateModel: Hashable {
        var timeRow: String
        var createTime: String
        var updateTime: String
        var itemCount: Int
        var totalBytes: Int
    }
    
    struct PhotoDataModel: Hashable {
        var photoName: String
        var shootDate: String
        var shootTime: String
        var modifyTime: String
        var photoData: Data
        var movData: Data?
        var bytes: Int
    }
}
