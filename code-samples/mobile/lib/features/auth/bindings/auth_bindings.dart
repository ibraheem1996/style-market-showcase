// Package imports:
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:my_project/features/auth/presentation/navigation/verify_route_args.dart';

// Project imports:
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../../core/services/firebase_google_auth_service.dart';
import '../../../../core/services/performance_service.dart';
import '../../../../core/storage/prefs_storage.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/forget_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/send_email_code_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/verify_reset_code_usecase.dart';
import '../controllers/forget_password_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/set_new_password_controller.dart';
import '../controllers/signup_controller.dart';
import '../controllers/verify_email_controller.dart';
import '../controllers/verify_reset_password_controller.dart';
import '../navigation/login_route_args.dart';
import '../navigation/set_new_password_route_args.dart';
import '../navigation/verify_rest_route_args.dart';

//! Bindings for authentication feature
class AuthBindings {
  static void setup() {
    //! Data Sources
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<Dio>()),
    );
    getIt.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(getIt<PrefsStorage>()),
    );
    getIt.registerLazySingleton<FirebaseGoogleAuthService>(
      () => FirebaseGoogleAuthService(),
    );

    //! Repositories
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        localDataSource: getIt<AuthLocalDataSource>(),
        tokenStorage: getIt<TokenStorage>(),
        googleAuthService: getIt<FirebaseGoogleAuthService>(),
        analytics: getIt<AnalyticsService>(),
        crash: getIt<CrashlyticsService>(),
        performance: getIt<PerformanceService>(),
      ),
    );

    //! Use Cases
    getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<SignInWithGoogleUseCase>(
      () => SignInWithGoogleUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<SignOutUseCase>(
      () => SignOutUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<SignupUseCase>(
      () => SignupUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<SendEmailCodeUseCase>(
      () => SendEmailCodeUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<VerifyEmailUseCase>(
      () => VerifyEmailUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<ForgetPasswordUseCase>(
      () => ForgetPasswordUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<VerifyResetCodeUseCase>(
      () => VerifyResetCodeUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<UpdatePasswordUseCase>(
      () => UpdatePasswordUseCase(getIt<AuthRepository>()),
    );
  }
}

class BindingLogin extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments;
    final loginRouteArgs = (arguments is LoginRouteArgs)
        ? arguments
        : const LoginRouteArgs();

    Get.lazyPut<LoginController>(
      () => LoginController(
        loginUseCase: getIt<LoginUseCase>(),
        signInWithGoogleUseCase: getIt<SignInWithGoogleUseCase>(),
        sendEmailCodeUseCase: getIt<SendEmailCodeUseCase>(),
        arguments: loginRouteArgs,
      ),
    );
  }
}

class BindingSignUp extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(
      () => SignupController(
        signupUseCase: getIt<SignupUseCase>(),
        signInWithGoogleUseCase: getIt<SignInWithGoogleUseCase>(),
        sendEmailCodeUseCase: getIt<SendEmailCodeUseCase>(),
      ),
    );
  }
}

class BindingVerifyEmail extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments;
    final verifyRouteArgs = (arguments is VerifyRouteArgs)
        ? arguments
        : const VerifyRouteArgs(email: "");
    Get.lazyPut<VerifyEmailController>(
      () => VerifyEmailController(
        sendEmailCodeUseCase: getIt<SendEmailCodeUseCase>(),
        verifyEmailUseCase: getIt<VerifyEmailUseCase>(),
        arguments: verifyRouteArgs,
      ),
    );
  }
}

class BindingForgetPassword extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgetPasswordController>(
      () => ForgetPasswordController(getIt<ForgetPasswordUseCase>()),
    );
  }
}

class BindingVerifyResetPassword extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments;
    final verifyRestRouteArgs = (arguments is VerifyRestRouteArgs)
        ? arguments
        : const VerifyRestRouteArgs(email: "");
    Get.lazyPut<VerifyResetPasswordController>(
      () => VerifyResetPasswordController(
        forgetPasswordUseCase: getIt<ForgetPasswordUseCase>(),
        verifyResetCodeUseCase: getIt<VerifyResetCodeUseCase>(),
        arguments: verifyRestRouteArgs,
      ),
    );
  }
}

class BindingSetNewPassword extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments;
    final setNewPasswordRouteArgs = (arguments is SetNewPasswordRouteArgs)
        ? arguments
        : const SetNewPasswordRouteArgs(email: "", verifyCode: "");
    Get.lazyPut<SetNewPasswordController>(
      () => SetNewPasswordController(
        updatePasswordUseCase: getIt<UpdatePasswordUseCase>(),
        arguments: setNewPasswordRouteArgs,
      ),
    );
  }
}
