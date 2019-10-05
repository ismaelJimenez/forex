// Copyright 2019 Ismael Jiménez. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library forex;

import 'package:meta/meta.dart';
import 'package:forex/src/utils/app_logger.dart';
import 'package:forex/src/quote_providers/ecb.dart';
import 'package:forex/src/quote_providers/yahoo.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// The identifier of the forex quote provider.
enum QuoteProvider { ecb, yahoo }

class Forex {
  /// Returns a [Map] object containing the forex quote price data retrieved, with a given currency base.
  /// The map contains a key for each symbol retrieved and the value is num currency price.
  /// In case no valid quote data is retrieved, an empty map is returned.
  ///
  /// The `quoteProvider` argument controls where the quote data comes from. This can
  /// be any of the values of [QuoteProvider].
  ///
  /// The `base` argument controls the base currency against the quotes price is given.
  /// This can be any string identifying a valid currency for the [QuoteProvider].
  ///
  /// The `quotes` argument controls which currency quotes shall be retrieved. This can
  /// be any string identifying a valid currency for the [QuoteProvider].
  ///
  /// If specified, the `client` provided will be used, otherwise default http IO client.
  /// This is used for testing purposes.
  ///
  /// If specified, the `logger` provided will be used, otherwise default Logger will be used.
  static Future<Map<String, num>> fx(
      {@required QuoteProvider quoteProvider,
      @required String base,
      @required List<String> quotes,
      http.Client client,
      Logger logger}) async {
    // If client is not provided, use http IO client
    client ??= http.Client();

    // If logger is not provided, use default logger
    logger ??= Logger(printer: AppLogger('Forex'));

    // Retrieved market data.
    Map<String, num> retrievedQuoteData = <String, num>{};

    if (quotes.isEmpty || base == null) {
      return retrievedQuoteData;
    }

    switch (quoteProvider) {
      case QuoteProvider.yahoo:
        {
          retrievedQuoteData = await Yahoo.fx(base, quotes, client, logger);
        }
        break;
      case QuoteProvider.ecb:
        {
          retrievedQuoteData = await Ecb.fx(base, quotes, client, logger);
        }
        break;
      default:
        {
          logger.e('Unknown Forex Quote Source');
        }
        break;
    }

    return retrievedQuoteData;
  }
}
