class DefaultExercise {
  final String name;
  final String muscleGroup;
  final String equipment;
  final String description;

  const DefaultExercise({
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.description,
  });
}

class SeedData {
  static const List<DefaultExercise> defaultExercises = [
    // CHEST
    DefaultExercise(
      name: 'Bench Press',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
      description: 'Compound chest press using a flat barbell bench.',
    ),
    DefaultExercise(
      name: 'Incline Bench Press',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
      description: 'Upper chest focused press on an inclined barbell bench.',
    ),
    DefaultExercise(
      name: 'Dumbbell Bench Press',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      description: 'Flat chest press using a pair of dumbbells for greater range of motion.',
    ),
    DefaultExercise(
      name: 'Incline Dumbbell Press',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      description: 'Incline press targeting upper pectoral muscle fibers with dumbbells.',
    ),
    DefaultExercise(
      name: 'Cable Fly',
      muscleGroup: 'Chest',
      equipment: 'Cable',
      description: 'Isolation chest exercise providing continuous tension across the chest.',
    ),

    // BACK
    DefaultExercise(
      name: 'Pull Up',
      muscleGroup: 'Back',
      equipment: 'Bodyweight',
      description: 'Upper body pulling exercise targeting lats and biceps.',
    ),
    DefaultExercise(
      name: 'Lat Pulldown',
      muscleGroup: 'Back',
      equipment: 'Cable',
      description: 'Cable machine pull down targeting the latissimus dorsi.',
    ),
    DefaultExercise(
      name: 'Barbell Row',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      description:
          'Bent-over compound row targeting middle and upper back thickness.',
    ),
    DefaultExercise(
      name: 'Seated Cable Row',
      muscleGroup: 'Back',
      equipment: 'Cable',
      description:
          'Horizontal cable pull targeting mid back, rhomboids, and lats.',
    ),
    DefaultExercise(
      name: 'One Arm Dumbbell Row',
      muscleGroup: 'Back',
      equipment: 'Dumbbell',
      description: 'Unilateral row focusing on individual lat contraction and back symmetry.',
    ),

    // SHOULDER
    DefaultExercise(
      name: 'Overhead Press',
      muscleGroup: 'Shoulders',
      equipment: 'Barbell',
      description: 'Standing military press building total shoulder strength and anterior deltoids.',
    ),
    DefaultExercise(
      name: 'Dumbbell Shoulder Press',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      description: 'Seated or standing shoulder press using dumbbells.',
    ),
    DefaultExercise(
      name: 'Lateral Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      description:
          'Isolation exercise targeting lateral deltoid for shoulder width.',
    ),
    DefaultExercise(
      name: 'Rear Delt Fly',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      description: 'Reverse fly targeting posterior deltoids and upper back.',
    ),
    DefaultExercise(
      name: 'Face Pull',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      description: 'High rope pull targeting rear delts, traps, and rotator cuffs for shoulder health.',
    ),

    // LEGS
    DefaultExercise(
      name: 'Squat',
      muscleGroup: 'Legs',
      equipment: 'Barbell',
      description: 'The king of leg exercises. Targets quads, glutes, hamstrings, and core.',
    ),
    DefaultExercise(
      name: 'Leg Press',
      muscleGroup: 'Legs',
      equipment: 'Machine',
      description: 'Machine press building quadriceps and glutes with reduced spine load.',
    ),
    DefaultExercise(
      name: 'Romanian Deadlift',
      muscleGroup: 'Legs',
      equipment: 'Barbell',
      description: 'Hinge movement targeting hamstrings and glutes through eccentric stretch.',
    ),
    DefaultExercise(
      name: 'Leg Curl',
      muscleGroup: 'Legs',
      equipment: 'Machine',
      description: 'Knee flexion exercise isolating hamstrings.',
    ),
    DefaultExercise(
      name: 'Leg Extension',
      muscleGroup: 'Legs',
      equipment: 'Machine',
      description: 'Knee extension isolating quadriceps.',
    ),
    DefaultExercise(
      name: 'Calf Raise',
      muscleGroup: 'Legs',
      equipment: 'Machine',
      description: 'Plantarflexion exercise targeting gastrocnemius and soleus calf muscles.',
    ),

    // BICEPS
    DefaultExercise(
      name: 'Barbell Curl',
      muscleGroup: 'Biceps',
      equipment: 'Barbell',
      description: 'Classic standing biceps curl for overall arm mass.',
    ),
    DefaultExercise(
      name: 'Dumbbell Curl',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      description:
          'Alternating or synchronized dumbbell curl with wrist supination.',
    ),
    DefaultExercise(
      name: 'Hammer Curl',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      description:
          'Neutral grip curl targeting brachialis and forearm brachioradialis.',
    ),

    // TRICEPS
    DefaultExercise(
      name: 'Triceps Pushdown',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
      description: 'Cable pushdown isolating triceps lateral and medial heads.',
    ),
    DefaultExercise(
      name: 'Skull Crusher',
      muscleGroup: 'Triceps',
      equipment: 'Barbell',
      description:
          'Lying triceps extension building triceps mass and long head.',
    ),
    DefaultExercise(
      name: 'Overhead Triceps Extension',
      muscleGroup: 'Triceps',
      equipment: 'Dumbbell',
      description:
          'Overhead movement placing maximum stretch on the triceps long head.',
    ),
  ];
}
