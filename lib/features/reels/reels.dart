/// Reels feature module barrel export

// Domain
export 'domain/entities/reel.dart';
export 'domain/repositories/reels_repository.dart';
export 'domain/usecases/get_reels_usecase.dart';
export 'domain/usecases/like_reel_usecase.dart';
export 'domain/usecases/save_reel_usecase.dart';

// Data
export 'data/models/reel_model.dart';
export 'data/datasources/reels_remote_datasource.dart';
export 'data/repositories/reels_repository_impl.dart';

// Presentation
export 'presentation/bloc/reels_bloc.dart';
export 'presentation/bloc/reels_event.dart';
export 'presentation/bloc/reels_state.dart';
export 'presentation/screens/reels_screen.dart';
export 'presentation/widgets/reel_player.dart';
export 'presentation/widgets/reel_overlay.dart';
export 'presentation/widgets/reel_actions.dart';
