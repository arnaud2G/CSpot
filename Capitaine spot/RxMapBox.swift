//
//  RxMapBox.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 14/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Mapbox

extension Reactive where Base: MGLMapView {
    
    /**
     Reactive wrapper for `delegate`.
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var delegate: DelegateProxy {
        return RxMGLMapViewDelegateProxy.proxyForObject(base)
    }
    
    // MARK: Responding to Location Events
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didChange: Observable<MGLMapView> {
        return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapView(_:didChange:animated:)))
            .map { a in
                return a[0] as! MGLMapView
        }
    }
    
    public var mapViewRegionIsChanging: Observable<MGLMapView> {
        return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapViewRegionIsChanging(_:)))
            .map { a in return a[0] as! MGLMapView }
    }
    
    public var regionWillChangeAnimated: Observable<MGLMapView> {
        return delegate.methodInvoked(#selector(MGLMapViewDelegate.mapView(_:regionWillChangeAnimated:)))
            .map { a in return a[0] as! MGLMapView }
    }
}


import CoreLocation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class RxMGLMapViewDelegateProxy : DelegateProxy, MGLMapViewDelegate, DelegateProxyType {
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let mapView: MGLMapView = castOrFatalError(value: object)
        return mapView.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let mapView: MGLMapView = castOrFatalError(value: object)
        mapView.delegate = castOptionalOrFatalError(value: delegate)
    }
}


// workaround for Swift compiler bug, cheers compiler team :)
func castOptionalOrFatalError<T>(value: AnyObject?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value: value)
    return v
}

func castOrFatalError<T>(value: AnyObject!, message: String) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError(lastMessage: message)
        return maybeResult!
    }
    
    return result
}

func castOrFatalError<T>(value: AnyObject!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError(lastMessage: "Failure converting from \(value) to \(T.self)")
        return maybeResult!
    }
    
    return result
}

func rxFatalErrorAndDontReturn<T>(lastMessage: String) -> T {
    rxFatalError(lastMessage: lastMessage)
    return (nil as T!)!
}


func rxFatalError(lastMessage: String) {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}
