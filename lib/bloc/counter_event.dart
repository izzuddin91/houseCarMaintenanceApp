part of 'counter_bloc.dart';

abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

class UpdateYearEvent extends CounterEvent {
  final int year;

  const UpdateYearEvent({required this.year});
  // @override
  // List<Object> get props => [year];
}

class UpdateMonthEvent extends CounterEvent {
  final int month;

  const UpdateMonthEvent({required this.month});
}

class UpdateGreaterThanDateString extends CounterEvent {
  final String value;

  const UpdateGreaterThanDateString({required this.value});
}

class UpdateLessThanDateString extends CounterEvent {
  final String value;

  const UpdateLessThanDateString({required this.value});
}

class DecrementEvent extends CounterEvent {}

class InitialLoadEvent extends CounterEvent {}
