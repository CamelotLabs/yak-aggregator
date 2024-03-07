//       ╟╗                                                                      ╔╬
//       ╞╬╬                                                                    ╬╠╬
//      ╔╣╬╬╬                                                                  ╠╠╠╠╦
//     ╬╬╬╬╬╩                                                                  ╘╠╠╠╠╬
//    ║╬╬╬╬╬                                                                    ╘╠╠╠╠╬
//    ╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬      ╒╬╬╬╬╬╬╬╜   ╠╠╬╬╬╬╬╬╬         ╠╬╬╬╬╬╬╬    ╬╬╬╬╬╬╬╬╠╠╠╠╠╠╠╠
//    ╙╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╕    ╬╬╬╬╬╬╬╜   ╣╠╠╬╬╬╬╬╬╬╬        ╠╬╬╬╬╬╬╬   ╬╬╬╬╬╬╬╬╬╠╠╠╠╠╠╠╩
//     ╙╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬  ╔╬╬╬╬╬╬╬    ╔╠╠╠╬╬╬╬╬╬╬╬        ╠╬╬╬╬╬╬╬ ╣╬╬╬╬╬╬╬╬╬╬╬╠╠╠╠╝╙
//               ╘╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬    ╒╠╠╠╬╠╬╩╬╬╬╬╬╬       ╠╬╬╬╬╬╬╬╣╬╬╬╬╬╬╬╙
//                 ╣╬╬╬╬╬╬╬╬╬╬╠╣     ╣╬╠╠╠╬╩ ╚╬╬╬╬╬╬      ╠╬╬╬╬╬╬╬╬╬╬╬╬╬╬
//                  ╣╬╬╬╬╬╬╬╬╬╣     ╣╬╠╠╠╬╬   ╣╬╬╬╬╬╬     ╠╬╬╬╬╬╬╬╬╬╬╬╬╬╬
//                   ╟╬╬╬╬╬╬╬╩      ╬╬╠╠╠╠╬╬╬╬╬╬╬╬╬╬╬     ╠╬╬╬╬╬╬╬╠╬╬╬╬╬╬╬
//                    ╬╬╬╬╬╬╬     ╒╬╬╠╠╬╠╠╬╬╬╬╬╬╬╬╬╬╬╬    ╠╬╬╬╬╬╬╬ ╣╬╬╬╬╬╬╬
//                    ╬╬╬╬╬╬╬     ╬╬╬╠╠╠╠╝╝╝╝╝╝╝╠╬╬╬╬╬╬   ╠╬╬╬╬╬╬╬  ╚╬╬╬╬╬╬╬╬
//                    ╬╬╬╬╬╬╬    ╣╬╬╬╬╠╠╩       ╘╬╬╬╬╬╬╬  ╠╬╬╬╬╬╬╬   ╙╬╬╬╬╬╬╬╬
//

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

import "./interface/IYakRouter.sol";
import "./interface/IAdapter.sol";
import "./interface/IERC20.sol";
import "./interface/IWETH.sol";
import "./lib/SafeERC20.sol";
import "./lib/Maintainable.sol";
import "./lib/YakViewUtils.sol";
import "./lib/Recoverable.sol";
import "./lib/SafeERC20.sol";

contract CamelotYakRouter is Maintainable, Recoverable, IYakRouter {
    using SafeERC20 for IERC20;
    using OfferUtils for Offer;

    address public immutable WNATIVE;
    address public constant NATIVE = address(0);
    string public constant NAME = "CamelotYakRouter";
    uint256 public constant FEE_DENOMINATOR = 1e4;
    uint256 public MIN_FEE = 0;
    address public FEE_CLAIMER;
    address[] public TRUSTED_TOKENS;
    address[] public ADAPTERS;

    constructor(
        address[] memory _adapters,
        address[] memory _trustedTokens,
        address _feeClaimer,
        address _wrapped_native
    ) {
        setAllowanceForWrapping(_wrapped_native);
        setTrustedTokens(_trustedTokens);
        setFeeClaimer(_feeClaimer);
        setAdapters(_adapters);
        WNATIVE = _wrapped_native;
    }

    // -- SETTERS --

    function setAllowanceForWrapping(address _wnative) public onlyMaintainer {
        IERC20(_wnative).safeApprove(_wnative, type(uint256).max);
    }

    function setTrustedTokens(
        address[] memory _trustedTokens
    ) public override onlyMaintainer {
        emit UpdatedTrustedTokens(_trustedTokens);
        TRUSTED_TOKENS = _trustedTokens;
    }

    function setAdapters(
        address[] memory _adapters
    ) public override onlyMaintainer {
        emit UpdatedAdapters(_adapters);
        ADAPTERS = _adapters;
    }

    function setMinFee(uint256 _fee) external override onlyMaintainer {
        emit UpdatedMinFee(MIN_FEE, _fee);
        MIN_FEE = _fee;
    }

    function setFeeClaimer(address _claimer) public override onlyMaintainer {
        emit UpdatedFeeClaimer(FEE_CLAIMER, _claimer);
        FEE_CLAIMER = _claimer;
    }

    //  -- GENERAL --

    function trustedTokensCount() external view override returns (uint256) {
        return TRUSTED_TOKENS.length;
    }

    function adaptersCount() external view override returns (uint256) {
        return ADAPTERS.length;
    }

    // Fallback
    receive() external payable {}

    // -- HELPERS --

    function _applyFee(
        uint256 _amountIn,
        uint256 _fee
    ) internal view returns (uint256) {
        require(_fee >= MIN_FEE, "YakRouter: Insufficient fee");
        return (_amountIn * (FEE_DENOMINATOR - _fee)) / FEE_DENOMINATOR;
    }

    function _wrap(uint256 _amount) internal {
        IWETH(WNATIVE).deposit{value: _amount}();
    }

    function _unwrap(uint256 _amount) internal {
        IWETH(WNATIVE).withdraw(_amount);
    }

    function _unwrapTo(address _to, uint256 _amount) internal {
        IWETH(WNATIVE).withdrawTo(_to, _amount);
    }

    /**
     * @notice Return tokens to user
     * @dev Pass address(0) for ETH
     * @param _token address
     * @param _amount tokens to return
     * @param _to address where funds should be sent to
     */
    function _returnTokensTo(
        address _token,
        uint256 _amount,
        address _to
    ) internal {
        if (address(this) != _to) {
            if (_token == NATIVE) {
                payable(_to).transfer(_amount);
            } else {
                IERC20(_token).safeTransfer(_to, _amount);
            }
        }
    }

    function _transferFrom(
        address token,
        address _from,
        address _to,
        uint _amount
    ) internal {
        if (_from != address(this))
            IERC20(token).safeTransferFrom(_from, _to, _amount);
        else IERC20(token).safeTransfer(_to, _amount);
    }

    // -- QUERIES --

    /**
     * Query single adapter
     */
    function queryAdapter(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint8 _index
    ) external view override returns (uint256) {
        IAdapter _adapter = IAdapter(ADAPTERS[_index]);
        try IAdapter(_adapter).query(_amountIn, _tokenIn, _tokenOut) returns (
            uint256 _amountOut
        ) {
            return _amountOut;
        } catch {
            return 0;
        }
    }

    /**
     * Query specified adapters
     */
    function queryNoSplit(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        uint8[] calldata _options
    ) public view override returns (Query memory) {
        Query memory bestQuery;
        for (uint8 i; i < _options.length; i++) {
            address _adapter = ADAPTERS[_options[i]];
            try
                IAdapter(_adapter).query(_amountIn, _tokenIn, _tokenOut)
            returns (uint256 amountOut) {
                if (i == 0 || amountOut > bestQuery.amountOut) {
                    bestQuery = Query(_adapter, _tokenIn, _tokenOut, amountOut);
                }
            } catch {
                continue;
            }
        }
        return bestQuery;
    }

    /**
     * Query all adapters
     */
    function queryNoSplit(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut
    ) public view override returns (Query memory) {
        Query memory bestQuery;
        for (uint8 i; i < ADAPTERS.length; i++) {
            address _adapter = ADAPTERS[i];
            try
                IAdapter(_adapter).query(_amountIn, _tokenIn, _tokenOut)
            returns (uint256 amountOut) {
                if (i == 0 || amountOut > bestQuery.amountOut) {
                    bestQuery = Query(_adapter, _tokenIn, _tokenOut, amountOut);
                }
            } catch {
                continue;
            }
        }
        return bestQuery;
    }

    /**
     * Return path with best returns between two tokens
     * Takes gas-cost into account
     */
    function findBestPathWithGas(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        address[] memory _trustedTokens,
        uint256 _maxSteps,
        uint256 _gasPrice
    ) external view override returns (FormattedOffer memory) {
        require(_maxSteps > 0 && _maxSteps < 5, "YakRouter: Invalid max-steps");
        Offer memory queries = OfferUtils.newOffer(_amountIn, _tokenIn);
        uint256 gasPriceInExitTkn = _gasPrice > 0
            ? getGasPriceInExitTkn(_gasPrice, _tokenOut)
            : 0;

        uint256 ttLength = TRUSTED_TOKENS.length;
        // Concatenate default and additional trusted tokens
        address[] memory _allTrustedTokens = new address[](
            ttLength + _trustedTokens.length
        );
        for (uint i = 0; i < ttLength; ) {
            _allTrustedTokens[i] = TRUSTED_TOKENS[i];
            unchecked {
                i++;
            }
        }
        for (uint i = 0; i < _trustedTokens.length; ) {
            _allTrustedTokens[ttLength + i] = _trustedTokens[i];
            unchecked {
                i++;
            }
        }

        queries = _findBestPath(
            _amountIn,
            _tokenIn,
            _tokenOut,
            _allTrustedTokens,
            _maxSteps,
            queries,
            gasPriceInExitTkn
        );
        if (queries.adapters.length == 0) {
            queries.amounts = "";
            queries.path = "";
        }
        return queries.format();
    }

    // Find the market price between gas-asset(native) and token-out and express gas price in token-out
    function getGasPriceInExitTkn(
        uint256 _gasPrice,
        address _tokenOut
    ) internal view returns (uint256 price) {
        // Avoid low-liquidity price appreciation (https://github.com/yieldyak/yak-aggregator/issues/20)
        address[] memory _trustedTokens;
        FormattedOffer memory gasQuery = findBestPath(
            1e18,
            WNATIVE,
            _tokenOut,
            _trustedTokens,
            2
        );
        if (gasQuery.path.length != 0) {
            // Leave result in nWei to preserve precision for assets with low decimal places
            price =
                (gasQuery.amounts[gasQuery.amounts.length - 1] * _gasPrice) /
                1e9;
        }
    }

    /**
     * Return path with best returns between two tokens
     */
    function findBestPath(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        address[] memory _trustedTokens,
        uint256 _maxSteps
    ) public view override returns (FormattedOffer memory) {
        require(_maxSteps > 0 && _maxSteps < 5, "YakRouter: Invalid max-steps");
        Offer memory queries = OfferUtils.newOffer(_amountIn, _tokenIn);

        uint256 ttLength = TRUSTED_TOKENS.length;
        // Concatenate default and additional trusted tokens
        address[] memory _allTrustedTokens = new address[](
            ttLength + _trustedTokens.length
        );
        for (uint i = 0; i < ttLength; ) {
            _allTrustedTokens[i] = TRUSTED_TOKENS[i];
            unchecked {
                i++;
            }
        }
        for (uint i = 0; i < _trustedTokens.length; ) {
            _allTrustedTokens[ttLength + i] = _trustedTokens[i];
            unchecked {
                i++;
            }
        }

        queries = _findBestPath(
            _amountIn,
            _tokenIn,
            _tokenOut,
            _allTrustedTokens,
            _maxSteps,
            queries,
            0
        );
        // If no paths are found return empty struct
        if (queries.adapters.length == 0) {
            queries.amounts = "";
            queries.path = "";
        }
        return queries.format();
    }

    function _findBestPath(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut,
        address[] memory _trustedTokens,
        uint256 _maxSteps,
        Offer memory _queries,
        uint256 _tknOutPriceNwei
    ) internal view returns (Offer memory) {
        Offer memory bestOption = _queries.clone();
        uint256 bestAmountOut;
        uint256 gasEstimate;
        bool withGas = _tknOutPriceNwei > 0;

        // First check if there is a path directly from tokenIn to tokenOut
        Query memory queryDirect = queryNoSplit(_amountIn, _tokenIn, _tokenOut);

        if (queryDirect.amountOut > 0) {
            if (withGas) {
                gasEstimate = IAdapter(queryDirect.adapter).swapGasEstimate();
            }
            bestOption.addToTail(
                queryDirect.amountOut,
                queryDirect.adapter,
                queryDirect.tokenOut,
                gasEstimate
            );
            bestAmountOut = queryDirect.amountOut;
        }

        // Only check the rest if they would go beyond step limit (Need at least 2 more steps)
        if (_maxSteps > 1 && _queries.adapters.length / 32 <= _maxSteps - 2) {
            // Check for paths that pass through trusted tokens
            for (uint256 i = 0; i < _trustedTokens.length; ) {
                if (_tokenIn == _trustedTokens[i]) {
                    unchecked {
                        i++;
                    }
                    continue;
                }
                // Loop through all adapters to find the best one for swapping tokenIn for one of the trusted tokens
                Query memory bestSwap = queryNoSplit(
                    _amountIn,
                    _tokenIn,
                    _trustedTokens[i]
                );
                if (bestSwap.amountOut == 0) {
                    unchecked {
                        i++;
                    }
                    continue;
                }
                // Explore options that connect the current path to the tokenOut
                Offer memory newOffer = _queries.clone();
                if (withGas) {
                    gasEstimate = IAdapter(bestSwap.adapter).swapGasEstimate();
                }
                newOffer.addToTail(
                    bestSwap.amountOut,
                    bestSwap.adapter,
                    bestSwap.tokenOut,
                    gasEstimate
                );
                newOffer = _findBestPath(
                    bestSwap.amountOut,
                    _trustedTokens[i],
                    _tokenOut,
                    _trustedTokens,
                    _maxSteps,
                    newOffer,
                    _tknOutPriceNwei
                ); // Recursive step
                // Check that the last token in the path is the tokenOut and update the new best option if neccesary
                if (
                    _tokenOut == newOffer.getTokenOut() &&
                    newOffer.getAmountOut() > bestAmountOut
                ) {
                    if (newOffer.gasEstimate > bestOption.gasEstimate) {
                        uint256 gasCostDiff = (_tknOutPriceNwei *
                            (newOffer.gasEstimate - bestOption.gasEstimate)) /
                            1e9;
                        if (
                            gasCostDiff >
                            newOffer.getAmountOut() - bestAmountOut
                        ) {
                            unchecked {
                                i++;
                            }
                            continue;
                        }
                    }
                    bestAmountOut = newOffer.getAmountOut();
                    bestOption = newOffer;
                }

                unchecked {
                    i++;
                }
            }
        }
        return bestOption;
    }

    // -- SWAPPERS --

    function _swapNoSplit(
        Trade calldata _trade,
        address _from,
        uint256 _fee,
        address _to
    ) internal returns (uint256) {
        uint256 amountIn = _trade.amountIn;
        if (_fee > 0 || MIN_FEE > 0) {
            // Transfer fees to the claimer account and decrease initial amount
            amountIn = _applyFee(_trade.amountIn, _fee);
            _transferFrom(
                _trade.path[0],
                _from,
                FEE_CLAIMER,
                _trade.amountIn - amountIn
            );
        }
        _transferFrom(_trade.path[0], _from, _trade.adapters[0], amountIn);

        address tokenOut = _trade.path[_trade.path.length - 1];
        uint256 balanceBefore = IERC20(tokenOut).balanceOf(_to);
        for (uint256 i = 0; i < _trade.adapters.length; i++) {
            // All adapters should transfer output token to the following target
            // All targets are the adapters, expect for the last swap where tokens are sent out
            address targetAddress = i < _trade.adapters.length - 1
                ? _trade.adapters[i + 1]
                : _to;
            IAdapter(_trade.adapters[i]).swap(
                amountIn,
                0,
                _trade.path[i],
                _trade.path[i + 1],
                targetAddress
            );
            amountIn = IERC20(_trade.path[i + 1]).balanceOf(targetAddress);
        }
        uint256 amountOut = amountIn - balanceBefore;
        require(
            amountOut >= _trade.amountOut,
            "YakRouter: Insufficient output amount"
        );
        emit YakSwap(_trade.path[0], tokenOut, _trade.amountIn, amountOut);
        return amountOut;
    }

    function swapNoSplit(
        Trade calldata _trade,
        uint256 _fee,
        address _to
    ) public override {
        _swapNoSplit(_trade, msg.sender, _fee, _to);
    }

    function swapNoSplitFromETH(
        Trade calldata _trade,
        uint256 _fee,
        address _to
    ) external payable override {
        require(
            _trade.path[0] == WNATIVE,
            "YakRouter: Path needs to begin with WETH"
        );
        _wrap(_trade.amountIn);
        _swapNoSplit(_trade, address(this), _fee, _to);
    }

    function swapNoSplitToETH(
        Trade calldata _trade,
        uint256 _fee,
        address _to
    ) public override {
        require(
            _trade.path[_trade.path.length - 1] == WNATIVE,
            "YakRouter: Path needs to end with WETH"
        );
        uint256 returnAmount = _swapNoSplit(
            _trade,
            msg.sender,
            _fee,
            address(this)
        );
        _unwrapTo(_to, returnAmount);
    }

    /**
     * Swap token to token without the need to approve the first token
     */
    function swapNoSplitWithPermit(
        Trade calldata _trade,
        uint256 _fee,
        address _to,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
        IERC20(_trade.path[0]).permit(
            msg.sender,
            address(this),
            _trade.amountIn,
            _deadline,
            _v,
            _r,
            _s
        );
        swapNoSplit(_trade, _fee, _to);
    }

    /**
     * Swap token to WETH without the need to approve the first token
     */
    function swapNoSplitToETHWithPermit(
        Trade calldata _trade,
        uint256 _fee,
        address _to,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
        IERC20(_trade.path[0]).permit(
            msg.sender,
            address(this),
            _trade.amountIn,
            _deadline,
            _v,
            _r,
            _s
        );
        swapNoSplitToETH(_trade, _fee, _to);
    }
}
