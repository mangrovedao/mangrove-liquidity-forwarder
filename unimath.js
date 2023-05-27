const sqrtToPrice = (sqrtPrice, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  let price = ((sqrtPrice ** 2n) * (10n ** maxDecimals)) / (2n ** 192n);

  return price;
}
// DAI/WETH
const price = sqrtToPrice(1855035694857951326591990562n, 18n, 18n);

console.log(price);

const computeQuote = (price, volume, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  const _volume =  (price * volume * 10n ** (maxDecimals - quoteDecimals)) / (10n ** quoteDecimals);

  return _volume;
}

const computeBase = (price, volume, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  const _volume =  (volume * 10n ** (maxDecimals - baseDecimals)) * (10n ** baseDecimals) / price;

  return _volume;
}

const volumeQuote = 1850n * 10n**18n;
const asks = computeQuote(price, volumeQuote, 18n, 18n);

const volumeBase = 1n * 10n**18n;
const bids = computeBase(price, volumeBase, 18n, 18n);

console.log('DAI/WETH');
console.log('volumeQuote', volumeQuote, asks, '===',  10n**18n);
console.log('volumeBase', volumeBase, bids, '===', 1800n * 10n ** 18n);

// USDC/WETH
const priceUSDCWETH = sqrtToPrice(1873995297957243817768222563116177n, 6n, 18n);

console.log('\nUSDC/WETH');
const volumeBase2 = 1787n * 10n**6n;
const resultQuote2 = computeQuote(priceUSDCWETH,  volumeBase2, 6n, 18n);

const volumQuote2 = 1n * 10n**18n;
const resultBase2 = computeBase(priceUSDCWETH, volumQuote2, 6n, 18n);

console.log('volumeBase2', volumeBase2, resultQuote2 , '===',  10n**18n);
console.log('volumQuote2', volumQuote2, resultBase2, '===', 1787n * 10n**6n);

console.log('\nWETH/DAI');
const price3 = sqrtToPrice(2505414483750479311860725186560n, 18n, 18n);

const volumeBase3 = 1n * 10n**18n;
const resultQuote3 = computeQuote(price3,  volumeBase3, 18n, 18n);

const volumeQuote3 = 1000n * 10n**18n;
const resultBase3 = computeBase(price3, volumeQuote3, 18n, 18n);

console.log('volumeBase3', volumeBase3, resultQuote3, '===', 1000n * 10n**18n);
console.log('volumeQuote3', volumeQuote3, resultBase3, '===', 10n**18n);

console.log('\nWETH/USDC');

const computePrice = (wants, wantsDecimals, gives, givesDecimals) => {
  return ((wants * 10n**wantsDecimals) / (gives * 10n**givesDecimals))
}

const price4 = computePrice(1n, 18n, 1000n, 6n);

console.log(price4);

const volumeBase4 = 1n * 10n**18n;
const resultQuote4 = computeQuote(price4,  volumeBase4, 6n, 18n);

const volumeQuote4 = 1000n * 10n**6n;
const resultBase4 = computeBase(price4, volumeQuote4, 6n, 18n);

console.log('volumeBase4', volumeBase4, resultQuote4, '===', 1000n * 10n**6n);
console.log('volumeQuote4', volumeQuote4, resultBase4, '===', 10n**18n);
