part of 'counter_bloc.dart';

class CounterState extends Equatable {
  final int year;
  final int month;
  final double accumulatedTotal;
  const CounterState(
      {required this.year,
      required this.month,
      required this.accumulatedTotal});

  @override
  List<Object> get props => [year, month, accumulatedTotal];
}
