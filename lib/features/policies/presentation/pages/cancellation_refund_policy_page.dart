import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/injection/injection_container.dart';
import '../bloc/policy_bloc.dart';
import 'policy_page.dart';

/// Cancellation & Refund Policy page
class CancellationRefundPolicyPage extends StatelessWidget {
  const CancellationRefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PolicyBloc>(),
      child: const PolicyPage(
        policyId: 'cancellation',
        title: 'Cancellation & Refund Policy',
      ),
    );
  }
}