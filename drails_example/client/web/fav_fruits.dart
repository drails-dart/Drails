import 'package:polymer/polymer.dart';

@CustomTag('fav-fruits')
class FavFruitsElement extends PolymerElement {
  final List fruits = toObservable(['apples', 'pears', 'bananas']);

  FavFruitsElement.created() : super.created();
}