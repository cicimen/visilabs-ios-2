//
//  EventViewController.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 22.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Eureka
import CleanyModal
import VisilabsIOSNew
import Euromsg

enum VisilabsEventType: String, CaseIterable {
    case login = "Login"
    case loginWithExtraParameters = "Login with Extra Parameters"
    case signUp  = "Sign Up"
    case pageView = "Page View"
    case productView = "Product View"
    case productAddToCart = "Product Add to Cart"
    case productPurchase = "Product Purchase"
    case productCategoryPageView = "Product Category Page View"
    case inAppSearch = "In App Search"
    case bannerClick = "Banner Click"
    case addToFavorites = "Add to Favorites"
    case removeFromFavorites = "Remove from Favorites"
    case sendingCampaignParameters = "Sending Campaign Parameters"
    case pushMessage = "Push Message"
}

class EventViewController: FormViewController {

    let inAppNotificationIds = ["mini": 491,
                                "full": 485,
                                "image_text_button": 490,
                                "full_image": 495,
                                "nps": 492,
                                "image_button": 489,
                                "smile_rating": 494,
                                "mailsubsform": 417,
                                "alert": 540,
                                "nps_with_numbers": 493,
                                "spintowin": 130]

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }

    private func initializeForm() {
        form
        +++ getCommonEventsSection()
        +++ getInAppSection()
    }

    private func getCommonEventsSection() -> Section {
        let section = Section("Common Events".uppercased(with: Locale(identifier: "en_US")))
        section.append(TextRow("exVisitorId") {
            $0.title = "exVisitorId"
            $0.value = visilabsProfile.userKey
            $0.cell.textField.autocapitalizationType = .none
        })
        section.append(TextRow("email") {
            $0.title = "email"
            $0.value = visilabsProfile.userEmail
            $0.cell.textField.autocapitalizationType = .none
        })

        for eventType in VisilabsEventType.allCases {
            section.append(ButtonRow {
                $0.title = eventType.rawValue
            }
            .onCellSelection { _, _ in
                self.customEvent(eventType)
            })
        }
        return section
    }

    private func  getInAppSection() -> Section {
        let section = Section("In App Notification Types".uppercased(with: Locale(identifier: "en_US")))
        for visilabsInAppNotificationType in VisilabsInAppNotificationType.allCases {
            section.append(ButtonRow {
                let notId = String(inAppNotificationIds[visilabsInAppNotificationType.rawValue]!)
                $0.title = visilabsInAppNotificationType.rawValue + " ID: " + notId
            }
            .onCellSelection { _, _ in
                self.inAppEvent(visilabsInAppNotificationType)
            })
        }
        return section
    }

    private func inAppEvent(_ visilabsInAppNotificationType: VisilabsInAppNotificationType) {
        var properties = [String: String]()
        properties["OM.inapptype"] = visilabsInAppNotificationType.rawValue
        Visilabs.callAPI().customEvent("InAppTest", properties: properties)
    }

    private func showModal(title: String, message: String) {
        let styleSettings = CleanyAlertConfig.getDefaultStyleSettings()
        styleSettings[.cornerRadius] = 18
        let alertViewController = CleanyAlertViewController(title: title,
                                                            message: message,
                                                            preferredStyle: .alert,
                                                            styleSettings: styleSettings)
        alertViewController.addAction(title: "Dismiss", style: .default)
        self.present(alertViewController, animated: true, completion: nil)
    }

    private func getRandomProductValues() -> RandomProduct {
        let randomProductCode1 = Int.random(min: 1, max: 1000)
        let randomProductCode2 = Int.random(min: 1, max: 1000, except: [randomProductCode1])
        let randomProductPrice1 = Double.random(in: 10..<10000)
        let randomProductPrice2 = Double.random(in: 10..<10000)
        let randomProductQuantity1 = Int.random(min: 1, max: 10)
        let randomProductQuantity2 = Int.random(min: 1, max: 10)
        let randomInventory = Int.random(min: 1, max: 100)
        let randomBasketID = Int.random(min: 1, max: 10000)
        let randomOrderID = Int.random(min: 1, max: 10000)
        let randomCategoryID = Int.random(min: 1, max: 100)
        let randomNumberOfSearchResults = Int.random(min: 1, max: 100)
        let randomBannerCode = Int.random(min: 1, max: 100)
        let genders: [String] = ["f", "m"]
        let randomGender = genders[Int.random(min: 0, max: 1)]

        return RandomProduct(randomProductCode1: randomProductCode1,
                             randomProductCode2: randomProductCode2,
                             randomProductPrice1: randomProductPrice1,
                             randomProductPrice2: randomProductPrice2,
                             randomProductQuantity1: randomProductQuantity1,
                             randomProductQuantity2: randomProductQuantity2,
                             randomInventory: randomInventory,
                             randomBasketID: randomBasketID,
                             randomOrderID: randomOrderID,
                             randomCategoryID: randomCategoryID,
                             randomNumberOfSearchResults: randomNumberOfSearchResults,
                             randomBannerCode: randomBannerCode,
                             genders: genders,
                             randomGender: randomGender)
    }

    //swiftlint:disable cyclomatic_complexity
    //swiftlint:disable function_body_length
    //TO_DO: favorites'lerde price göndermek gerekiyor mu?
    //TO_DO: örnekte OM parametreleri mi olsun, utm mi?
    //TO_DO: utm parametreleri geliyorsa bunları da targetpreferences içine kaydetmeli miyiz?
    //TO_DO: birthday ve gender formatı doğru mu?
    private func customEvent(_ eventType: VisilabsEventType) {
        let exVisitorId: String = ((self.form.rowBy(tag: "exVisitorId") as TextRow?)!.value
                                    ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email: String = ((self.form.rowBy(tag: "email") as TextRow?)!.value
                                ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var properties = [String: String]()
        let randomValues = getRandomProductValues()

        switch eventType {
        case .login, .signUp, .loginWithExtraParameters:
            properties["OM.sys.TokenID"] = visilabsProfile.appToken //"Token ID to use for push messages"
            properties["OM.sys.AppID"] = visilabsProfile.appAlias // "App ID to use for push messages"
            if exVisitorId.isEmpty {
                self.showModal(title: "Warning", message: "exVisitorId can not be empty")
                return
            } else {
                visilabsProfile.userKey = exVisitorId
                visilabsProfile.userEmail = email
                DataManager.saveVisilabsProfile(visilabsProfile)
                if eventType == .login {
                    Visilabs.callAPI().login(exVisitorId: visilabsProfile.userKey, properties: properties)
                } else if eventType == .signUp {
                    Visilabs.callAPI().signUp(exVisitorId: visilabsProfile.userKey, properties: properties)
                } else {
                    properties["OM.vseg1"] = "seg1val" // Visitor Segment 1
                    properties["OM.vseg2"] = "seg2val" // Visitor Segment 2
                    properties["OM.vseg3"] = "seg3val" // Visitor Segment 3
                    properties["OM.vseg4"] = "seg4val" // Visitor Segment 4
                    properties["OM.vseg5"] = "seg5val" // Visitor Segment 5
                    properties["OM.bd"] = "1977-03-15" // Birthday
                    properties["OM.gn"] = randomValues.randomGender // Gender
                    properties["OM.loc"] = "Bursa" // Location
                    Visilabs.callAPI().login(exVisitorId: visilabsProfile.userKey, properties: properties)
                }
                Euromsg.setEuroUserId(userKey: visilabsProfile.userKey)
                Euromsg.setEmail(email: visilabsProfile.userEmail, permission: true)
                return
            }
        case .pageView:
            Visilabs.callAPI().customEvent("Page Name", properties: [String: String]())
            return
        case .productView:
            properties["OM.pv"] = "\(randomValues.randomProductCode1)" // Product Code
            properties["OM.pn"] = "Name-\(randomValues.randomProductCode1)" //Product Name
            properties["OM.ppr"] = randomValues.randomProductPrice1.formatPrice() // Product Price
            properties["OM.pv.1"] = "Brand" //Product Brand
            properties["OM.inv"] = "\(randomValues.randomInventory)" //Number of items in stock
            Visilabs.callAPI().customEvent("Product View", properties: properties)
            return
        case .productAddToCart:
            properties["OM.pbid"] = "\(randomValues.randomBasketID)" // Basket ID
            properties["OM.pb"] = "\(randomValues.randomProductCode1);\(randomValues.randomProductCode2)"
            //Product1 Code;Product2 Code
            properties["OM.pu"] = "\(randomValues.randomProductQuantity1);\(randomValues.randomProductQuantity2)"
            // Product1 Quantity;Product2 Quantity
            let price1 = (randomValues.randomProductPrice1 * Double(randomValues.randomProductQuantity1)).formatPrice()
            let price2 = (randomValues.randomProductPrice2 * Double(randomValues.randomProductQuantity2)).formatPrice()
            properties["OM.ppr"] = "\(price1);\(price2)"
            Visilabs.callAPI().customEvent("Cart", properties: properties)
            return
        case .productPurchase:
            properties["OM.tid"] = "\(randomValues.randomOrderID)" // Order ID
            properties["OM.pp"] = "\(randomValues.randomProductCode1);\(randomValues.randomProductCode2)"
            //Product1 Code;Product2 Code
            properties["OM.pu"] = "\(randomValues.randomProductQuantity1);\(randomValues.randomProductQuantity2)"
            // Product1 Quantity;Product2 Quantity
            let price1 = (randomValues.randomProductPrice1 * Double(randomValues.randomProductQuantity1)).formatPrice()
            let price2 = (randomValues.randomProductPrice2 * Double(randomValues.randomProductQuantity2)).formatPrice()
            properties["OM.ppr"] = "\(price1);\(price2)"
            Visilabs.callAPI().customEvent("Purchase", properties: properties)
            return
        case .productCategoryPageView:
            properties["OM.clist"] = "\(randomValues.randomCategoryID)" // Category Code/Category ID
            Visilabs.callAPI().customEvent("Category View", properties: properties)
            return
        case .inAppSearch:
            properties["OM.OSS"] = "laptop" // Search Keyword
            properties["OM.OSSR"] = "\(randomValues.randomNumberOfSearchResults)" // Number of Search Results
            Visilabs.callAPI().customEvent("In App Search", properties: properties)
            return
        case .bannerClick:
            properties["OM.OSB"] = "\(randomValues.randomBannerCode)" // Banner Name/Banner Code
            Visilabs.callAPI().customEvent("Banner Click", properties: properties)
            return
        case .addToFavorites:
            properties["OM.pf"] = "\(randomValues.randomProductCode1)" // Product Code
            properties["OM.pfu"] = "1"
            properties["OM.ppr"] = randomValues.randomProductPrice1.formatPrice() // Product Price
            Visilabs.callAPI().customEvent("Add To Favorites", properties: properties)
            return
        case .removeFromFavorites:
            properties["OM.pf"] = "\(randomValues.randomProductCode1)" // Product Code
            properties["OM.pfu"] = "-1"
            properties["OM.ppr"] = randomValues.randomProductPrice1.formatPrice() // Product Price
            Visilabs.callAPI().customEvent("Add To Favorites", properties: properties)
            return
        case .sendingCampaignParameters:
            properties["utm_source"] = "euromsg"
            properties["utm_medium"] = "push"
            properties["utm_campaign"] = "euromsg campaign"
            properties["OM.csource"] = "euromsg"
            properties["OM.cmedium"] = "push"
            properties["OM.cname"] = "euromsg campaign"
            Visilabs.callAPI().customEvent("Login Page", properties: properties)
            return
        case .pushMessage:
            properties["OM.sys.TokenID"] = visilabsProfile.appToken //"Token ID to use for push messages"
            properties["OM.sys.AppID"] = visilabsProfile.appAlias // "App ID to use for push messages"
            Visilabs.callAPI().customEvent("RegisterToken", properties: properties)
            return
        }
    }
}

struct RandomProduct {
    let randomProductCode1: Int
    let randomProductCode2: Int
    let randomProductPrice1: Double
    let randomProductPrice2: Double
    let randomProductQuantity1: Int
    let randomProductQuantity2: Int
    let randomInventory: Int
    let randomBasketID: Int
    let randomOrderID: Int
    let randomCategoryID: Int
    let randomNumberOfSearchResults: Int
    let randomBannerCode: Int
    let genders: [String]
    let randomGender: String
}
