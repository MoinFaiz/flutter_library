import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/injection/injection_container.dart';
import '../bloc/policy_bloc.dart';
import 'policy_page.dart';

/// Terms & Conditions page
class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PolicyBloc>(),
      child: const PolicyPage(
        policyId: 'terms',
        title: 'Terms & Conditions',
      ),
    );
  }
}