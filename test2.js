// const sqrtToPrice = (sqrtPrice, decimals0, decimals1) => {
//
//   let decimals = decimals0;
//   if (decimals0 !== decimals1) {
//     decimals = decimals0 > decimals1 ? decimals0 - decimals1 : decimals1 - decimals0;
//   }
//
//   let price = ((sqrtPrice ** 2n) * (10n ** decimals)) / (2n ** 192n);
//
//   return price;
// }
// // WMATIC/WETH
// const price = sqrtToPrice(1787846101747825361402690939n, 18n, 18n);
//
// console.log(price);
//
// const computeAsks = (price, volume, baseDecimals, quoteDecimals) => {
//   const _volume =  price * (volume * 10n**baseDecimals);
//
//   return _volume / 10n ** quoteDecimals;
// }
//
// const computeBids = (price, volume, baseDecimals, quoteDecimals) => {
//   const _volume =  (volume * 10n ** quoteDecimals) * 10n ** baseDecimals / price;
//
//   return _volume;
// }
//
//
// const asks = computeAsks(price, 1787n, 18n, 18n);
// const bids = computeBids(price, 1n, 18n, 18n);
//
// console.log('asks', asks);
// console.log('bids', bids);

const sqrtToPrice = (sqrtPrice, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  let price = ((sqrtPrice ** 2n) * (10n ** maxDecimals)) / (2n ** 192n);

  return price;
}
// DAI/WETH
const price = sqrtToPrice(1855035694857951326591990562n, 18n, 18n);

console.log(price);

const computeAsks = (price, volume, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  const _volume =  (price * volume * 10n ** (maxDecimals - quoteDecimals)) / (10n ** quoteDecimals);

  return _volume;
}

const computeBids = (price, volume, baseDecimals, quoteDecimals) => {
  const maxDecimals = baseDecimals > quoteDecimals ? baseDecimals : quoteDecimals;
  const _volume =  (volume * 10n ** (maxDecimals - baseDecimals)) * (10n ** baseDecimals) / price;

  return _volume;
}

const asks = computeAsks(price, 1850n * 10n**18n ,18n, 18n);
const bids = computeBids(price, 1n * 10n**18n, 18n, 18n);

console.log('asks', asks);
console.log('bids', bids);
