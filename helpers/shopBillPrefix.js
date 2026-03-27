const SHOP_PREFIX_STOP_WORDS = new Set([
  'AND',
  'CO',
  'COMPANY',
  'INC',
  'LTD',
  'LIMITED',
  'LLC',
  'PVT',
  'PRIVATE'
]);

function buildShopInvoicePrefix(shopName) {
  const normalizedWords = String(shopName || '')
    .toUpperCase()
    .replace(/[^A-Z0-9\s]/g, ' ')
    .split(/\s+/)
    .map((word) => word.replace(/[^A-Z]/g, ''))
    .filter(Boolean);

  const meaningfulWords = normalizedWords.filter((word) => !SHOP_PREFIX_STOP_WORDS.has(word));
  const words = meaningfulWords.length > 0 ? meaningfulWords : normalizedWords;

  if (words.length >= 3) {
    return words.slice(0, 3).map((word) => word[0]).join('');
  }

  if (words.length === 2) {
    const [firstWord, secondWord] = words;
    const lastLetter = secondWord.length > 1 ? secondWord[secondWord.length - 1] : 'X';
    return `${firstWord[0]}${secondWord[0]}${lastLetter}`;
  }

  if (words.length === 1) {
    return words[0].slice(0, 3).padEnd(3, words[0][words[0].length - 1] || 'X');
  }

  return 'INV';
}

function normalizeBillPrefix(prefixCandidate, fallbackShopName = '') {
  const rawPrefix = String(prefixCandidate || '').trim().toUpperCase().replace(/[^A-Z0-9]/g, '');
  const normalized = rawPrefix || buildShopInvoicePrefix(fallbackShopName);

  return normalized.slice(0, 10);
}

module.exports = {
  buildShopInvoicePrefix,
  normalizeBillPrefix,
};