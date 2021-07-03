# AppAttest

The App Attest service, which Apple introduced in iOS 14, provides a secure way of verifying that connections to your server come from legitimate instances of your app. Generating assertions and attestations in your app is [fairly straightforward](https://developer.apple.com/documentation/devicecheck/establishing_your_app_s_integrity), but verifying them on the server is [a little more complicated](https://developer.apple.com/documentation/devicecheck/validating_apps_that_connect_to_your_server). This Swift package implements the server-side validation logic for you.

Note that this is still a young project and the API may change a little. At the moment, the library is able to validate assertions and attestations, but not receipts (which is an optional step, anyway). I’ll update the readme soon with instructions for usage. In the meantime, check out Sources/AppAttest/API.swift as well as the unit tests to get started.
