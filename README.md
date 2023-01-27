# Coffee

<p align="center">
<img src="https://raw.githubusercontent.com/dnys1/coffee/main/icon.png" alt="Coffee Logo" width="100px" height="100px"><br>
https://coffee.dillonnys.com
</p>

An app for browsing and cataloging your favorite coffees.

## Setup

```sh
$ flutter pub get
$ flutter pub run build_runner build
$ flutter run
```

## Design

The app uses [drift](https://pub.dev/packages/drift) to implement a cross-platform caching solution and the [worker_bee](https://pub.dev/packages/worker_bee) to allow image resize on a worker thread across all platforms.

The [backend](backend/) is deployed as a single Lambda function which proxies to [coffee.alexflipnote.dev](https://coffee.alexflipnote.dev/) to retrieve random images of coffee. The proxy is needed to add CORS headers which are not originally included and which are needed on Web.
