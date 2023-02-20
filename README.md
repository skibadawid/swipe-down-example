# Swipe Down Extension
- simple way to add a customizable swipe down to dismiss functionality to a ViewController, primarily its `view`) using panGesture
- `SwipeDownConfiguration` offer options to futher customize the

### SwipeDownConfiguration
- **isSticky**: if true, view's y-axis swipe offset is half the true offset (appears to be stickier to top)
- **shouldViewFade**: if true, the view fades relative to the y-axis offset
- **animationDuration**: duration of when view transform to original position or if out of bounds (swipe down action triggered)
- **minimumVelocityToDismiss**: minimum velocity required trigger swipe down action
- **minimumScreenPercentageOffsetToDismiss**: minimum vertical offset, in terms of percent of the screen's height, required to trigger swipe down action. values range: 0.0 - 0.9
- **statusChange**: closure that gets called when there is a `SwipeDownStatus` change

### SwipeDownConfiguration.SwipeDownStatus
- **initiated**: swipe down action conditions met, view will transform verticallty down
- **completed**: view is completely out of bounds
- **cancelled**: pan gesture stopped, it did not meet the required conditionas. view is reverted to its original transform

### How to use
- in about two lines of code, you can add a swipe down functionality to a view controller

```
let swipeDownConfiguration = SwipeDownConfiguration(
  isSticky: true,
  shouldViewFade: true,
  animationDuration: 0.2,
  minimumVelocityToDismiss: 0.4,
  minimumScreenPercentageOffsetToDismiss: 0.5) { state in
  ...
}
viewController.addSwipeDownToDismiss(with: swipeDownConfiguration)
```

## Demo App

### RootViewController
- contains the configuration controls (ConfigurationsView) for creating `SwipeDownConfiguration`
- presents a ruler (RulerView) behind AssetViewController, when presented, to visualize `SwipeDownConfiguration.minimumScreenPercentageOffsetToDismiss`

#### ConfigurationsView  (SwiftUI)
- shows toggles and sliders for everything that can be configured in `SwipeDownConfiguration`

#### RulerView (SwiftUI)
- dummy ruler showing slices of the screen with relative percentage values

### AssetViewController
- a view controller that has a nested UIImageView 
- accepts an Asset (image wrapper) 

### Examples

| screen ratio | screen ratio sticky | minimum velocity |
| ------------- | ------------- | ------------- |
| <img src="/gifs/example_screen_ratio.gif" width="200" > | <img src="/gifs/example_screen_ratio_sticky.gif" width="200" > | <img src="/gifs/example_minimum_velocity.gif" width="200" > |

### Demo App Logs
- demo app logs the each of the SwipeDownStatus enums
    - when `initiated` is triggered, the rulerView will start to disappear
    - when `completed` is triggered, the pressented navigationController is dismissed
    - when `cancelled` is triggered, nothing 

###
<p align="center">
    <img src="/gifs/example_logs.gif" width="200" >
</p>


## When not to use / undesired behavior
- there is a scroll view inside the UIViewController.view where swipe down to dismiss is added
    - most likely, tho based on the layout, the scroll view is overtaking gestures, ignoring the swipe down pan gesture.
    - below is an example of such behavior. the `addSwipeDownToDismiss` was added to the pressented UINavigationController. only the navigation bar is registering the pan gesture. 
- ideally use when ViewController.modalPresentationStyle is `.overFullScreen` / `.fullScreen`

###
<p align="center">
    <img src="/gifs/example_view_controller_with_scroll_view.gif" width="200" >
</p>  
