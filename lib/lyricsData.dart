import 'package:riverpod/riverpod.dart';

class MyData extends StateNotifier<String> {
  MyData() : super('');
  void changState(newState) => this.state = newState;
}
