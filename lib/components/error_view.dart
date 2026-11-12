import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

bool isNetworkError(Object? error) => error is ClientException || error is TimeoutException;

class ErrorView extends StatelessWidget {
    const ErrorView({ super.key, required this.error, this.onRetry });

    final Object? error;
    final VoidCallback? onRetry;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final offline = isNetworkError(error);

        return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                        child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 12,
                                children: [
                                    Icon(
                                        offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                                        size: 64,
                                        color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    Text(
                                        offline ? "Pas de connexion" : "Une erreur est survenue",
                                        style: theme.textTheme.titleLarge,
                                        textAlign: TextAlign.center,
                                    ),
                                    Text(
                                        offline
                                            ? "Vérifie ta connexion Internet puis réessaie."
                                            : "Impossible de charger les données pour le moment.",
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                    ),
                                    if (onRetry != null) Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: FilledButton.tonalIcon(
                                            onPressed: onRetry,
                                            icon: const Icon(Icons.refresh),
                                            label: const Text("Réessayer"),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}
