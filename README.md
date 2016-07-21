## UIScrollView-Infinite

Swift infinite scroll implementation as a category for UIScrollView.
Works with both UICollectionView and UITableView

![preview](/Assets/sc1.png?raw=true "UIScrollView-Infinite with UICollectionView")

### Basic usage

```swift

collectionView.sf_addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
		addMoreData()
}

```
***

#### sf_addInfiniteScrollWithHandler
Setup infinite scroll handler
***

#### sf_removeInfiniteScroll
Unregister infinite scroll
***

#### sf_finishInfiniteScrollWithCompletion
Finish infinite scroll animations
***

#### sf_callInfiniteScrollHandlerWhileScrolling
Flag that indicates whether infinite scroll is hidden
***

#### sf_infiniteScrollHidden
Flag that indicates whether infinite scroll is hidden
***

#### sf_isAnimatingInfiniteScroll
Flag that indicates whether infinite scroll is animating
***

#### sf_infiniteScrollIndicatorStyle
Infinite scroll activity indicator style
***

#### sf_setInfiniteScrollIndicatorView
Infinite indicator view (can be a custom view)
***

#### sf_infiniteScrollIndicatorMargin
Vertical margin around indicator view
***

#### sf_infiniteScrollTriggerOffset
Sets the offset between the real end of the scroll view content and the scroll position, so the handler can be triggered before reaching end.

Defaults to 0.0
***

#### sf_setScrollViewContentInset
Set content inset with animation.
***

### Attributions

A Swift port of UIScrollView-InfiniteScroll by Andrej Mihajlov
https://github.com/pronebird/UIScrollView-InfiniteScroll
