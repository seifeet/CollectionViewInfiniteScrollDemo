//
//  UIScrollView-Infinite.swift
//  Monkry Work
//
//  A Swift port of UIScrollView-InfiniteScroll by Andrej Mihajlov
//  https://github.com/pronebird/UIScrollView-InfiniteScroll
//
//  Created by AT on 7/18/16.
//  Copyright © 2016 AT. All rights reserved.
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/iCarousel
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

//
//  UIScrollView-Infinite.swift
//  Nebula
//
//  A Swift port of UIScrollView-InfiniteScroll by Andrej Mihajlov
//  https://github.com/pronebird/UIScrollView-InfiniteScroll
//
//  Created by AT on 7/18/16.
//  Copyright © 2016 Visva. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

protocol ActivityIndicatorInterface {
    func startAnimating()
    func stopAnimating()
    func isAnimating() -> Bool
}

class InternalActivityIndicatorView : UIActivityIndicatorView, ActivityIndicatorInterface {
    
}

extension UIScrollView {
    
    private struct Constants {
        static let AnimationDuration: NSTimeInterval = 0.35
        static var InfiniteScrollStateKey: UInt8 = 0
    }
    
    /**
     *  Setup infinite scroll handler
     *
     *  @param handler a handler block
     */
    func sf_addInfiniteScrollWithHandler(handler:(scrollView:UIScrollView)->(Void)) {
        let state = infiniteScrollState
        
        state.infiniteScrollHandler = handler
        
        // Double initialization only replaces handler block
        // Do not continue if already initialized
        if(state.initialized) {
            return
        }
        
        self.panGestureRecognizer.addTarget(self, action: #selector(sf_handlePanGesture))
        
        state.initialized = true;
        state.addObservers()
    }
    
    /**
     *  Unregister infinite scroll
     */
    func sf_removeInfiniteScroll() {
        let state = infiniteScrollState
        
        // Ignore multiple calls to remove infinite scroll
        if(!state.initialized) {
            return
        }
        
        // Remove pan gesture handler
        self.panGestureRecognizer.removeTarget(self, action: #selector(sf_handlePanGesture))
        
        // Destroy infinite scroll indicator
        state.indicatorView?.removeFromSuperview()
        state.indicatorView = nil
        
        // Release handler block
        state.infiniteScrollHandler = nil
        
        // Mark infinite scroll as uninitialized
        state.initialized = false
        
        // remove observers
        state.removeObservers()
    }
    
    /**
     *  Finish infinite scroll animations
     *
     *  You must call this method from your infinite scroll handler to finish all
     *  animations properly and reset infinite scroll state
     *
     *  @param handler a completion block handler called when animation finished
     */
    func sf_finishInfiniteScrollWithCompletion(handler:(scrollView:UIScrollView) -> (Void)) {
        if (infiniteScrollState.loading) {
            sf_stopAnimatingInfiniteScrollWithCompletion(handler)
        }
    }
    
    /**
     *  Call infinite scroll handler block, primarily here because we use performSelector to call this method.
     */
    func sf_callInfiniteScrollHandler() {
        let state = infiniteScrollState
        
        state.infiniteScrollHandler?(scrollView: self)
    }
    
    /**
     *  Additional pan gesture handler used to adjust content offset to reveal or hide indicator view.
     *
     *  @param gestureRecognizer
     */
    func sf_handlePanGesture(gestureRecognizer:UITapGestureRecognizer) {
        if gestureRecognizer.state == .Ended {
            sf_scrollToInfiniteIndicatorIfNeeded(true)
        }
    }
    
    // MARK: - Public Accessors
    
    /**
     *  Flag that indicates whether infinite scroll
     *  should postpone calling infinite scroll handler
     *  until scrolling is stopped
     *
     *  false by default
     *
     */
    
    var sf_callInfiniteScrollHandlerWhileScrolling:Bool {
        get {
            return infiniteScrollState.callHandlerWhileScrolling
        }
        set {
            let state = infiniteScrollState
            state.callHandlerWhileScrolling = newValue
        }
    }
    
    /**
     *  Flag that indicates whether infinite scroll is hidden
     *
     *  false by default
     *
     */
    
    var sf_infiniteScrollHidden:Bool {
        get {
            return infiniteScrollState.hidden
        }
        set {
            let state = infiniteScrollState
            state.hidden = newValue
        }
    }
    
    /**
     *  Flag that indicates whether infinite scroll is animating
     */
    var sf_isAnimatingInfiniteScroll:Bool {
        get {
            return self.infiniteScrollState.loading
        }
    }
    
    /**
     *  Infinite scroll activity indicator style (default: UIActivityIndicatorViewStyleGray on iOS, UIActivityIndicatorViewStyleWhite on tvOS)
     */
    var sf_infiniteScrollIndicatorStyle:UIActivityIndicatorViewStyle {
        get {
            let state = infiniteScrollState
            return state.indicatorStyle
        }
        set {
            let state = infiniteScrollState
            state.indicatorStyle = sf_infiniteScrollIndicatorStyle
            
            if let activityIndicatorView = state.indicatorView as? UIActivityIndicatorView {
                activityIndicatorView.activityIndicatorViewStyle = newValue
            }
        }
    }
    
    /**
     *  Infinite indicator view
     *
     *  Infinite scroll will call implemented methods during user interaction.
     */
    func sf_setInfiniteScrollIndicatorView<T: UIView where T: ActivityIndicatorInterface>(view:T) {
        view.hidden = true
        let state = infiniteScrollState
        state.indicatorView = view
    }
    
    /**
     *  Vertical margin around indicator view (Default: 11)
     */
    var sf_infiniteScrollIndicatorMargin:CGFloat {
        get {
            return infiniteScrollState.indicatorMargin
        }
        set {
            let state = infiniteScrollState
            state.indicatorMargin = newValue
        }
    }
    
    /**
     *  Sets the offset between the real end of the scroll view content and the scroll position, so the handler can be triggered before reaching end.
     *  Defaults to 0.0;
     */
    var sf_infiniteScrollTriggerOffset:CGFloat {
        get {
            return infiniteScrollState.triggerOffset
        }
        set {
            let state = infiniteScrollState
            state.triggerOffset = fabs(newValue)
        }
    }
    
    /**
     *  Set content inset with animation.
     *
     *  @param contentInset a new content inset
     *  @param animated     animate?
     *  @param completion   a completion block
     */
    func sf_setScrollViewContentInset(contentInset:UIEdgeInsets, animated:Bool, completion:((finished:Bool)->(Void))) {
        let animations: (Void) -> (Void) = { self.contentInset = contentInset }
        
        if(animated)
        {
            let options: UIViewAnimationOptions = [.AllowUserInteraction, .BeginFromCurrentState]
            
            UIView.animateWithDuration(Constants.AnimationDuration, delay: 0.0, options: options, animations: animations, completion: completion)
        }
        else
        {
            UIView.performWithoutAnimation(animations)
            completion(finished: true)
        }
    }
    
    // MARK: - Private
    
    /**
     *
     *  A class to store infinite scroll state
     *
     */
    
    private class InfiniteScrollState : NSObject {
        
        private struct Constants {
            static let ContentSizeKey = "contentSize"
            static let ContentOffsetKey = "contentOffset"
            
            static var ContentSizeContext:UInt8 = 0
            static var ContentOffsetContext:UInt8 = 0
        }
        
        /**
         *  A weak reference to target scrollview used exclusively for KVO
         */
        weak var targetScrollView:UIScrollView? = nil
        
        /**
         *  A flag that indicates whether scroll is initialized
         */
        var initialized:Bool = false
        
        /**
         *  A flag that indicates whether loading is in progress.
         */
        var loading:Bool = false
        
        /**
         *  A flag that indicates whether infinite scroll is hidden
         */
        var hidden:Bool = false
        
        /**
         *  A flag that indicates whether infinite scroll is hidden
         */
        var callHandlerWhileScrolling:Bool = false
        
        /**
         *  Indicator view.
         */
        var indicatorView:UIView?
        
        /**
         *  Indicator style when UIActivityIndicatorView used.
         */
        var indicatorStyle:UIActivityIndicatorViewStyle = .Gray
        
        /**
         *  Extra padding to push indicator view below view bounds.
         *  Used in case when content size is smaller than view bounds
         */
        var extraBottomInset:CGFloat = 0
        
        /**
         *  Indicator view inset.
         *  Essentially is equal to indicator view height.
         */
        var indicatorInset:CGFloat = 0
        
        /**
         *  Indicator view margin (top and bottom)
         */
        var indicatorMargin:CGFloat = 0
        
        /**
         *  Trigger offset.
         */
        var triggerOffset:CGFloat = 0
        
        /**
         *  Infinite scroll handler block
         */
        var infiniteScrollHandler:((scrollView:UIScrollView) -> (Void))?
        
        /**
         *  Content size changed handler block
         */
        var didChangeContentSizeHandler:((newContentSize:CGSize) -> (Void))?
        
        
        /**
         *  Content offset changed handler block
         */
        var didChangeContentOffsetHandler:((newContentOffset:CGPoint) -> (Void))?
        
        private override init () {
            #if TARGET_OS_TV
                indicatorStyle = .White
            #endif
            
            // Default row height (44) minus activity indicator height (22) / 2
            indicatorMargin = 11
        }
        
        /**
         *  Designated initializer.
         *
         *  @param scrollView
         *
         */
        convenience init(scrollView:UIScrollView) {
            self.init()
            self.targetScrollView = scrollView
        }
        
        // MARK: observers
        func addObservers() {
            targetScrollView?.addObserver(self,
                                          forKeyPath: Constants.ContentSizeKey,
                                          options: NSKeyValueObservingOptions.New,
                                          context:&Constants.ContentSizeContext)
            targetScrollView?.addObserver(self,
                                          forKeyPath: Constants.ContentOffsetKey,
                                          options: NSKeyValueObservingOptions.New,
                                          context:&Constants.ContentOffsetContext)
        }
        
        func removeObservers() {
            targetScrollView?.removeObserver(self, forKeyPath: Constants.ContentSizeKey)
            targetScrollView?.removeObserver(self, forKeyPath: Constants.ContentOffsetKey)
        }
        
        override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            
            if(change != nil && context == &Constants.ContentSizeContext) {
                guard let newValue = change![NSKeyValueChangeNewKey] else {
                    return
                }
                self.didChangeContentSizeHandler?(newContentSize: newValue.CGSizeValue())
            }
            else if(change != nil && context == &Constants.ContentOffsetContext) {
                guard let newValue = change![NSKeyValueChangeNewKey] else {
                    return
                }
                self.didChangeContentOffsetHandler?(newContentOffset: newValue.CGPointValue())
            }
            else {
                super.observeValueForKeyPath(keyPath, ofObject: object, change:change, context: context)
            }
        }
        
    }
    
    /**
     *
     *  Get infinite scroll state
     *  the state is stored as an associated object
     *
     */
    private var infiniteScrollState:InfiniteScrollState {
        get {
            guard let storedState = objc_getAssociatedObject(self, &Constants.InfiniteScrollStateKey) as? InfiniteScrollState else {
                
                let state = InfiniteScrollState(scrollView: self)
                
                state.didChangeContentSizeHandler = { [weak self] (newContentSize) -> (Void) in
                    guard let strongSelf = self else {
                        return
                    }
                    if state.initialized {
                        strongSelf.sf_positionInfiniteScrollIndicatorWithContentSize(newContentSize)
                    }
                }
                
                state.didChangeContentOffsetHandler = { [weak self] (newContentOffset) -> (Void) in
                    guard let strongSelf = self else {
                        return
                    }
                    if state.initialized {
                        strongSelf.sf_scrollViewDidScroll(newContentOffset)
                    }
                }
                
                objc_setAssociatedObject(self, &Constants.InfiniteScrollStateKey, state, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return state
            }
            return storedState
        }
    }
    
    /**
     *  Start animating infinite indicator
     */
    private func sf_startAnimatingInfiniteScroll() {
        let state = infiniteScrollState
        var contentInset = self.contentInset
        let indicatorView = sf_getOrCreateActivityIndicatorView()
        
        // Layout indicator view
        sf_positionInfiniteScrollIndicatorWithContentSize(self.contentSize)
        
        // It's show time!
        indicatorView.hidden = true;
        
        if let activityIndicatorView = indicatorView as? ActivityIndicatorInterface {
            activityIndicatorView.startAnimating()
        }
        
        // Calculate indicator view inset
        let indicatorInset = sf_infiniteIndicatorRowHeight
        
        // Make a room to accommodate indicator view
        contentInset.bottom += indicatorInset;
        
        // We have to pad scroll view when content height is smaller than view bounds.
        // This will guarantee that indicator view appears at the very bottom of scroll view.
        let adjustedContentHeight = sf_clampContentSizeToFitVisibleBounds(self.contentSize)
        let extraBottomInset = adjustedContentHeight - self.contentSize.height
        
        // Add empty space padding
        contentInset.bottom += extraBottomInset;
        
        // Save indicator view inset
        state.indicatorInset = indicatorInset;
        
        // Save extra inset
        state.extraBottomInset = extraBottomInset;
        
        // Update infinite scroll state
        state.loading = true;
        
        // Animate content insets
        sf_setScrollViewContentInset(contentInset, animated: true) { (finished) -> (Void) in
            if finished {
                self.sf_scrollToInfiniteIndicatorIfNeeded(true)
            }
        }
    }
    
    /**
     *  Stop animating infinite scroll indicator
     *
     *  @param handler a completion handler
     */
    private func sf_stopAnimatingInfiniteScrollWithCompletion(handler:(scrollView:UIScrollView) -> (Void)) {
        let state = infiniteScrollState
        var contentInset = self.contentInset
        
        // Force the table view to update its contentSize; if we don't do this,
        // finishInfiniteScroll() will adjust contentInsets and cause contentOffset
        // to be off by an amount equal to the height of the activity indicator.
        // Note: this call has to happen before we reset extraBottomInset or indicatorInset
        //       otherwise indicator may re-layout at the wrong position but we haven't set
        //       contentInset yet!
        if let tableView = self as? UITableView {
            tableView.contentSize = tableView.sizeThatFits(CGSizeMake(CGRectGetWidth(tableView.frame), CGFloat.max))
        }
        
        // Remove row height inset
        contentInset.bottom -= state.indicatorInset;
        
        // Remove extra inset added to pad infinite scroll
        contentInset.bottom -= state.extraBottomInset;
        
        // Reset indicator view inset
        state.indicatorInset = 0;
        
        // Reset extra bottom inset
        state.extraBottomInset = 0;
        
        // Animate content insets
        sf_setScrollViewContentInset(contentInset, animated: true) { (finished) -> (Void) in
            // Initiate scroll to the bottom if due to user interaction contentOffset.y
            // stuck somewhere between last cell and activity indicator
            if finished {
                self.sf_scrollToInfiniteIndicatorIfNeeded(false)
            }
            
            let indicatorView = self.sf_getOrCreateActivityIndicatorView()
            indicatorView.hidden  = true
            
            // Curtain is closing they're throwing roses at my feet
            if let activityIndicatorView = indicatorView as? ActivityIndicatorInterface {
                activityIndicatorView.stopAnimating()
            }
            
            // Reset scroll state
            state.loading = false
            
            // Call completion handler
            handler(scrollView: self)
        }
    }
    
    /**
     *  Scrolls down to activity indicator if it is partially visible
     *
     *  @param reveal scroll to reveal or hide activity indicator
     */
    private func sf_scrollToInfiniteIndicatorIfNeeded(reveal:Bool) {
        // do not interfere with user
        if self.dragging {
            return
        }
        
        let state = infiniteScrollState
        
        // filter out calls from pan gesture
        if !state.loading {
            return
        }
        
        let contentHeight:CGFloat = sf_clampContentSizeToFitVisibleBounds(self.contentSize)
        let indicatorRowHeight:CGFloat = sf_infiniteIndicatorRowHeight
        
        let minY:CGFloat = contentHeight - self.bounds.size.height + self.sf_originalBottomInset
        let maxY:CGFloat = minY + indicatorRowHeight;
        
        if (self.contentOffset.y > minY && self.contentOffset.y < maxY) {
            self.setContentOffset(CGPointMake(0, reveal ? maxY : minY), animated: false)
        }
    }
    
    /**
     *  Clamp content size to fit visible bounds of scroll view.
     *  Visible area is a scroll view size minus original top and bottom insets.
     *
     *  @param contentSize content size
     *
     *  @return CGFloat
     */
    private func sf_clampContentSizeToFitVisibleBounds(contentSize:CGSize) -> CGFloat  {
        // Find minimum content height. Only original insets are used in calculation.
        let minHeight:CGFloat = self.bounds.size.height - self.contentInset.top - self.sf_originalBottomInset
        
        return max(contentSize.height, minHeight);
    }
    
    /**
     *  Returns bottom inset without extra padding and indicator padding.
     *
     *  @return CGFloat
     */
    private  var sf_originalBottomInset:CGFloat {
        get {
            let state = infiniteScrollState
            
            return self.contentInset.bottom - state.extraBottomInset - state.indicatorInset
        }
    }
    
    /**
     *  A row height for indicator view, in other words: indicator margin + indicator height.
     *
     *  @return CGFloat
     */
    private var sf_infiniteIndicatorRowHeight:CGFloat {
        get {
            let activityIndicator = self.sf_getOrCreateActivityIndicatorView()
            let indicatorHeight:CGFloat = CGRectGetHeight(activityIndicator.bounds);
            
            return indicatorHeight + self.sf_infiniteScrollIndicatorMargin * 2;
        }
    }
    
    /**
     *  Guaranteed to return an indicator view.
     *
     *  @return indicator view.
     */
    private  func sf_getOrCreateActivityIndicatorView() -> UIView {
        let state = infiniteScrollState
        guard let indicatorView = state.indicatorView else {
            // create activity indicator view
            let activityIndicatorView = InternalActivityIndicatorView()
            activityIndicatorView.activityIndicatorViewStyle = self.sf_infiniteScrollIndicatorStyle
            
            self.sf_setInfiniteScrollIndicatorView(activityIndicatorView)
            self.addSubview(activityIndicatorView)
            
            return activityIndicatorView
        }
        
        // Add activity indicator into scroll view if needed
        if indicatorView.superview != self {
            self.addSubview(indicatorView)
        }
        
        return indicatorView
    }
    
    
    /**
     *  Update infinite scroll indicator's position in view.
     *
     *  @param contentSize content size.
     */
    private func sf_positionInfiniteScrollIndicatorWithContentSize(contentSize:CGSize) {
        let activityIndicator = sf_getOrCreateActivityIndicatorView()
        let contentHeight = sf_clampContentSizeToFitVisibleBounds(contentSize)
        let indicatorRowHeight = sf_infiniteIndicatorRowHeight
        let center = CGPointMake(contentSize.width * 0.5, contentHeight + indicatorRowHeight * 0.5)
        
        if(!CGPointEqualToPoint(activityIndicator.center, center)) {
            activityIndicator.center = center;
        }
    }
    
    /**
     *  Called whenever content offset changes.
     *
     *  @param contentOffset
     */
    private func sf_scrollViewDidScroll(contentOffset:CGPoint) {
        let state = infiniteScrollState
        
        let contentHeight = sf_clampContentSizeToFitVisibleBounds(self.contentSize)
        
        // The lower bound when infinite scroll should kick in
        var actionOffset = CGPointZero
        actionOffset.x = 0;
        actionOffset.y = contentHeight - self.bounds.size.height + sf_originalBottomInset
        
        // apply trigger offset adjustment
        actionOffset.y -= state.triggerOffset;
        
        // Disable infinite scroll when scroll view is empty
        // Default UITableView reports height = 1 on empty tables
        let hasActualContent = (self.contentSize.height > 1)
        
        // is there any content?
        if(!hasActualContent) {
            return;
        }
        
        // is user initiated?
        if(!self.dragging) {
            return;
        }
        
        // did it kick in already?
        if(state.loading) {
            return;
        }
        
        if(contentOffset.y > actionOffset.y) {
            
            // Only show the infinite scroll if it is allowed
            if(!sf_infiniteScrollHidden) {
                sf_startAnimatingInfiniteScroll()
                
                // This will delay handler execution until scroll deceleration
                let modes = sf_callInfiniteScrollHandlerWhileScrolling ? [NSRunLoopCommonModes] : [NSDefaultRunLoopMode]
                self.performSelector(#selector(sf_callInfiniteScrollHandler),
                                     withObject: self,
                                     afterDelay: 0.1,
                                     inModes: modes)
            }
        }
    }
}

