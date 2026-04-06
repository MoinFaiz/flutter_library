import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/shared/widgets/app_error_widget.dart';
import 'package:flutter_library/shared/widgets/loading_widget.dart';
import '../bloc/policy_bloc.dart';
import '../bloc/policy_event.dart';
import '../bloc/policy_state.dart';
import '../widgets/markdown_viewer.dart';

/// Generic policy page that can display any policy
class PolicyPage extends StatelessWidget {
  final String policyId;
  final String title;

  const PolicyPage({
    super.key,
    required this.policyId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PolicyBloc>().add(RefreshPolicy(policyId));
            },
          ),
        ],
      ),
      body: BlocBuilder<PolicyBloc, PolicyState>(
        builder: (context, state) {
          if (state is PolicyInitial) {
            // Load policy when page is first opened
            context.read<PolicyBloc>().add(LoadPolicy(policyId));
            return const LoadingWidget();
          }
          
          if (state is PolicyLoading) {
            return const LoadingWidget();
          }
          
          if (state is PolicyLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PolicyBloc>().add(RefreshPolicy(policyId));
              },
              child: MarkdownViewer(
                content: state.policy.content,
                title: state.policy.title,
                lastUpdated: state.policy.lastUpdated,
              ),
            );
          }
          
          if (state is PolicyError) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PolicyBloc>().add(LoadPolicy(policyId));
              },
              child: AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<PolicyBloc>().add(LoadPolicy(policyId));
                },
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
