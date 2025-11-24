import 'package:equatable/equatable.dart';

abstract class SessionManagerEvent extends Equatable {
  const SessionManagerEvent();

  @override
  List<Object?> get props => [];
}

class CheckInProgressSession extends SessionManagerEvent {
  const CheckInProgressSession();
}
