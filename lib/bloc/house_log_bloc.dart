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
            imageFile: new File(''))) {
    on<AddHouseLog>((event, emit) {
      emit(HouseLogState(
          amount: event.amount,
          dateTime: event.dateTime,
          description: event.description,
          houseId: event.houseId,
          id: event.id,
          imageLink: event.imageLink,
          imageFile: event.imageFile));
      // TODO: implement event handler
    });

    on<UpdateHouseLogImage>((event, emit) {
      print('update image');
      emit(HouseLogState(
          amount: state.amount,
          dateTime: state.dateTime,
          description: state.description,
          houseId: state.houseId,
          id: state.id,
          imageFile: event.imageFile,
          imageLink: event.imageLink));
      // TODO: implement event handler
    });
  }
}
