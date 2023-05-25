// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol"; 
import "../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Factory.sol"; 
import "../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Pool.sol"; 

import "./mocks/ERC20Mock.sol"; 

contract UniswapV3PoolTest is Test { 
    IUniswapV3Factory public factory; 
    IUniswapV3Pool public pool; 

    ERC20Mock public WETH; 
    ERC20Mock public DAI; 

    function setUp() public { 
        WETH = new ERC20Mock("WETH", "WETH", 18); 
        DAI = new ERC20Mock("DAI", "DAI", 18); 

        factory = IUniswapV3Factory(deployCode("UniswapV3Factory.sol:UniswapV3Factory")); 
        pool = IUniswapV3Pool(
            factory.createPool(address(WETH), address(DAI), 500)
        );
        console.log('Contract created successfully');
    }

    function testAllGod() public {
        assertEq(true, true);
    }

}
