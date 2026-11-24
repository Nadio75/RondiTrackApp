import '../../../core/localization/localization_context.dart';

import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.activity)),
      body: Center(child: Text(l10n.activityEmpty)),
    );
  }
}
