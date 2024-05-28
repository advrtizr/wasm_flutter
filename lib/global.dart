const deviceArr = [
  116,
  1,
  2,
  36,
  64,
  3,
  80,
  73,
  78,
  3,
  1,
  68,
  32,
  147,
  160,
  35,
  106,
  99,
  219,
  17,
  217,
  221,
  255,
  45,
  142,
  207,
  160,
  9,
  84,
  75,
  188,
  165,
  86,
  176,
  170,
  228,
  178,
  88,
  198,
  60,
  147,
  42,
  138,
  42,
  40,
  3,
  1,
  83,
  32,
  167,
  241,
  91,
  203,
  216,
  58,
  139,
  188,
  104,
  21,
  185,
  211,
  33,
  105,
  19,
  82,
  203,
  108,
  81,
  151,
  135,
  212,
  88,
  210,
  76,
  226,
  118,
  98,
  163,
  220,
  65,
  211,
  3,
  1,
  85,
  32,
  89,
  55,
  216,
  135,
  133,
  220,
  209,
  184,
  190,
  182,
  71,
  89,
  23,
  24,
  200,
  99,
  80,
  91,
  0,
  134,
  143,
  107,
  235,
  236,
  249,
  154,
  122,
  42,
  228,
  40,
  155,
  26
];
const recArr = [
  55,
  1,
  2,
  36,
  64,
  6,
  87,
  97,
  108,
  108,
  101,
  116,
  20,
  1,
  78,
  0,
  3,
  1,
  83,
  32,
  167,
  241,
  91,
  203,
  216,
  58,
  139,
  188,
  104,
  21,
  185,
  211,
  33,
  105,
  19,
  82,
  203,
  108,
  81,
  151,
  135,
  212,
  88,
  210,
  76,
  226,
  118,
  98,
  163,
  220,
  65,
  211,
  2,
  1,
  89,
  0
];
const accArr = [
  177,
  2,
  1,
  2,
  36,
  64,
  8,
  36,
  65,
  99,
  99,
  111,
  117,
  110,
  116,
  3,
  2,
  36,
  89,
  0,
  2,
  6,
  36,
  98,
  105,
  108,
  108,
  115,
  79,
  2,
  0,
  0,
  75,
  1,
  2,
  36,
  64,
  3,
  84,
  71,
  78,
  2,
  2,
  36,
  86,
  10,
  18,
  18,
  18,
  18,
  192,
  202,
  243,
  243,
  163,
  163,
  3,
  2,
  36,
  89,
  33,
  3,
  137,
  125,
  226,
  121,
  102,
  95,
  148,
  186,
  21,
  141,
  60,
  48,
  111,
  60,
  78,
  131,
  104,
  244,
  209,
  189,
  21,
  22,
  160,
  40,
  228,
  69,
  100,
  138,
  68,
  107,
  62,
  61,
  9,
  2,
  36,
  116,
  0,
  3,
  2,
  36,
  120,
  4,
  188,
  18,
  46,
  160,
  2,
  9,
  36,
  100,
  101,
  114,
  105,
  118,
  101,
  114,
  115,
  77,
  2,
  0,
  0,
  73,
  3,
  0,
  0,
  33,
  3,
  137,
  125,
  226,
  121,
  102,
  95,
  148,
  186,
  21,
  141,
  60,
  48,
  111,
  60,
  78,
  131,
  104,
  244,
  209,
  189,
  21,
  22,
  160,
  40,
  228,
  69,
  100,
  138,
  68,
  107,
  62,
  61,
  3,
  0,
  1,
  32,
  45,
  247,
  8,
  185,
  185,
  146,
  72,
  253,
  58,
  118,
  181,
  127,
  238,
  142,
  1,
  74,
  73,
  189,
  147,
  44,
  247,
  106,
  35,
  81,
  8,
  249,
  88,
  161,
  234,
  170,
  146,
  92,
  2,
  6,
  36,
  104,
  105,
  114,
  112,
  99,
  0,
  2,
  7,
  36,
  108,
  111,
  99,
  107,
  101,
  100,
  0,
  2,
  10,
  36,
  114,
  101,
  113,
  117,
  101,
  115,
  116,
  101,
  100,
  0,
  2,
  19,
  36,
  114,
  101,
  113,
  117,
  101,
  115,
  116,
  101,
  100,
  95,
  105,
  110,
  118,
  111,
  105,
  99,
  101,
  115,
  0,
  3,
  6,
  36,
  115,
  116,
  97,
  116,
  101,
  32,
  45,
  247,
  8,
  185,
  185,
  146,
  72,
  253,
  58,
  118,
  181,
  127,
  238,
  142,
  1,
  74,
  73,
  189,
  147,
  44,
  247,
  106,
  35,
  81,
  8,
  249,
  88,
  161,
  234,
  170,
  146,
  92,
  2,
  5,
  36,
  117,
  115,
  101,
  100,
  0,
  1,
  4,
  110,
  97,
  109,
  101,
  0
];

const deviceBase64 =
    'dAECJEADUElOAwFEIMmNnAuLLaXuEYuK4c3hWZIrQLHuI0Vwvmaq4pY9XVhFAwFTIGd-EaaYR7bicSxEoFVy1ndOk9poWAYokMQudVj9X_1cAwFVIK9-Mr_VEiskef28uiZ7o1_1aQMKfdqPPc0UgGB-8tsI';
const recoverBase64 = 'NwECJEAGV2FsbGV0FAFOAAMBUyBnfhGmmEe24nEsRKBVctZ3TpPaaFgGKJDELnVY_V_9XAIBWQA=';
const accountBase64 =
    'sQIBAiRACCRBY2NvdW50AwIkWQACBiRiaWxsc08CAABLAQIkQANUR04CAiRWChISEhLAyvPzo6MDAiRZIQLccv-FA0YVc3Qsg_pg5QVD4rwxQsDyYIGNm4-RrfBGzQkCJHQAAwIkeARHGOfPAgkkZGVyaXZlcnNNAgAASQMAACEC3HL_hQNGFXN0LIP6YOUFQ-K8MULA8mCBjZuPka3wRs0DAAEgVtelKQq2ZA55v9tr060pAd_uMxOeLTepjtWuvgqOfAkCBiRoaXJwYwACByRsb2NrZWQAAgokcmVxdWVzdGVkAAITJHJlcXVlc3RlZF9pbnZvaWNlcwADBiRzdGF0ZSBW16UpCrZkDnm_22vTrSkB3-4zE54tN6mO1a6-Co58CQIFJHVzZWQAAQRuYW1lAA==';
