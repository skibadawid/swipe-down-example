# Swipe Down Extension
- simple way to add a customizable swipe down to dismiss functionality to a ViewController, primarily its `view`) using panGesture
- includes a demo app, with adjustable configurations

### RootViewController
- contains the configuration controls (ConfigurationsView) for creating `SwipeDownConfiguration`
- presents a ruler (RulerView) behind AssetViewController, when presented, to visualize `SwipeDownConfiguration.minimumScreenRatioToHide`

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


### When not to use / undesired behavior
- there is a scroll view inside the UIViewController.view where swipe down to dismiss is added
    - most likely, tho based on the layout, the scroll view is overtaking gestures, ignoring the swipe down pan gesture.
    - below is an example of such behavior. the `addSwipeDownToDismiss` was added to the pressented UINavigationController. only the navigation bar is registering the pan gesture. 

###
<p align="center">
    <img src="/gifs/example_view_controller_with_scroll_view.gif" width="200" >
</p>  
