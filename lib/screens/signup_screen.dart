// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  // Avatar selection
  String _selectedAvatar = '😊';
  final List<String> _avatars = ['😊', '🚀', '🎮', '🎨', '⚡'];
  
  // Field validation states for bounce animation
  bool _nameValid = false;
  bool _emailValid = false;
  bool _passwordValid = false;
  bool _dobValid = false;
  
  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;
  
  // Progress tracking
  double _progress = 0.0;
  String _milestoneMessage = "Let's get started! ✨";
  
  // Shake animation controllers
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String _shakingField = '';
  
  // Achievement badges
  List<String> _badges = [];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    // Add listeners to track progress
    _nameController.addListener(_updateProgress);
    _emailController.addListener(_updateProgress);
    _passwordController.addListener(_updatePasswordStrength);
    _dobController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // Calculate password strength
  void _updatePasswordStrength() {
    String password = _passwordController.text;
    double strength = 0.0;
    
    if (password.isEmpty) {
      strength = 0.0;
      _passwordStrengthText = '';
      _passwordStrengthColor = Colors.red;
    } else {
      // Length check
      if (password.length >= 6) strength += 0.2;
      if (password.length >= 8) strength += 0.1;
      if (password.length >= 10) strength += 0.1;
      
      // Contains uppercase
      if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
      
      // Contains lowercase
      if (password.contains(RegExp(r'[a-z]'))) strength += 0.1;
      
      // Contains numbers
      if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
      
      // Contains special characters
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;
      
      // Determine strength level
      if (strength <= 0.3) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (strength <= 0.6) {
        _passwordStrengthText = 'Medium';
        _passwordStrengthColor = Colors.orange;
      } else if (strength <= 0.8) {
        _passwordStrengthText = 'Good';
        _passwordStrengthColor = Colors.yellow[700]!;
      } else {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.green;
      }
    }
    
    setState(() {
      _passwordStrength = strength;
    });
    _updateProgress();
  }

  // Update progress tracker
  void _updateProgress() {
    int completedFields = 0;
    double oldProgress = _progress;
    
    // Check each field
    if (_nameController.text.isNotEmpty) completedFields++;
    if (_emailController.text.isNotEmpty && 
        _emailController.text.contains('@') && 
        _emailController.text.contains('.')) completedFields++;
    if (_passwordController.text.length >= 6) completedFields++;
    if (_dobController.text.isNotEmpty) completedFields++;
    
    double newProgress = completedFields / 4.0;
    
    setState(() {
      _progress = newProgress;
      
      // Update milestone messages with haptic feedback
      if (_progress >= 0.25 && oldProgress < 0.25) {
        _milestoneMessage = "Great start! 🎯";
        _triggerHapticFeedback();
      } else if (_progress >= 0.50 && oldProgress < 0.50) {
        _milestoneMessage = "Halfway there! 🔥";
        _triggerHapticFeedback();
      } else if (_progress >= 0.75 && oldProgress < 0.75) {
        _milestoneMessage = "Almost done! 💪";
        _triggerHapticFeedback();
      } else if (_progress >= 1.0 && oldProgress < 1.0) {
        _milestoneMessage = "Ready for adventure! 🚀";
        _triggerHapticFeedback();
      }
    });
  }

  // Trigger haptic feedback
  void _triggerHapticFeedback() {
    HapticFeedback.mediumImpact();
  }

  // Shake animation for invalid input
  void _shakeField(String fieldName) {
    setState(() {
      _shakingField = fieldName;
    });
    _shakeController.forward().then((_) {
      _shakeController.reverse().then((_) {
        setState(() {
          _shakingField = '';
        });
      });
    });
  }

  // Date Picker Function
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
        _dobValid = true;
      });
      _triggerHapticFeedback();
    }
  }

  // Calculate achievement badges
  void _calculateBadges() {
    _badges.clear();
    
    // Strong Password Master
    if (_passwordStrength >= 0.8) {
      _badges.add('🏆 Strong Password Master');
    }
    
    // Early Bird Special (before 12 PM)
    if (DateTime.now().hour < 12) {
      _badges.add('🌅 Early Bird Special');
    }
    
    // Profile Completer
    if (_progress >= 1.0) {
      _badges.add('✅ Profile Completer');
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      _calculateBadges();

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              userName: _nameController.text,
              selectedAvatar: _selectedAvatar,
              badges: _badges,
            ),
          ),
        );
      });
    } else {
      _shakeField('form');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account 🎉'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Progress Tracker
                _buildProgressTracker(),
                const SizedBox(height: 20),

                // Avatar Selection
                _buildAvatarSelector(),
                const SizedBox(height: 20),

                // Animated Form Header
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates,
                          color: Colors.deepPurple[800]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Complete your adventure profile!',
                          style: TextStyle(
                            color: Colors.deepPurple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Name Field with bounce animation
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _shakingField == 'name'
                          ? Offset(_shakeAnimation.value, 0)
                          : Offset.zero,
                      child: _buildAnimatedTextField(
                        controller: _nameController,
                        label: 'Adventure Name',
                        icon: Icons.person,
                        isValid: _nameValid,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _shakeField('name');
                            setState(() => _nameValid = false);
                            return 'What should we call you on this adventure?';
                          }
                          setState(() => _nameValid = true);
                          _triggerHapticFeedback();
                          return null;
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Email Field with bounce animation
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _shakingField == 'email'
                          ? Offset(_shakeAnimation.value, 0)
                          : Offset.zero,
                      child: _buildAnimatedTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email,
                        isValid: _emailValid,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _shakeField('email');
                            setState(() => _emailValid = false);
                            return 'We need your email for adventure updates!';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            _shakeField('email');
                            setState(() => _emailValid = false);
                            return 'Oops! That doesn\'t look like a valid email 🤔';
                          }
                          setState(() => _emailValid = true);
                          _triggerHapticFeedback();
                          return null;
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // DOB with Calendar
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _shakingField == 'dob'
                          ? Offset(_shakeAnimation.value, 0)
                          : Offset.zero,
                      child: _buildDOBField(),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Password Field with strength meter
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _shakingField == 'password'
                          ? Offset(_shakeAnimation.value, 0)
                          : Offset.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPasswordField(),
                          const SizedBox(height: 8),
                          _buildPasswordStrengthMeter(),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Submit Button with Loading Animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start My Adventure',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.rocket_launch, color: Colors.white),
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

  // Progress Tracker Widget
  Widget _buildProgressTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Adventure Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _progress >= 0.75
                    ? Colors.green
                    : _progress >= 0.5
                        ? Colors.orange
                        : Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _milestoneMessage,
              key: ValueKey(_milestoneMessage),
              style: TextStyle(
                fontSize: 14,
                color: Colors.deepPurple[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Avatar Selector Widget
  Widget _buildAvatarSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Avatar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _avatars.map((avatar) {
              bool isSelected = _selectedAvatar == avatar;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatar = avatar;
                  });
                  _triggerHapticFeedback();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepPurple[100]
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.deepPurple
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      avatar,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Animated TextField with bounce effect
  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isValid,
    required String? Function(String?) validator,
  }) {
    return AnimatedScale(
      scale: isValid ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.bounceOut,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          suffixIcon: isValid
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isValid ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isValid ? Colors.green : Colors.grey[300]!,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isValid ? Colors.green : Colors.deepPurple,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: isValid ? Colors.green[50] : Colors.grey[50],
        ),
        validator: validator,
        onChanged: (value) {
          // Trigger validation on change for real-time feedback
          _formKey.currentState?.validate();
        },
      ),
    );
  }

  // DOB Field
  Widget _buildDOBField() {
    return AnimatedScale(
      scale: _dobValid ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.bounceOut,
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        onTap: _selectDate,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon:
              const Icon(Icons.calendar_today, color: Colors.deepPurple),
          suffixIcon: _dobValid
              ? const Icon(Icons.check_circle, color: Colors.green)
              : IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _selectDate,
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _dobValid ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _dobValid ? Colors.green : Colors.grey[300]!,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _dobValid ? Colors.green : Colors.deepPurple,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: _dobValid ? Colors.green[50] : Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            _shakeField('dob');
            setState(() => _dobValid = false);
            return 'When did your adventure begin? 📅';
          }
          return null;
        },
      ),
    );
  }

  // Password Field
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Secret Password',
        prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.deepPurple,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          _shakeField('password');
          setState(() => _passwordValid = false);
          return 'Every adventurer needs a secret password! 🔐';
        }
        if (value.length < 6) {
          _shakeField('password');
          setState(() => _passwordValid = false);
          return 'Make it stronger! At least 6 characters 💪';
        }
        setState(() => _passwordValid = true);
        return null;
      },
    );
  }

  // Password Strength Meter
  Widget _buildPasswordStrengthMeter() {
    if (_passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _passwordStrengthText,
              style: TextStyle(
                color: _passwordStrengthColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tip: Use uppercase, lowercase, numbers, and symbols for a strong password! ✨',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}