part of 'house_log_bloc.dart';

abstract class HouseLogEvent extends Equatable {
  const HouseLogEvent();

  @override
  List<Object> get props => [];
}

class AddHouseLog extends HouseLogEvent {
  final DateTime dateTime;
  final String description;
  final double amount;
  final String houseId;
  final File imageFile;
  const AddHouseLog(
      {required this.dateTime,
      required this.description,
      required this.amount,
      required this.houseId,
      required this.imageFile});
}

class UpdateHouseLogImage extends HouseLogEvent {
  final File imageFile;
  const UpdateHouseLogImage({required this.imageFile});
}
