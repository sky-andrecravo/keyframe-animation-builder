//
//  UIView+KeyframeAnimation.swift
//  
//
//  Created by André Cravo on 27/04/2022.
//

import UIKit
import Foundation

extension UIView {
    
    public struct KeyframeAnimation {
        let duration: TimeInterval
        let delay: TimeInterval
        let options: UIView.KeyframeAnimationOptions
        let keyframes: [Keyframe]
        
        public init(
            duration: TimeInterval,
            delay: TimeInterval,
            options: UIView.KeyframeAnimationOptions = [],
            completion: ((Bool) -> Void)? = nil,
            keyframes: [Keyframe])
        {
            self.duration = duration
            self.delay = delay
            self.options = options
            self.keyframes = keyframes
        }
        
        public func keyframe(
            at: TimeInterval,
            duration: TimeInterval,
            operation: ((Operation) -> Operation)
        ) -> KeyframeAnimation {

            let processed = operation(
                Operation(
                    input: Keyframe(
                        start: at,
                        duration: duration
                    ),
                    output:[]
                )
            )
            
            return KeyframeAnimation(
                duration: self.duration,
                delay: self.delay,
                options: self.options,
                keyframes: keyframes + processed.output
            )
        }
                
        public func keyframe(
            at: TimeInterval,
            duration: TimeInterval,
            animation: @escaping () -> Void
        ) -> KeyframeAnimation {
            let keyframe = Keyframe(
                start: at,
                duration: duration,
                animation: animation
            )
            
            return KeyframeAnimation(
                duration: self.duration,
                delay: self.delay,
                options: self.options,
                keyframes: keyframes + [keyframe]
            )
        }
        
        public func animate(completion: ((Bool) -> Void)? = nil) {
            guard !keyframes.isEmpty else { return }
            
            UIView.animateKeyframes(
                withDuration: duration,
                delay: delay,
                options: options,
                animations: {
                    for keyframe in keyframes {
                        guard let animation = keyframe.animation else { continue }
                        
                        UIView.addKeyframe(
                            withRelativeStartTime: (keyframe.start / self.duration),
                            relativeDuration: (keyframe.duration / self.duration),
                            animations: animation
                        )
                    }
                },
                completion: completion
            )
        }
    }
    
    // MARK: Keyframe
    
    public struct Keyframe {
        let start: TimeInterval
        let duration: TimeInterval
        let animation: (() -> Void)?
        
        init(
            start: TimeInterval,
            duration: TimeInterval,
            animation: (() -> Void)? = nil
        ) {
            self.start = start
            self.duration = duration
            self.animation = animation
        }
    }
    
    // MARK: Keyframe Operation
    
    public struct Operation {
        let input: Keyframe
        let output: [Keyframe]
        
        public func slice(
            from: TimeInterval,
            to: TimeInterval,
            animation: @escaping (() -> Void)
        ) -> Operation {
            
            // slice self into two
            // start duration - relatives to in
            let kf = Keyframe(
                start: input.start + from,
                duration: to - from,
                animation: animation
            )
            
            return Operation(
                input: self.input,
                output:self.output + [kf]
            )
        }
    }
    
    public static func animation(
        duration: TimeInterval,
        delay: TimeInterval = 0,
        options: UIView.KeyframeAnimationOptions = []
    ) -> KeyframeAnimation {
        return KeyframeAnimation(
            duration: duration,
            delay: delay,
            options: options,
            completion: nil,
            keyframes: []
        )
    }
    
}
