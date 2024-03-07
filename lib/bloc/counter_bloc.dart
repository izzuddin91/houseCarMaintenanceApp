import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
part 'counter_event.dart';

part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc()
      : super(CounterState(
            year: DateTime.now().year, month: DateTime.now().month)) {
    on<InitialLoadEvent>((event, emit) {
      //TODO
      emit(
          CounterState(year: DateTime.now().year, month: DateTime.now().month));
    });

    on<UpdateYearEvent>((event, emit) {
      //TODO
      emit(CounterState(
        year: event.year,
        month: state.month,
      ));
    });

    on<UpdateMonthEvent>((event, emit) {
      //TODO
      emit(CounterState(year: state.year, month: event.month));
    });
  }

  Stream<CounterState> mapEventToState(CounterEvent event) async* {
    // if (event is IncrementEvent) {
    //   yield CounterState(counter: state.counter + 1);
    // } else if (state is DecrementEvent) {
    //   yield CounterState(counter: state.counter - 1);
    // }
  }
}
