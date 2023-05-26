const sqrtToPrice = (sqrtPrice, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  let price = ((sqrtPrice ** 2n) * (10n ** maxDecimals)) / (2n ** 192n);

  return price;
}
// USDC/WETH
const price = sqrtToPrice(1873995297957243817768222563116177n, 6n, 18n);

console.log(price);

const computeAsks = (price, volume, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  const _volume =  (price * volume * 10n ** (maxDecimals - quoteDecimals)) / (10n ** quoteDecimals);

  return _volume;
}

const computeAsksInQuote = (price, volume, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  const _volume =  (price * volume * 10n ** (maxDecimals - quoteDecimals)) / (10n ** quoteDecimals);

  return _volume;
}

const computeBids = (price, volume, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  const _volume =  (volume * 10n ** (maxDecimals - baseDecimals)) * (10n ** baseDecimals) / price;

  return _volume;
}

const asks = computeAsks(price, 1787n * 10n**6n , 6n, 18n);
const bids = computeBids(price, 1n * 10n**18n, 6n, 18n);
const asksWithQuote = computeAsks(price, bids , 6n, 18n);

console.log('asks', asks);
console.log('bids', bids);
console.log('asks with quote', asksWithQuote);
