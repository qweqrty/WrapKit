# Encapsulating Toast View in Presenter

Declare a variable in the presenter:

```swift
public var toastView: CommonToastOutput?
```

## Assign the output to the view:

```swift
presenter.loadingView = CommonToastiOSAdapter.init(
    onView: view, // usually your view controller's view
    toastViewBuilder: { commonToast in
      // you are able to specify particular toastView based on type of commonToast
      return ToastView()
    },
    position: .center
)
```

## Usage

```swift
toastView.display(.error(.init(title: "error")))
```

## Conclusion

This approach keeps your presenter encapsulated from UIKit.

Conclusion
The CommonToast component is a simple and effective way to provide feedback during long-running operations. By following this guide, you can quickly integrate and customize the toast view to suit your application's needs