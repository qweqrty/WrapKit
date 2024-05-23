# Encapsulating Loading View in Presenter

Declare a variable in the presenter:

```swift
public var loadingView: CommonLoadingOutput?
```

## Assign the output to the view:

```swift
presenter.loadingView = CommonLoadingiOSAdapter.defaultLoader(
    onView: contentView,
    loadingViewColor: .white,
    wrapperViewColor: .black.withAlphaComponent(0.4)
)
```

## Usage

```swift
loadingView.display(isLoading: true)
```

## Conclusion

This approach keeps your presenter encapsulated from UIKit.

Conclusion
The CommonLoading component is a simple and effective way to provide feedback during long-running operations. By following this guide, you can quickly integrate and customize the loading view to suit your application's needs