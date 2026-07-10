import 'dart:async';
import 'package:flutter/material.dart';
import '../../infrastructure/providers/firestore_provider.dart';
import '../../injection.dart';

class InsigniaNotificaciones extends StatefulWidget {
  final String usuarioId;
  final VoidCallback? onTap;

  const InsigniaNotificaciones({
    super.key,
    required this.usuarioId,
    this.onTap,
  });

  @override
  State<InsigniaNotificaciones> createState() =>
      _InsigniaNotificacionesState();
}

class _InsigniaNotificacionesState
    extends State<InsigniaNotificaciones>
    with WidgetsBindingObserver {
  int _noLeidas = 0;
  StreamSubscription<int>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _suscribirFirestore();
  }

  void _suscribirFirestore() {
    _subscription?.cancel();
    final firestoreProvider = sl<FirestoreProvider>();
    _subscription = firestoreProvider
        .contarNoLeidas(widget.usuarioId)
        .listen(
      (count) {
        if (mounted) setState(() => _noLeidas = count);
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _subscription?.cancel();
      _suscribirFirestore();
    }
  }

  @override
  void didUpdateWidget(
      covariant InsigniaNotificaciones oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.usuarioId != widget.usuarioId) {
      _subscription?.cancel();
      _suscribirFirestore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(
              Icons.notifications_outlined),
          onPressed: widget.onTap ??
              () async {
                await Navigator.pushNamed(
                  context,
                  '/notificaciones',
                  arguments:
                      widget.usuarioId,
                );
              },
        ),
        if (_noLeidas > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                _noLeidas > 99
                    ? '99+'
                    : '$_noLeidas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
