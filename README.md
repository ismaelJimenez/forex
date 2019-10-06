The fundamental package for retrieving currency exhange rates with Dart.

[![pub package](https://img.shields.io/pub/v/forex.svg)](https://pub.dev/packages/forex)
[![Build Status](https://travis-ci.org/ismaelJimenez/forex.svg?branch=master)](https://travis-ci.org/ismaelJimenez/forex)

This package provides a set of high-level functions and classes that make it easy to retrieve currency exchange rates. It's platform-independent, supports iOS and Android.
# Using

The easiest way to use this library is via the top-level functions. They allow you to make currency exchange rate requests with minimal hassle:
```dart
  Map<String, num> quotes = await Forex.fx(
      quoteProvider: QuoteProvider.yahoo,
      base: 'USD',
      quotes: <String>['EUR']);

  print('Number of quotes retrieved: ${quotes.keys.length}.');
  print('Exchange rate USDEUR: ${quotes['USDEUR']}.');
```
If you're making multiple quote requests to the same server, you can request all of them in a single function call:
```dart
  quotes = await Forex.fx(
      quoteProvider: QuoteProvider.ecb,
      base: 'JPY',
      quotes: <String>['EUR', 'USD']);

  print('Number of quotes retrieved: ${quotes.keys.length}.');
  print('Exchange rate JPYEUR: ${quotes['JPYEUR']}.');
  print('Exchange rate JPYUSD: ${quotes['JPYUSD']}.');
```  
  
  # Supported providers
  
  * European Central Bank (ECB)
  * Yahoo
  
  # TERMS & CONDITIONS

Quote information fetched through this module is bound by the quote providers terms and conditions.
