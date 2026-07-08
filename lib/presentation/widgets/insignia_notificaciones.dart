import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/obtener_no_leidas_usecase.dart';
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
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarNoLeidas();
    _refreshTimer = Timer.periodic(
        const Duration(seconds: 30), (_) {
      if (mounted) _cargarNoLeidas();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cargarNoLeidas();
    }
  }

  @override
  void didUpdateWidget(
      covariant InsigniaNotificaciones oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cargarNoLeidas();
  }

  Future<void> _cargarNoLeidas() async {
    try {
      final useCase = sl<ObtenerNoLeidasUseCase>();
      final count =
          await useCase.execute(widget.usuarioId);
      if (mounted) {
        setState(() => _noLeidas = count);
      }
    } catch (e) {
      print('Error cargando no leídas: $e');
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
                _cargarNoLeidas();
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
