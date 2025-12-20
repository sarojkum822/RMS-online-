import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'owner_controller.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  late Razorpay _razorpay;
  bool _isLoading = false;
  bool _isYearly = false; // Toggle for yearly pricing
  String _selectedPlan = 'pro'; // Default to recommended plan

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _initiatePayment(String planId, int amountInPaise) {
    if (planId.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _selectedPlan = planId;
    });
    
    // In Production: Call YOUR Backend to create an Order ID
    // final orderId = await backend.createOrder(amount);
    
    // For specific Key ID used below
    const String keyId = 'rzp_test_1DP5mmOlF5G5ag'; 

    var options = {
      'key': keyId, 
      'amount': amountInPaise, 
      'name': 'KirayaBook Pro',
      'description': '${planId.toUpperCase()} Subscription',
      'prefill': {
        'contact': '9876543210', // Get from User Profile
        'email': 'user@example.com' // Get from User Profile
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // 2. TRUE SECURITY: Verify on Server via Cloud Function
    try {
       setState(() => _isLoading = true); // Show loading while verifying
       
       debugPrint("Verifying payment on server...");
       
       final callable = FirebaseFunctions.instance.httpsCallable('verifyPayment');
       final result = await callable.call({
         'paymentId': response.paymentId,
         'orderId': response.orderId ?? '', // Might be empty in direct flow
         'signature': response.signature ?? '',
         'planId': _selectedPlan,
       });
       
       debugPrint("Server verification result: ${result.data}");

       // If function throws, we go to catch. If returns, it's success.
       
       // Force refresh to get new status from Firestore
       ref.invalidate(ownerControllerProvider);
       // Optional: Wait a bit or re-read
       await Future.delayed(const Duration(seconds: 1));
       await ref.refresh(ownerControllerProvider.future);

       if (mounted) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text("Plan Upgraded to $_selectedPlan! (Server Verified)"), 
             backgroundColor: Colors.green
           )
         );
         Navigator.pop(context);
       }

    } catch (e) {
       debugPrint("Verification Failed: $e");
       _handlePaymentError(PaymentFailureResponse(0, "Server Verification Failed: $e", {}));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"), 
        backgroundColor: Colors.red
      )
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch current plan
    final ownerAsync = ref.watch(ownerControllerProvider);
    final currentPlan = ownerAsync.value?.subscriptionPlan ?? 'free';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Upgrade Plan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleOption(title: 'Monthly', isSelected: !_isYearly),
                  _buildToggleOption(title: 'Yearly (-20%)', isSelected: _isYearly),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Plan 1: Free
            _buildPlanCard(
              context, 
              title: 'Free', 
              price: '₹0', 
              period: '/life', 
              description: 'Perfect for starters',
              features: ['Up to 2 Tenants', 'Local Storage', 'Basic Sync', 'No Reports', 'Single Device'],
              color: Colors.grey,
              isCurrent: currentPlan == 'free',
              onTap: () {}, // Already active or downgrade logic (omitted)
              buttonText: currentPlan == 'free' ? 'Current Plan' : 'Downgrade'
            ),

            const SizedBox(height: 20),

            // Plan 2: Pro (Recommended)
            _buildPlanCard(
              context, 
              title: 'Pro Owner', 
              price: _isYearly ? '₹1,199' : '₹149', 
              period: _isYearly ? '/year' : '/month',
              description: 'For serious landlords',
              features: ['Up to 20 Tenants', 'Multi-device Sync', 'Rent Due Reminders', 'Monthly PDF Reports', 'Reduced Ads'],
              color: const Color(0xFF2563EB), // Blue
              isRecommended: true,
              isCurrent: currentPlan == 'pro',
              onTap: () => _initiatePayment('pro', _isYearly ? 119900 : 14900),
              buttonText: currentPlan == 'pro' ? 'Current Plan' : 'Upgrade to Pro'
            ),

            const SizedBox(height: 20),

            // Plan 3: Power
            _buildPlanCard(
              context, 
              title: 'Power Owner', 
              price: _isYearly ? '₹3,499' : '₹399', 
              period: _isYearly ? '/year' : '/month',
              description: 'For societies & complexes',
              features: ['Unlimited Tenants', 'Multiple Properties', 'Advanced Analytics', 'Priority Support', 'No Ads'],
              color: const Color(0xFF7C3AED), // Purple
              isCurrent: currentPlan == 'power',
              onTap: () => _initiatePayment('power', _isYearly ? 349900 : 39900),
              buttonText: currentPlan == 'power' ? 'Current Plan' : 'Get Power'
            ),
            
            const SizedBox(height: 40),
            Text('Secured by Razorpay • Cancel Anytime', style: GoogleFonts.outfit(color: theme.disabledColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({required String title, required bool isSelected}) {
    return GestureDetector(
      onTap: () => setState(() => _isYearly = !isSelected), // Toggle logic needs care if specific tap, but simple binary toggle works here
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, {
    required String title, required String price, required String period, required String description,
    required List<String> features, required Color color, 
    bool isRecommended = false, bool isCurrent = false,
    required VoidCallback onTap, required String buttonText
  }) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isRecommended ? color : theme.dividerColor, 
              width: isRecommended ? 2 : 1
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isRecommended ? 0.2 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4)
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                   Text(price, style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                   Text(period, style: GoogleFonts.outfit(fontSize: 14, color: theme.hintColor)),
                ],
              ),
              const SizedBox(height: 4),
              Text(description, style: GoogleFonts.outfit(color: theme.hintColor, fontSize: 13)),
              const SizedBox(height: 24),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                     Icon(Icons.check_circle, size: 18, color: color),
                     const SizedBox(width: 12),
                     Expanded(child: Text(f, style: GoogleFonts.outfit(fontSize: 14))),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCurrent ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrent ? theme.disabledColor : color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading && !isCurrent && _selectedPlan == title.split(' ')[0].toLowerCase() 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(buttonText, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
        if (isRecommended)
           Positioned(
             top: 0,
             right: 24,
             child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
               decoration: BoxDecoration(
                 color: color,
                 borderRadius: BorderRadius.circular(20),
               ),
               child: Text('MOST POPULAR', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
             ),
           )
      ],
    );
  }
}
