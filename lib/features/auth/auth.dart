/// Auth feature module barrel export

// Domain
export 'domain/entities/user.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/usecases/send_otp_usecase.dart';
export 'domain/usecases/verify_otp_usecase.dart';
export 'domain/usecases/complete_profile_usecase.dart';
export 'domain/usecases/logout_usecase.dart';
export 'domain/usecases/get_current_user_usecase.dart';

// Data
export 'data/models/user_model.dart';
export 'data/datasources/auth_remote_datasource.dart';
export 'data/datasources/auth_local_datasource.dart';
export 'data/repositories/auth_repository_impl.dart';

// Presentation
export 'presentation/bloc/auth_bloc.dart';
export 'presentation/bloc/auth_event.dart';
export 'presentation/bloc/auth_state.dart';
export 'presentation/screens/splash_screen.dart';
export 'presentation/screens/onboarding_screen.dart';
export 'presentation/screens/login_screen.dart';
export 'presentation/screens/otp_screen.dart';
export 'presentation/screens/register_screen.dart';
