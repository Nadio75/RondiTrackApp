import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_version_provider.dart';

class AppVersionTile extends ConsumerWidget {
  const AppVersionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider);
    final nso = Localizations.localeOf(context).languageCode == 'nso';

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline),
          title: Text(nso ? 'Phetolelo ya tirišo' : 'Application version'),
          subtitle: version.when(
            data: (info) => Text(
              '${info.version} (${info.buildNumber})',
              key: const Key('installed_app_version'),
            ),
            loading: () => Text(nso ? 'E a laetša...' : 'Loading...'),
            error: (error, stackTrace) =>
                Text(nso ? 'Ga e hwetšagale' : 'Version unavailable'),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.layers_outlined),
          title: Text(nso ? 'Tikologo' : 'Environment'),
          subtitle: Text(
            appEnvironmentLabel(configuredAppFlavor),
            key: const Key('installed_app_environment'),
          ),
        ),
      ],
    );
  }
}
