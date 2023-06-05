// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "../../lib-0_7_6/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "mangrove-core/src/strategies/offer_maker/abstract/Direct.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

abstract contract AbstractLiqudityForwarder is Direct, Ownable {
    uint8 MAX_DECIMALS;
    uint256 public spreadBps;
    uint256 public acceptedLossBps;

    IUniswapV3Pool pool;

    IERC20 BASE;
    IERC20 QUOTE;

    IERC20 token0;
    IERC20 token1;

    bool inversed;

    uint256 QUOTE_TOKEN_VOLUME;

    bool initialized = false;

    ///@notice Constructor
    ///@param mgv The Mangrove deployment.
    ///@param gasreq the gasreq to use for offers
    ///@param reserveId identifier of this contract's reserve when using a router.
    constructor(
        IMangrove mgv, 
        uint gasreq, 
        address reserveId,
        IERC20 base,
        IERC20 quote,
        address _pool, 
        uint256 _QUOTE_TOKEN_VOLUME
    )
        Direct(mgv, NO_ROUTER, gasreq, reserveId) Ownable()
    {
        pool = IUniswapV3Pool(_pool);
        BASE = base;
        QUOTE = quote;

        token0 = IERC20(pool.token0());
        token1 = IERC20(pool.token1());

        if (address(base) != pool.token0()) {
            inversed = true;
        }

        MAX_DECIMALS = BASE.decimals() > QUOTE.decimals() ? BASE.decimals() : QUOTE.decimals();

        QUOTE_TOKEN_VOLUME = _QUOTE_TOKEN_VOLUME;
    }

    function initialize() external onlyOwner {
        require(initialized == false, "AbstractLiqudityForwarder/alreadyInitialized");
        initialized = true;

        newBid();
        newAsk();
    }

    function getPrice() virtual internal returns (uint256 price);

    function computeQuote(uint256 price, uint256 volume) internal returns (uint256 _volume) {
        _volume = price * volume / (10 ** MAX_DECIMALS);
    }

    function computeBase(uint256 price, uint256 volume) internal returns (uint256 _volume) {
        _volume = (volume * 10 ** MAX_DECIMALS) / price;
    }

    function newBid() internal {
        uint256 price = getPrice();
        price = price * (10_000 - spreadBps) / 10_000;

        uint256 baseVolume = computeBase(price, QUOTE_TOKEN_VOLUME);

        _newOffer(OfferArgs({
            outbound_tkn: QUOTE,
            inbound_tkn: BASE,
            gives: QUOTE_TOKEN_VOLUME,
            wants: baseVolume,
            gasreq: offerGasreq(),
            gasprice: 0,
            pivotId: 0,
            fund: msg.value,
            noRevert: true
        }));
    }

    function newAsk() internal {
        uint256 price = getPrice();
        price = price * (10_000 + spreadBps) / 10_000;
        uint256 baseVolume = computeBase(price, QUOTE_TOKEN_VOLUME);

        _newOffer(OfferArgs({
            outbound_tkn: BASE,
            inbound_tkn: QUOTE,
            gives: baseVolume,
            wants: QUOTE_TOKEN_VOLUME,
            gasreq: offerGasreq(),
            gasprice: 0,
            pivotId: 0,
            fund: msg.value,
            noRevert: true
        }));
    }

    function __lastLook__(MgvLib.SingleOrder calldata order) internal override returns (bytes32 data) {
        bytes32 makerData = super.__lastLook__(order);

        uint256 sourcePrice = getPrice();
        if (order.outbound_tkn == address(token0)) {
            // outbound_tkn = token0, inbound_tkn == token1
            // gives = token0 , wants = token1
            uint256 token1Volume = computeQuote(sourcePrice, order.gives);
            token1Volume = token1Volume * (10_000 + acceptedLossBps) / 10_000;

            if (token1Volume < order.wants) {
                //reneg
            }
        } else {
            // outbound_tkn = token1, inbound_tkn == token0
            // gives = token1 , wants = token0
            uint256 token0Volume = computeBase(sourcePrice, order.gives);
            token0Volume = token0Volume * (10_000 + acceptedLossBps) / 10_000;
            if (token0Volume  < order.wants) {
                // reneg
            }
        }
    }

}
