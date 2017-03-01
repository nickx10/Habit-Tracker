//
//  HabitController.swift
//  Habit Tracker
//
//  Created by Nicholas Ellis on 2/14/17.
//  Copyright © 2017 Nicholas Ellis. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import UserNotifications
import FBSDKCoreKit
import FBSDKShareKit

class HabitController {
    
    static let shared = HabitController()
    
    // MARK: - Internal Properties
    
    fileprivate static let userNotificationIdentifier = "habitNotification"
    
    var habits: [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        return (try? CoreDataStack.context.fetch(request)) ?? []
    }
    
    //  MARK: - Habit Methods
    
    func addHabit(name: String, imageName: String, timeOfNotification: String, color: String) -> Habit {
        let habit = Habit(name: name, icon: imageName, timeOfNotification: timeOfNotification, color: color)
        saveToPersistentStore()
        return habit
    }
    
    //  MARK: - Persistence
    
    func saveToPersistentStore() {
        let moc = CoreDataStack.context
        do {
            try moc.save()
        } catch let error {
            NSLog("There was a problem saving to coredata: \(error)")
        }
    }
}

//  MARK: - Push Notifications

protocol HabitNotificationScheduler {
    func scheduleLocalNotifications(_ habit: Habit)
    func cancelLocalNotifications(_ habit: Habit)
}

extension HabitNotificationScheduler {
    
    func scheduleLocalNotifications(_ habit: Habit) {
        guard let name = habit.name else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "\(name)"
        content.body = "Finish Your Habit Today!"
        content.categoryIdentifier = "dailyHabit"
        //let dateComponents = calendar.dateComponents([.year, .month, .day, .hour], from: fireDate as Date)
        //let dateTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: habit.fireTimeOfNotification, repeats: true)
        let request = UNNotificationRequest(identifier: HabitController.userNotificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print("\(error?.localizedDescription)")
                print("\(error)")
                print("There was an error an Nick sucks")
            }
        }
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            for request in requests {
                print("************** \(request.trigger)")
            }
        }
    }
    
    func cancelLocalNotifications(_ habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [HabitController.userNotificationIdentifier])
    }
}
