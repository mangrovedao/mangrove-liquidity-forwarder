// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/console.sol"; 
import "../../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Pool.sol"; 

import "../mocks/ERC20Mock.sol";
import "./LiqudityMath.sol";
import "./MathLib.sol";
import "./MathLib.sol";

contract UniswapV3Mint {

    struct CallbackData {
        address token0;
        address token1;
        address payer;
    }

    struct MintParams {
        IUniswapV3Pool pool;
        LiquidityRange[] liquidity;
    }

    struct SwapParams {
        IUniswapV3Pool pool;
        address tokenIn;
        address tokenOut;
        uint256 amount;
    }

    struct LiquidityRange {
        int24 lowerTick;
        int24 upperTick;
        uint128 amount;
    }

    function liquidityRanges(LiquidityRange memory range)
        internal
        pure
        returns (LiquidityRange[] memory ranges)
    {
        ranges = new LiquidityRange[](1);
        ranges[0] = range;
    }

    function liquidityRange(
        uint256 lowerPrice,
        uint256 upperPrice,
        uint256 amount0,
        uint256 amount1,
        uint256 currentPrice
    ) internal pure returns (LiquidityRange memory range) {
        range = LiquidityRange({
            lowerTick: MathLib.tick60(lowerPrice),
            upperTick: MathLib.tick60(upperPrice),
            amount: LiquidityMath.getLiquidityForAmounts(
                MathLib.sqrtP(currentPrice),
                MathLib.sqrtP60(lowerPrice),
                MathLib.sqrtP60(upperPrice),
                amount0,
                amount1
            )
        });
    }

    function mint(
        address minter,
        MintParams memory params
    ) public returns (uint256 poolBalance0, uint256 poolBalance1) {
        bytes memory data = abi.encode(
            CallbackData({
                token0: params.pool.token0(),
                token1: params.pool.token1(),
                payer: minter
            })
        );

        uint256 poolBalance0Tmp;
        uint256 poolBalance1Tmp;
        for (uint256 i = 0; i < params.liquidity.length; i++) {
            (poolBalance0Tmp, poolBalance1Tmp) = params.pool.mint(
                minter,
                params.liquidity[i].lowerTick,
                params.liquidity[i].upperTick,
                params.liquidity[i].amount,
                data
            );
            poolBalance0 += poolBalance0Tmp;
            poolBalance1 += poolBalance1Tmp;
        }
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) public {
        CallbackData memory extra = abi.decode(
            data,
            (CallbackData)
        );

        IERC20(extra.token0).transferFrom(extra.payer, msg.sender, amount0);
        IERC20(extra.token1).transferFrom(extra.payer, msg.sender, amount1);
    }

    function swap(
        address payer,
        SwapParams memory params
    ) public {
        bool zeroForOne = params.tokenIn < params.tokenOut; // TokenIn TokenOut

        bytes memory data = abi.encode(
            CallbackData({
                token0: params.pool.token0(),
                token1: params.pool.token1(),
                payer: payer
            })
        );

        params.pool.swap(
            payer,
            zeroForOne,
            1e5,
            zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1,
            data
        );

    }


    function uniswapV3SwapCallback(
        int256 amount0,
        int256 amount1,
        bytes calldata data
    ) public {
        CallbackData memory cbData = abi.decode(
            data,
            (CallbackData)
        );

        if (amount0 > 0) {
            IERC20(cbData.token0).transferFrom(
                cbData.payer,
                msg.sender,
                uint256(amount0)
            );
        }

        if (amount1 > 0) {
            IERC20(cbData.token1).transferFrom(
                cbData.payer,
                msg.sender,
                uint256(amount1)
            );
        }
    }


}
