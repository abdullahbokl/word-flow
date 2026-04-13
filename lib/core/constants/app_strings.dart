abstract final class AppStrings {
  // Shell tabs
  static const analyzerTab = 'Analyzer';
  static const lexiconTab = 'Lexicon';
  static const historyTab = 'History';

  // Exit dialog
  static const exitDialogTitle = 'Exit WordFlow?';
  static const exitDialogBody = 'Are you sure you want to close the app?';
  static const exitDialogStay = 'Stay';
  static const exitDialogExit = 'Exit';

  // Lexicon page
  static const myLexicon = 'My Lexicon';
  static const addWord = 'Add Word';
  static const enterWord = 'Enter a word...';
  static const cancel = 'Cancel';
  static const add = 'Add';
  static const editWord = 'Edit Word';
  static const save = 'Save';
  static const searchWords = 'Search words...';
  static const noWordsYet = 'No words yet';
  static const noWordsSubtitle = 'Analyze a text to populate your lexicon.';
  static const loading = 'Loading...';

  // History page
  static const history = 'History';
  static const deleteAnalysis = 'Delete Analysis';
  static const deletionInstructions =
      'How would you like to delete this analysis?';
  static const deletionOptions =
      '• Only history: Keeps all words in your lexicon.\n'
      '• History & unique words: Removes words that are only found in this text.';
  static const deleteOnlyHistory = 'Only History';
  static const deleteEverything = 'Delete Everything';
  static const noAnalysisHistory = 'No analysis history';
  static const noAnalysisSubtitle = 'Analyzed texts will appear here.';
  static const loadingHistory = 'Loading history...';

  // History detail
  static const analysisDetail = 'Analysis Detail';
  static const textExcerpt = 'Full text content excerpt:';
  static const totalWords = 'Total Words';
  static const uniqueWords = 'Unique Words';
  static const knownWords = 'Known Words';
  static const unknown = 'Unknown';

  // Text Analyzer
  static const textAnalyzer = 'Text Analyzer';
  static const newAnalysis = 'New Analysis';
  static const titleOptional = 'Title (Optional)';
  static const textToAnalyze = 'Text to Analyze';
  static const analyzeText = 'Analyze Text';
  static const uploadTxtFile = 'Upload .txt File';
  static const pickingFile = 'Picking file...';
  static const fileError = 'Could not read file';
  static const processingText = 'Processing text...';

  // Analysis summary
  static const analysisResults = 'Analysis Results';
  static const comprehension = 'Comprehension';

  // Word list
  static const wordBreakdown = 'Word Breakdown';
  static const all = 'All';
  static const known = 'Known';
  static const unknownLabel = 'Unknown';
  static const noWordsForFilter = 'No words found for this filter.';

  // Common
  static const retry = 'Retry';
  static const error = 'Error';
  static const loadingLexicon = 'Loading lexicon...';
  static const undo = 'Undo';
  static String wordDeleted(String word) => 'Deleted "$word"';
}
