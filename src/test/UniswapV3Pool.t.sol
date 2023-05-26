// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol"; 
import "../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Factory.sol"; 
import "../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Pool.sol"; 

import "./mocks/ERC20Mock.sol"; 
import "./utils/UniswapV3Utils.sol";
import "./utils/MathLib.sol";
import "../../lib/prb-math/src/Common.sol";

interface CheatCodes {
   // Gets address for a given private key, (privateKey) => (address)
   function addr(uint256) external returns (address);
}

contract UniswapV3PoolTest is Test, UniswapV3Utils {

    address public owner;
    address public addr1;
    address public addr2;

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    IUniswapV3Factory public factory; 
    IUniswapV3Pool public pool; 

    ERC20Mock public WETH;
    ERC20Mock public DAI; 
    mapping(address => mapping(address => uint256)) balances;

    uint160 private initialPrice = 1000;

    function setBalances() internal {
        balances[address(WETH)][address(addr1)] = 1e24;
        balances[address(DAI)][address(addr1)] = 1e24;

        balances[address(WETH)][address(addr2)] = 1e24;
        balances[address(DAI)][address(addr2)] = 1e24;

        WETH.mint(addr1, balances[address(WETH)][addr1]);
        DAI.mint(addr1, balances[address(DAI)][addr1]);

        WETH.mint(addr2, balances[address(WETH)][addr2]);
        DAI.mint(addr2, balances[address(DAI)][addr2]);

        vm.startPrank(addr1);

        WETH.approve(address(this), 2**256 - 1);
        DAI.approve(address(this), 2**256 - 1);

        vm.stopPrank();

        vm.startPrank(addr2);

        WETH.approve(address(this), 2**256 - 1);
        DAI.approve(address(this), 2**256 - 1);

        vm.stopPrank();
    }

    function setUp() public { 
        owner = address(this);
        addr1 = cheats.addr(1);
        addr2 = cheats.addr(2);

        WETH = new ERC20Mock("WETH", "WETH", 18); 
        DAI = new ERC20Mock("DAI", "DAI", 18); 

        bool isWethDai = address(WETH) < address(DAI);

        console.log(isWethDai ? 'WETH/DAI' : 'DAI/WETH');

        factory = IUniswapV3Factory(deployCode("UniswapV3Factory.sol:UniswapV3Factory")); 
        pool = IUniswapV3Pool(
            factory.createPool(address(WETH), address(DAI), 500)
        );
        pool.initialize(MathLib.sqrtP(initialPrice));
        setBalances();
        console.log('Contract created successfully');
    }

    function testMintLiqudityOnUniswapV3() public {
        (
            uint256 poolBalance0,
            uint256 poolBalance1
        ) = mint(
            addr1,
            MintParams({
                pool: pool,
                liquidity: liquidityRanges(
                    liquidityRange(500, 1500, 1e18, 1000e18, initialPrice)
                )
            })
        );

        (
            uint160 sqrtPriceX96,
            int24 tick,
            ,// uint16 observationIndex,
            ,// uint16 observationCardinality,
            ,// uint16 observationCardinalityNext,
            ,// uint8 feeProtocol,
            // bool unlocked
        ) = pool.slot0();
        console.logUint(sqrtPriceX96);
        console.logInt(tick);
    }

    function testSwapWETHToDaiUniswapV3() public {
        (
            uint256 poolBalance0,
            uint256 poolBalance1
        ) = mint(
            addr1,
            MintParams({
                pool: pool,
                liquidity: liquidityRanges(
                    liquidityRange(500, 1500, 1e18, 1000e18, initialPrice)
                )
            })
        );

        uint256 amoutWETHBeforeSwap = WETH.balanceOf(addr2);
        uint256 amoutDAIBeforeSwap = DAI.balanceOf(addr2);
        swap(
            addr2,
            SwapParams({
                pool: pool,
                tokenIn: address(WETH),
                tokenOut: address(DAI),
                amount: 1e5
            })
        );

        console.log('Swap WETH -> DAI');
        console.log('WETH balances');
        console.logUint(amoutWETHBeforeSwap);
        console.logUint(WETH.balanceOf(addr2));

        console.log('Dai balances');
        console.logUint(amoutDAIBeforeSwap);
        console.logUint(DAI.balanceOf(addr2));

        assertEq(amoutWETHBeforeSwap > WETH.balanceOf(addr2), true);
        assertEq(amoutDAIBeforeSwap < DAI.balanceOf(addr2), true);
    }

    function testSwapDAIToWETHUniswapV3() public {
        (
            uint256 poolBalance0,
            uint256 poolBalance1
        ) = mint(
            addr1,
            MintParams({
                pool: pool,
                liquidity: liquidityRanges(
                    liquidityRange(500, 1500, 1e18, 1000e18, initialPrice)
                )
            })
        );

        uint256 amoutWETHBeforeSwap = WETH.balanceOf(addr2);
        uint256 amoutDAIBeforeSwap = DAI.balanceOf(addr2);
        swap(
            addr2,
            SwapParams({
                pool: pool,
                tokenIn: address(DAI),
                tokenOut: address(WETH),
                amount: 1e5
            })
        );

        console.log('Swap DAI -> WETH');
        console.log('Dai balances');
        console.logUint(amoutDAIBeforeSwap);
        console.logUint(DAI.balanceOf(addr2));

        console.log('WETH balances');
        console.logUint(amoutWETHBeforeSwap);
        console.logUint(WETH.balanceOf(addr2));

        assertEq(amoutWETHBeforeSwap < WETH.balanceOf(addr2), true);
        assertEq(amoutDAIBeforeSwap > DAI.balanceOf(addr2), true);

        (
            uint160 sqrtPriceX96,
            int24 tick,
            ,// uint16 observationIndex,
            ,// uint16 observationCardinality,
            ,// uint16 observationCardinalityNext,
            ,// uint8 feeProtocol,
            // bool unlocked
        ) = pool.slot0();

        console.logUint(sqrtPriceX96);
        console.logInt(tick);
    }

}
