import 'dart:ffi';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'house_log_event.dart';
part 'house_log_state.dart';

class HouseLogBloc extends Bloc<HouseLogEvent, HouseLogState> {
  HouseLogBloc()
      : super(HouseLogState(
            amount: 0.0,
            dateTime: new DateTime.now(),
            description: '',
            houseId: '',
            imageFile: new File(''))) {
    on<AddHouseLog>((event, emit) {
      emit(HouseLogState(
          amount: event.amount,
          dateTime: event.dateTime,
          description: event.description,
          houseId: event.houseId,
          imageFile: event.imageFile));
      // TODO: implement event handler
    });

    on<UpdateHouseLogImage>((event, emit) {
      emit(HouseLogState(
          amount: state.amount,
          dateTime: state.dateTime,
          description: state.description,
          houseId: state.houseId,
          imageFile: event.imageFile));
      // TODO: implement event handler
    });
  }
}
