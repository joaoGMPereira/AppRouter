//
//  TabRouter.swift
//  Sports
//
//  Created by joao gabriel medeiros pereira on 05/10/24.
//
import SwiftUI

@Observable
public final class TabRouter<Routes: TabRoutable>: TabRoutableObject {
    public typealias Destination = Routes

    public var selectedTab: Routes
    
    public let id: String
    
    public var dismiss: ((_ routerId: String) -> Void)?

    public init(selectedTab: Routes, id: String) {
        self.selectedTab = selectedTab
        self.id = id
    }
}


public protocol TabRoutableObject: AnyObject {
    /// The type of the destination views in the navigation stack. Must conform to `Routable`.
    associatedtype Destination: TabRoutable

    /// An array representing the current navigation stack of destinations.
    /// Modifying this stack updates the navigation state of the application.
    var selectedTab: Destination { get set }
}

public typealias TabRoutable = Hashable
