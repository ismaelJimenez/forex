// Copyright 2019 Ismael Jiménez. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:forex/forex.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

void main() {
  group('downloadQuotePrice/downloadRawQuote Test [FinanceQuote] - Real API',
      () {
//    test('Yahoo', () async {
//      Map<String, Map<String, dynamic>> quote;
//      try {
//        quote = await Forex.getPrice(
//            quoteProvider: QuoteProvider.yahoo, symbols: <String>['KO']);
//      } catch (e) {
//        expect(e, 'No exception');
//      }
//
//      expect(quote.keys.length, 1);
//      expect(quote['KO'].keys.length, 2);
//    });

    test('Yahoo', () async {
      Map<String, num> quote;
      try {
        quote = await Forex.fx(
            quoteProvider: QuoteProvider.yahoo,
            base: 'EUR',
            quotes: <String>['USD', 'JPY']);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quote.keys.length, 2);
      expect(quote.containsKey('EURUSD'), true);
      expect(quote.containsKey('EURJPY'), true);
    });

    test('Ecb', () async {
      Map<String, num> quote;
      try {
        quote = await Forex.fx(
            quoteProvider: QuoteProvider.ecb,
            base: 'EUR',
            quotes: <String>['USD', 'JPY']);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quote.keys.length, 2);
      expect(quote.containsKey('EURUSD'), true);
      expect(quote.containsKey('EURJPY'), true);
    });
  });
}
