import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/config_service.dart';
import '../services/project_service.dart';
import '../services/auth_service.dart';
import '../models/project.dart';
import '../models/user.dart' as app_user;

class CreateProjectScreen extends StatefulWidget {
  final Project? project;

  const CreateProjectScreen({
    super.key,
    this.project,
  });

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectService = ProjectService();

  late String _projectName;
  late String _company;
  String? _projectType;
  String? _status;
  late String _assignedToId;
  late String _assignedToName;
  late String _assignedToInitial;
  late String _priority;
  double? _estimatedValue;
  String? _nextAction;
  String? _currencyType;
  late String _contactName;
  late String _contactNumber;
  late String _notes;
  late List<String> _tags;

  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;

  final _projectNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagController = TextEditingController();

  String _phoneCode = '+1';

  final List<String> _suggestionTags = [
    'branding',
    'web',
    'mobile',
    'sass',
    'urgent',
    'referral',
    'enterprise',
    'startup',
    'retainer'
  ];

  @override
  void initState() {
    super.initState();

    if (widget.project != null) {
      final p = widget.project!;
      _projectName = p.projectName;
      _company = p.company;
      _projectType = p.projectType;
      _status = p.status;
      _assignedToId = p.assignedToId;
      _assignedToName = p.assignedToName;
      _assignedToInitial = p.assignedToInitial;
      _priority = p.priority;
      _estimatedValue = p.estimatedValue;
      _nextAction = p.nextAction;
      _contactName = p.contactName;

      // Extract phone code
      String phoneNum = p.contactNumber;
      for (var code in ['+977', '+91', '+44', '+61', '+971', '+1']) {
        if (phoneNum.startsWith(code)) {
          _phoneCode = code;
          phoneNum = phoneNum.replaceFirst(code, '').trim();
          break;
        }
      }
      _contactNumber = phoneNum;

      _notes = p.notes;
      _tags = List.from(p.tags);

      if (p.reminderAt != null) {
        _reminderDate = p.reminderAt;
        _reminderTime = TimeOfDay.fromDateTime(p.reminderAt!);
      }
    } else {
      final config = ConfigService();
      _projectName = '';
      _company = '';
      _projectType =
          config.projectTypes.isNotEmpty ? config.projectTypes[0] : 'Branding';
      _status = config.statuses.isNotEmpty ? config.statuses[0] : 'New';
      _assignedToId = '';
      _assignedToName = '';
      _assignedToInitial = '';
      _priority = 'Medium';
      _estimatedValue = null;
      _nextAction =
          config.nextActions.isNotEmpty ? config.nextActions[0] : 'Call';
      _currencyType = '\$';
      _contactName = '';
      _contactNumber = '';
      _notes = '';
      _tags = [];
    }

    _projectNameController.text = _projectName;
    _companyController.text = _company;
    _estimatedValueController.text =
        _estimatedValue != null ? _estimatedValue!.toStringAsFixed(2) : '';
    _contactNameController.text = _contactName;
    _contactNumberController.text = _contactNumber;
    _notesController.text = _notes;

    _projectNameController
        .addListener(() => _projectName = _projectNameController.text);
    _companyController.addListener(() => _company = _companyController.text);
    _contactNameController
        .addListener(() => _contactName = _contactNameController.text);
    _contactNumberController
        .addListener(() => _contactNumber = _contactNumberController.text);
    _notesController.addListener(() {
      setState(() {
        _notes = _notesController.text;
      });
    });
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _companyController.dispose();
    _estimatedValueController.dispose();
    _contactNameController.dispose();
    _contactNumberController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final clean = tag.trim().replaceAll('#', '').toLowerCase();
    if (clean.isNotEmpty && !_tags.contains(clean)) {
      setState(() {
        _tags.add(clean);
      });
    }
  }

  Future<void> _selectReminderDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _reminderDate = date;
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (time != null) {
      setState(() {
        _reminderTime = time;
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_assignedToId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an assignee')),
      );
      return;
    }

    if (_projectType == null || _projectType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project type')),
      );
      return;
    }

    if (_status == null || _status!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status')),
      );
      return;
    }

    if (_nextAction == null || _nextAction!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select next action')),
      );
      return;
    }

    final valStr = _estimatedValueController.text.trim();
    if (valStr.isNotEmpty) {
      _estimatedValue = double.tryParse(valStr);
    } else {
      _estimatedValue = null;
    }

    DateTime? reminderDateTime;
    if (_reminderDate != null && _reminderTime != null) {
      reminderDateTime = DateTime(
        _reminderDate!.year,
        _reminderDate!.month,
        _reminderDate!.day,
        _reminderTime!.hour,
        _reminderTime!.minute,
      );
    }

    final fullNumber = '$_phoneCode ${_contactNumber.trim()}';

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (widget.project != null) {
        // Update Project
        final updatedProject = widget.project!.copyWith(
          projectName: _projectName,
          company: _company,
          projectType: _projectType!,
          status: _status!,
          assignedToId: _assignedToId,
          assignedToName: _assignedToName,
          assignedToInitial: _assignedToInitial,
          priority: _priority,
          estimatedValue: _estimatedValue,
          nextAction: _nextAction!,
          contactName: _contactName,
          contactNumber: fullNumber,
          notes: _notes,
          tags: _tags,
          reminderAt: reminderDateTime,
        );
        await _projectService.updateProject(updatedProject);
        messenger.showSnackBar(
          const SnackBar(content: Text('Project updated successfully')),
        );
      } else {
        // Create Project
        final newProject = Project(
          id: '',
          projectName: _projectName,
          contactName: _contactName,
          contactNumber: fullNumber,
          company: _company,
          projectType: _projectType!,
          status: _status!,
          assignedToId: _assignedToId,
          assignedToName: _assignedToName,
          assignedToInitial: _assignedToInitial,
          priority: _priority,
          estimatedValue: _estimatedValue,
          nextAction: _nextAction!,
          notes: _notes,
          tags: _tags,
          reminderAt: reminderDateTime,
          createdAt: DateTime.now(),
          lastContactAt: DateTime.now(),
          createdById: '',
          createdByName: '',
          updatedAt: DateTime.now(),
          updatedBy: '',
        );
        await _projectService.addProject(newProject);
        messenger.showSnackBar(
          const SnackBar(content: Text('Project created successfully')),
        );
      }
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error saving project: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigService>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Defensive configurations fallback
    if (_status != null && !config.statuses.contains(_status!)) {
      _status = config.statuses.isNotEmpty ? config.statuses[0] : 'New';
    }
    if (_projectType != null && !config.projectTypes.contains(_projectType!)) {
      _projectType =
          config.projectTypes.isNotEmpty ? config.projectTypes[0] : 'Branding';
    }
    if (_nextAction != null && !config.nextActions.contains(_nextAction!)) {
      _nextAction =
          config.nextActions.isNotEmpty ? config.nextActions[0] : 'Call';
    }
    if (_currencyType != null && !config.currencies.contains(_currencyType!)) {
      _currencyType =
          config.currencies.isNotEmpty ? config.currencies[0] : '\$';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF94A3B8)
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    widget.project == null ? 'New Project' : 'Edit Project',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.headlineMedium?.color,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      // Card 1: PROJECT INFO
                      _cardSection(
                        title: 'PROJECT INFO',
                        children: [
                          _fieldLabel('PROJECT NAME', required: true),
                          TextFormField(
                            controller: _projectNameController,
                            style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color),
                            decoration:
                                _inputDecoration('e.g. Meridian Rebrand'),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Project name is required'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          _fieldLabel('PROJECT TYPE'),
                          DropdownButtonFormField<String>(
                            value: _projectType,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color),
                            decoration: _inputDecoration('Select type...'),
                            items: config.projectTypes
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(
                                        color:
                                            theme.textTheme.bodyLarge?.color)),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _projectType = v;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          _fieldLabel('ESTIMATED VALUE'),
                          Row(
                            children: [
                              Container(
                                width: 70,
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.dividerColor),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : Colors.white,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _currencyType,
                                    hint: Text('\$',
                                        style: TextStyle(
                                            color: theme
                                                .textTheme.bodyLarge?.color)),
                                    style: TextStyle(
                                        color:
                                            theme.textTheme.bodyLarge?.color),
                                    dropdownColor: theme.cardColor,
                                    items: config.currencies
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: TextStyle(
                                                color: theme.textTheme.bodyLarge
                                                    ?.color)),
                                      );
                                    }).toList(),
                                    onChanged: (v) {
                                      setState(() {
                                        _currencyType = v;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _estimatedValueController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  style: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color),
                                  decoration: _inputDecoration('0.00'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Card 2: CONTACT
                      _cardSection(
                        title: 'CONTACT',
                        children: [
                          _fieldLabel('CONTACT NAME', required: true),
                          TextFormField(
                            controller: _contactNameController,
                            style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color),
                            decoration: _inputDecoration('Full name'),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Contact name is required'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          _fieldLabel('PHONE NUMBER', required: true),
                          Row(
                            children: [
                              Container(
                                width: 85,
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.dividerColor),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : Colors.white,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _phoneCode,
                                    style: TextStyle(
                                        color:
                                            theme.textTheme.bodyLarge?.color),
                                    dropdownColor: theme.cardColor,
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() {
                                          _phoneCode = v;
                                        });
                                      }
                                    },
                                    items: <String>[
                                      '+977',
                                      '+1',
                                      '+91',
                                      '+44',
                                      '+61',
                                      '+971'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: TextStyle(
                                                color: theme.textTheme.bodyLarge
                                                    ?.color)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _contactNumberController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color),
                                  decoration:
                                      _inputDecoration('(555) 000-0000'),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Phone number is required'
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Card 3: CLASSIFICATION
                      _cardSection(
                        title: 'CLASSIFICATION',
                        children: [
                          _fieldLabel('STATUS'),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: config.statuses.map((status) {
                              final isSelected = _status == status;
                              return GestureDetector(
                                onTap: () => setState(() => _status = status),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primaryContainer
                                        : (isDark
                                            ? const Color(0xFF0F172A)
                                            : Colors.white),
                                    border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.dividerColor),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : (isDark
                                              ? const Color(0xFF94A3B8)
                                              : AppTheme.textSecondary),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                          _fieldLabel('PRIORITY'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildPriorityButton(
                                      'High',
                                      const Color(0xFFEF4444),
                                      const Color(0xFFFFE4E6))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _buildPriorityButton(
                                      'Medium',
                                      const Color(0xFFF97316),
                                      const Color(0xFFFFF2EC))),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _buildPriorityButton(
                                      'Low',
                                      const Color(0xFF10B981),
                                      const Color(0xFFECFDF5))),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _fieldLabel('ASSIGNED TO'),
                          const SizedBox(height: 6),
                          StreamBuilder<List<app_user.User>>(
                            stream: AuthService().getActiveTeamMembersStream(),
                            builder: (context, snapshot) {
                              final users = snapshot.data ?? [];
                              if (_assignedToId.isEmpty && users.isNotEmpty) {
                                _assignedToId = users[0].id;
                                _assignedToName =
                                    users[0].name.split(' ').first;
                                _assignedToInitial = users[0].initial;
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: users.map((user) {
                                    final firstName =
                                        user.name.split(' ').first;
                                    final isSelected = _assignedToId == user.id;

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _assignedToId = user.id;
                                          _assignedToName = firstName;
                                          _assignedToInitial = user.initial;
                                        }),
                                        child: Container(
                                          width: 76,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? theme.colorScheme
                                                    .primaryContainer
                                                : (isDark
                                                    ? const Color(0xFF0F172A)
                                                    : Colors.white),
                                            border: Border.all(
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme.dividerColor),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme.dividerColor,
                                                child: Text(
                                                  user.initial,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : theme.textTheme
                                                            .bodyLarge?.color,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                firstName,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isSelected
                                                      ? theme
                                                          .colorScheme.primary
                                                      : (isDark
                                                          ? const Color(
                                                              0xFF94A3B8)
                                                          : AppTheme
                                                              .textSecondary),
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // Card 4: FOLLOW-UP
                      _cardSection(
                        title: 'FOLLOW-UP',
                        children: [
                          _fieldLabel('NEXT ACTION'),
                          DropdownButtonFormField<String>(
                            value: _nextAction,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color),
                            decoration:
                                _inputDecoration('Select next action...'),
                            items: config.nextActions
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(
                                        color:
                                            theme.textTheme.bodyLarge?.color)),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _nextAction = v;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          _fieldLabel('REMINDER DATE & TIME'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _selectReminderDate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: theme.dividerColor),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _reminderDate == null
                                              ? 'Select Date'
                                              : '${_reminderDate!.day}/${_reminderDate!.month}/${_reminderDate!.year}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _reminderDate == null
                                                ? (isDark
                                                    ? const Color(0xFF64748B)
                                                    : AppTheme.textMuted)
                                                : theme
                                                    .textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        Icon(Icons.calendar_today_rounded,
                                            size: 14,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : AppTheme.textSecondary),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _selectReminderTime,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: theme.dividerColor),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _reminderTime == null
                                              ? 'Select Time'
                                              : _reminderTime!.format(context),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _reminderTime == null
                                                ? (isDark
                                                    ? const Color(0xFF64748B)
                                                    : AppTheme.textMuted)
                                                : theme
                                                    .textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        Icon(Icons.access_time_rounded,
                                            size: 14,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : AppTheme.textSecondary),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Card 5: NOTES
                      _cardSection(
                        title: 'NOTES',
                        children: [
                          TextFormField(
                            controller: _notesController,
                            maxLines: 4,
                            style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color),
                            decoration: _inputDecoration(
                                'Add context, meeting notes, or anything useful about this project...'),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${_notesController.text.length} chars',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Card 6: TAGS
                      _cardSection(
                        title: 'TAGS',
                        children: [
                          if (_tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _tags.map((tag) {
                                return Chip(
                                  label: Text(tag,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.primary)),
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  side: BorderSide(
                                      color: theme.colorScheme.primary),
                                  onDeleted: () {
                                    setState(() {
                                      _tags.remove(tag);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                          ],
                          TextFormField(
                            controller: _tagController,
                            style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color),
                            decoration:
                                _inputDecoration('#add tag, press Enter'),
                            onFieldSubmitted: (v) {
                              if (v.isNotEmpty) {
                                _addTag(v);
                                _tagController.clear();
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Suggestions',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _suggestionTags.map((tag) {
                              final isAdded = _tags.contains(tag);
                              return GestureDetector(
                                onTap: () {
                                  if (isAdded) {
                                    setState(() => _tags.remove(tag));
                                  } else {
                                    _addTag(tag);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isAdded
                                        ? theme.colorScheme.primaryContainer
                                        : (isDark
                                            ? const Color(0xFF0F172A)
                                            : Colors.white),
                                    border: Border.all(
                                        color: isAdded
                                            ? theme.colorScheme.primary
                                            : theme.dividerColor),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '+$tag',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isAdded
                                          ? theme.colorScheme.onPrimaryContainer
                                          : (isDark
                                              ? const Color(0xFF94A3B8)
                                              : AppTheme.textSecondary),
                                      fontWeight: isAdded
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // Delete button (only in edit mode)
                      if (widget.project != null) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Project'),
                                    content: Text(
                                        'Are you sure you want to delete "${widget.project!.projectName}"? This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx); // pop dialog
                                          final navigator =
                                              Navigator.of(context);
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          _projectService
                                              .softDeleteProject(
                                                  widget.project!.id)
                                              .then((_) {
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('Project deleted')),
                                            );
                                            navigator.pop(); // pop edit screen
                                            navigator
                                                .pop(); // pop details screen
                                          }).catchError((e) {
                                            messenger.showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error deleting project: $e')),
                                            );
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFFEF4444)),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.danger,
                                side: BorderSide(color: theme.dividerColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Delete Project',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityButton(
      String priority, Color activeColor, Color activeBg) {
    final isSelected = _priority == priority;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color iconColor;
    if (priority == 'High') {
      iconColor = const Color(0xFFEF4444);
    } else if (priority == 'Medium') {
      iconColor = const Color(0xFFF97316);
    } else {
      iconColor = const Color(0xFF10B981);
    }

    return GestureDetector(
      onTap: () => setState(() => _priority = priority),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? activeColor.withValues(alpha: 0.15) : activeBg)
              : (isDark ? const Color(0xFF0F172A) : Colors.white),
          border:
              Border.all(color: isSelected ? activeColor : theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_rounded,
              color: iconColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              priority,
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? activeColor
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : AppTheme.textSecondary),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardSection({required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border:
            isDark ? Border.all(color: theme.dividerColor, width: 1.5) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryLight,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: RichText(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF94A3B8)
                : AppTheme.textSecondary,
            letterSpacing: 0.3,
          ),
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.brightness == Brightness.dark
          ? const Color(0xFF0F172A)
          : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      hintStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        color: isDark ? const Color(0xFF64748B) : AppTheme.textMuted,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
      ),
    );
  }
}
