// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/console.sol"; 
import "../../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Pool.sol"; 

import "../mocks/ERC20Mock.sol";

contract UniswapV3Mint {

    struct CallBackData {
        address token0;
        address token1;
        address payer;
    }

    struct Params {
        IUniswapV3Pool pool;
        uint256[2] balances;
        LiquidityRange[] liquidity;
        bool transferInMintCallback;
        bool transferInSwapCallback;
        bool mintLiqudity;
    }

    struct LiquidityRange {
        int24 lowerTick;
        int24 upperTick;
        uint128 amount;
    }

    function liquidityRange(
        uint256 lowerPrice,
        uint256 upperPrice,
        uint256 amount0,
        uint256 amount1,
        uint256 currentPrice
    ) internal pure returns (LiquidityRange memory range) {
        range = LiquidityRange({
            lowerTick: tick60(lowerPrice),
            upperTick: tick60(upperPrice),
            amount: LiquidityMath.getLiquidityForAmounts(
                sqrtP(currentPrice),
                sqrtP60(lowerPrice),
                sqrtP60(upperPrice),
                amount0,
                amount1
            )
        });
    }

    function mint(
        address minter,
        Params memory params
    ) public {
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
