// Copyright 2019 Ismael Jiménez. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';

class EcbApiException implements Exception {
  final int statusCode;
  final String message;

  const EcbApiException({this.statusCode, this.message});
}

class Ecb {
  static Future<Map<String, num>> fx(String base, List<String> quotes,
      http.Client client, Logger logger) async {
    final Map<String, num> results = <String, num>{};

    try {
      final Map<String, num> fxQuotes = await _getFxQuotes(client);

      // Search in the answer obtained the data corresponding to the symbols.
      // If requested symbol data is found add it to results.
      if (base == 'EUR') {
        fxQuotes.forEach((String key, num value) {
          if (quotes.contains(key)) {
            results[base+key] = value;
          }
        });
      } else {
        if (fxQuotes.containsKey(base)) {
          final num baseQuote = 1 / fxQuotes[base];

          if (quotes.contains('EUR')) {
            results[base+'EUR'] = baseQuote;
          }

          fxQuotes.forEach((String key, num value) {
            if (quotes.contains(key)) {
              results[base+key] = value * baseQuote;
            }
          });
        }
      }
    } on EcbApiException catch (e) {
      logger.e(
          'EcbApiException{base: $base, quotes: ${quotes.join(',')}, statusCode: ${e.statusCode}, message: ${e.message}}');
    }

    for (String symbol in quotes) {
      if (!results.containsKey(base+symbol)) {
        logger.e('EcbApi: Symbol $symbol not found.');
      }
    }

    return results;
  }

  static Future<Map<String, num>> _getFxQuotes(http.Client client) async {
    const String quoteUrl =
        'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml';
    try {
      final http.Response quoteRes = await client.get(quoteUrl);
      if (quoteRes != null &&
          quoteRes.statusCode == 200 &&
          quoteRes.body != null) {
        return parseRawQuote(quoteRes.body);
      } else {
        throw EcbApiException(
            statusCode: quoteRes?.statusCode, message: 'Invalid response.');
      }
    } on http.ClientException {
      throw const EcbApiException(message: 'Connection failed.');
    }
  }

  static Map<String, num> parseRawQuote(String quoteResBody) {
    final Map<String, num> results = <String, num>{};

    try {
      final XmlDocument document = xml.parse(quoteResBody);

      final Iterable<xml.XmlElement> allNodes =
          document.findAllElements('Cube');

      for (xml.XmlElement node in allNodes) {
        final String currency = node.getAttribute('currency');
        final String rate = node.getAttribute('rate');

        if (currency != null && rate != null) {
          results[currency] = num.parse(rate);
        }
      }
      return results;
    } catch (e) {
      throw const EcbApiException(
          statusCode: 200, message: 'Quote was not parseable.');
    }
  }
}
