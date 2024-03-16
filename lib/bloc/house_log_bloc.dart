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
            imageLink: '',
            id: '',
            imageFile: new File(''),
            logType: <bool>[false, true])) {
    on<AddHouseLog>((event, emit) {
      emit(HouseLogState(
          amount: event.amount,
          dateTime: event.dateTime,
          description: event.description,
          houseId: event.houseId,
          id: event.id,
          imageLink: event.imageLink,
          imageFile: event.imageFile,
          logType: state.logType));
      // TODO: implement event handler
    });

    on<UpdateHouseLogImage>((event, emit) {
      emit(HouseLogState(
          amount: state.amount,
          dateTime: state.dateTime,
          description: state.description,
          houseId: state.houseId,
          id: state.id,
          imageFile: event.imageFile,
          imageLink: event.imageLink,
          logType: state.logType));
      // TODO: implement event handler
    });

    on<UpdateLogType>((event, emit) {
      emit(HouseLogState(
          dateTime: state.dateTime,
          description: state.description,
          amount: state.amount,
          houseId: state.houseId,
          id: state.id,
          imageFile: state.imageFile,
          imageLink: state.imageLink,
          logType: event.logType));
    });
  }
}
