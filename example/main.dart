import 'package:forex/forex.dart';

Future<void> main(List<String> arguments) async {
  Map<String, num> quotes = await Forex.fx(
      quoteProvider: QuoteProvider.yahoo,
      base: 'USD',
      quotes: <String>['EUR', 'JPY']);

  print('Number of quotes retrieved: ${quotes.keys.length}.');
  print('Exchange rate USDEUR: ${quotes['USDEUR']}.');
  print('Exchange rate USDJPY: ${quotes['USDJPY']}.');

  quotes = await Forex.fx(
      quoteProvider: QuoteProvider.ecb,
      base: 'JPY',
      quotes: <String>['EUR', 'USD']);

  print('Number of quotes retrieved: ${quotes.keys.length}.');
  print('Exchange rate JPYEUR: ${quotes['JPYEUR']}.');
  print('Exchange rate JPYUSD: ${quotes['JPYUSD']}.');
}
