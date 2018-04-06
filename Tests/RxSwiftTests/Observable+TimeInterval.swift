//
//  Observable+TimeInterval.swift
//
//  Created by Ayal Spitz on 4/6/18.
//

import XCTest
import RxSwift
import RxTest

class ObservableTimeIntervalTest : RxTest {
}

extension ObservableTimeIntervalTest {
    func testTimeInterval_Basic() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        let observer = PrimitiveMockObserver<RxTimeInterval>()
        let expectCompleted = expectation(description: "It will complete")
        
        let d = Observable<Int64>.interval(1.0, scheduler: scheduler)
            .takeWhile { $0 < 10 }
            .timeInterval()
            .map{ $0.rounded(.toNearestOrAwayFromZero) }
            .subscribe(onNext: { observer.on(.next($0)) },
                       onCompleted: { expectCompleted.fulfill() } )
        
        defer {
            d.dispose()
        }
        
        waitForExpectations(timeout: 15.0) { e in
            XCTAssert(e == nil, "Did not complete")
        }
        
        let cleanResources = expectation(description: "Clean resources")
        
        _ = scheduler.schedule(()) { _ in
            cleanResources.fulfill()
            return Disposables.create()
        }
        
        waitForExpectations(timeout: 1.0) { e in
            XCTAssert(e == nil, "Did not clean up")
        }
        
        let correct = Recorded.events(
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0)
        )
        
        XCTAssertEqual(observer.events, correct)
    }
}
