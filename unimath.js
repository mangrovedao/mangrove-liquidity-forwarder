const sqrtToPrice = (sqrtPrice, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  let price = ((sqrtPrice ** 2n) * (10n ** maxDecimals)) / (2n ** 192n);

  return price;
}
// DAI/WETH
const price = sqrtToPrice(1855035694857951326591990562n, 18n, 18n);

console.log(price);

const maxDecimals = 18n;
const computeQuote = (price, volume) => {
  const _volume =  (price * volume) / (10n ** maxDecimals);

  return _volume;
}

const computeBase = (price, volume) => {
  const _volume =  (volume * 10n ** maxDecimals) / price;

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

console.log('\nUSDC/WETH');
const priceUSDCWETH = sqrtToPrice(1873995297957243817768222563116177n, 6n, 18n);
const volumeBase2 = 1787n * 10n**6n;
const resultQuote2 = computeQuote(priceUSDCWETH,  volumeBase2, 6n, 18n);

const volumQuote2 = 1n * 10n**18n;
const resultBase2 = computeBase(priceUSDCWETH, volumQuote2, 6n, 18n);

console.log('price', priceUSDCWETH);
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

const order = {
  wants: 1n * 10n**18n,
  gives: 990n * 10n **6n
} // wants > gives, wants: BASE, gives: QUOTE

console.log(order.wants/order.gives, price4);

let orderPrice = order.wants / order.gives;

console.log();
console.log('orderPrice', orderPrice);
console.log('sourcePrice', price4);
let resultBase = computeBase(price4,  order.gives, 6n, 18n);
console.log('volumeBase:', resultBase, 'wants', order.wants);
console.log();

const order2 = {
  gives: 1n * 10n**18n,
  wants: 1010n * 10n **6n
} // gives > wants, wants: QUOTE, gives: BASE
orderPrice = order2.gives / order2.wants;

console.log();
console.log('orderPrice', orderPrice);
console.log('sourcePrice', price4);
let resultQuote = computeQuote(price4,  order2.gives, 6n, 18n);
console.log('volumeQuote:', resultQuote, 'wants', order2.wants);
let resultQuoteWithAcceptanceLoss = (resultQuote * (10_000n + 100n) / 10_000n);
console.log('acceptedLoss', resultQuoteWithAcceptanceLoss);
let lossOrEarn = resultQuote - order2.wants;
console.log( lossOrEarn > 0 ? 'earn' : 'loss', lossOrEarn);
console.log('volumeQuote + 1% < wants',  resultQuoteWithAcceptanceLoss < order2.wants ? 'reneg' : 'accept');
console.log();

const order3 = {
  gives: 1n * 10n**18n, // QUOTE
  wants: 1010n * 10n **6n // BASE
} 
orderPrice = order3.gives / order3.wants;

console.log();
console.log('orderPrice', orderPrice);
console.log('sourcePrice', priceUSDCWETH);
resultBase = computeBase(priceUSDCWETH,  order3.gives, 6n, 18n);
console.log('volumeQuote:', resultBase, 'wants', order3.wants);
let resulBaseWithAcceptanceLoss = (resultBase * (10_000n + 100n) / 10_000n);
console.log('acceptedLoss', resulBaseWithAcceptanceLoss);
lossOrEarn = resultBase - order3.wants;
console.log( lossOrEarn > 0 ? 'earn' : 'loss', lossOrEarn);
console.log('volumeQuote + 1% < wants',  resulBaseWithAcceptanceLoss < order3.wants ? 'reneg' : 'accept');
console.log();

// Inversed case

// ETH/USDC
const order4 = {
  gives: 1n * 10n**18n, // BASE
  wants: 1010n * 10n **6n // QUOTE
} 
orderPrice = order3.gives / order3.wants;
let orderPriceTest = 10n**18n * order3.wants / order3.gives;

console.log('ETH/USDC, 10**18/10**6', orderPrice * 10n**18n);
console.log('USDC/ETH, 10**6/10**18', priceUSDCWETH);

console.log('ETH/USDC, 10**18/10**6', orderPrice);
console.log('USDC/ETH, 10**6/10**18', orderPriceTest);

console.log('Price USDC/ETH:', priceUSDCWETH)
// USDC/ETH
let _wants = computeBase(priceUSDCWETH, order4.gives)
console.log('USDC', _wants);

// USDC/ETH
let _quote = computeQuote(priceUSDCWETH, order4.wants)
console.log('ETH', _quote);

console.log('\nPrice ETH/USDC:', orderPrice)

_wants = computeQuote(orderPrice, order4.gives);
console.log('USDC', _wants); // USDC

// ETH/USDC
_quote = computeBase(orderPrice, order4.wants)
console.log('ETH', _quote); // ETH

orderPrice *= 10n**18n

console.log('\nPrice USDC/ETH:', orderPrice)

_wants = computeBase(orderPrice, order4.gives);
console.log('USDC', _wants); // USDC

_quote = computeQuote(orderPrice, order4.wants);
console.log('ETH', _quote); // ETH


console.log('\nPrice: ETH/USDC', orderPriceTest)

_wants = computeQuote(orderPriceTest, order4.gives);
console.log('USDC', _wants);

_gives = computeBase(orderPriceTest, order4.wants);
console.log('ETH', _gives); // USDC
