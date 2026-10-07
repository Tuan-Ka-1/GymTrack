import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'GymTrack'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get navWorkout;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get commonTest;

  /// No description provided for @commonClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get commonClearFilters;

  /// No description provided for @commonDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get commonDiscard;

  /// No description provided for @commonFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get commonFinish;

  /// No description provided for @commonRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// No description provided for @commonArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get commonArchive;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonError(String error);

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning ☀️'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon ⚡'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening 🌙'**
  String get homeGreetingEvening;

  /// No description provided for @homeTooltipBodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Body Weight'**
  String get homeTooltipBodyWeight;

  /// No description provided for @homeTooltipExerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get homeTooltipExerciseLibrary;

  /// No description provided for @homeTodayBadge.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get homeTodayBadge;

  /// No description provided for @homeQuickWorkoutRoutine.
  ///
  /// In en, this message translates to:
  /// **'Quick Workout Routine'**
  String get homeQuickWorkoutRoutine;

  /// No description provided for @homeNoRoutineDesc.
  ///
  /// In en, this message translates to:
  /// **'No routine set. Tap start to begin an open session.'**
  String get homeNoRoutineDesc;

  /// No description provided for @homeStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'START WORKOUT'**
  String get homeStartWorkout;

  /// No description provided for @homeBodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Body Weight'**
  String get homeBodyWeight;

  /// No description provided for @homeTapToLog.
  ///
  /// In en, this message translates to:
  /// **'Tap to log'**
  String get homeTapToLog;

  /// No description provided for @homeLastSession.
  ///
  /// In en, this message translates to:
  /// **'Last Session'**
  String get homeLastSession;

  /// No description provided for @homeNoWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get homeNoWorkoutsYet;

  /// No description provided for @homeRecentPrHighlights.
  ///
  /// In en, this message translates to:
  /// **'Recent PR Highlights 🏆'**
  String get homeRecentPrHighlights;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @homeEmptyPrDesc.
  ///
  /// In en, this message translates to:
  /// **'Establish your personal records by logging exercises!'**
  String get homeEmptyPrDesc;

  /// No description provided for @homePrAchievedOn.
  ///
  /// In en, this message translates to:
  /// **'Achieved on {date}'**
  String homePrAchievedOn(String date);

  /// No description provided for @workoutPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Plans'**
  String get workoutPlansTitle;

  /// No description provided for @workoutPlansNewTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Plan'**
  String get workoutPlansNewTooltip;

  /// No description provided for @workoutPlansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Workout Plans Yet'**
  String get workoutPlansEmptyTitle;

  /// No description provided for @workoutPlansEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first workout plan or start with a pre-built split.'**
  String get workoutPlansEmptySubtitle;

  /// No description provided for @workoutPlansCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get workoutPlansCreateButton;

  /// No description provided for @workoutPlansDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Plan?'**
  String get workoutPlansDeleteTitle;

  /// No description provided for @workoutPlansDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? Past workout history will remain intact.'**
  String workoutPlansDeleteMessage(String name);

  /// No description provided for @workoutPlansDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete Plan'**
  String get workoutPlansDeleteAction;

  /// No description provided for @workoutPlansDayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days added} =1{1 day added} other{{count} days added}}'**
  String workoutPlansDayCount(int count);

  /// No description provided for @dialogCreatePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Workout Plan'**
  String get dialogCreatePlanTitle;

  /// No description provided for @dialogPlanNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan Name (e.g., Upper Lower, PPL)'**
  String get dialogPlanNameLabel;

  /// No description provided for @dialogPlanDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get dialogPlanDescLabel;

  /// No description provided for @dialogAddWorkoutDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Workout Day'**
  String get dialogAddWorkoutDayTitle;

  /// No description provided for @dialogWorkoutDayHint.
  ///
  /// In en, this message translates to:
  /// **'Day Name (e.g., Push, Chest & Back)'**
  String get dialogWorkoutDayHint;

  /// No description provided for @dialogRenamePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Plan'**
  String get dialogRenamePlanTitle;

  /// No description provided for @dialogRenamePlanHint.
  ///
  /// In en, this message translates to:
  /// **'Plan name'**
  String get dialogRenamePlanHint;

  /// No description provided for @dialogRenameDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Day'**
  String get dialogRenameDayTitle;

  /// No description provided for @dialogRenameDayHint.
  ///
  /// In en, this message translates to:
  /// **'Day name (e.g., Push, Pull)'**
  String get dialogRenameDayHint;

  /// No description provided for @dialogEditExerciseParamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise Settings'**
  String get dialogEditExerciseParamsTitle;

  /// No description provided for @dialogTargetSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Sets'**
  String get dialogTargetSetsLabel;

  /// No description provided for @dialogMinRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Min Reps'**
  String get dialogMinRepsLabel;

  /// No description provided for @dialogMaxRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Reps'**
  String get dialogMaxRepsLabel;

  /// No description provided for @dialogRestSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest (seconds)'**
  String get dialogRestSecondsLabel;

  /// No description provided for @planDetailRenameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rename Plan'**
  String get planDetailRenameTooltip;

  /// No description provided for @planDetailAddDay.
  ///
  /// In en, this message translates to:
  /// **'Add Day'**
  String get planDetailAddDay;

  /// No description provided for @planDetailNoDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'No workout days yet'**
  String get planDetailNoDaysTitle;

  /// No description provided for @planDetailNoDaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add days like \"Push\", \"Pull\", or \"Legs\" to organize exercises.'**
  String get planDetailNoDaysSubtitle;

  /// No description provided for @planDetailAddDayButton.
  ///
  /// In en, this message translates to:
  /// **'Add Workout Day'**
  String get planDetailAddDayButton;

  /// No description provided for @planDetailExerciseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets • {minReps}-{maxReps} reps • {restSeconds}s rest'**
  String planDetailExerciseSubtitle(
    int sets,
    int minReps,
    int maxReps,
    int restSeconds,
  );

  /// No description provided for @planDetailEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Settings'**
  String get planDetailEditTooltip;

  /// No description provided for @planDetailRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get planDetailRemoveTooltip;

  /// No description provided for @dayCardRenameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rename Day'**
  String get dayCardRenameTooltip;

  /// No description provided for @dayCardStartButton.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get dayCardStartButton;

  /// No description provided for @dayCardDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Day?'**
  String get dayCardDeleteTitle;

  /// No description provided for @dayCardDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\" and its exercises?'**
  String dayCardDeleteMessage(String name);

  /// No description provided for @dayCardAddExerciseEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise to this day'**
  String get dayCardAddExerciseEmpty;

  /// No description provided for @dayCardAddExerciseButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add Exercise'**
  String get dayCardAddExerciseButton;

  /// No description provided for @activeWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Workout'**
  String get activeWorkoutTitle;

  /// No description provided for @activeWorkoutFinishButton.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get activeWorkoutFinishButton;

  /// No description provided for @activeWorkoutAddExercise.
  ///
  /// In en, this message translates to:
  /// **'+ ADD EXERCISE'**
  String get activeWorkoutAddExercise;

  /// No description provided for @activeWorkoutNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Notes'**
  String get activeWorkoutNotesTitle;

  /// No description provided for @activeWorkoutNotesHint.
  ///
  /// In en, this message translates to:
  /// **'How was the workout? E.g., felt strong today...'**
  String get activeWorkoutNotesHint;

  /// No description provided for @activeWorkoutFinishDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout?'**
  String get activeWorkoutFinishDialogTitle;

  /// No description provided for @activeWorkoutFinishDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish and save this workout session?'**
  String get activeWorkoutFinishDialogMessage;

  /// No description provided for @activeWorkoutFinishDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get activeWorkoutFinishDialogConfirm;

  /// No description provided for @activeWorkoutDiscardDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard Workout?'**
  String get activeWorkoutDiscardDialogTitle;

  /// No description provided for @activeWorkoutDiscardDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel and delete this workout session? Data will not be saved.'**
  String get activeWorkoutDiscardDialogMessage;

  /// No description provided for @activeWorkoutDiscardDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get activeWorkoutDiscardDialogConfirm;

  /// No description provided for @activeWorkoutSetHeader.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get activeWorkoutSetHeader;

  /// No description provided for @activeWorkoutWeightHeader.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT ({unit})'**
  String activeWorkoutWeightHeader(String unit);

  /// No description provided for @activeWorkoutRepsHeader.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get activeWorkoutRepsHeader;

  /// No description provided for @activeWorkoutAddSet.
  ///
  /// In en, this message translates to:
  /// **'+ ADD SET'**
  String get activeWorkoutAddSet;

  /// No description provided for @activeWorkoutPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous: {summary}'**
  String activeWorkoutPrevious(String summary);

  /// No description provided for @restTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'REST TIMER'**
  String get restTimerTitle;

  /// No description provided for @restTimerAdd30s.
  ///
  /// In en, this message translates to:
  /// **'+30s'**
  String get restTimerAdd30s;

  /// No description provided for @restTimerNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest finished! 🔔'**
  String get restTimerNotificationTitle;

  /// No description provided for @restTimerNotificationBodyWithExercise.
  ///
  /// In en, this message translates to:
  /// **'Time for the next set of {exercise}'**
  String restTimerNotificationBodyWithExercise(String exercise);

  /// No description provided for @restTimerNotificationBodyDefault.
  ///
  /// In en, this message translates to:
  /// **'Time for the next set!'**
  String get restTimerNotificationBodyDefault;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Completed! 💪'**
  String get summaryTitle;

  /// No description provided for @summarySessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get summarySessionNotFound;

  /// No description provided for @summaryDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get summaryDuration;

  /// No description provided for @summaryExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get summaryExercises;

  /// No description provided for @summarySets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get summarySets;

  /// No description provided for @summaryVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get summaryVolume;

  /// No description provided for @summaryNotePrefix.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String summaryNotePrefix(String note);

  /// No description provided for @summaryBackToHome.
  ///
  /// In en, this message translates to:
  /// **'BACK TO HOME'**
  String get summaryBackToHome;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Workouts Completed Yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a workout session and log your sets. Your history and volume progress will appear here.'**
  String get historyEmptySubtitle;

  /// No description provided for @historyExercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise} other{{count} exercises}}'**
  String historyExercisesCount(int count);

  /// No description provided for @historyDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Details'**
  String get historyDetailTitle;

  /// No description provided for @historyDetailDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Log'**
  String get historyDetailDeleteTooltip;

  /// No description provided for @historyDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Workout Log?'**
  String get historyDetailDeleteTitle;

  /// No description provided for @historyDetailDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this workout from history?'**
  String get historyDetailDeleteMessage;

  /// No description provided for @historyDetailSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get historyDetailSessionNotFound;

  /// No description provided for @historyDetailExercisesAndSets.
  ///
  /// In en, this message translates to:
  /// **'Exercises & Sets'**
  String get historyDetailExercisesAndSets;

  /// No description provided for @historyDetailNoSets.
  ///
  /// In en, this message translates to:
  /// **'No sets recorded'**
  String get historyDetailNoSets;

  /// No description provided for @historyDetailSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Set {setNumber}:'**
  String historyDetailSetLabel(int setNumber);

  /// No description provided for @historyDetailSetSummary.
  ///
  /// In en, this message translates to:
  /// **'{weight} × {reps} reps'**
  String historyDetailSetSummary(String weight, int reps);

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress & Analytics'**
  String get progressTitle;

  /// No description provided for @progressTotalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Total Workouts'**
  String get progressTotalWorkouts;

  /// No description provided for @progressTotalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get progressTotalVolume;

  /// No description provided for @progressExerciseAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Exercise Analytics'**
  String get progressExerciseAnalytics;

  /// No description provided for @progressVolumeMetric.
  ///
  /// In en, this message translates to:
  /// **'Volume ({unit})'**
  String progressVolumeMetric(String unit);

  /// No description provided for @progressMaxWeightMetric.
  ///
  /// In en, this message translates to:
  /// **'Max Wt ({unit})'**
  String progressMaxWeightMetric(String unit);

  /// No description provided for @progressEstimated1RMMetric.
  ///
  /// In en, this message translates to:
  /// **'Epley 1RM ({unit})'**
  String progressEstimated1RMMetric(String unit);

  /// No description provided for @progressSelectExercise.
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get progressSelectExercise;

  /// No description provided for @progress1RM.
  ///
  /// In en, this message translates to:
  /// **'1RM'**
  String get progress1RM;

  /// No description provided for @progressMaxWeight.
  ///
  /// In en, this message translates to:
  /// **'Max Wt'**
  String get progressMaxWeight;

  /// No description provided for @progressVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get progressVolume;

  /// No description provided for @progressNoCompletedSets.
  ///
  /// In en, this message translates to:
  /// **'No completed sets recorded for this exercise yet.\nComplete workouts to see your progress curve!'**
  String get progressNoCompletedSets;

  /// No description provided for @progressPrTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Records (PR)'**
  String get progressPrTitle;

  /// No description provided for @progressPrEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete workout sets to establish your PRs!'**
  String get progressPrEmpty;

  /// No description provided for @progressPrRow.
  ///
  /// In en, this message translates to:
  /// **'{maxWeight} (Est 1RM: {est1RM})'**
  String progressPrRow(String maxWeight, String est1RM);

  /// No description provided for @bodyTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Tracking'**
  String get bodyTrackingTitle;

  /// No description provided for @bodyTrackingLogTooltip.
  ///
  /// In en, this message translates to:
  /// **'Log Measurement'**
  String get bodyTrackingLogTooltip;

  /// No description provided for @bodyTrackingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Body Measurements'**
  String get bodyTrackingEmptyTitle;

  /// No description provided for @bodyTrackingEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your body weight, body fat percentage, and circumference measurements over time.'**
  String get bodyTrackingEmptySubtitle;

  /// No description provided for @bodyTrackingLogWeightButton.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get bodyTrackingLogWeightButton;

  /// No description provided for @bodyTrackingWeightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight Trend'**
  String get bodyTrackingWeightTrend;

  /// No description provided for @bodyTrackingLatestPrefix.
  ///
  /// In en, this message translates to:
  /// **'Latest: {weight}'**
  String bodyTrackingLatestPrefix(String weight);

  /// No description provided for @bodyTrackingHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurement History'**
  String get bodyTrackingHistoryTitle;

  /// No description provided for @bodyTrackingDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry?'**
  String get bodyTrackingDeleteDialogTitle;

  /// No description provided for @bodyTrackingDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this measurement entry?'**
  String get bodyTrackingDeleteDialogMessage;

  /// No description provided for @bodyTrackingDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Body Measurement'**
  String get bodyTrackingDialogTitle;

  /// No description provided for @bodyTrackingWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Weight ({unit}) *'**
  String bodyTrackingWeightLabel(String unit);

  /// No description provided for @bodyTrackingWeightHintLb.
  ///
  /// In en, this message translates to:
  /// **'e.g. 160.0'**
  String get bodyTrackingWeightHintLb;

  /// No description provided for @bodyTrackingWeightHintKg.
  ///
  /// In en, this message translates to:
  /// **'e.g. 72.5'**
  String get bodyTrackingWeightHintKg;

  /// No description provided for @bodyTrackingBodyFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Fat %'**
  String get bodyTrackingBodyFatLabel;

  /// No description provided for @bodyTrackingWaistLabel.
  ///
  /// In en, this message translates to:
  /// **'Waist (cm)'**
  String get bodyTrackingWaistLabel;

  /// No description provided for @bodyTrackingChestLabel.
  ///
  /// In en, this message translates to:
  /// **'Chest (cm)'**
  String get bodyTrackingChestLabel;

  /// No description provided for @bodyTrackingArmLabel.
  ///
  /// In en, this message translates to:
  /// **'Arm (cm)'**
  String get bodyTrackingArmLabel;

  /// No description provided for @bodyTrackingThighLabel.
  ///
  /// In en, this message translates to:
  /// **'Thigh (cm)'**
  String get bodyTrackingThighLabel;

  /// No description provided for @bodyTrackingNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get bodyTrackingNotesLabel;

  /// No description provided for @bodyTrackingNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Morning weight, fasting...'**
  String get bodyTrackingNotesHint;

  /// No description provided for @bodyTrackingSaveButton.
  ///
  /// In en, this message translates to:
  /// **'SAVE MEASUREMENT'**
  String get bodyTrackingSaveButton;

  /// No description provided for @bodyTrackingSubtitleFat.
  ///
  /// In en, this message translates to:
  /// **'Fat: {fat}%'**
  String bodyTrackingSubtitleFat(String fat);

  /// No description provided for @bodyTrackingSubtitleWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist: {waist}cm'**
  String bodyTrackingSubtitleWaist(String waist);

  /// No description provided for @exerciseLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exerciseLibraryTitle;

  /// No description provided for @exerciseLibraryAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Exercise'**
  String get exerciseLibraryAddTooltip;

  /// No description provided for @exerciseLibraryHideArchivedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide Archived'**
  String get exerciseLibraryHideArchivedTooltip;

  /// No description provided for @exerciseLibraryShowArchivedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show Archived'**
  String get exerciseLibraryShowArchivedTooltip;

  /// No description provided for @exerciseLibrarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, Vietnamese, keyword...'**
  String get exerciseLibrarySearchHint;

  /// No description provided for @exerciseLibraryAllMuscles.
  ///
  /// In en, this message translates to:
  /// **'All Muscles'**
  String get exerciseLibraryAllMuscles;

  /// No description provided for @exerciseLibraryEquipmentFilter.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get exerciseLibraryEquipmentFilter;

  /// No description provided for @exerciseLibraryTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'Exercise Type'**
  String get exerciseLibraryTypeFilter;

  /// No description provided for @exerciseLibraryNoExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get exerciseLibraryNoExercisesFound;

  /// No description provided for @exerciseLibraryCustomBadge.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM'**
  String get exerciseLibraryCustomBadge;

  /// No description provided for @exerciseLibraryArchivedBadge.
  ///
  /// In en, this message translates to:
  /// **'ARCHIVED'**
  String get exerciseLibraryArchivedBadge;

  /// No description provided for @exerciseLibraryEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Exercise'**
  String get exerciseLibraryEditTooltip;

  /// No description provided for @exerciseLibraryArchiveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get exerciseLibraryArchiveTooltip;

  /// No description provided for @exerciseLibraryArchiveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive Exercise?'**
  String get exerciseLibraryArchiveDialogTitle;

  /// No description provided for @exerciseLibraryArchiveDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This will hide \"{name}\" from the library and pickers.\nYour workout history for this exercise will be preserved.'**
  String exerciseLibraryArchiveDialogMessage(String name);

  /// No description provided for @exerciseLibraryRestoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get exerciseLibraryRestoreTooltip;

  /// No description provided for @exerciseLibraryRestoreDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Exercise?'**
  String get exerciseLibraryRestoreDialogTitle;

  /// No description provided for @exerciseLibraryRestoreDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Restore \"{name}\" to the library and pickers?'**
  String exerciseLibraryRestoreDialogMessage(String name);

  /// No description provided for @exerciseLibraryNoArchived.
  ///
  /// In en, this message translates to:
  /// **'No archived exercises'**
  String get exerciseLibraryNoArchived;

  /// No description provided for @exerciseDetailPrimaryMuscle.
  ///
  /// In en, this message translates to:
  /// **'Primary: {muscle}'**
  String exerciseDetailPrimaryMuscle(String muscle);

  /// No description provided for @exerciseDetailSecondaryMuscles.
  ///
  /// In en, this message translates to:
  /// **'Secondary Muscles'**
  String get exerciseDetailSecondaryMuscles;

  /// No description provided for @exerciseDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get exerciseDetailDescription;

  /// No description provided for @exerciseDetailInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get exerciseDetailInstructions;

  /// No description provided for @exerciseDetailTips.
  ///
  /// In en, this message translates to:
  /// **'Pro Tips & Cues'**
  String get exerciseDetailTips;

  /// No description provided for @exerciseDetailCustomBadge.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get exerciseDetailCustomBadge;

  /// No description provided for @createExerciseTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New Custom Exercise'**
  String get createExerciseTitleNew;

  /// No description provided for @createExerciseTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise'**
  String get createExerciseTitleEdit;

  /// No description provided for @createExerciseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name *'**
  String get createExerciseNameLabel;

  /// No description provided for @createExerciseNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bulgarian Split Squat'**
  String get createExerciseNameHint;

  /// No description provided for @createExerciseNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter exercise name'**
  String get createExerciseNameRequired;

  /// No description provided for @createExerciseMuscleLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle Group *'**
  String get createExerciseMuscleLabel;

  /// No description provided for @createExerciseEquipmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment *'**
  String get createExerciseEquipmentLabel;

  /// No description provided for @createExerciseDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get createExerciseDescLabel;

  /// No description provided for @createExerciseDescHint.
  ///
  /// In en, this message translates to:
  /// **'Short summary of the exercise...'**
  String get createExerciseDescHint;

  /// No description provided for @createExerciseInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions (optional)'**
  String get createExerciseInstructionsLabel;

  /// No description provided for @createExerciseInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Set up...\nStep 2: Lower...\nStep 3: Press...'**
  String get createExerciseInstructionsHint;

  /// No description provided for @createExerciseTipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Form Tips & Cues (optional)'**
  String get createExerciseTipsLabel;

  /// No description provided for @createExerciseTipsHint.
  ///
  /// In en, this message translates to:
  /// **'Cues, common mistakes to avoid...'**
  String get createExerciseTipsHint;

  /// No description provided for @createExerciseSaveButton.
  ///
  /// In en, this message translates to:
  /// **'SAVE EXERCISE'**
  String get createExerciseSaveButton;

  /// No description provided for @createExerciseUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'UPDATE EXERCISE'**
  String get createExerciseUpdateButton;

  /// No description provided for @exercisePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get exercisePickerTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsDarkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkModeTitle;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sleek dark theme optimized for the gym'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsWeightUnitTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight Unit'**
  String get settingsWeightUnitTitle;

  /// No description provided for @settingsWeightUnitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Currently: {unit}'**
  String settingsWeightUnitSubtitle(String unit);

  /// No description provided for @settingsRestTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Default Rest Timer'**
  String get settingsRestTimerTitle;

  /// No description provided for @settingsRestTimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds between sets'**
  String settingsRestTimerSubtitle(int seconds);

  /// No description provided for @settingsAutoFillTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-fill Previous Performance'**
  String get settingsAutoFillTitle;

  /// No description provided for @settingsAutoFillSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When ON, pre-fills weight/reps from last workout. When OFF, sets start empty (reference only).'**
  String get settingsAutoFillSubtitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose application language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsSectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Workout Reminders'**
  String get settingsSectionReminders;

  /// No description provided for @settingsReminderSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily / Scheduled Reminder'**
  String get settingsReminderSwitchTitle;

  /// No description provided for @settingsReminderSwitchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local notification to remind you to workout'**
  String get settingsReminderSwitchSubtitle;

  /// No description provided for @settingsReminderTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get settingsReminderTimeTitle;

  /// No description provided for @settingsReminderDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Days'**
  String get settingsReminderDaysTitle;

  /// No description provided for @settingsReminderTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get settingsReminderTestTitle;

  /// No description provided for @settingsReminderTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sends an instant local notification'**
  String get settingsReminderTestSubtitle;

  /// No description provided for @settingsReminderTestSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Notification triggered!'**
  String get settingsReminderTestSnackBar;

  /// No description provided for @settingsReminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to workout 💪'**
  String get settingsReminderNotificationTitle;

  /// No description provided for @settingsReminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your scheduled workout is waiting!'**
  String get settingsReminderNotificationBody;

  /// No description provided for @settingsReminderNotificationBodyInstant.
  ///
  /// In en, this message translates to:
  /// **'Don\'t skip today\'s session! Consistency is key.'**
  String get settingsReminderNotificationBodyInstant;

  /// No description provided for @settingsSectionBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Data'**
  String get settingsSectionBackup;

  /// No description provided for @settingsExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Backup (JSON)'**
  String get settingsExportTitle;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export all workouts, routines, and measurements'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get settingsImportTitle;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore data from JSON backup'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get settingsDeleteAllTitle;

  /// No description provided for @settingsDeleteAllSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Erase all local data with confirmation'**
  String get settingsDeleteAllSubtitle;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 • 100% Local & Offline'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsAboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'Local-first offline fitness workout tracker.\nBuilt with Flutter, Drift & SQLite.'**
  String get settingsAboutLegalese;

  /// No description provided for @settingsExportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get settingsExportDialogTitle;

  /// No description provided for @settingsExportDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Backup data generated successfully! You can copy to clipboard or share via device.'**
  String get settingsExportDialogMessage;

  /// No description provided for @settingsExportCopyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get settingsExportCopyButton;

  /// No description provided for @settingsExportShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share File'**
  String get settingsExportShareButton;

  /// No description provided for @settingsExportCopiedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Backup JSON copied to clipboard!'**
  String get settingsExportCopiedSnackBar;

  /// No description provided for @settingsImportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get settingsImportDialogTitle;

  /// No description provided for @settingsImportDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Paste your exported JSON backup string below:'**
  String get settingsImportDialogMessage;

  /// No description provided for @settingsImportDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Paste JSON content here...'**
  String get settingsImportDialogHint;

  /// No description provided for @settingsImportSuccessSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Database restored successfully!'**
  String get settingsImportSuccessSnackBar;

  /// No description provided for @settingsImportFailedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Failed to import backup: {error}'**
  String settingsImportFailedSnackBar(String error);

  /// No description provided for @settingsDeleteAllDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data?'**
  String get settingsDeleteAllDialogTitle;

  /// No description provided for @settingsDeleteAllDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This will completely erase all workout history, custom exercises, routines, and body measurements. This action CANNOT be undone.'**
  String get settingsDeleteAllDialogMessage;

  /// No description provided for @settingsDeleteAllDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'DELETE EVERYTHING'**
  String get settingsDeleteAllDialogConfirm;

  /// No description provided for @settingsDeleteAllSuccessSnackBar.
  ///
  /// In en, this message translates to:
  /// **'All data has been reset to defaults.'**
  String get settingsDeleteAllSuccessSnackBar;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySun;

  /// No description provided for @dayMonShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMonShort;

  /// No description provided for @dayTueShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTueShort;

  /// No description provided for @dayWedShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWedShort;

  /// No description provided for @dayThuShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThuShort;

  /// No description provided for @dayFriShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFriShort;

  /// No description provided for @daySatShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySatShort;

  /// No description provided for @daySunShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySunShort;

  /// No description provided for @muscleChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscleChest;

  /// No description provided for @muscleBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscleBack;

  /// No description provided for @muscleShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleShoulders;

  /// No description provided for @muscleLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get muscleLegs;

  /// No description provided for @muscleBiceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscleBiceps;

  /// No description provided for @muscleTriceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscleTriceps;

  /// No description provided for @muscleCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscleCore;

  /// No description provided for @muscleFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get muscleFullBody;

  /// No description provided for @muscleCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get muscleCardio;

  /// No description provided for @muscleQuads.
  ///
  /// In en, this message translates to:
  /// **'Quads'**
  String get muscleQuads;

  /// No description provided for @muscleHamstrings.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get muscleHamstrings;

  /// No description provided for @muscleCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get muscleCalves;

  /// No description provided for @muscleGlutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muscleGlutes;

  /// No description provided for @muscleLats.
  ///
  /// In en, this message translates to:
  /// **'Lats'**
  String get muscleLats;

  /// No description provided for @muscleTraps.
  ///
  /// In en, this message translates to:
  /// **'Traps'**
  String get muscleTraps;

  /// No description provided for @muscleForearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get muscleForearms;

  /// No description provided for @equipmentBarbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get equipmentBarbell;

  /// No description provided for @equipmentDumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get equipmentDumbbell;

  /// No description provided for @equipmentMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get equipmentMachine;

  /// No description provided for @equipmentCable.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get equipmentCable;

  /// No description provided for @equipmentBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get equipmentBodyweight;

  /// No description provided for @equipmentKettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get equipmentKettlebell;

  /// No description provided for @equipmentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get equipmentOther;

  /// No description provided for @typeWeightReps.
  ///
  /// In en, this message translates to:
  /// **'Weight & Reps'**
  String get typeWeightReps;

  /// No description provided for @typeBodyweightReps.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Reps'**
  String get typeBodyweightReps;

  /// No description provided for @typeDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get typeDuration;

  /// No description provided for @typeCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get typeCardio;

  /// No description provided for @validationErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get validationErrorRequired;

  /// No description provided for @validationErrorInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get validationErrorInvalidNumber;

  /// No description provided for @validationErrorNegative.
  ///
  /// In en, this message translates to:
  /// **'Must be >= 0'**
  String get validationErrorNegative;

  /// No description provided for @validationErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Value too large'**
  String get validationErrorTooLarge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
