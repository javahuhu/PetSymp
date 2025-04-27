import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../userdata.dart';
import 'recovery.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  EmailScreenState createState() => EmailScreenState();
}

class EmailScreenState extends State<EmailScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    
    // Enhanced animations with smoother timing
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuint),
      ),
    );
    
    // Start animation after a shorter delay for better responsiveness
    Future.delayed(const Duration(milliseconds: 150), () {
      _animationController.forward();
    });
  }

  void _navigateToNextPage() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final userData = Provider.of<UserData>(context, listen: false);
      final email = _emailController.text;
      
      // Generate a random 6-digit OTP
      final otp = (Random().nextInt(900000) + 100000).toString();

      // Send the OTP to the backend
      final success = await userData.sendOtpToEmail(email, otp);
      
      if (success) {
        // Save email and OTP in your provider for later verification
        userData.setOTPemail(email);
        userData.setOtpCode(otp);
        setState(() => _isLoading = false);

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const RecoveryScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = const Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.easeOutQuint;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                const Text('Failed to send OTP. Please try again.'),
              ],
            ),
            backgroundColor: Colors.redAccent.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: _navigateToNextPage,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFECF5F8),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced back button
                Padding(
                  padding: EdgeInsets.only(left: 8.0.w, top: 8.0.h, right: 16.0.w),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          splashColor: const Color(0xFF52AAA4).withOpacity(0.2),
                          highlightColor: const Color(0xFF52AAA4).withOpacity(0.1),
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: const Color(0xFF3D2F28),
                              size: 22.sp,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Added App Logo
                      Container(
                        height: 40.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF52AAA4).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.lock_reset,
                            color: const Color(0xFF52AAA4),
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                // Enhanced Heading
                Center(
                  child: Text(
                    "Email Recovery",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D1D2C),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Enhanced Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    "We'll send a verification code to your email address to securely reset your password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black87.withOpacity(0.65),
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 50.h),
                // Enhanced Email input field with animation
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        setState(() {
                          _isFocused = hasFocus;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isFocused ? [
                            BoxShadow(
                              color: const Color(0xFF52AAA4).withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ] : [],
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.done,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF1D1D2C),
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Your email address',
                            hintStyle: TextStyle(
                              color: Colors.black38,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.email_outlined,
                                color: _isFocused 
                                    ? const Color(0xFF4826A3) 
                                    : const Color(0xFF52AAA4),
                                size: 22.sp,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: const Color(0xFF52AAA4).withOpacity(0.7),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF4826A3),
                                width: 2.0,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.redAccent.shade700,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.redAccent.shade700,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 18.h,
                              horizontal: 16.w,
                            ),
                            suffixIcon: _emailController.text.isNotEmpty 
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.black45,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _emailController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          ),
                          onChanged: (value) {
                            setState(() {}); // Rebuild to show/hide clear button
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                // Add email instruction text
                Padding(
                  padding: EdgeInsets.only(top: 12.h, left: 30.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16.sp,
                        color: const Color(0xFF52AAA4),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "Use the email address linked to your account",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Enhanced Submit button with dynamic states
                Padding(
                  padding: EdgeInsets.only(bottom: 32.h, left: 24.w, right: 24.w),
                  child: Center(
                    child: _isLoading
                        ? Container(
                            width: size.width * 0.7,
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF52AAA4).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _navigateToNextPage,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF52AAA4),
                              minimumSize: Size(size.width * 0.7, 56.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFF52AAA4).withOpacity(0.4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Send Verification Code",
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                // Add secure process indicator at bottom
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield,
                          size: 18.sp,
                          color: const Color(0xFF52AAA4),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "Secure verification process",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}