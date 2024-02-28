part of 'counter_bloc.dart';

class CounterState extends Equatable {
  final int year;
  final int month;
  const CounterState({required this.year, required this.month});

  @override
  List<Object> get props => [year, month];
}
