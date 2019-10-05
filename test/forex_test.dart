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

String ecbValidResponse = r"""<?xml version="1.0" encoding="UTF-8"?>
<gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
<gesmes:subject>Reference rates</gesmes:subject>
<gesmes:Sender>
<gesmes:name>European Central Bank</gesmes:name>
</gesmes:Sender>
<Cube>
<Cube time='2019-10-04'>
<Cube currency='USD' rate='1.0979'/>
<Cube currency='JPY' rate='117.23'/>
<Cube currency='BGN' rate='1.9558'/>
<Cube currency='CZK' rate='25.741'/>
<Cube currency='DKK' rate='7.4666'/>
<Cube currency='GBP' rate='0.89045'/>
<Cube currency='HUF' rate='332.76'/>
<Cube currency='PLN' rate='4.3245'/>
<Cube currency='RON' rate='4.7480'/>
<Cube currency='SEK' rate='10.8105'/>
<Cube currency='CHF' rate='1.0913'/>
<Cube currency='ISK' rate='135.70'/>
<Cube currency='NOK' rate='9.9915'/>
<Cube currency='HRK' rate='7.4215'/>
<Cube currency='RUB' rate='71.1420'/>
<Cube currency='TRY' rate='6.2505'/>
<Cube currency='AUD' rate='1.6247'/>
<Cube currency='BRL' rate='4.4726'/>
<Cube currency='CAD' rate='1.4612'/>
<Cube currency='CNY' rate='7.8497'/>
<Cube currency='HKD' rate='8.6099'/>
<Cube currency='IDR' rate='15531.39'/>
<Cube currency='ILS' rate='3.8254'/>
<Cube currency='INR' rate='77.8415'/>
<Cube currency='KRW' rate='1312.32'/>
<Cube currency='MXN' rate='21.5087'/>
<Cube currency='MYR' rate='4.5953'/>
<Cube currency='NZD' rate='1.7350'/>
<Cube currency='PHP' rate='56.811'/>
<Cube currency='SGD' rate='1.5139'/>
<Cube currency='THB' rate='33.437'/>
<Cube currency='ZAR' rate='16.6446'/>
</Cube>
</Cube>
</gesmes:Envelope>""";

void main() {
  test('fx - No quotes', () async {
    final MockClient client = MockClient();

    Map<String, num> quote;
    try {
      quote = await Forex.fx(
          quoteProvider: QuoteProvider.ecb,
          base: 'EUR',
          quotes: <String>[],
          client: client);
    } catch (e) {
      expect(e, 'No exception');
    }

    expect(quote.keys.length, 0);
  });

  test('fx - No base', () async {
    final MockClient client = MockClient();

    Map<String, num> quote;
    try {
      quote = await Forex.fx(
          quoteProvider: QuoteProvider.ecb,
          base: null,
          quotes: <String>[],
          client: client);
    } catch (e) {
      expect(e, 'No exception');
    }

    expect(quote.keys.length, 0);
  });

  group('Fx Test [Forex] - Ecb', () {
    test('Ecb: base EUR and 1 valid quote, 200 - Response', () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .thenAnswer((_) async => http.Response(ecbValidResponse, 200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.ecb,
            base: 'EUR',
            quotes: <String>['USD'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 1);
      expect(quotes['EURUSD'], 1.0979);

      verify(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .called(1);
    });

    test('Ecb: base EUR and 3 valid quotes, 200 - Response', () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .thenAnswer((_) async => http.Response(ecbValidResponse, 200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.ecb,
            base: 'EUR',
            quotes: <String>['USD', 'JPY', 'CAD'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 3);
      expect(quotes['EURUSD'], 1.0979);
      expect(quotes['EURJPY'], 117.23);
      expect(quotes['EURCAD'], 1.4612);

      verify(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .called(1);
    });

    test('Ecb: base EUR, 2 valid quotes and 1 invalid quote, 200 - Response',
        () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .thenAnswer((_) async => http.Response(ecbValidResponse, 200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.ecb,
            base: 'EUR',
            quotes: <String>['USD', 'JPYT', 'CAD'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 2);
      expect(quotes['EURUSD'], 1.0979);
      expect(quotes['EURCAD'], 1.4612);

      verify(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .called(1);
    });

    test('Ecb: base EUR and 1 invalid quote, 200 - Response', () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .thenAnswer((_) async => http.Response(ecbValidResponse, 200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.ecb,
            base: 'EUR',
            quotes: <String>['JPYT'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 0);

      verify(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .called(1);
    });

    test('Ecb: base NOT EUR and 3 quotes containg EUR, 200 - Response',
        () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .thenAnswer((_) async => http.Response(ecbValidResponse, 200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.ecb,
            base: 'USD',
            quotes: <String>['EUR', 'CADFAIL', 'JPY'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 2);
      expect(quotes['USDEUR'], 0.91082976591675);
      expect(quotes['USDJPY'], 106.77657345842061);

      verify(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .called(1);
    });

    test('Ecb: base NOT valid and 3 quotes containg EUR, 200 - Response',
        () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .thenAnswer((_) async => http.Response(ecbValidResponse, 200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.ecb,
            base: 'USDFAIL',
            quotes: <String>['EUR', 'CADFAIL', 'JPY'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 0);

      verify(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .called(1);
    });

    test('Ecb: null, 200 - Response', () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .thenAnswer((_) async => http.Response('', 200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.ecb,
            base: 'USD',
            quotes: <String>['EUR', 'CADFAIL', 'JPY'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 0);

      verify(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .called(1);
    });

    test('Ecb: null, 404 - Response', () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .thenAnswer((_) async => http.Response('', 404));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.ecb,
            base: 'USD',
            quotes: <String>['EUR', 'CADFAIL', 'JPY'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 0);

      verify(client.get(
              'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'))
          .called(1);
    });
  });

  group('Fx Test [Forex] - Yahoo', () {
    test('Yahoo: base EUR and 1 valid quote, 200 - Response', () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=EURUSD=X'))
          .thenAnswer((_) async => http.Response(
              '{"quoteResponse":{"result":[{"language":"en-US","region":"US","quoteType":"CURRENCY","currency":"USD","regularMarketOpen":0.0,"regularMarketDayHigh":1.0986596,"regularMarketDayLow":1.0986596,"shortName":"EUR/USD","fiftyTwoWeekLow":1.0881511,"fiftyTwoWeekHigh":1.162007,"fiftyDayAverage":1.1046354,"twoHundredDayAverage":1.1190069,"regularMarketChangePercent":-0.0,"regularMarketPreviousClose":1.0986596,"bid":1.0986596,"ask":1.0980564,"regularMarketPrice":1.0986596,"regularMarketChange":0.0,"regularMarketVolume":0,"exchange":"CCY","market":"ccy_market","exchangeDataDelayedBy":0,"marketState":"CLOSED","fiftyTwoWeekRange":"1.0881511 - 1.162007","fiftyTwoWeekHighChange":-0.008790016,"fiftyTwoWeekHighChangePercent":-0.0075645125,"twoHundredDayAverageChangePercent":0.014790277,"fiftyDayAverageChange":0.00492388,"fiftyDayAverageChangePercent":0.004457471,"twoHundredDayAverageChange":0.016550422,"priceHint":4,"regularMarketDayRange":"1.0986596 - 1.0986596","bidSize":0,"askSize":0,"messageBoardId":"finmb_EUR_X","fullExchangeName":"CCY","averageDailyVolume3Month":0,"averageDailyVolume10Day":0,"fiftyTwoWeekLowChange":0.049619973,"fiftyTwoWeekLowChangePercent":0.04560026,"esgPopulated":false,"tradeable":false,"triggerable":false,"sourceInterval":15,"exchangeTimezoneName":"Europe/London","exchangeTimezoneShortName":"BST","gmtOffSetMilliseconds":3600000,"regularMarketTime":1570224600,"symbol":"EURUSD=X"}],"error":null}}',
              200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.yahoo,
            base: 'EUR',
            quotes: <String>['USD'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 1);
      expect(quotes['EURUSD'], 1.0986596);

      verify(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=EURUSD=X'))
          .called(1);
    });

    test('Yahoo: base EUR and 3 valid quotes, 200 - Response', () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=EURUSD=X,EURJPY=X,EURCAD=X'))
          .thenAnswer((_) async => http.Response(
              '{"quoteResponse":{"result":[{"language":"en-US","region":"US","quoteType":"CURRENCY","currency":"USD","fiftyDayAverage":1.1046354,"twoHundredDayAverage":1.1190069,"regularMarketPreviousClose":1.0986596,"bid":1.0986596,"ask":1.0980564,"fiftyTwoWeekLow":1.0881511,"fiftyTwoWeekHigh":1.162007,"shortName":"EUR/USD","regularMarketPrice":1.0986596,"regularMarketChange":0.0,"regularMarketOpen":0.0,"regularMarketDayHigh":1.0986596,"regularMarketDayLow":1.0986596,"regularMarketChangePercent":-0.0,"fiftyTwoWeekHighChangePercent":-0.0075645125,"exchange":"CCY","marketState":"CLOSED","fiftyDayAverageChange":0.00492388,"fiftyDayAverageChangePercent":0.004457471,"twoHundredDayAverageChange":0.016550422,"sourceInterval":15,"exchangeTimezoneName":"Europe/London","exchangeTimezoneShortName":"BST","gmtOffSetMilliseconds":3600000,"regularMarketDayRange":"1.0986596 - 1.0986596","bidSize":0,"askSize":0,"messageBoardId":"finmb_EUR_X","fullExchangeName":"CCY","averageDailyVolume3Month":0,"averageDailyVolume10Day":0,"fiftyTwoWeekLowChange":0.049619973,"fiftyTwoWeekLowChangePercent":0.04560026,"fiftyTwoWeekRange":"1.0881511 - 1.162007","fiftyTwoWeekHighChange":-0.008790016,"market":"ccy_market","exchangeDataDelayedBy":0,"twoHundredDayAverageChangePercent":0.014790277,"regularMarketTime":1570224600,"regularMarketVolume":0,"esgPopulated":false,"tradeable":false,"triggerable":false,"priceHint":4,"symbol":"EURUSD=X"},{"language":"en-US","region":"US","quoteType":"CURRENCY","currency":"JPY","fiftyTwoWeekHighChangePercent":-0.10551827,"exchange":"CCY","marketState":"CLOSED","fiftyDayAverage":117.74384,"fiftyDayAverageChange":-0.3538437,"fiftyDayAverageChangePercent":-0.0030051991,"twoHundredDayAverage":122.061584,"twoHundredDayAverageChange":-4.671585,"sourceInterval":15,"exchangeTimezoneName":"Europe/London","exchangeTimezoneShortName":"BST","gmtOffSetMilliseconds":3600000,"regularMarketDayRange":"117.39 - 117.39","regularMarketPreviousClose":117.39,"bid":117.39,"ask":117.39,"bidSize":0,"askSize":0,"messageBoardId":"finmb_EURJPY_X","fullExchangeName":"CCY","averageDailyVolume3Month":0,"averageDailyVolume10Day":0,"fiftyTwoWeekLowChange":1.5220032,"fiftyTwoWeekLowChangePercent":0.013135665,"fiftyTwoWeekRange":"115.868 - 131.238","fiftyTwoWeekHighChange":-13.848007,"fiftyTwoWeekLow":115.868,"fiftyTwoWeekHigh":131.238,"market":"ccy_market","exchangeDataDelayedBy":0,"twoHundredDayAverageChangePercent":-0.038272362,"shortName":"EUR/JPY","regularMarketPrice":117.39,"regularMarketTime":1570224840,"regularMarketChange":0.0,"regularMarketOpen":0.0,"regularMarketDayHigh":117.39,"regularMarketDayLow":117.39,"regularMarketVolume":0,"esgPopulated":false,"tradeable":false,"triggerable":false,"priceHint":4,"regularMarketChangePercent":0.0,"symbol":"EURJPY=X"},{"language":"en-US","region":"US","quoteType":"CURRENCY","currency":"CAD","fiftyTwoWeekHighChangePercent":-0.06627471,"exchange":"CCY","marketState":"CLOSED","fiftyDayAverage":1.4689732,"fiftyDayAverageChange":-0.007973194,"fiftyDayAverageChangePercent":-0.005427733,"twoHundredDayAverage":1.4904408,"twoHundredDayAverageChange":-0.02944088,"sourceInterval":15,"exchangeTimezoneName":"Europe/London","exchangeTimezoneShortName":"BST","gmtOffSetMilliseconds":3600000,"regularMarketDayRange":"1.461 - 1.461","regularMarketPreviousClose":1.461,"bid":1.461,"ask":1.4628,"bidSize":0,"askSize":0,"messageBoardId":"finmb_EURCAD_X","fullExchangeName":"CCY","averageDailyVolume3Month":0,"averageDailyVolume10Day":0,"fiftyTwoWeekLowChange":0.010999918,"fiftyTwoWeekLowChangePercent":0.00758615,"fiftyTwoWeekRange":"1.45 - 1.5647","fiftyTwoWeekHighChange":-0.10370004,"fiftyTwoWeekLow":1.45,"fiftyTwoWeekHigh":1.5647,"market":"ccy_market","exchangeDataDelayedBy":0,"twoHundredDayAverageChangePercent":-0.019753136,"shortName":"EUR/CAD","regularMarketPrice":1.461,"regularMarketTime":1570228218,"regularMarketChange":0.0,"regularMarketOpen":1.461,"regularMarketDayHigh":1.461,"regularMarketDayLow":1.461,"regularMarketVolume":0,"esgPopulated":false,"tradeable":false,"triggerable":false,"priceHint":4,"regularMarketChangePercent":0.0,"symbol":"EURCAD=X"}],"error":null}}',
              200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.yahoo,
            base: 'EUR',
            quotes: <String>['USD', 'JPY', 'CAD'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 3);
      expect(quotes['EURUSD'], 1.0986596);
      expect(quotes['EURJPY'], 117.39);
      expect(quotes['EURCAD'], 1.461);

      verify(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=EURUSD=X,EURJPY=X,EURCAD=X'))
          .called(1);
    });

    test('Yahoo: base EUR, 2 valid quotes and 1 invalid quote, 200 - Response',
        () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=EURUSD=X,EURJPYT=X,EURCAD=X'))
          .thenAnswer((_) async => http.Response(
              '{"quoteResponse":{"result":[{"language":"en-US","region":"US","quoteType":"CURRENCY","currency":"USD","fiftyTwoWeekLow":1.0881511,"fiftyTwoWeekHigh":1.162007,"fiftyDayAverage":1.1046354,"regularMarketChangePercent":-0.0,"bid":1.0986596,"regularMarketPreviousClose":1.0986596,"ask":1.0980564,"twoHundredDayAverage":1.1190294,"regularMarketPrice":1.0986596,"regularMarketChange":0.0,"regularMarketOpen":0.0,"regularMarketDayHigh":1.0986596,"regularMarketDayLow":1.0986596,"shortName":"EUR/USD","triggerable":false,"exchangeDataDelayedBy":0,"regularMarketDayRange":"1.0986596 - 1.0986596","bidSize":0,"askSize":0,"messageBoardId":"finmb_EUR_X","fullExchangeName":"CCY","averageDailyVolume3Month":0,"averageDailyVolume10Day":0,"fiftyTwoWeekLowChange":0.049619973,"fiftyTwoWeekLowChangePercent":0.04560026,"fiftyTwoWeekRange":"1.0881511 - 1.162007","fiftyTwoWeekHighChange":-0.008790016,"fiftyTwoWeekHighChangePercent":-0.0075645125,"fiftyDayAverageChange":0.00492388,"fiftyDayAverageChangePercent":0.004457471,"twoHundredDayAverageChange":0.016568422,"exchangeTimezoneName":"Europe/London","exchangeTimezoneShortName":"BST","gmtOffSetMilliseconds":3600000,"regularMarketTime":1570224600,"regularMarketVolume":0,"esgPopulated":false,"tradeable":false,"market":"ccy_market","priceHint":4,"exchange":"CCY","sourceInterval":15,"twoHundredDayAverageChangePercent":0.014806065,"marketState":"CLOSED","symbol":"EURUSD=X"},{"language":"en-US","region":"US","quoteType":"CURRENCY","currency":"CAD","fiftyTwoWeekLow":1.45,"fiftyTwoWeekHigh":1.5647,"triggerable":false,"exchangeDataDelayedBy":0,"fiftyDayAverage":1.4689732,"regularMarketChangePercent":0.0,"regularMarketDayRange":"1.461 - 1.461","bid":1.461,"regularMarketPreviousClose":1.461,"ask":1.4628,"bidSize":0,"askSize":0,"messageBoardId":"finmb_EURCAD_X","fullExchangeName":"CCY","averageDailyVolume3Month":0,"averageDailyVolume10Day":0,"fiftyTwoWeekLowChange":0.010999918,"fiftyTwoWeekLowChangePercent":0.00758615,"fiftyTwoWeekRange":"1.45 - 1.5647","fiftyTwoWeekHighChange":-0.10370004,"fiftyTwoWeekHighChangePercent":-0.06627471,"fiftyDayAverageChange":-0.007973194,"fiftyDayAverageChangePercent":-0.005427733,"twoHundredDayAverage":1.4904408,"twoHundredDayAverageChange":-0.02944088,"exchangeTimezoneName":"Europe/London","exchangeTimezoneShortName":"BST","gmtOffSetMilliseconds":3600000,"regularMarketPrice":1.461,"regularMarketTime":1570228218,"regularMarketChange":0.0,"regularMarketOpen":1.461,"regularMarketDayHigh":1.461,"regularMarketDayLow":1.461,"regularMarketVolume":0,"esgPopulated":false,"tradeable":false,"market":"ccy_market","priceHint":4,"shortName":"EUR/CAD","exchange":"CCY","sourceInterval":15,"twoHundredDayAverageChangePercent":-0.019753136,"marketState":"CLOSED","symbol":"EURCAD=X"}],"error":null}}',
              200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.yahoo,
            base: 'EUR',
            quotes: <String>['USD', 'JPYT', 'CAD'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 2);
      expect(quotes['EURUSD'], 1.0986596);
      expect(quotes['EURCAD'], 1.461);

      verify(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=EURUSD=X,EURJPYT=X,EURCAD=X'))
          .called(1);
    });

    test('Yahoo: base EUR and 1 invalid quote, 200 - Response', () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=EURJPYT=X'))
          .thenAnswer((_) async => http.Response(
              '{"quoteResponse":{"result":[],"error":null}}', 200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.yahoo,
            base: 'EUR',
            quotes: <String>['JPYT'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 0);

      verify(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=EURJPYT=X'))
          .called(1);
    });

    test('Yahoo: base NOT EUR and 3 quotes containg EUR, 200 - Response',
        () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=USDEUR=X,USDCADFAIL=X,USDJPY=X'))
          .thenAnswer((_) async => http.Response(
              '{"quoteResponse":{"result":[{"language":"en-US","region":"US","quoteType":"CURRENCY","currency":"EUR","shortName":"USD/EUR","regularMarketPrice":0.9102,"regularMarketChange":0.0,"regularMarketOpen":0.0,"regularMarketDayHigh":0.9102,"regularMarketDayLow":0.9102,"regularMarketChangePercent":0.0,"regularMarketPreviousClose":0.9102,"bid":0.9102,"ask":0.9107,"fiftyTwoWeekLow":0.86058,"fiftyTwoWeekHigh":0.91899,"fiftyDayAverage":0.9052761,"twoHundredDayAverage":0.8936316,"priceHint":4,"messageBoardId":"finmb_EUR_X","market":"ccy_market","regularMarketTime":1570224600,"regularMarketVolume":0,"regularMarketDayRange":"0.9102 - 0.9102","bidSize":0,"askSize":0,"fullExchangeName":"CCY","averageDailyVolume3Month":0,"averageDailyVolume10Day":0,"fiftyTwoWeekLowChange":0.049619973,"fiftyTwoWeekLowChangePercent":0.057658754,"fiftyTwoWeekRange":"0.86058 - 0.91899","fiftyTwoWeekHighChange":-0.008790016,"fiftyTwoWeekHighChangePercent":-0.009564865,"fiftyDayAverageChange":0.00492388,"fiftyDayAverageChangePercent":0.005439092,"marketState":"CLOSED","exchange":"CCY","twoHundredDayAverageChange":0.016568422,"twoHundredDayAverageChangePercent":0.018540552,"sourceInterval":15,"exchangeTimezoneName":"Europe/London","exchangeTimezoneShortName":"BST","gmtOffSetMilliseconds":3600000,"esgPopulated":false,"tradeable":false,"triggerable":false,"exchangeDataDelayedBy":0,"symbol":"USDEUR=X"},{"language":"en-US","region":"US","quoteType":"CURRENCY","currency":"JPY","shortName":"USD/JPY","regularMarketPrice":106.88,"regularMarketChange":0.0,"regularMarketOpen":106.88,"regularMarketDayHigh":106.88,"regularMarketDayLow":106.88,"regularMarketChangePercent":0.0,"regularMarketPreviousClose":106.88,"bid":106.88,"ask":106.99,"fiftyTwoWeekLow":104.871,"fiftyTwoWeekHigh":114.184,"fiftyDayAverage":106.99614,"twoHundredDayAverage":108.74016,"priceHint":4,"messageBoardId":"finmb_JPY_X","market":"ccy_market","regularMarketTime":1570228211,"regularMarketVolume":0,"regularMarketDayRange":"106.88 - 106.88","bidSize":0,"askSize":0,"fullExchangeName":"CCY","averageDailyVolume3Month":0,"averageDailyVolume10Day":0,"fiftyTwoWeekLowChange":2.008995,"fiftyTwoWeekLowChangePercent":0.019156821,"fiftyTwoWeekRange":"104.871 - 114.184","fiftyTwoWeekHighChange":-7.304001,"fiftyTwoWeekHighChangePercent":-0.06396694,"fiftyDayAverageChange":-0.11614227,"fiftyDayAverageChangePercent":-0.001085481,"marketState":"CLOSED","exchange":"CCY","twoHundredDayAverageChange":-1.8601608,"twoHundredDayAverageChangePercent":-0.017106475,"sourceInterval":15,"exchangeTimezoneName":"Europe/London","exchangeTimezoneShortName":"BST","gmtOffSetMilliseconds":3600000,"esgPopulated":false,"tradeable":false,"triggerable":false,"exchangeDataDelayedBy":0,"symbol":"USDJPY=X"}],"error":null}}',
              200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.yahoo,
            base: 'USD',
            quotes: <String>['EUR', 'CADFAIL', 'JPY'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 2);
      expect(quotes['USDEUR'], 0.9102);
      expect(quotes['USDJPY'], 106.88);

      verify(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=USDEUR=X,USDCADFAIL=X,USDJPY=X'))
          .called(1);
    });

    test('Yahoo: base NOT valid and 3 quotes containg EUR, 200 - Response',
        () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=USDFAILEUR=X,USDFAILCADFAIL=X,USDFAILJPY=X'))
          .thenAnswer((_) async => http.Response(
              '{"quoteResponse":{"result":[],"error":null}}', 200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.yahoo,
            base: 'USDFAIL',
            quotes: <String>['EUR', 'CADFAIL', 'JPY'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 0);

      verify(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=USDFAILEUR=X,USDFAILCADFAIL=X,USDFAILJPY=X'))
          .called(1);
    });

    test('Yahoo: null, 200 - Response', () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=USDEUR=X,USDCADFAIL=X,USDJPY=X'))
          .thenAnswer((_) async => http.Response('', 200));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.yahoo,
            base: 'USD',
            quotes: <String>['EUR', 'CADFAIL', 'JPY'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 0);

      verify(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=USDEUR=X,USDCADFAIL=X,USDJPY=X'))
          .called(1);
    });

    test('Yahoo: null, 404 - Response', () async {
      final MockClient client = MockClient();

      when(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=USDEUR=X,USDCADFAIL=X,USDJPY=X'))
          .thenAnswer((_) async => http.Response('', 404));

      Map<String, num> quotes;
      try {
        quotes = await Forex.fx(
            quoteProvider: QuoteProvider.yahoo,
            base: 'USD',
            quotes: <String>['EUR', 'CADFAIL', 'JPY'],
            client: client);
      } catch (e) {
        expect(e, 'No exception');
      }

      expect(quotes.keys.length, 0);

      verify(client.get(
              'https://query1.finance.yahoo.com/v7/finance/quote?symbols=USDEUR=X,USDCADFAIL=X,USDJPY=X'))
          .called(1);
    });
  });
}
