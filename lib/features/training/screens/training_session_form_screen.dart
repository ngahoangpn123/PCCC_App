import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/form_fields.dart';
import '../../team/models/member.dart';
import '../models/training.dart';

class TrainingSessionFormScreen extends StatefulWidget {
  const TrainingSessionFormScreen({super.key, this.session, this.presetPlanId});

  final TrainingSession? session;
  final String? presetPlanId;

  @override
  State<TrainingSessionFormScreen> createState() => _TrainingSessionFormScreenState();
}

class _TrainingSessionFormScreenState extends State<TrainingSessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.session?.title ?? '');
  late final _location = TextEditingController(text: widget.session?.location ?? '');
  late final _instructor = TextEditingController(text: widget.session?.instructor ?? '');
  late final _content = TextEditingController(text: widget.session?.content ?? '');
  late final _duration = TextEditingController(text: '${widget.session?.durationMinutes ?? 90}');
  late DateTime _date = widget.session?.date ?? DateTime.now().add(const Duration(days: 7));
  late String _time = widget.session == null
      ? '08:00'
      : '${widget.session!.date.hour.toString().padLeft(2, '0')}:${widget.session!.date.minute.toString().padLeft(2, '0')}';
  late String _format = widget.session?.format ?? trainingFormats.last;
  late String? _planId = widget.session?.planId ?? widget.presetPlanId;
  late final Set<String> _participants = {
    ...?widget.session?.attendance.map((a) => a.memberId),
  };

  List<TrainingPlan> _plans = [];
  List<Member> _members = [];

  bool get _isEdit => widget.session != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final plans = await Locator.training.getPlans();
    final members = await Locator.team.getMembers();
    if (!mounted) return;
    setState(() {
      _plans = plans;
      _members = members.where((m) => m.status != MemberStatus.left).toList();
      _planId ??= plans.isEmpty ? null : plans.first.id;
    });
  }

  @override
  void dispose() {
    for (final c in [_title, _location, _instructor, _content, _duration]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final planId = _planId;
    if (planId == null) {
      showSnack(context, 'Hãy tạo kế hoạch huấn luyện trước');
      return;
    }
    final parts = _time.split(':');
    final start = DateTime(_date.year, _date.month, _date.day, int.parse(parts[0]), int.parse(parts[1]));
    final s = widget.session ??
        TrainingSession(
          id: newId(),
          planId: planId,
          title: '',
          date: start,
          location: '',
          instructor: '',
          content: '',
          format: _format,
          durationMinutes: 90,
        );
    s
      ..planId = planId
      ..title = _title.text.trim()
      ..date = start
      ..location = _location.text.trim()
      ..instructor = _instructor.text.trim()
      ..content = _content.text.trim()
      ..format = _format
      ..durationMinutes = int.tryParse(_duration.text.trim()) ?? 90;
    // Đồng bộ danh sách tham gia, giữ nguyên kết quả của người đã có.
    s.attendance.removeWhere((a) => !_participants.contains(a.memberId));
    for (final id in _participants) {
      if (!s.attendance.any((a) => a.memberId == id)) {
        s.attendance.add(Attendance(memberId: id));
      }
    }
    await Locator.training.saveSession(s);
    if (!mounted) return;
    showSnack(context, _isEdit ? 'Đã cập nhật buổi huấn luyện' : 'Đã tạo buổi huấn luyện');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa buổi huấn luyện' : 'Tạo buổi huấn luyện')),
      bottomNavigationBar: BottomActionBar(label: 'Lưu', onPressed: _save),
      body: _members.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const FormSectionTitle('Thông tin buổi học'),
                  if (_plans.isNotEmpty)
                    DropdownField<String>(
                      label: 'Thuộc kế hoạch',
                      value: _planId ?? _plans.first.id,
                      items: _plans.map((p) => p.id).toList(),
                      labelOf: (id) => _plans.firstWhere((p) => p.id == id).title,
                      onChanged: (v) => setState(() => _planId = v),
                    ),
                  AppTextField(label: 'Tên buổi / chủ đề', controller: _title, required: true),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DatePickerField(
                          label: 'Ngày',
                          value: _date,
                          required: true,
                          onChanged: (v) => setState(() => _date = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TimePickerField(
                          label: 'Giờ',
                          value: _time,
                          onChanged: (v) => setState(() => _time = v),
                        ),
                      ),
                    ],
                  ),
                  AppTextField(label: 'Địa điểm', controller: _location, required: true),
                  AppTextField(label: 'Người hướng dẫn', controller: _instructor),
                  DropdownField<String>(
                    label: 'Hình thức',
                    value: _format,
                    items: trainingFormats,
                    labelOf: (v) => v,
                    onChanged: (v) => setState(() => _format = v),
                  ),
                  AppTextField(
                    label: 'Thời lượng (phút)',
                    controller: _duration,
                    keyboardType: TextInputType.number,
                  ),
                  AppTextField(label: 'Nội dung, tài liệu sử dụng', controller: _content, maxLines: 3),
                  FormSectionTitle('Thành phần tham gia (${_participants.length})'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ActionChip(
                        label: const Text('Chọn tất cả'),
                        onPressed: () => setState(() => _participants.addAll(_members.map((m) => m.id))),
                      ),
                      for (final m in _members)
                        FilterChip(
                          label: Text(m.name),
                          selected: _participants.contains(m.id),
                          onSelected: (v) => setState(() {
                            if (v) {
                              _participants.add(m.id);
                            } else {
                              _participants.remove(m.id);
                            }
                          }),
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
