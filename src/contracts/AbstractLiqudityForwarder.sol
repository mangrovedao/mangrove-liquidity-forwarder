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

    uint256 QUOTE_TOKEN_VOLUME;

    bool initialized = false;

    ///@notice Constructor
    ///@param mgv The Mangrove deployment.
    ///@param gasreq the gasreq to use for offers
    ///@param reserveId identifier of this contract's reserve when using a router.
    constructor(IMangrove mgv, uint gasreq, address reserveId, address _pool, uint256 _QUOTE_TOKEN_VOLUME)
        Direct(mgv, NO_ROUTER, gasreq, reserveId) Ownable()
    {
        pool = IUniswapV3Pool(_pool);
        BASE = IERC20(pool.token0());
        QUOTE = IERC20(pool.token1());

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
        _volume =  (price * volume * 10 ** (MAX_DECIMALS - QUOTE.decimals())) / (10 ** QUOTE.decimals());
    }

    function computeBase(uint256 price, uint256 volume) internal returns (uint256 _volume) {
        _volume =  (volume * 10 ** (MAX_DECIMALS - BASE.decimals())) * (10 ** BASE.decimals()) / price;
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
        uint256 orderPrice = 0;
        if (order.gives > order.wants) {
            orderPrice = order.gives / order.wants;
        } else {
            orderPrice = order.wants / order.gives;
        }

        if (order.outbound_tkn == address(BASE)) {
            // outbound_tkn = BASE, inbound_tkn == QUOTE
            // gives = BASE , wants = QUOTE
            uint256 volumeQuote = computeQuote(sourcePrice, order.gives);
            volumeQuote = volumeQuote * (10_000 + acceptedLossBps) / 10_000;
            if (volumeQuote < order.wants) {
                //reneg
            }
        
        } else {
            // outbound_tkn = QUOTE, inbound_tkn == BASE
            // gives = QUOTE , wants = BASE
            uint256 volumeBase = computeBase(sourcePrice, order.gives);
            volumeBase = volumeBase * (10_000 + acceptedLossBps) / 10_000;
            if (volumeBase  < order.wants) {
                // reneg
            }
        }
    }

}
