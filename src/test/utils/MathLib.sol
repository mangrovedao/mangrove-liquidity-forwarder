// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "./TickMath.sol";

import "../../../lib-0_7_6/v3-core/contracts/libraries/FixedPoint96.sol";

library MathLib {

  int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

  /*
   * Maximum value signed 64.64-bit fixed point number may have. 
   */
  int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
   * number.
   *
   * @param x unsigned 256-bit integer number
   * @return unsigned 128-bit integer number
   */
  function sqrtu(uint256 x) private pure returns (uint128) {
    unchecked {
      if (x == 0) return 0;
      else {
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
        if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
        if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
        if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
        if (xx >= 0x100) { xx >>= 8; r <<= 4; }
        if (xx >= 0x10) { xx >>= 4; r <<= 2; }
        if (xx >= 0x4) { r <<= 1; }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return uint128 (r < r1 ? r : r1);
      }
    }
    }

    /**
    * Calculate sqrt (x) rounding down.  Revert if x < 0.
    *
    * @param x signed 64.64-bit fixed point number
    * @return signed 64.64-bit fixed point number
    */
    function sqrt(int128 x) internal pure returns (int128) {
        unchecked {
          require (x >= 0);
          return int128 (sqrtu (uint256 (int256 (x)) << 64));
        }
    }

    /**
    * Calculate x / y rounding towards zero.  Revert on overflow or when y is
    * zero.
    *
    * @param x signed 64.64-bit fixed point number
    * @param y signed 64.64-bit fixed point number
    * @return signed 64.64-bit fixed point number
    */
    function div (int128 x, int128 y) internal pure returns (int128) {
        unchecked {
          require (y != 0);
          int256 result = (int256 (x) << 64) / y;
          require (result >= MIN_64x64 && result <= MAX_64x64);
          return int128 (result);
        }
    }

    function divRound(int128 x, int128 y)
        internal
        pure
        returns (int128 result)
    {
        int128 quot = div(x, y);
        result = quot >> 64;

        // Check if remainder is greater than 0.5
        if (quot % 2**64 >= 0x8000000000000000) {
            result += 1;
        }
    }

    function nearestUsableTick(int24 tick_, uint24 tickSpacing)
        internal
        pure
        returns (int24 result)
    {
        result =
            int24(divRound(int128(tick_), int128(int24(tickSpacing)))) *
            int24(tickSpacing);

        if (result < TickMath.MIN_TICK) {
            result += int24(tickSpacing);
        } else if (result > TickMath.MAX_TICK) {
            result -= int24(tickSpacing);
        }
    }

    function sqrtP(uint256 price) internal pure returns (uint160) {
        return
            uint160(
                int160(
                    sqrt(int128(int256(price << 64))) <<
                        (FixedPoint96.RESOLUTION - 64)
                )
            );
    }

    // Calculates sqrtP from price with tick spacing equal to 60;
    function sqrtP60(uint256 price) internal pure returns (uint160) {
        return TickMath.getSqrtRatioAtTick(tick60(price));
    }

    // Calculates sqrtP from tick with tick spacing equal to 60;
    function sqrtP60FromTick(int24 tick_) internal pure returns (uint160) {
        return TickMath.getSqrtRatioAtTick(nearestUsableTick(tick_, 60));
    }

    function tick(uint256 price) internal pure returns (int24 tick_) {
        tick_ = TickMath.getTickAtSqrtRatio(sqrtP(price));
    }

    // Calculates tick from price with tick spacing equal to 60;
    function tick60(uint256 price) internal pure returns (int24 tick_) {
        tick_ = tick(price);
        tick_ = nearestUsableTick(tick_, 60);
    }
}
