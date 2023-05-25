// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/console.sol"; 
import "../../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Pool.sol"; 

import "../mocks/ERC20Mock.sol";
import "./LiqudityMath.sol";
import "./MathLib.sol";
import "./MathLib.sol";

contract UniswapV3Mint {

    struct CallBackData {
        address token0;
        address token1;
        address payer;
    }

    struct Params {
        IUniswapV3Pool pool;
        LiquidityRange[] liquidity;
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
        Params memory params
    ) public returns (uint256 poolBalance0, uint256 poolBalance1) {
        bytes memory data = abi.encode(
            CallBackData({
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
        CallBackData memory extra = abi.decode(
            data,
            (CallBackData)
        );

        IERC20(extra.token0).transferFrom(extra.payer, msg.sender, amount0);
        IERC20(extra.token1).transferFrom(extra.payer, msg.sender, amount1);
    }
}
