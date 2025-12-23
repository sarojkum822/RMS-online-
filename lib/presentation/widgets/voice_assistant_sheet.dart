import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/kiraya_voice_service.dart';
import '../../core/utils/intent_parser_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../providers/data_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../screens/owner/rent/rent_controller.dart';
import '../screens/owner/tenant/tenant_controller.dart';
import '../screens/owner/settings/owner_controller.dart';

final kirayaVoiceServiceProvider = Provider<KirayaVoiceService>((ref) => KirayaVoiceService());

class VoiceAssistantSheet extends ConsumerStatefulWidget {
  const VoiceAssistantSheet({super.key});

  @override
  ConsumerState<VoiceAssistantSheet> createState() => _VoiceAssistantSheetState();
}

class _VoiceAssistantSheetState extends ConsumerState<VoiceAssistantSheet> with SingleTickerProviderStateMixin {
  String _transcription = 'Listening...';
  String? _answer;
  bool _isListening = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _startVoiceRecognition();
  }

  Future<void> _startVoiceRecognition() async {
    final service = ref.read(kirayaVoiceServiceProvider);
    setState(() => _isListening = true);
    
    await service.startListening(
      onResult: (text) {
        setState(() => _transcription = text);
      },
      onDone: () {
        _handleTranscriptionDone();
      },
    );
  }

  void _handleTranscriptionDone() {
    if (!mounted) return;
    setState(() => _isListening = false);
    
    final action = IntentParserUtils.parse(_transcription);
    
    switch (action.intent) {
      case KirayaIntent.getRevenue:
        final stats = ref.read(dashboardStatsProvider).valueOrNull;
        final owner = ref.read(ownerControllerProvider).valueOrNull;
        final symbol = CurrencyUtils.getSymbol(owner?.currency);
        final revenue = stats?.thisMonthCollected ?? 0.0;
        setState(() => _answer = 'You have collected $symbol${CurrencyUtils.formatNumber(revenue)} this month.');
        break;
      case KirayaIntent.getOccupancy:
        final tenants = ref.read(tenantControllerProvider).valueOrNull ?? [];
        final occupiedCount = tenants.where((t) => t.isActive).length;
        setState(() => _answer = 'You currently have $occupiedCount active tenants.');
        break;
      case KirayaIntent.checkPendingRent:
        final stats = ref.read(dashboardStatsProvider).valueOrNull;
        final owner = ref.read(ownerControllerProvider).valueOrNull;
        final symbol = CurrencyUtils.getSymbol(owner?.currency);
        final pending = stats?.totalPending ?? 0.0;
        setState(() => _answer = 'There is a total of $symbol${CurrencyUtils.formatNumber(pending)} pending rent.');
        break;
      case KirayaIntent.addTenant:
      case KirayaIntent.addProperty:
      case KirayaIntent.openVault:
      case KirayaIntent.showReports:
        // These still navigate
        _navigate(action);
        return;
      default:
        setState(() => _answer = 'I understood you said: \"$_transcription\", but I don\'t have an action for that yet.');
    }

    // Auto-close after 4 seconds if it was just an answer
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _navigate(VoiceAction action) {
    Navigator.pop(context);
    switch (action.intent) {
      case KirayaIntent.addTenant:
        context.push('/owner/tenants/add', extra: action.entities);
        break;
      case KirayaIntent.addProperty:
        context.push('/owner/houses/add');
        break;
      case KirayaIntent.openVault:
        context.push('/owner/vault');
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    ref.read(kirayaVoiceServiceProvider).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          
          // Transcription Text
          Text(
            _transcription.isEmpty ? 'Say something like "Add a tenant"...' : _transcription,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: _transcription.isEmpty ? Colors.grey : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          
          if (_answer != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
              ),
              child: Text(
                _answer!,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          
          const SizedBox(height: 48),
          
          // Pulsing Mic Button (Only if listening)
          if (_isListening)
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mic_rounded,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          else 
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 40,
                color: Colors.green,
              ),
            ),
          
          const SizedBox(height: 24),
          Text(
            'Kiraya Voice Assistant',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
