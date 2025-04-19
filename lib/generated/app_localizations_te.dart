// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get settings => 'సెట్టింగ్స్';

  @override
  String get general => 'సాధారణం';

  @override
  String get providers => 'ప్రొవైడర్లు';

  @override
  String get mcpServer => 'MCP సర్వర్';

  @override
  String get language => 'భాష';

  @override
  String get theme => 'థీమ్';

  @override
  String get dark => 'డార్క్';

  @override
  String get light => 'లైట్';

  @override
  String get system => 'సిస్టమ్';

  @override
  String get languageSettings => 'భాషా సెట్టింగ్స్';

  @override
  String get featureSettings => 'ఫీచర్ సెట్టింగ్స్';

  @override
  String get enableArtifacts => 'ఆర్టిఫాక్ట్స్ ఎనేబుల్ చేయండి';

  @override
  String get enableArtifactsDescription => 'AI అసిస్టెంట్ యొక్క ఆర్టిఫాక్ట్స్‌ని సంభాషణలో ఎనేబుల్ చేయండి, ఎక్కువ టోకెన్లు ఉపయోగించబడతాయి';

  @override
  String get enableToolUsage => 'టూల్ వాడకం ఎనేబుల్ చేయండి';

  @override
  String get enableToolUsageDescription => 'సంభాషణలో టూల్స్ వాడకాన్ని ఎనేబుల్ చేయండి, ఎక్కువ టోకెన్లు ఉపయోగించబడతాయి';

  @override
  String get themeSettings => 'థీమ్ సెట్టింగ్స్';

  @override
  String get lightTheme => 'లైట్ థీమ్';

  @override
  String get darkTheme => 'డార్క్ థీమ్';

  @override
  String get followSystem => 'సిస్టమ్‌ని అనుసరించు';

  @override
  String get showAvatar => 'అవతార్‌ని చూపించు';

  @override
  String get showAssistantAvatar => 'అసిస్టెంట్ అవతార్‌ని చూపించు';

  @override
  String get showAssistantAvatarDescription => 'సంభాషణలో AI అసిస్టెంట్ యొక్క అవతార్‌ని చూపించు';

  @override
  String get showUserAvatar => 'యూజర్ అవతార్‌ని చూపించు';

  @override
  String get showUserAvatarDescription => 'సంభాషణలో యూజర్ యొక్క అవతార్‌ని చూపించు';

  @override
  String get systemPrompt => 'సిస్టమ్ ప్రాంప్ట్';

  @override
  String get systemPromptDescription => 'ఇది AI అసిస్టెంట్‌తో సంభాషణ కోసం సిస్టమ్ ప్రాంప్ట్, అసిస్టెంట్ ప్రవర్తన మరియు శైలిని సెట్ చేయడానికి ఉపయోగించబడుతుంది';

  @override
  String get llmKey => 'LLM కీ';

  @override
  String get toolKey => 'టూల్ కీ';

  @override
  String get saveSettings => 'సెట్టింగ్స్ సేవ్ చేయండి';

  @override
  String get apiKey => 'API కీ';

  @override
  String enterApiKey(Object provider) {
    return 'మీ $provider API కీని ఎంటర్ చేయండి';
  }

  @override
  String get apiKeyValidation => 'API కీ కనీసం 10 అక్షరాలు ఉండాలి';

  @override
  String get apiEndpoint => 'API ఎండ్‌పాయింట్';

  @override
  String get enterApiEndpoint => 'API ఎండ్‌పాయింట్ URL ఎంటర్ చేయండి';

  @override
  String get platformNotSupported => 'ప్రస్తుత ప్లాట్‌ఫారమ్ MCP సర్వర్‌ని సపోర్ట్ చేయదు';

  @override
  String get mcpServerDesktopOnly => 'MCP సర్వర్ డెస్క్‌టాప్ ప్లాట్‌ఫారమ్‌లను (Windows, macOS, Linux) మాత్రమే సపోర్ట్ చేస్తుంది';

  @override
  String get searchServer => 'సర్వర్‌ని వెతకండి...';

  @override
  String get noServerConfigs => 'సర్వర్ కాన్ఫిగరేషన్లు కనుగొనబడలేదు';

  @override
  String get addServer => 'సర్వర్‌ని జోడించండి';

  @override
  String get refresh => 'రిఫ్రెష్';

  @override
  String get install => 'ఇన్‌స్టాల్';

  @override
  String get edit => 'ఎడిట్';

  @override
  String get delete => 'డిలీట్';

  @override
  String get command => 'కమాండ్';

  @override
  String get arguments => 'ఆర్గ్యుమెంట్స్';

  @override
  String get environmentVariables => 'ఎన్విరాన్మెంట్ వేరియబుల్స్';

  @override
  String get serverName => 'సర్వర్ పేరు';

  @override
  String get commandExample => 'ఉదాహరణకు: npx, uvx';

  @override
  String get argumentsExample => 'స్పేస్‌లతో ఆర్గ్యుమెంట్లను వేరు చేయండి, ఉదాహరణకు: -m mcp.server';

  @override
  String get envVarsFormat => 'ప్రతి లైన్‌కు ఒకటి, ఫార్మాట్: KEY=VALUE';

  @override
  String get cancel => 'రద్దు';

  @override
  String get save => 'సేవ్';

  @override
  String get confirmDelete => 'తొలగింపును నిర్ధారించండి';

  @override
  String confirmDeleteServer(Object name) {
    return 'మీరు నిజంగా సర్వర్ \"$name\"ని తొలగించాలనుకుంటున్నారా?';
  }

  @override
  String get error => 'ఎర్రర్';

  @override
  String commandNotExist(Object command, Object path) {
    return 'కమాండ్ \"$command\" ఉనికిలో లేదు, దయచేసి మొదట దీన్ని ఇన్‌స్టాల్ చేయండి\n\nప్రస్తుత PATH:\n$path';
  }

  @override
  String get all => 'అన్నీ';

  @override
  String get installed => 'ఇన్‌స్టాల్ చేయబడింది';

  @override
  String get modelSettings => 'మోడల్ సెట్టింగ్స్';

  @override
  String temperature(Object value) {
    return 'టెంపరేచర్: $value';
  }

  @override
  String get temperatureTooltip => 'శాంప్లింగ్ టెంపరేచర్ అవుట్‌పుట్ యాదృచ్ఛికతను నియంత్రిస్తుంది:\n• 0.0: కోడ్ జనరేషన్ మరియు గణిత సమస్యలకు సరైనది\n• 1.0: డేటా ఎక్స్‌ట్రాక్షన్ మరియు విశ్లేషణకు సరైనది\n• 1.3: సాధారణ సంభాషణ మరియు అనువాదానికి సరైనది\n• 1.5: సృజనాత్మక రచన మరియు కవిత్వానికి సరైనది';

  @override
  String topP(Object value) {
    return 'టాప్ P: $value';
  }

  @override
  String get topPTooltip => 'టాప్ P (న్యూక్లియస్ శాంప్లింగ్) టెంపరేచర్‌కు ప్రత్యామ్నాయం. మోడల్ సంచిత సంభావ్యత P ని మించే టోకెన్‌లను మాత్రమే పరిగణిస్తుంది. ఒకేసారి టెంపరేచర్ మరియు top_p రెండింటినీ సవరించడం సిఫార్సు చేయబడదు.';

  @override
  String get maxTokens => 'గరిష్ట టోకెన్లు';

  @override
  String get maxTokensTooltip => 'జనరేట్ చేయాల్సిన గరిష్ట టోకెన్ల సంఖ్య. ఒక టోకెన్ సుమారు 4 అక్షరాలకు సమానం. పొడవైన సంభాషణలకు మరిన్ని టోకెన్లు అవసరం.';

  @override
  String frequencyPenalty(Object value) {
    return 'ఫ్రీక్వెన్సీ పెనాల్టీ: $value';
  }

  @override
  String get frequencyPenaltyTooltip => 'ఫ్రీక్వెన్సీ పెనాల్టీ పారామీటర్. సానుకూల విలువలు టెక్స్ట్‌లో ఉన్న వాటి ఫ్రీక్వెన్సీ ఆధారంగా కొత్త టోకెన్‌లను పెనాల్టీ చేస్తాయి, అదే కంటెంట్‌ని యథాతథంగా పునరావృతం చేసే మోడల్ సంభావ్యతను తగ్గిస్తాయి.';

  @override
  String presencePenalty(Object value) {
    return 'ప్రెజెన్స్ పెనాల్టీ: $value';
  }

  @override
  String get presencePenaltyTooltip => 'ప్రెజెన్స్ పెనాల్టీ పారామీటర్. సానుకూల విలువలు టెక్స్ట్‌లో కనిపించే ఆధారంగా కొత్త టోకెన్‌లను పెనాల్టీ చేస్తాయి, కొత్త అంశాల గురించి మాట్లాడే మోడల్ సంభావ్యతను పెంచుతాయి.';

  @override
  String get enterMaxTokens => 'గరిష్ట టోకెన్లను ఎంటర్ చేయండి';

  @override
  String get share => 'షేర్';

  @override
  String get modelConfig => 'మోడల్ కాన్ఫిగ్';

  @override
  String get debug => 'డీబగ్';

  @override
  String get webSearchTest => 'వెబ్ సెర్చ్ టెస్ట్';

  @override
  String get today => 'నేడు';

  @override
  String get yesterday => 'నిన్న';

  @override
  String get last7Days => 'గత 7 రోజులు';

  @override
  String get last30Days => 'గత 30 రోజులు';

  @override
  String get earlier => 'మునుపటి';

  @override
  String get confirmDeleteSelected => 'ఎంచుకున్న సంభాషణలను తొలగించాలని నిజంగా అనుకుంటున్నారా?';

  @override
  String get ok => 'సరే';

  @override
  String get askMeAnything => 'ఏదైనా అడగండి...';

  @override
  String get uploadFiles => 'ఫైల్స్ అప్‌లోడ్ చేయండి';

  @override
  String get welcomeMessage => 'నేను మీకు ఎలా సహాయపడగలను?';

  @override
  String get copy => 'కాపీ';

  @override
  String get copied => 'క్లిప్‌బోర్డ్‌కి కాపీ చేయబడింది';

  @override
  String get retry => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get brokenImage => 'చెడిపోయిన చిత్రం';

  @override
  String toolCall(Object name) {
    return 'call $name';
  }

  @override
  String toolResult(Object name) {
    return 'call $name result';
  }

  @override
  String get selectModel => 'మోడల్‌ని ఎంచుకోండి';

  @override
  String get close => 'మూసివేయి';

  @override
  String get selectFromGallery => 'గ్యాలరీ నుండి ఎంచుకోండి';

  @override
  String get selectFile => 'ఫైల్‌ని ఎంచుకోండి';

  @override
  String get uploadFile => 'ఫైల్ అప్‌లోడ్';

  @override
  String get openBrowser => 'బ్రౌజర్ తెరవండి';

  @override
  String get codeCopiedToClipboard => 'కోడ్ క్లిప్‌బోర్డ్‌కి కాపీ చేయబడింది';

  @override
  String get thinking => 'ఆలోచిస్తోంది';

  @override
  String get thinkingEnd => 'ఆలోచన ముగిసింది';

  @override
  String get tool => 'టూల్';

  @override
  String get userCancelledToolCall => 'టూల్ ఎక్సిక్యూషన్ విఫలమైంది';

  @override
  String get code => 'కోడ్';

  @override
  String get preview => 'ప్రివ్యూ';

  @override
  String get loadContentFailed => 'కంటెంట్ లోడ్ చేయడం విఫలమైంది, దయచేసి మళ్ళీ ప్రయత్నించండి';

  @override
  String get openingBrowser => 'బ్రౌజర్ తెరుస్తోంది';

  @override
  String get functionCallAuth => 'టూల్ కాల్ ఆథరైజేషన్';

  @override
  String get allowFunctionExecution => 'క్రింది టూల్‌ని ఎక్సిక్యూట్ చేయడానికి అనుమతించాలనుకుంటున్నారా:';

  @override
  String parameters(Object params) {
    return 'పారామీటర్లు: $params';
  }

  @override
  String get allow => 'అనుమతించు';

  @override
  String get loadDiagramFailed => 'డయాగ్రామ్ లోడ్ చేయడం విఫలమైంది, దయచేసి మళ్ళీ ప్రయత్నించండి';

  @override
  String get copiedToClipboard => 'క్లిప్‌బోర్డ్‌కి కాపీ చేయబడింది';

  @override
  String get chinese => 'చైనీస్';

  @override
  String get functionRunning => 'టూల్ రన్ అవుతోంది...';

  @override
  String get thinkingProcess => 'ఆలోచిస్తోంది';

  @override
  String get thinkingProcessWithDuration => 'ఆలోచిస్తోంది, ఉపయోగించిన సమయం';

  @override
  String get thinkingEndWithDuration => 'ఆలోచన ముగిసింది, ఉపయోగించిన సమయం';

  @override
  String get thinkingEndComplete => 'ఆలోచన ముగిసింది';

  @override
  String seconds(Object seconds) {
    return '$secondsసె';
  }

  @override
  String get fieldRequired => 'ఈ ఫీల్డ్ అవసరం';

  @override
  String get autoApprove => 'ఆటో అప్రూవ్';

  @override
  String get verify => 'కీని వెరిఫై చేయండి';

  @override
  String get howToGet => 'ఎలా పొందాలి';

  @override
  String get modelList => 'మోడల్ జాబితా';

  @override
  String get enableModels => 'మోడల్స్ ఎనేబుల్ చేయండి';

  @override
  String get disableAllModels => 'అన్ని మోడల్స్ డిసేబుల్ చేయండి';

  @override
  String get saveSuccess => 'సెట్టింగ్స్ విజయవంతంగా సేవ్ చేయబడ్డాయి';
}
