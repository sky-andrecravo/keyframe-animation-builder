//
//  KeyframeAnimationTests.swift
//  
//
//  Created by André Cravo on 27/04/2022.
//

import XCTest
@testable import AnimationExtensionKit

class KeyframeAnimationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UIView.setAnimationsEnabled(false)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UIView.setAnimationsEnabled(true)
    }

    // MARK: UIView.Keyframe
    
    func test_keyframe_construction_outputs_keyframe() throws {
        
        // given
        let start: TimeInterval = 0.0
        let duration: TimeInterval = 0.5
        let animation: (() -> Void)? = nil
        
        // when
        let sut = UIView.Keyframe(start: start, duration: duration, animation: animation)
        
        // then
        XCTAssertEqual(start, sut.start)
        XCTAssertEqual(duration, sut.duration)
        XCTAssertNil(sut.animation)
    }
    
    // MARK: UIView.KeyframeAnimation
    
    func test_keyframeAnimation_construction_outputs_keyframeAnimation() throws {
        // given
        let duration: TimeInterval = 0.5
        let delay: TimeInterval = 0.1
        let options: UIView.KeyframeAnimationOptions = .allowUserInteraction
        let completion: ((Bool) -> Void)? = { finished in
        }
        
        let kf1 = UIView.Keyframe(start: 0, duration: 0.3, animation: {})
        let kf2 = UIView.Keyframe(start: 0.3, duration: 0.2, animation: {})
        let keyframes = [kf1, kf2]
        
        // when
        let sut = UIView.KeyframeAnimation(duration: duration, delay: delay, options: options, completion: completion, keyframes: keyframes)
        
        // then
        XCTAssertEqual(duration, sut.duration)
        XCTAssertEqual(delay, sut.delay)
        XCTAssertEqual(options, sut.options)
        XCTAssertNotNil(completion)
        XCTAssertTrue(keyframes.count == sut.keyframes.count)
    }
    
    func test_keyframeAnimation_addKeyframe_returnsNewAnimationWithKeyframe() throws {
        // given
        let duration: TimeInterval = 1.0
        let delay: TimeInterval = 0.1
        let sut = UIView.KeyframeAnimation(duration: duration, delay: delay, keyframes: [])
        
        let kf1Start = 0.0
        let kf1Duration = 0.4
        let kf1Animation: (() -> Void) = {}
        
        let kf2Start = 0.2
        let kf2Duration = 0.6
        let kf2Animation: (() -> Void) = {}
        
        // when
        let resultOneAdded = sut.keyframe(at: kf1Start, duration: kf1Duration, animation: kf1Animation)
        let resultTwoAdded = resultOneAdded.keyframe(at: kf2Start, duration: kf2Duration, animation: kf2Animation)
        
        // then
        XCTAssertEqual(duration, resultOneAdded.duration)
        XCTAssertEqual(duration, resultTwoAdded.duration)
        XCTAssertEqual(delay, resultOneAdded.delay)
        XCTAssertEqual(delay, resultTwoAdded.delay)
        
        XCTAssertTrue(resultOneAdded.keyframes.count == 1)
        XCTAssertTrue(resultTwoAdded.keyframes.count == 2)
        
        XCTAssertEqual(kf1Start, resultTwoAdded.keyframes[0].start)
        XCTAssertEqual(kf1Duration, resultTwoAdded.keyframes[0].duration)
        XCTAssertNotNil(resultTwoAdded.keyframes[0].animation)
        
        XCTAssertEqual(kf2Start, resultTwoAdded.keyframes[1].start)
        XCTAssertEqual(kf2Duration, resultTwoAdded.keyframes[1].duration)
        XCTAssertNotNil(resultTwoAdded.keyframes[1].animation)
    }
    
    func test_keyframeAnimation_addKeyframeWithOperation_returnsNewAnimationWithKeyframe() throws {
        // given
        let duration: TimeInterval = 1.0
        let delay: TimeInterval = 0.1
        let sut = UIView.KeyframeAnimation(duration: duration, delay: delay, keyframes: [])
        
        let kfStart = 0.0
        let kfDuration = 0.4

        let kfSlice1From = 0.0
        let kfSlice1To = 0.3
        let kfSlice1Animation: (() -> Void) = {}
        let kfSlice2From = 0.3
        let kfSlice2To = 0.4
        let kfSlice2Animation: (() -> Void) = {}
        
        // when
        let resultOneAdded = sut.keyframe(at: kfStart, duration: kfDuration) { operation in
            return operation
                .slice(from: kfSlice1From, to: kfSlice1To, animation: kfSlice1Animation)
                .slice(from: kfSlice2From, to: kfSlice2To, animation: kfSlice2Animation)
        }
        
        // then
        XCTAssertEqual(duration, resultOneAdded.duration)
        XCTAssertEqual(delay, resultOneAdded.delay)
        XCTAssertTrue(resultOneAdded.keyframes.count == 2)

        
        XCTAssertEqual(kfSlice1From, resultOneAdded.keyframes[0].start)
        XCTAssertEqual((kfSlice1To - kfSlice1From), resultOneAdded.keyframes[0].duration)
        XCTAssertNotNil(resultOneAdded.keyframes[0].animation)
        
        XCTAssertEqual(kfSlice2From, resultOneAdded.keyframes[1].start)
        XCTAssertEqual((kfSlice2To - kfSlice2From), resultOneAdded.keyframes[1].duration)
        XCTAssertNotNil(resultOneAdded.keyframes[1].animation)
    }
    
    // MARK: UIView.Operation
    
    func test_keyframeOperation_construct_outputs_operation() throws {
        // given
        let start: TimeInterval = 0.0
        let duration: TimeInterval = 0.5
        let animation: (() -> Void)? = nil
        let inputKeyframe = UIView.Keyframe(start: start, duration: duration, animation: animation)
        let outputKeyframes = [
            UIView.Keyframe(start: 0.0, duration: 0.25, animation: {}),
            UIView.Keyframe(start: 0.25, duration: 0.25, animation: {})
        ]
        
        // when
        let sut = UIView.Operation(input: inputKeyframe, output: outputKeyframes)
        
        // then
        XCTAssertNotNil(sut.input)
        XCTAssertEqual(start, sut.input.start)
        XCTAssertEqual(duration, sut.input.duration)
        XCTAssertNil(sut.input.animation)
        
        XCTAssertTrue(sut.output.count == 2)
        
        XCTAssertEqual(outputKeyframes[0].start, sut.output[0].start)
        XCTAssertEqual(outputKeyframes[0].duration, sut.output[0].duration)
        XCTAssertNotNil(sut.output[0].animation)
        
        XCTAssertEqual(outputKeyframes[1].start, sut.output[1].start)
        XCTAssertEqual(outputKeyframes[1].duration, sut.output[1].duration)
        XCTAssertNotNil(sut.output[1].animation)
    }
    
    func test_keyframeOperation_slice_appends_to_output() throws {
        // given
        let start: TimeInterval = 0.0
        let duration: TimeInterval = 0.5
        let animation: (() -> Void)? = nil
        let inputKeyframe = UIView.Keyframe(start: start, duration: duration, animation: animation)
        let outputKeyframes: [UIView.Keyframe] = []
        let operation = UIView.Operation(input: inputKeyframe, output: outputKeyframes)

        // when
        let sut = operation.slice(from: 0.15, to: 0.25) {
            // some animation
        }.slice(from: 0.25, to: 0.5) {
            // some animation
        }
        

        // then
        XCTAssertTrue(sut.output.count == 2)

        XCTAssertEqual(0.15, sut.output[0].start)
        XCTAssertEqual(0.10, sut.output[0].duration)
        XCTAssertNotNil(sut.output[0].animation)

        XCTAssertEqual(0.25, sut.output[1].start)
        XCTAssertEqual(0.25, sut.output[1].duration)
        XCTAssertNotNil(sut.output[1].animation)
    }
    
    
    // MARK: UIView
    
    func test_uiview_animationWithKeyframes_shouldAnimate() throws {
        // given
        var keyframe1AnimationBlockCalled = false
        var keyframe2AnimationBlockCalled = false
        var completionBlockCalled = false
        
        let labelOut = UILabel()
        labelOut.alpha = 1.0
        let labelIn = UILabel()
        labelIn.alpha = 0.0
        
        let expectation = expectation(description: "completion expectation")
        
        // when
        UIView
            .animation(duration: 0.7)
            .keyframe(at: 0.2, duration: 0.3) {
                // some animation
                labelOut.alpha = 0.0
                keyframe1AnimationBlockCalled = true
            }
            .keyframe(at: 0.3, duration: 0.3) {
                // another animation
                keyframe2AnimationBlockCalled = true
                labelIn.alpha = 1.0
            }
            .animate { finished in
                completionBlockCalled = true
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 0.1)
        
        // then
        XCTAssertTrue(keyframe1AnimationBlockCalled)
        XCTAssertTrue(keyframe2AnimationBlockCalled)
        XCTAssertEqual(labelOut.alpha, 0.0)
        XCTAssertEqual(labelIn.alpha, 1.0)
        XCTAssertTrue(completionBlockCalled)
    }
    
    func test_uiview_animationWithSlicedKeyframes_shouldAnimate() throws {
        // given
        var keyframe1Slice1AnimationBlockCalled = false
        var keyframe1Slice2AnimationBlockCalled = false
        var keyframe2Slice1AnimationBlockCalled = false
        var keyframe2Slice2AnimationBlockCalled = false
        var completionBlockCalled = false
        
        let labelOut = UILabel()
        labelOut.alpha = 1.0
        let labelIn = UILabel()
        labelIn.alpha = 0.0
        
        let expectation = expectation(description: "completion expectation")
        
        // when
        UIView
            .animation(duration: 7)
            .keyframe(at: 5, duration: 2) { operation in
                return operation.slice(from: 0, to: 1) {
                    // some animation
                    labelOut.alpha = 0.7
                    keyframe1Slice1AnimationBlockCalled = true
                }.slice(from: 1, to: 2) {
                    // some animation
                    labelOut.alpha = 0.0
                    keyframe1Slice2AnimationBlockCalled = true
                }
            }
            .keyframe(at: 5, duration: 2) { operation in
                return operation.slice(from: 0, to: 1) {
                    // some animation
                    labelIn.alpha = 0.7
                    keyframe2Slice1AnimationBlockCalled = true
                }.slice(from: 1, to: 2) {
                    // some animation
                    labelIn.alpha = 1.0
                    keyframe2Slice2AnimationBlockCalled = true
                }
            }
            .animate { finished in
                completionBlockCalled = true
                expectation.fulfill()
            }
        
        
        wait(for: [expectation], timeout: 0.1)
        
        // then
        XCTAssertTrue(keyframe1Slice1AnimationBlockCalled)
        XCTAssertTrue(keyframe1Slice2AnimationBlockCalled)
        XCTAssertTrue(keyframe2Slice1AnimationBlockCalled)
        XCTAssertTrue(keyframe2Slice2AnimationBlockCalled)
        XCTAssertEqual(labelOut.alpha, 0.0)
        XCTAssertEqual(labelIn.alpha, 1.0)
        XCTAssertTrue(completionBlockCalled)
    }
    
}
