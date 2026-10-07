// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'GymTrack';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navWorkout => 'Tập luyện';

  @override
  String get navHistory => 'Lịch sử';

  @override
  String get navProgress => 'Tiến độ';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get commonCancel => 'Huỷ';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonAdd => 'Thêm';

  @override
  String get commonCreate => 'Tạo';

  @override
  String get commonDelete => 'Xoá';

  @override
  String get commonEdit => 'Sửa';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String get commonTest => 'Thử';

  @override
  String get commonClearFilters => 'Xoá bộ lọc';

  @override
  String get commonDiscard => 'Huỷ bỏ';

  @override
  String get commonFinish => 'Hoàn thành';

  @override
  String get commonRestore => 'Khôi phục';

  @override
  String get commonArchive => 'Lưu trữ';

  @override
  String commonError(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get homeGreetingMorning => 'Chào buổi sáng ☀️';

  @override
  String get homeGreetingAfternoon => 'Chào buổi chiều ⚡';

  @override
  String get homeGreetingEvening => 'Chào buổi tối 🌙';

  @override
  String get homeTooltipBodyWeight => 'Ghi cân nặng';

  @override
  String get homeTooltipExerciseLibrary => 'Thư viện bài tập';

  @override
  String get homeTodayBadge => 'HÔM NAY';

  @override
  String get homeQuickWorkoutRoutine => 'Buổi tập nhanh';

  @override
  String get homeNoRoutineDesc =>
      'Chưa chọn giáo án. Nhấn bắt đầu để tập tự do.';

  @override
  String get homeStartWorkout => 'BẮT ĐẦU TẬP';

  @override
  String get homeBodyWeight => 'Cân nặng';

  @override
  String get homeTapToLog => 'Nhấn để ghi';

  @override
  String get homeLastSession => 'Buổi tập gần nhất';

  @override
  String get homeNoWorkoutsYet => 'Chưa có buổi tập nào';

  @override
  String get homeRecentPrHighlights => 'Kỷ lục gần đây 🏆';

  @override
  String get homeViewAll => 'Xem tất cả';

  @override
  String get homeEmptyPrDesc =>
      'Thiết lập kỷ lục cá nhân bằng cách ghi lại các bài tập!';

  @override
  String homePrAchievedOn(String date) {
    return 'Đạt ngày $date';
  }

  @override
  String get workoutPlansTitle => 'Giáo án tập luyện';

  @override
  String get workoutPlansNewTooltip => 'Tạo giáo án';

  @override
  String get workoutPlansEmptyTitle => 'Chưa có giáo án nào';

  @override
  String get workoutPlansEmptySubtitle =>
      'Tạo giáo án đầu tiên của bạn hoặc bắt đầu với giáo án mẫu.';

  @override
  String get workoutPlansCreateButton => 'Tạo giáo án';

  @override
  String get workoutPlansDeleteTitle => 'Xoá giáo án?';

  @override
  String workoutPlansDeleteMessage(String name) {
    return 'Bạn có chắc muốn xoá \"$name\"? Lịch sử các buổi tập đã qua vẫn được giữ nguyên.';
  }

  @override
  String get workoutPlansDeleteAction => 'Xoá giáo án';

  @override
  String workoutPlansDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày tập',
    );
    return '$_temp0';
  }

  @override
  String get dialogCreatePlanTitle => 'Tạo giáo án mới';

  @override
  String get dialogPlanNameLabel => 'Tên giáo án (ví dụ: Upper Lower, PPL)';

  @override
  String get dialogPlanDescLabel => 'Mô tả (tuỳ chọn)';

  @override
  String get dialogAddWorkoutDayTitle => 'Thêm ngày tập';

  @override
  String get dialogWorkoutDayHint => 'Tên ngày tập (ví dụ: Push, Ngực & Lưng)';

  @override
  String get dialogRenamePlanTitle => 'Đổi tên giáo án';

  @override
  String get dialogRenamePlanHint => 'Tên giáo án';

  @override
  String get dialogRenameDayTitle => 'Đổi tên ngày tập';

  @override
  String get dialogRenameDayHint => 'Tên ngày tập (ví dụ: Push, Pull)';

  @override
  String get dialogEditExerciseParamsTitle => 'Chỉnh sửa thiết lập bài tập';

  @override
  String get dialogTargetSetsLabel => 'Số hiệp mục tiêu';

  @override
  String get dialogMinRepsLabel => 'Số lần tối thiểu';

  @override
  String get dialogMaxRepsLabel => 'Số lần tối đa';

  @override
  String get dialogRestSecondsLabel => 'Thời gian nghỉ (giây)';

  @override
  String get planDetailRenameTooltip => 'Đổi tên giáo án';

  @override
  String get planDetailAddDay => 'Thêm ngày';

  @override
  String get planDetailNoDaysTitle => 'Chưa có ngày tập nào';

  @override
  String get planDetailNoDaysSubtitle =>
      'Thêm các ngày như \"Push\", \"Pull\" hoặc \"Legs\" để sắp xếp bài tập.';

  @override
  String get planDetailAddDayButton => 'Thêm ngày tập';

  @override
  String planDetailExerciseSubtitle(
    int sets,
    int minReps,
    int maxReps,
    int restSeconds,
  ) {
    return '$sets hiệp • $minReps-$maxReps lần • nghỉ ${restSeconds}s';
  }

  @override
  String get planDetailEditTooltip => 'Chỉnh sửa';

  @override
  String get planDetailRemoveTooltip => 'Xoá';

  @override
  String get dayCardRenameTooltip => 'Đổi tên ngày';

  @override
  String get dayCardStartButton => 'BẮT ĐẦU';

  @override
  String get dayCardDeleteTitle => 'Xoá ngày tập?';

  @override
  String dayCardDeleteMessage(String name) {
    return 'Bạn có chắc muốn xoá \"$name\" cùng các bài tập trong ngày này?';
  }

  @override
  String get dayCardAddExerciseEmpty => 'Thêm bài tập vào ngày này';

  @override
  String get dayCardAddExerciseButton => '+ Thêm bài tập';

  @override
  String get activeWorkoutTitle => 'Đang tập luyện';

  @override
  String get activeWorkoutFinishButton => 'HOÀN THÀNH';

  @override
  String get activeWorkoutAddExercise => '+ THÊM BÀI TẬP';

  @override
  String get activeWorkoutNotesTitle => 'Ghi chú buổi tập';

  @override
  String get activeWorkoutNotesHint =>
      'Buổi tập hôm nay thế nào? Ví dụ: cảm thấy sung sức...';

  @override
  String get activeWorkoutFinishDialogTitle => 'Hoàn thành buổi tập?';

  @override
  String get activeWorkoutFinishDialogMessage =>
      'Bạn có chắc muốn hoàn thành và lưu buổi tập này?';

  @override
  String get activeWorkoutFinishDialogConfirm => 'Hoàn thành';

  @override
  String get activeWorkoutDiscardDialogTitle => 'Huỷ buổi tập?';

  @override
  String get activeWorkoutDiscardDialogMessage =>
      'Bạn có chắc muốn huỷ buổi tập này? Dữ liệu buổi tập sẽ không được lưu.';

  @override
  String get activeWorkoutDiscardDialogConfirm => 'Huỷ bỏ';

  @override
  String get activeWorkoutSetHeader => 'HIỆP';

  @override
  String activeWorkoutWeightHeader(String unit) {
    return 'MỨC TẠ ($unit)';
  }

  @override
  String get activeWorkoutRepsHeader => 'SỐ LẦN';

  @override
  String get activeWorkoutAddSet => '+ THÊM HIỆP';

  @override
  String activeWorkoutPrevious(String summary) {
    return 'Lần trước: $summary';
  }

  @override
  String get restTimerTitle => 'THỜI GIAN NGHỈ';

  @override
  String get restTimerAdd30s => '+30s';

  @override
  String get restTimerNotificationTitle => 'Hết giờ nghỉ! 🔔';

  @override
  String restTimerNotificationBodyWithExercise(String exercise) {
    return 'Đến hiệp tiếp theo của $exercise';
  }

  @override
  String get restTimerNotificationBodyDefault => 'Đến hiệp tiếp theo!';

  @override
  String get summaryTitle => 'Hoàn thành buổi tập! 💪';

  @override
  String get summarySessionNotFound => 'Không tìm thấy buổi tập';

  @override
  String get summaryDuration => 'Thời gian';

  @override
  String get summaryExercises => 'Số bài tập';

  @override
  String get summarySets => 'Số hiệp';

  @override
  String get summaryVolume => 'Tổng khối lượng';

  @override
  String summaryNotePrefix(String note) {
    return 'Ghi chú: $note';
  }

  @override
  String get summaryBackToHome => 'VỀ TRANG CHỦ';

  @override
  String get historyTitle => 'Lịch sử tập luyện';

  @override
  String get historyEmptyTitle => 'Chưa hoàn thành buổi tập nào';

  @override
  String get historyEmptySubtitle =>
      'Bắt đầu một buổi tập và ghi lại các hiệp. Lịch sử và khối lượng tập sẽ hiển thị ở đây.';

  @override
  String historyExercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bài tập',
    );
    return '$_temp0';
  }

  @override
  String get historyDetailTitle => 'Chi tiết buổi tập';

  @override
  String get historyDetailDeleteTooltip => 'Xoá nhật ký';

  @override
  String get historyDetailDeleteTitle => 'Xoá buổi tập này?';

  @override
  String get historyDetailDeleteMessage =>
      'Bạn có chắc muốn xoá vĩnh viễn buổi tập này khỏi lịch sử?';

  @override
  String get historyDetailSessionNotFound => 'Không tìm thấy buổi tập';

  @override
  String get historyDetailExercisesAndSets => 'Bài tập & Hiệp tập';

  @override
  String get historyDetailNoSets => 'Chưa ghi nhận hiệp tập nào';

  @override
  String historyDetailSetLabel(int setNumber) {
    return 'Hiệp $setNumber:';
  }

  @override
  String historyDetailSetSummary(String weight, int reps) {
    return '$weight × $reps lần';
  }

  @override
  String get progressTitle => 'Tiến độ & Phân tích';

  @override
  String get progressTotalWorkouts => 'Tổng số buổi tập';

  @override
  String get progressTotalVolume => 'Tổng khối lượng';

  @override
  String get progressExerciseAnalytics => 'Phân tích bài tập';

  @override
  String progressVolumeMetric(String unit) {
    return 'Khối lượng ($unit)';
  }

  @override
  String progressMaxWeightMetric(String unit) {
    return 'Tạ nặng nhất ($unit)';
  }

  @override
  String progressEstimated1RMMetric(String unit) {
    return 'Ước tính 1RM ($unit)';
  }

  @override
  String get progressSelectExercise => 'Chọn bài tập';

  @override
  String get progress1RM => '1RM';

  @override
  String get progressMaxWeight => 'Tạ nặng nhất';

  @override
  String get progressVolume => 'Khối lượng';

  @override
  String get progressNoCompletedSets =>
      'Chưa có hiệp tập hoàn thành nào cho bài tập này.\nHãy hoàn thành buổi tập để theo dõi biểu đồ tiến độ!';

  @override
  String get progressPrTitle => 'Kỷ lục cá nhân (PR)';

  @override
  String get progressPrEmpty =>
      'Hoàn thành các hiệp tập để thiết lập kỷ lục PR!';

  @override
  String progressPrRow(String maxWeight, String est1RM) {
    return '$maxWeight (Ước tính 1RM: $est1RM)';
  }

  @override
  String get bodyTrackingTitle => 'Theo dõi thể trạng';

  @override
  String get bodyTrackingLogTooltip => 'Ghi chỉ số';

  @override
  String get bodyTrackingEmptyTitle => 'Chưa có chỉ số cơ thể';

  @override
  String get bodyTrackingEmptySubtitle =>
      'Theo dõi cân nặng, tỷ lệ mỡ và các số đo vòng cơ thể theo thời gian.';

  @override
  String get bodyTrackingLogWeightButton => 'Ghi cân nặng';

  @override
  String get bodyTrackingWeightTrend => 'Xu hướng cân nặng';

  @override
  String bodyTrackingLatestPrefix(String weight) {
    return 'Mới nhất: $weight';
  }

  @override
  String get bodyTrackingHistoryTitle => 'Lịch sử số đo';

  @override
  String get bodyTrackingDeleteDialogTitle => 'Xoá chỉ số?';

  @override
  String get bodyTrackingDeleteDialogMessage => 'Xoá chỉ số đã đo này?';

  @override
  String get bodyTrackingDialogTitle => 'Ghi nhận chỉ số cơ thể';

  @override
  String bodyTrackingWeightLabel(String unit) {
    return 'Cân nặng ($unit) *';
  }

  @override
  String get bodyTrackingWeightHintLb => 'ví dụ 160.0';

  @override
  String get bodyTrackingWeightHintKg => 'ví dụ 72.5';

  @override
  String get bodyTrackingBodyFatLabel => 'Tỷ lệ mỡ %';

  @override
  String get bodyTrackingWaistLabel => 'Vòng eo (cm)';

  @override
  String get bodyTrackingChestLabel => 'Vòng ngực (cm)';

  @override
  String get bodyTrackingArmLabel => 'Vòng tay (cm)';

  @override
  String get bodyTrackingThighLabel => 'Vòng đùi (cm)';

  @override
  String get bodyTrackingNotesLabel => 'Ghi chú (tuỳ chọn)';

  @override
  String get bodyTrackingNotesHint => 'Cân sáng sớm, bụng đói...';

  @override
  String get bodyTrackingSaveButton => 'LƯU CHỈ SỐ';

  @override
  String bodyTrackingSubtitleFat(String fat) {
    return 'Mỡ: $fat%';
  }

  @override
  String bodyTrackingSubtitleWaist(String waist) {
    return 'Eo: ${waist}cm';
  }

  @override
  String get exerciseLibraryTitle => 'Thư viện bài tập';

  @override
  String get exerciseLibraryAddTooltip => 'Thêm bài tập tự tạo';

  @override
  String get exerciseLibraryHideArchivedTooltip => 'Ẩn bài đã lưu trữ';

  @override
  String get exerciseLibraryShowArchivedTooltip => 'Hiện bài đã lưu trữ';

  @override
  String get exerciseLibrarySearchHint =>
      'Tìm theo tên, tiếng Việt, từ khoá...';

  @override
  String get exerciseLibraryAllMuscles => 'Tất cả nhóm cơ';

  @override
  String get exerciseLibraryEquipmentFilter => 'Thiết bị';

  @override
  String get exerciseLibraryTypeFilter => 'Loại bài tập';

  @override
  String get exerciseLibraryNoExercisesFound => 'Không tìm thấy bài tập nào';

  @override
  String get exerciseLibraryCustomBadge => 'TỰ TẠO';

  @override
  String get exerciseLibraryArchivedBadge => 'ĐÃ LƯU TRỮ';

  @override
  String get exerciseLibraryEditTooltip => 'Sửa bài tập tự tạo';

  @override
  String get exerciseLibraryArchiveTooltip => 'Lưu trữ';

  @override
  String get exerciseLibraryArchiveDialogTitle => 'Lưu trữ bài tập?';

  @override
  String exerciseLibraryArchiveDialogMessage(String name) {
    return 'Bài tập \"$name\" sẽ được ẩn khỏi thư viện và danh sách chọn.\nLịch sử tập luyện của bài tập này vẫn được bảo lưu.';
  }

  @override
  String get exerciseLibraryRestoreTooltip => 'Khôi phục';

  @override
  String get exerciseLibraryRestoreDialogTitle => 'Khôi phục bài tập?';

  @override
  String exerciseLibraryRestoreDialogMessage(String name) {
    return 'Khôi phục \"$name\" về thư viện và danh sách chọn?';
  }

  @override
  String get exerciseLibraryNoArchived => 'Không có bài tập lưu trữ nào';

  @override
  String exerciseDetailPrimaryMuscle(String muscle) {
    return 'Cơ chính: $muscle';
  }

  @override
  String get exerciseDetailSecondaryMuscles => 'Nhóm cơ phụ';

  @override
  String get exerciseDetailDescription => 'Mô tả';

  @override
  String get exerciseDetailInstructions => 'Hướng dẫn thực hiện';

  @override
  String get exerciseDetailTips => 'Mẹo & Lưu ý kỹ thuật';

  @override
  String get exerciseDetailCustomBadge => 'Tự tạo';

  @override
  String get createExerciseTitleNew => 'Thêm bài tập tự tạo';

  @override
  String get createExerciseTitleEdit => 'Sửa bài tập';

  @override
  String get createExerciseNameLabel => 'Tên bài tập *';

  @override
  String get createExerciseNameHint => 'ví dụ: Bulgarian Split Squat';

  @override
  String get createExerciseNameRequired => 'Vui lòng nhập tên bài tập';

  @override
  String get createExerciseMuscleLabel => 'Nhóm cơ chính *';

  @override
  String get createExerciseEquipmentLabel => 'Thiết bị *';

  @override
  String get createExerciseDescLabel => 'Mô tả (tuỳ chọn)';

  @override
  String get createExerciseDescHint => 'Tóm tắt ngắn gọn về bài tập...';

  @override
  String get createExerciseInstructionsLabel =>
      'Hướng dẫn thực hiện (tuỳ chọn)';

  @override
  String get createExerciseInstructionsHint =>
      'Bước 1: Chuẩn bị tư thế...\nBước 2: Hạ người...\nBước 3: Đẩy lên...';

  @override
  String get createExerciseTipsLabel => 'Mẹo & Lưu ý kỹ thuật (tuỳ chọn)';

  @override
  String get createExerciseTipsHint => 'Lưu ý tư thế, lỗi sai thường gặp...';

  @override
  String get createExerciseSaveButton => 'LƯU BÀI TẬP';

  @override
  String get createExerciseUpdateButton => 'CẬP NHẬT BÀI TẬP';

  @override
  String get exercisePickerTitle => 'Chọn bài tập';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsSectionPreferences => 'Tuỳ chọn';

  @override
  String get settingsDarkModeTitle => 'Giao diện tối';

  @override
  String get settingsDarkModeSubtitle => 'Giao diện tối tối ưu khi tập gym';

  @override
  String get settingsWeightUnitTitle => 'Đơn vị khối lượng';

  @override
  String settingsWeightUnitSubtitle(String unit) {
    return 'Hiện tại: $unit';
  }

  @override
  String get settingsRestTimerTitle => 'Thời gian nghỉ mặc định';

  @override
  String settingsRestTimerSubtitle(int seconds) {
    return '$seconds giây giữa các hiệp';
  }

  @override
  String get settingsAutoFillTitle => 'Tự động điền mức tạ lần trước';

  @override
  String get settingsAutoFillSubtitle =>
      'Khi BẬT, tự điền mức tạ/số lần từ buổi trước. Khi TẮT, để trống hiệp mới (chỉ hiện tham khảo).';

  @override
  String get settingsLanguageTitle => 'Ngôn ngữ';

  @override
  String get settingsLanguageSubtitle => 'Chọn ngôn ngữ hiển thị ứng dụng';

  @override
  String get settingsSectionReminders => 'Nhắc nhở tập luyện';

  @override
  String get settingsReminderSwitchTitle => 'Lịch nhắc nhở tập luyện';

  @override
  String get settingsReminderSwitchSubtitle =>
      'Thông báo cục bộ nhắc bạn tập luyện đúng lịch';

  @override
  String get settingsReminderTimeTitle => 'Giờ nhắc';

  @override
  String get settingsReminderDaysTitle => 'Ngày nhắc trong tuần';

  @override
  String get settingsReminderTestTitle => 'Thử thông báo';

  @override
  String get settingsReminderTestSubtitle =>
      'Gửi ngay một thông báo thử nghiệm';

  @override
  String get settingsReminderTestSnackBar => 'Đã gửi thông báo!';

  @override
  String get settingsReminderNotificationTitle => 'Đến giờ tập rồi 💪';

  @override
  String get settingsReminderNotificationBody =>
      'Buổi tập đã lên lịch đang chờ bạn!';

  @override
  String get settingsReminderNotificationBodyInstant =>
      'Đừng bỏ lỡ buổi tập hôm nay! Kiên trì là chìa khoá thành công.';

  @override
  String get settingsSectionBackup => 'Sao lưu & Dữ liệu';

  @override
  String get settingsExportTitle => 'Xuất bản sao lưu (JSON)';

  @override
  String get settingsExportSubtitle =>
      'Xuất toàn bộ lịch sử, giáo án và số đo cơ thể';

  @override
  String get settingsImportTitle => 'Khôi phục sao lưu';

  @override
  String get settingsImportSubtitle => 'Khôi phục dữ liệu từ tệp JSON đã lưu';

  @override
  String get settingsDeleteAllTitle => 'Xoá toàn bộ dữ liệu';

  @override
  String get settingsDeleteAllSubtitle =>
      'Xoá sạch dữ liệu cục bộ với xác nhận an toàn';

  @override
  String get settingsSectionAbout => 'Giới thiệu';

  @override
  String get settingsAboutSubtitle =>
      'Phiên bản 1.0.0 • 100% Cục bộ & Ngoại tuyến';

  @override
  String get settingsAboutLegalese =>
      'Ứng dụng theo dõi tập gym ngoại tuyến, ưu tiên dữ liệu cục bộ.\nXây dựng bằng Flutter, Drift & SQLite.';

  @override
  String get settingsExportDialogTitle => 'Xuất dữ liệu sao lưu';

  @override
  String get settingsExportDialogMessage =>
      'Đã tạo dữ liệu sao lưu thành công! Bạn có thể sao chép vào bộ nhớ tạm hoặc chia sẻ tệp.';

  @override
  String get settingsExportCopyButton => 'Sao chép vào bộ nhớ tạm';

  @override
  String get settingsExportShareButton => 'Chia sẻ tệp';

  @override
  String get settingsExportCopiedSnackBar =>
      'Đã sao chép chuỗi JSON vào bộ nhớ tạm!';

  @override
  String get settingsImportDialogTitle => 'Khôi phục dữ liệu';

  @override
  String get settingsImportDialogMessage =>
      'Dán chuỗi JSON đã sao lưu vào ô bên dưới:';

  @override
  String get settingsImportDialogHint => 'Dán nội dung JSON vào đây...';

  @override
  String get settingsImportSuccessSnackBar =>
      'Đã khôi phục cơ sở dữ liệu thành công!';

  @override
  String settingsImportFailedSnackBar(String error) {
    return 'Khôi phục dữ liệu thất bại: $error';
  }

  @override
  String get settingsDeleteAllDialogTitle => 'Xoá toàn bộ dữ liệu?';

  @override
  String get settingsDeleteAllDialogMessage =>
      'Hành động này sẽ xoá hoàn toàn lịch sử tập, bài tập tự tạo, giáo án và số đo cơ thể. Hành động KHÔNG THỂ hoàn tác.';

  @override
  String get settingsDeleteAllDialogConfirm => 'XOÁ TẤT CẢ';

  @override
  String get settingsDeleteAllSuccessSnackBar =>
      'Đã đặt lại toàn bộ dữ liệu về mặc định.';

  @override
  String get dayMon => 'Thứ hai';

  @override
  String get dayTue => 'Thứ ba';

  @override
  String get dayWed => 'Thứ tư';

  @override
  String get dayThu => 'Thứ năm';

  @override
  String get dayFri => 'Thứ sáu';

  @override
  String get daySat => 'Thứ bảy';

  @override
  String get daySun => 'Chủ nhật';

  @override
  String get dayMonShort => 'T2';

  @override
  String get dayTueShort => 'T3';

  @override
  String get dayWedShort => 'T4';

  @override
  String get dayThuShort => 'T5';

  @override
  String get dayFriShort => 'T6';

  @override
  String get daySatShort => 'T7';

  @override
  String get daySunShort => 'CN';

  @override
  String get muscleChest => 'Ngực';

  @override
  String get muscleBack => 'Lưng';

  @override
  String get muscleShoulders => 'Vai';

  @override
  String get muscleLegs => 'Chân';

  @override
  String get muscleBiceps => 'Tay trước';

  @override
  String get muscleTriceps => 'Tay sau';

  @override
  String get muscleCore => 'Bụng';

  @override
  String get muscleFullBody => 'Toàn thân';

  @override
  String get muscleCardio => 'Cardio';

  @override
  String get muscleQuads => 'Đùi trước';

  @override
  String get muscleHamstrings => 'Đùi sau';

  @override
  String get muscleCalves => 'Bắp chân';

  @override
  String get muscleGlutes => 'Mông';

  @override
  String get muscleLats => 'Cơ xô';

  @override
  String get muscleTraps => 'Cơ cầu vai';

  @override
  String get muscleForearms => 'Cẳng tay';

  @override
  String get equipmentBarbell => 'Đòn tạ';

  @override
  String get equipmentDumbbell => 'Tạ đơn';

  @override
  String get equipmentMachine => 'Máy tập';

  @override
  String get equipmentCable => 'Dây cáp';

  @override
  String get equipmentBodyweight => 'Thể trọng';

  @override
  String get equipmentKettlebell => 'Tạ ấm';

  @override
  String get equipmentOther => 'Khác';

  @override
  String get typeWeightReps => 'Tạ & Lần';

  @override
  String get typeBodyweightReps => 'Thể trọng & Lần';

  @override
  String get typeDuration => 'Thời gian';

  @override
  String get typeCardio => 'Cardio';

  @override
  String get validationErrorRequired => 'Vui lòng nhập giá trị';

  @override
  String get validationErrorInvalidNumber => 'Số không hợp lệ';

  @override
  String get validationErrorNegative => 'Phải >= 0';

  @override
  String get validationErrorTooLarge => 'Giá trị quá lớn';
}
