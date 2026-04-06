import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

/// Form widget for editing profile information
class ProfileForm extends StatefulWidget {
  final UserProfile profile;
  final bool isLoading;
  final Function(UserProfile) onProfileChanged;
  final VoidCallback? onSendEmailVerification;
  final Function(String)? onSendPhoneVerification;
  final Function(bool Function())? onFormValidatorSet;

  const ProfileForm({
    super.key,
    required this.profile,
    this.isLoading = false,
    required this.onProfileChanged,
    this.onSendEmailVerification,
    this.onSendPhoneVerification,
    this.onFormValidatorSet,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _countryController;

  late UserProfile _currentProfile;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _selectedBirthDate = widget.profile.birthDate;
    
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _streetController = TextEditingController(text: widget.profile.address?.street ?? '');
    _cityController = TextEditingController(text: widget.profile.address?.city ?? '');
    _stateController = TextEditingController(text: widget.profile.address?.state ?? '');
    _zipCodeController = TextEditingController(text: widget.profile.address?.zipCode ?? '');
    _countryController = TextEditingController(text: widget.profile.address?.country ?? '');

    // Add listeners to update profile on changes
    _nameController.addListener(_updateProfile);
    _emailController.addListener(_updateProfile);
    _phoneController.addListener(_updateProfile);
    _bioController.addListener(_updateProfile);
    _streetController.addListener(_updateProfile);
    _cityController.addListener(_updateProfile);
    _stateController.addListener(_updateProfile);
    _zipCodeController.addListener(_updateProfile);
    _countryController.addListener(_updateProfile);

    // Notify the parent widget about the form validator function
    widget.onFormValidatorSet?.call(validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    final updatedAddress = ProfileAddress(
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      country: _countryController.text.trim(),
      isDefault: true,
    );

    _currentProfile = _currentProfile.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      address: updatedAddress,
      birthDate: _selectedBirthDate,
    );

    widget.onProfileChanged(_currentProfile);
  }

  /// Validate the form
  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  /// Get the current form key for external validation
  GlobalKey<FormState> get formKey => _formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information Section
          _buildSectionHeader('Personal Information'),
          const SizedBox(height: AppConstants.smallPadding),
          
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            suffix: widget.profile.isEmailVerified
                ? Icon(Icons.verified, color: AppColors.success)
                : TextButton(
                    onPressed: widget.onSendEmailVerification,
                    child: const Text('Verify'),
                  ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            suffix: widget.profile.isPhoneVerified
                ? Icon(Icons.verified, color: AppColors.success)
                : _phoneController.text.isNotEmpty
                    ? TextButton(
                        onPressed: () => widget.onSendPhoneVerification?.call(_phoneController.text),
                        child: const Text('Verify'),
                      )
                    : null,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\+\-\(\)\s]')),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return null;
              }

              final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
              if (digitsOnly.length < 10 || digitsOnly.length > 15) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Birth Date
          _buildDateField(),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildTextField(
            controller: _bioController,
            label: 'Bio',
            icon: Icons.description_outlined,
            maxLines: 3,
            hint: 'Tell us about yourself and your reading interests...',
          ),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // Address Section
          _buildSectionHeader('Address Information'),
          const SizedBox(height: AppConstants.smallPadding),
          
          _buildTextField(
            controller: _streetController,
            label: 'Street Address',
            icon: Icons.home_outlined,
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city_outlined,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  icon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _zipCodeController,
                  label: 'ZIP Code',
                  icon: Icons.local_post_office_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    if (!RegExp(r'^\d{4,10}$').hasMatch(value.trim())) {
                      return 'Invalid ZIP code';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _countryController,
                  label: 'Country',
                  icon: Icons.public_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !widget.isLoading,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: widget.isLoading ? null : _selectBirthDate,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cake_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedBirthDate != null
                    ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                    : 'Birth Date',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _selectedBirthDate != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: AppDimensions.iconSm,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(now.year - 25);
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selectedDate != null) {
      setState(() {
        _selectedBirthDate = selectedDate;
      });
      _updateProfile();
    }
  }
}
