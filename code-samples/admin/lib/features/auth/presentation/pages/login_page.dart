import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../cubit/admin_session_cubit.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screen = AppResponsive.of(context);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: AppSpacing.pagePadding(screen),
                      child: BlocListener<LoginCubit, LoginState>(
                        listenWhen: (previous, current) =>
                            previous.session != current.session &&
                            current.session != null,
                        listener: (context, state) {
                          final session = state.session!;
                          context
                              .read<AdminSessionCubit>()
                              .acceptAuthenticatedSession(session.admin);
                        },
                        child: BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            final cubit = context.read<LoginCubit>();
                            return LoginForm(
                              state: state,
                              onEmailChanged: cubit.emailChanged,
                              onPasswordChanged: cubit.passwordChanged,
                              onSubmit: cubit.submit,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
