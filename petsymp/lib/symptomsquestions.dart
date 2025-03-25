
  // Symptom-question mapping
   // Mapping for symptom questions and impact values.
  final Map<String, dynamic> symptomQuestions = {
    "vomiting": {
      "questions": [
        "How long has your pet had vomiting?",
        "Is the vomiting Mild or Severe?"
      ],
      "impactDays": {"1-4 days": 1.1, "5-7 days": 1.2},
      "impactSymptom": {"mild": 1.1, "severe": 1.5},
    },
    "diarrhea": {
      "questions": [
        "How long has your pet had diarrhea?",
        "Is the diarrhea Watery or Bloody?"
      ],
      "impactDays": {"1-4 days": 1.1, "5-7 days": 1.2},
      "impactSymptom": {"watery": 1.3, "bloody": 1.5},
    },
    "coughing": {
      "questions": [
        "How long has your pet had coughing?",
        "Is the coughing Dry or Wet?"
      ],
      "impactDays": {
        "1-4 days": 1.1,
        "5-7 days": 1.2,
        "8-14 days": 1.4,
        "persistent": 1.1
      },
      "impactSymptom": {"dry": 1.2, "wet": 1.4},
    },
    "fever": {
      "questions": [
        "How long has your pet had fever?",
        "Is the fever Mild, Moderate, or Severe?"
      ],
      "impactDays": {"1-4 days": 1.1, "5-7 days": 1.2, "8-14 days": 1.4},
      "impactSymptom": {"mild": 1.1, "moderate": 1.3, "severe": 1.5},
    },
    "lethargy": {
      "questions": [
        "How long has your pet had lethargy?",
        "Is the lethargy Mild or Severe?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-5 days": 1.1, "6-10 days": 1.2, "11+ days": 1.5, "variable": 1.1},
      "impactSymptom": {"mild": 1.1, "severe": 1.5, "variable": 1.1},
    },
    "eye discharge": {
      "questions": [
        "How long has your pet had eye discharge?",
        "Is the eye discharge Watery or Mucous-like?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-10 days": 1.1},
      "impactSymptom": {"watery": 1.3, "mucous-like": 1.2},
    },
    "nasal discharge": {
      "questions": [
        "How long has your pet had nasal discharge?",
        "Is the nasal discharge Clear or Purulent?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-10 days": 1.1},
      "impactSymptom": {"clear": 1.2, "purulent": 1.2},
    },
    "muscle twitching": {
      "questions": [
        "How long has your pet had muscle twitching?",
        "Is the muscle twitching Mild or Severe?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-5 days": 1.1, "6-10 days": 1.2, "11+ days": 1.5},
      "impactSymptom": {"mild": 1.1, "severe": 1.5, "variable": 1.1},
    },
    "seizures": {
      "questions": [
        "How long has your pet had seizures?",
        "Are the seizures Partial or Generalized?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-5 days": 1.1, "6-10 days": 1.2, "11+ days": 1.5, "generalized": 1.4,},
      "impactSymptom": {
        "partial": 1.1,
        "generalized": 1.4,
        "intermittent": 1.2,
        "progressive": 1.3,
        "chronic": 1.1
      },
    },
    "sneezing": {
      "questions": [
        "How long has your pet had sneezing?",
        "Is the sneezing Intermittent?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-5 days": 1.1, "6-10 days": 1.2},
      "impactSymptom": {"intermittent": 1.2},
    },
    "muscle paralysis": {
      "questions": [
        "How long has your pet had muscle paralysis?",
        "Is the muscle paralysis Ascending?"
      ],
      "impactDays": {"1-2 days": 1.0, "3-5 days": 1.1, "6-10 days": 1.2, "11+ days": 1.5, "irreversible": 1.2},
      "impactSymptom": {"ascending": 1.3, "irreversible": 1.2},
    },
  };