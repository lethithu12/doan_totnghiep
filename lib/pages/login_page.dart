import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../services/auth_service.dart';
import '../config/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.headerBackground.withOpacity(0.05),
              AppColors.headerBackground.withOpacity(0.02),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ResponsiveConstraints(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : (isTablet ? 32 : 48),
                    vertical: isMobile ? 32 : (isTablet ? 48 : 64),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: _AuthTabs(
                        tabController: _tabController,
                        authService: _authService,
                        isMobile: isMobile,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  final TabController tabController;
  final AuthService authService;
  final bool isMobile;

  const _AuthTabs({
    required this.tabController,
    required this.authService,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerBackground.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo/Title with gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.headerBackground,
                    AppColors.primaryLight,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.headerBackground.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_bag_rounded,
                size: isMobile ? 48 : 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ChangStore',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 28 : 32,
                    color: AppColors.headerBackground,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Điện tử - Điện lạnh',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: isMobile ? 14 : 16,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 32 : 40),
            // Tab Bar with modern design
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[700],
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.headerBackground,
                      AppColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Đăng nhập'),
                  Tab(text: 'Đăng ký'),
                ],
              ),
            ),
            SizedBox(
              height: isMobile ? 420 : 520,
              child: TabBarView(
                controller: tabController,
                children: [
                  _LoginTab(
                    authService: authService,
                    isMobile: isMobile,
                  ),
                  _RegisterTab(
                    authService: authService,
                    isMobile: isMobile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginTab extends StatefulWidget {
  final AuthService authService;
  final bool isMobile;

  const _LoginTab({
    required this.authService,
    required this.isMobile,
  });

  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.authService.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (mounted) {
          final isAdmin = widget.authService.isAdmin;
          if (isAdmin) {
            context.go('/admin');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng nhập admin thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            context.go('/');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng nhập thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: widget.isMobile ? 24 : 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Chào mừng bạn trở lại!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    fontSize: widget.isMobile ? 14 : 16,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: widget.isMobile ? 24 : 32),
            // Email field
            _AuthTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Nhập email của bạn',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
              isMobile: widget.isMobile,
            ),
            SizedBox(height: widget.isMobile ? 16 : 20),
            // Password field
            _AuthTextField(
              controller: _passwordController,
              label: 'Mật khẩu',
              hint: 'Nhập mật khẩu của bạn',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
              isMobile: widget.isMobile,
            ),
            SizedBox(height: widget.isMobile ? 8 : 12),
            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showForgotPasswordDialog();
                },
                child: Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    fontSize: widget.isMobile ? 13 : 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.isMobile ? 24 : 32),
            // Login button with gradient
            Container(
              height: widget.isMobile ? 52 : 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.headerBackground,
                    AppColors.primaryLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.headerBackground.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: widget.isMobile ? 20 : 24,
                        width: widget.isMobile ? 20 : 24,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: widget.isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: EdgeInsets.all(widget.isMobile ? 24 : 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.headerBackground.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.headerBackground,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Quên mật khẩu',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.headerBackground,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nhập email của bạn để nhận link đặt lại mật khẩu',
                    style: TextStyle(
                      fontSize: widget.isMobile ? 14 : 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: widget.isMobile ? 15 : 16,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Nhập email của bạn',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.headerBackground,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.headerBackground,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: widget.isMobile ? 14 : 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.headerBackground,
                              AppColors.primaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.headerBackground.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    setDialogState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      await widget.authService.sendPasswordResetEmail(
                                        emailController.text,
                                      );

                                      if (mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư của bạn.',
                                            ),
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            duration: const Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setDialogState(() {
                                        isLoading = false;
                                      });
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            duration: const Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Gửi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterTab extends StatefulWidget {
  final AuthService authService;
  final bool isMobile;

  const _RegisterTab({
    required this.authService,
    required this.isMobile,
  });

  @override
  State<_RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<_RegisterTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.authService.signUpWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        );

        if (mounted) {
          context.go('/');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Chào mừng bạn đến với ChangStore!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: widget.isMobile ? 24 : 32),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tạo tài khoản mới',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontSize: widget.isMobile ? 14 : 16,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: widget.isMobile ? 24 : 32),
              // Name field
              _AuthTextField(
                controller: _nameController,
                label: 'Họ và tên',
                hint: 'Nhập họ và tên của bạn',
                keyboardType: TextInputType.name,
                prefixIcon: Icons.person_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  if (value.length < 2) {
                    return 'Họ và tên phải có ít nhất 2 ký tự';
                  }
                  return null;
                },
                isMobile: widget.isMobile,
              ),
              SizedBox(height: widget.isMobile ? 16 : 20),
              // Email field
              _AuthTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Nhập email của bạn',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
                isMobile: widget.isMobile,
              ),
              SizedBox(height: widget.isMobile ? 16 : 20),
              // Password field
              _AuthTextField(
                controller: _passwordController,
                label: 'Mật khẩu',
                hint: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
                isMobile: widget.isMobile,
              ),
              SizedBox(height: widget.isMobile ? 16 : 20),
              // Confirm password field
              _AuthTextField(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu',
                hint: 'Nhập lại mật khẩu',
                obscureText: _obscureConfirmPassword,
                prefixIcon: Icons.lock_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != _passwordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
                isMobile: widget.isMobile,
              ),
              SizedBox(height: widget.isMobile ? 24 : 32),
              // Register button with gradient
              Container(
                height: widget.isMobile ? 52 : 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.headerBackground,
                      AppColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.headerBackground.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: widget.isMobile ? 20 : 24,
                          width: widget.isMobile ? 20 : 24,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Đăng ký',
                          style: TextStyle(
                            fontSize: widget.isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isMobile;

  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: isMobile ? 15 : 16,
        color: Colors.grey[800],
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.headerBackground,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.headerBackground,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontSize: isMobile ? 14 : 15,
        ),
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: isMobile ? 14 : 15,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMobile ? 18 : 20,
        ),
      ),
    );
  }
}
