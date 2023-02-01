# Swipe Down Extension
- simple way to add a customizable swipe down functionality to a ViewController's view using panGesture
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


