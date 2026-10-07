// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GymTrack';

  @override
  String get navHome => 'Home';

  @override
  String get navWorkout => 'Workout';

  @override
  String get navHistory => 'History';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonTest => 'Test';

  @override
  String get commonClearFilters => 'Clear Filters';

  @override
  String get commonDiscard => 'Discard';

  @override
  String get commonFinish => 'Finish';

  @override
  String get commonRestore => 'Restore';

  @override
  String get commonArchive => 'Archive';

  @override
  String commonError(String error) {
    return 'Error: $error';
  }

  @override
  String get homeGreetingMorning => 'Good Morning ☀️';

  @override
  String get homeGreetingAfternoon => 'Good Afternoon ⚡';

  @override
  String get homeGreetingEvening => 'Good Evening 🌙';

  @override
  String get homeTooltipBodyWeight => 'Log Body Weight';

  @override
  String get homeTooltipExerciseLibrary => 'Exercise Library';

  @override
  String get homeTodayBadge => 'TODAY';

  @override
  String get homeQuickWorkoutRoutine => 'Quick Workout Routine';

  @override
  String get homeNoRoutineDesc =>
      'No routine set. Tap start to begin an open session.';

  @override
  String get homeStartWorkout => 'START WORKOUT';

  @override
  String get homeBodyWeight => 'Body Weight';

  @override
  String get homeTapToLog => 'Tap to log';

  @override
  String get homeLastSession => 'Last Session';

  @override
  String get homeNoWorkoutsYet => 'No workouts yet';

  @override
  String get homeRecentPrHighlights => 'Recent PR Highlights 🏆';

  @override
  String get homeViewAll => 'View All';

  @override
  String get homeEmptyPrDesc =>
      'Establish your personal records by logging exercises!';

  @override
  String homePrAchievedOn(String date) {
    return 'Achieved on $date';
  }

  @override
  String get workoutPlansTitle => 'Workout Plans';

  @override
  String get workoutPlansNewTooltip => 'New Plan';

  @override
  String get workoutPlansEmptyTitle => 'No Workout Plans Yet';

  @override
  String get workoutPlansEmptySubtitle =>
      'Create your first workout plan or start with a pre-built split.';

  @override
  String get workoutPlansCreateButton => 'Create Plan';

  @override
  String get workoutPlansDeleteTitle => 'Delete Plan?';

  @override
  String workoutPlansDeleteMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? Past workout history will remain intact.';
  }

  @override
  String get workoutPlansDeleteAction => 'Delete Plan';

  @override
  String workoutPlansDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days added',
      one: '1 day added',
      zero: '0 days added',
    );
    return '$_temp0';
  }

  @override
  String get dialogCreatePlanTitle => 'Create Workout Plan';

  @override
  String get dialogPlanNameLabel => 'Plan Name (e.g., Upper Lower, PPL)';

  @override
  String get dialogPlanDescLabel => 'Description (optional)';

  @override
  String get dialogAddWorkoutDayTitle => 'Add Workout Day';

  @override
  String get dialogWorkoutDayHint => 'Day Name (e.g., Push, Chest & Back)';

  @override
  String get dialogRenamePlanTitle => 'Rename Plan';

  @override
  String get dialogRenamePlanHint => 'Plan name';

  @override
  String get dialogRenameDayTitle => 'Rename Day';

  @override
  String get dialogRenameDayHint => 'Day name (e.g., Push, Pull)';

  @override
  String get dialogEditExerciseParamsTitle => 'Edit Exercise Settings';

  @override
  String get dialogTargetSetsLabel => 'Target Sets';

  @override
  String get dialogMinRepsLabel => 'Min Reps';

  @override
  String get dialogMaxRepsLabel => 'Max Reps';

  @override
  String get dialogRestSecondsLabel => 'Rest (seconds)';

  @override
  String get planDetailRenameTooltip => 'Rename Plan';

  @override
  String get planDetailAddDay => 'Add Day';

  @override
  String get planDetailNoDaysTitle => 'No workout days yet';

  @override
  String get planDetailNoDaysSubtitle =>
      'Add days like \"Push\", \"Pull\", or \"Legs\" to organize exercises.';

  @override
  String get planDetailAddDayButton => 'Add Workout Day';

  @override
  String planDetailExerciseSubtitle(
    int sets,
    int minReps,
    int maxReps,
    int restSeconds,
  ) {
    return '$sets sets • $minReps-$maxReps reps • ${restSeconds}s rest';
  }

  @override
  String get planDetailEditTooltip => 'Edit Settings';

  @override
  String get planDetailRemoveTooltip => 'Remove';

  @override
  String get dayCardRenameTooltip => 'Rename Day';

  @override
  String get dayCardStartButton => 'START';

  @override
  String get dayCardDeleteTitle => 'Delete Day?';

  @override
  String dayCardDeleteMessage(String name) {
    return 'Are you sure you want to delete \"$name\" and its exercises?';
  }

  @override
  String get dayCardAddExerciseEmpty => 'Add Exercise to this day';

  @override
  String get dayCardAddExerciseButton => '+ Add Exercise';

  @override
  String get activeWorkoutTitle => 'Active Workout';

  @override
  String get activeWorkoutFinishButton => 'FINISH';

  @override
  String get activeWorkoutAddExercise => '+ ADD EXERCISE';

  @override
  String get activeWorkoutNotesTitle => 'Session Notes';

  @override
  String get activeWorkoutNotesHint =>
      'How was the workout? E.g., felt strong today...';

  @override
  String get activeWorkoutFinishDialogTitle => 'Finish Workout?';

  @override
  String get activeWorkoutFinishDialogMessage =>
      'Are you sure you want to finish and save this workout session?';

  @override
  String get activeWorkoutFinishDialogConfirm => 'Finish';

  @override
  String get activeWorkoutDiscardDialogTitle => 'Discard Workout?';

  @override
  String get activeWorkoutDiscardDialogMessage =>
      'Are you sure you want to cancel and delete this workout session? Data will not be saved.';

  @override
  String get activeWorkoutDiscardDialogConfirm => 'Discard';

  @override
  String get activeWorkoutSetHeader => 'SET';

  @override
  String activeWorkoutWeightHeader(String unit) {
    return 'WEIGHT ($unit)';
  }

  @override
  String get activeWorkoutRepsHeader => 'REPS';

  @override
  String get activeWorkoutAddSet => '+ ADD SET';

  @override
  String activeWorkoutPrevious(String summary) {
    return 'Previous: $summary';
  }

  @override
  String get restTimerTitle => 'REST TIMER';

  @override
  String get restTimerAdd30s => '+30s';

  @override
  String get restTimerNotificationTitle => 'Rest finished! 🔔';

  @override
  String restTimerNotificationBodyWithExercise(String exercise) {
    return 'Time for the next set of $exercise';
  }

  @override
  String get restTimerNotificationBodyDefault => 'Time for the next set!';

  @override
  String get summaryTitle => 'Workout Completed! 💪';

  @override
  String get summarySessionNotFound => 'Session not found';

  @override
  String get summaryDuration => 'Duration';

  @override
  String get summaryExercises => 'Exercises';

  @override
  String get summarySets => 'Sets';

  @override
  String get summaryVolume => 'Total Volume';

  @override
  String summaryNotePrefix(String note) {
    return 'Note: $note';
  }

  @override
  String get summaryBackToHome => 'BACK TO HOME';

  @override
  String get historyTitle => 'Workout History';

  @override
  String get historyEmptyTitle => 'No Workouts Completed Yet';

  @override
  String get historyEmptySubtitle =>
      'Start a workout session and log your sets. Your history and volume progress will appear here.';

  @override
  String historyExercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String get historyDetailTitle => 'Workout Details';

  @override
  String get historyDetailDeleteTooltip => 'Delete Log';

  @override
  String get historyDetailDeleteTitle => 'Delete Workout Log?';

  @override
  String get historyDetailDeleteMessage =>
      'Are you sure you want to permanently delete this workout from history?';

  @override
  String get historyDetailSessionNotFound => 'Session not found';

  @override
  String get historyDetailExercisesAndSets => 'Exercises & Sets';

  @override
  String get historyDetailNoSets => 'No sets recorded';

  @override
  String historyDetailSetLabel(int setNumber) {
    return 'Set $setNumber:';
  }

  @override
  String historyDetailSetSummary(String weight, int reps) {
    return '$weight × $reps reps';
  }

  @override
  String get progressTitle => 'Progress & Analytics';

  @override
  String get progressTotalWorkouts => 'Total Workouts';

  @override
  String get progressTotalVolume => 'Total Volume';

  @override
  String get progressExerciseAnalytics => 'Exercise Analytics';

  @override
  String progressVolumeMetric(String unit) {
    return 'Volume ($unit)';
  }

  @override
  String progressMaxWeightMetric(String unit) {
    return 'Max Wt ($unit)';
  }

  @override
  String progressEstimated1RMMetric(String unit) {
    return 'Epley 1RM ($unit)';
  }

  @override
  String get progressSelectExercise => 'Select Exercise';

  @override
  String get progress1RM => '1RM';

  @override
  String get progressMaxWeight => 'Max Wt';

  @override
  String get progressVolume => 'Volume';

  @override
  String get progressNoCompletedSets =>
      'No completed sets recorded for this exercise yet.\nComplete workouts to see your progress curve!';

  @override
  String get progressPrTitle => 'Personal Records (PR)';

  @override
  String get progressPrEmpty => 'Complete workout sets to establish your PRs!';

  @override
  String progressPrRow(String maxWeight, String est1RM) {
    return '$maxWeight (Est 1RM: $est1RM)';
  }

  @override
  String get bodyTrackingTitle => 'Body Tracking';

  @override
  String get bodyTrackingLogTooltip => 'Log Measurement';

  @override
  String get bodyTrackingEmptyTitle => 'No Body Measurements';

  @override
  String get bodyTrackingEmptySubtitle =>
      'Track your body weight, body fat percentage, and circumference measurements over time.';

  @override
  String get bodyTrackingLogWeightButton => 'Log Weight';

  @override
  String get bodyTrackingWeightTrend => 'Weight Trend';

  @override
  String bodyTrackingLatestPrefix(String weight) {
    return 'Latest: $weight';
  }

  @override
  String get bodyTrackingHistoryTitle => 'Measurement History';

  @override
  String get bodyTrackingDeleteDialogTitle => 'Delete Entry?';

  @override
  String get bodyTrackingDeleteDialogMessage =>
      'Remove this measurement entry?';

  @override
  String get bodyTrackingDialogTitle => 'Log Body Measurement';

  @override
  String bodyTrackingWeightLabel(String unit) {
    return 'Body Weight ($unit) *';
  }

  @override
  String get bodyTrackingWeightHintLb => 'e.g. 160.0';

  @override
  String get bodyTrackingWeightHintKg => 'e.g. 72.5';

  @override
  String get bodyTrackingBodyFatLabel => 'Body Fat %';

  @override
  String get bodyTrackingWaistLabel => 'Waist (cm)';

  @override
  String get bodyTrackingChestLabel => 'Chest (cm)';

  @override
  String get bodyTrackingArmLabel => 'Arm (cm)';

  @override
  String get bodyTrackingThighLabel => 'Thigh (cm)';

  @override
  String get bodyTrackingNotesLabel => 'Notes (optional)';

  @override
  String get bodyTrackingNotesHint => 'Morning weight, fasting...';

  @override
  String get bodyTrackingSaveButton => 'SAVE MEASUREMENT';

  @override
  String bodyTrackingSubtitleFat(String fat) {
    return 'Fat: $fat%';
  }

  @override
  String bodyTrackingSubtitleWaist(String waist) {
    return 'Waist: ${waist}cm';
  }

  @override
  String get exerciseLibraryTitle => 'Exercise Library';

  @override
  String get exerciseLibraryAddTooltip => 'Add Custom Exercise';

  @override
  String get exerciseLibraryHideArchivedTooltip => 'Hide Archived';

  @override
  String get exerciseLibraryShowArchivedTooltip => 'Show Archived';

  @override
  String get exerciseLibrarySearchHint =>
      'Search by name, Vietnamese, keyword...';

  @override
  String get exerciseLibraryAllMuscles => 'All Muscles';

  @override
  String get exerciseLibraryEquipmentFilter => 'Equipment';

  @override
  String get exerciseLibraryTypeFilter => 'Exercise Type';

  @override
  String get exerciseLibraryNoExercisesFound => 'No exercises found';

  @override
  String get exerciseLibraryCustomBadge => 'CUSTOM';

  @override
  String get exerciseLibraryArchivedBadge => 'ARCHIVED';

  @override
  String get exerciseLibraryEditTooltip => 'Edit Custom Exercise';

  @override
  String get exerciseLibraryArchiveTooltip => 'Archive';

  @override
  String get exerciseLibraryArchiveDialogTitle => 'Archive Exercise?';

  @override
  String exerciseLibraryArchiveDialogMessage(String name) {
    return 'This will hide \"$name\" from the library and pickers.\nYour workout history for this exercise will be preserved.';
  }

  @override
  String get exerciseLibraryRestoreTooltip => 'Restore';

  @override
  String get exerciseLibraryRestoreDialogTitle => 'Restore Exercise?';

  @override
  String exerciseLibraryRestoreDialogMessage(String name) {
    return 'Restore \"$name\" to the library and pickers?';
  }

  @override
  String get exerciseLibraryNoArchived => 'No archived exercises';

  @override
  String exerciseDetailPrimaryMuscle(String muscle) {
    return 'Primary: $muscle';
  }

  @override
  String get exerciseDetailSecondaryMuscles => 'Secondary Muscles';

  @override
  String get exerciseDetailDescription => 'Description';

  @override
  String get exerciseDetailInstructions => 'Instructions';

  @override
  String get exerciseDetailTips => 'Pro Tips & Cues';

  @override
  String get exerciseDetailCustomBadge => 'Custom';

  @override
  String get createExerciseTitleNew => 'New Custom Exercise';

  @override
  String get createExerciseTitleEdit => 'Edit Exercise';

  @override
  String get createExerciseNameLabel => 'Exercise Name *';

  @override
  String get createExerciseNameHint => 'e.g. Bulgarian Split Squat';

  @override
  String get createExerciseNameRequired => 'Please enter exercise name';

  @override
  String get createExerciseMuscleLabel => 'Muscle Group *';

  @override
  String get createExerciseEquipmentLabel => 'Equipment *';

  @override
  String get createExerciseDescLabel => 'Description (optional)';

  @override
  String get createExerciseDescHint => 'Short summary of the exercise...';

  @override
  String get createExerciseInstructionsLabel => 'Instructions (optional)';

  @override
  String get createExerciseInstructionsHint =>
      'Step 1: Set up...\nStep 2: Lower...\nStep 3: Press...';

  @override
  String get createExerciseTipsLabel => 'Form Tips & Cues (optional)';

  @override
  String get createExerciseTipsHint => 'Cues, common mistakes to avoid...';

  @override
  String get createExerciseSaveButton => 'SAVE EXERCISE';

  @override
  String get createExerciseUpdateButton => 'UPDATE EXERCISE';

  @override
  String get exercisePickerTitle => 'Select Exercise';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionPreferences => 'Preferences';

  @override
  String get settingsDarkModeTitle => 'Dark Mode';

  @override
  String get settingsDarkModeSubtitle =>
      'Sleek dark theme optimized for the gym';

  @override
  String get settingsWeightUnitTitle => 'Weight Unit';

  @override
  String settingsWeightUnitSubtitle(String unit) {
    return 'Currently: $unit';
  }

  @override
  String get settingsRestTimerTitle => 'Default Rest Timer';

  @override
  String settingsRestTimerSubtitle(int seconds) {
    return '$seconds seconds between sets';
  }

  @override
  String get settingsAutoFillTitle => 'Auto-fill Previous Performance';

  @override
  String get settingsAutoFillSubtitle =>
      'When ON, pre-fills weight/reps from last workout. When OFF, sets start empty (reference only).';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose application language';

  @override
  String get settingsSectionReminders => 'Workout Reminders';

  @override
  String get settingsReminderSwitchTitle => 'Daily / Scheduled Reminder';

  @override
  String get settingsReminderSwitchSubtitle =>
      'Local notification to remind you to workout';

  @override
  String get settingsReminderTimeTitle => 'Reminder Time';

  @override
  String get settingsReminderDaysTitle => 'Reminder Days';

  @override
  String get settingsReminderTestTitle => 'Test Notification';

  @override
  String get settingsReminderTestSubtitle =>
      'Sends an instant local notification';

  @override
  String get settingsReminderTestSnackBar => 'Notification triggered!';

  @override
  String get settingsReminderNotificationTitle => 'Time to workout 💪';

  @override
  String get settingsReminderNotificationBody =>
      'Your scheduled workout is waiting!';

  @override
  String get settingsReminderNotificationBodyInstant =>
      'Don\'t skip today\'s session! Consistency is key.';

  @override
  String get settingsSectionBackup => 'Backup & Data';

  @override
  String get settingsExportTitle => 'Export Backup (JSON)';

  @override
  String get settingsExportSubtitle =>
      'Export all workouts, routines, and measurements';

  @override
  String get settingsImportTitle => 'Import Backup';

  @override
  String get settingsImportSubtitle => 'Restore data from JSON backup';

  @override
  String get settingsDeleteAllTitle => 'Delete All Data';

  @override
  String get settingsDeleteAllSubtitle =>
      'Erase all local data with confirmation';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsAboutSubtitle => 'Version 1.0.0 • 100% Local & Offline';

  @override
  String get settingsAboutLegalese =>
      'Local-first offline fitness workout tracker.\nBuilt with Flutter, Drift & SQLite.';

  @override
  String get settingsExportDialogTitle => 'Export Backup';

  @override
  String get settingsExportDialogMessage =>
      'Backup data generated successfully! You can copy to clipboard or share via device.';

  @override
  String get settingsExportCopyButton => 'Copy to Clipboard';

  @override
  String get settingsExportShareButton => 'Share File';

  @override
  String get settingsExportCopiedSnackBar => 'Backup JSON copied to clipboard!';

  @override
  String get settingsImportDialogTitle => 'Import Backup';

  @override
  String get settingsImportDialogMessage =>
      'Paste your exported JSON backup string below:';

  @override
  String get settingsImportDialogHint => 'Paste JSON content here...';

  @override
  String get settingsImportSuccessSnackBar => 'Database restored successfully!';

  @override
  String settingsImportFailedSnackBar(String error) {
    return 'Failed to import backup: $error';
  }

  @override
  String get settingsDeleteAllDialogTitle => 'Delete All Data?';

  @override
  String get settingsDeleteAllDialogMessage =>
      'This will completely erase all workout history, custom exercises, routines, and body measurements. This action CANNOT be undone.';

  @override
  String get settingsDeleteAllDialogConfirm => 'DELETE EVERYTHING';

  @override
  String get settingsDeleteAllSuccessSnackBar =>
      'All data has been reset to defaults.';

  @override
  String get dayMon => 'Monday';

  @override
  String get dayTue => 'Tuesday';

  @override
  String get dayWed => 'Wednesday';

  @override
  String get dayThu => 'Thursday';

  @override
  String get dayFri => 'Friday';

  @override
  String get daySat => 'Saturday';

  @override
  String get daySun => 'Sunday';

  @override
  String get dayMonShort => 'Mon';

  @override
  String get dayTueShort => 'Tue';

  @override
  String get dayWedShort => 'Wed';

  @override
  String get dayThuShort => 'Thu';

  @override
  String get dayFriShort => 'Fri';

  @override
  String get daySatShort => 'Sat';

  @override
  String get daySunShort => 'Sun';

  @override
  String get muscleChest => 'Chest';

  @override
  String get muscleBack => 'Back';

  @override
  String get muscleShoulders => 'Shoulders';

  @override
  String get muscleLegs => 'Legs';

  @override
  String get muscleBiceps => 'Biceps';

  @override
  String get muscleTriceps => 'Triceps';

  @override
  String get muscleCore => 'Core';

  @override
  String get muscleFullBody => 'Full Body';

  @override
  String get muscleCardio => 'Cardio';

  @override
  String get muscleQuads => 'Quads';

  @override
  String get muscleHamstrings => 'Hamstrings';

  @override
  String get muscleCalves => 'Calves';

  @override
  String get muscleGlutes => 'Glutes';

  @override
  String get muscleLats => 'Lats';

  @override
  String get muscleTraps => 'Traps';

  @override
  String get muscleForearms => 'Forearms';

  @override
  String get equipmentBarbell => 'Barbell';

  @override
  String get equipmentDumbbell => 'Dumbbell';

  @override
  String get equipmentMachine => 'Machine';

  @override
  String get equipmentCable => 'Cable';

  @override
  String get equipmentBodyweight => 'Bodyweight';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentOther => 'Other';

  @override
  String get typeWeightReps => 'Weight & Reps';

  @override
  String get typeBodyweightReps => 'Bodyweight Reps';

  @override
  String get typeDuration => 'Duration';

  @override
  String get typeCardio => 'Cardio';

  @override
  String get validationErrorRequired => 'Please enter a value';

  @override
  String get validationErrorInvalidNumber => 'Invalid number';

  @override
  String get validationErrorNegative => 'Must be >= 0';

  @override
  String get validationErrorTooLarge => 'Value too large';
}
