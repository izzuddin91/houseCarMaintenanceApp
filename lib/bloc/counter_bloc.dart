import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
part 'counter_event.dart';

part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc()
      : super(CounterState(
          year: DateTime.now().year,
          month: DateTime.now().month,
          accumulatedTotal: 0.0,
        )) {
    on<InitialLoadEvent>((event, emit) {
      //TODO
      emit(CounterState(
        year: DateTime.now().year,
        month: DateTime.now().month,
        accumulatedTotal: state.accumulatedTotal,
      ));
    });

    on<UpdateYearEvent>((event, emit) {
      //TODO
      emit(CounterState(
        year: event.year,
        accumulatedTotal: state.accumulatedTotal,
        month: state.month,
      ));
    });

    on<UpdateMonthEvent>((event, emit) {
      //TODO
      emit(CounterState(
        year: state.year,
        month: event.month,
        accumulatedTotal: state.accumulatedTotal,
      ));
    });

    on<UpdateAccumulatedTotal>((event, emit) {
      //TODO
      emit(CounterState(
        year: state.year,
        month: state.month,
        accumulatedTotal: event.accumulatedTotal,
      ));
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
