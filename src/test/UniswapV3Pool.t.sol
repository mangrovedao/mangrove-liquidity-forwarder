// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract UniswapV3PoolTest is Test{
    IUniswapV3Factory factory;
    IUniswapV3Pool pool;

    bool transferInMintCallback = true;
    bool flashCallbackCalled = false;

    function setUp() public {
        factory = IUniswapV3Factory(deployCode("UniswapV3Factory.sol:UniswapV3Factory"));
    }

}
