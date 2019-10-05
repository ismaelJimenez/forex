// Copyright 2019 Ismael Jiménez. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:finance_quote/finance_quote.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class YahooApiException implements Exception {
  final int statusCode;
  final String message;

  const YahooApiException({this.statusCode, this.message});
}

class Yahoo {
  static Future<Map<String, num>> fx(String base, List<String> quotes,
      http.Client client, Logger logger) async {
    final Map<String, num> results = <String, num>{};

    try {
      final Map<String, dynamic> fxQuotes =
          await _getFxQuotes(base, quotes, client, logger);

      // Search in the answer obtained the data corresponding to the symbols.
      // If requested symbol data is found add it to [portfolioQuotePrices].
      for (String symbol in quotes) {
        if (fxQuotes.containsKey(base + symbol + '=X')) {
          results[base + symbol] =
              fxQuotes[base + symbol + '=X']['regularMarketPrice'] as num;
        }
      }
    } on YahooApiException catch (e) {
      logger.e(
          'YahooApiException{base: $base, quotes: ${quotes.join(',')}, statusCode: ${e.statusCode}, message: ${e.message}}');
    }

    for (String symbol in quotes) {
      if (!results.containsKey(base + symbol)) {
        logger.e('YahooApi: Symbol $symbol not found.');
      }
    }

    return results;
  }

  static Future<Map<String, dynamic>> _getFxQuotes(String base,
      List<String> quotes, http.Client client, Logger logger) async {
    final List<String> symbolList =
        quotes.map((String quote) => base + quote + '=X').toList();

    return await FinanceQuote.getRawData(
        quoteProvider: QuoteProvider.yahoo,
        symbols: symbolList,
        client: client,
        logger: logger);
  }
}
