import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../cubit/audience_form/admin_audience_form_cubit.dart';
import '../cubit/audience_form/admin_audience_form_state.dart';
import 'admin_audience_form_view.dart';

class AdminAudienceCreatePage extends StatelessWidget {
  const AdminAudienceCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminAudienceFormCubit>()..loadCreate(),
      child: const AdminAudienceFormView(mode: AdminAudienceFormMode.create),
    );
  }
}
