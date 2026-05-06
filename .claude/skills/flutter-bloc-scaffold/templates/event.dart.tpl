import 'package:equatable/equatable.dart';

abstract class {{Feature}}Event extends Equatable {
  const {{Feature}}Event();

  @override
  List<Object?> get props => [];
}

class {{Feature}}Requested extends {{Feature}}Event {
  const {{Feature}}Requested();
}

class {{Feature}}ErrorCleared extends {{Feature}}Event {
  const {{Feature}}ErrorCleared();
}
