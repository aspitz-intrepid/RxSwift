//
//  TimeInterval.swift
//
//  Created by Ayal Spitz on 4/6/18.
//

import Foundation

extension ObservableType {
    public func timeInterval() -> Observable<RxTimeInterval> {
        return TimeInterval(source: asObservable())
    }
}

final fileprivate class TimeInterval<SourceType>: Producer<RxTimeInterval> {
    private let source: Observable<SourceType>
    var subscribeTime: RxTimeInterval = 0.0
    
    init(source: Observable<SourceType>) {
        self.source = source
    }

    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == RxTimeInterval {
        subscribeTime = Date.timeIntervalSinceReferenceDate
        return super.subscribe(observer)
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == RxTimeInterval {
        let sink = TimeIntervalSink(parent: self, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class TimeIntervalSink<SourceType, O : ObserverType> : Sink<O>, ObserverType where O.E == RxTimeInterval{
    typealias Parent = TimeInterval<SourceType>

    var time = Date.timeIntervalSinceReferenceDate
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        time = parent.subscribeTime
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<SourceType>) {
        switch event {
        case .next:
            let now = Date.timeIntervalSinceReferenceDate
            let timeInterval = now - time
            time = now
            forwardOn(.next(timeInterval))
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}
