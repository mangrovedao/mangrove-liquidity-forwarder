// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol"; 
import "../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Factory.sol"; 
import "../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Pool.sol"; 

import "./mocks/ERC20Mock.sol"; 
import "./utils/UniswapV3Mint.utils.sol";

interface CheatCodes {
   // Gets address for a given private key, (privateKey) => (address)
   function addr(uint256) external returns (address);
}

contract UniswapV3PoolTest is Test, UniswapV3Mint {

    address public owner;
    address public addr1;
    address public addr2;

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    IUniswapV3Factory public factory; 
    IUniswapV3Pool public pool; 

    ERC20Mock public WETH;
    ERC20Mock public DAI; 
    mapping(address => mapping(address => uint256)) balances;

    uint160 private initialPrice = 1873995297957243817768222563116177;


    function setBalances() internal {
        balances[address(WETH)][address(addr1)] = 1e18;
        balances[address(DAI)][address(addr1)] = 10e18;
        WETH.mint(addr1, balances[addr1][address(WETH)]);
        DAI.mint(addr1, balances[addr1][address(DAI)]);

        vm.startPrank(addr1);

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

        factory = IUniswapV3Factory(deployCode("UniswapV3Factory.sol:UniswapV3Factory")); 
        pool = IUniswapV3Pool(
            factory.createPool(address(WETH), address(DAI), 500)
        );
        pool.initialize(initialPrice);
        setBalances();
        console.log('Contract created successfully');
    }

    function testAllGod() public {

        mint(
            Params({
                pool: pool,
                balances: [5e17, 1e18],
            })
        );

        // (
        //     uint160 sqrtPriceX96,
        //     int24 tick,
        //     uint16 observationIndex,
        //     uint16 observationCardinality,
        //     uint16 observationCardinalityNext,
        //     uint8 feeProtocol,
        //     bool unlocked
        // ) = pool.slot0();
        //
        // console.logInt(tick);
        // console.logUint(sqrtPriceX96);
        // assertEq(true, true);
    }

}
