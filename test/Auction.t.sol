//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Auction.sol";

contract TestConstructor is Test {
    Auction public _auction;

    function setUp() public {
        _auction = new Auction(address(this), 1683992518, 1686670991);
    }

    function test_setAuctionOwner() public {
        assertEq(_auction.auctionOwner(), address(this));
    }

    function test_setStartTime() public {
        assertEq(_auction.auctionStart(), 1683992518);
    }

    function test_setAuctionEnd() public {
        assertEq(_auction.auctionEnd(), 1686670991);
    }
}

contract TestBid is Test {
    Auction public _auction;

    function setUp() public {
        _auction = new Auction(address(this), 1683992518, 1686670991);
        vm.warp(1683992528);
        _auction.bid{value: 1e10}();
    }

    function test_revertsNotStarted() public {
        vm.warp(1683992418);
        vm.expectRevert(bytes4(keccak256("AuctionNotStarted()")));
        _auction.bid{value: 1e17}();
    }

    function test_revertEnded() public {
        vm.warp(1686670999);
        vm.expectRevert(bytes4(keccak256("AuctionEnded()")));
        _auction.bid{value: 1e17}();
    }

    function test_revertBidMore() public {
        vm.expectRevert(bytes4(keccak256("BidMore()")));
        _auction.bid{value: 1e8}();
    }

    function test_updateRefunds() public {
        assertEq(_auction.refunds(address(this)), 1e10);
    }

    function test_updateHighestBidder() public {
        assertEq(_auction.highestBidder(), address(this));
    }

    function test_updateHighestBid() public {
        assertEq(_auction.highestBid(), 1e10);
    }
}

contract TestWithdraw is Test {
    Auction public _auction;

    function setUp() public {
        _auction = new Auction(address(this), 1683992518, 1686670991);
        vm.warp(1683992528);
        _auction.bid{value: 1e10}();
    }

    function test_revertsWinner() public {
        vm.expectRevert(bytes4(keccak256("WinnerCanNotWithdraw()")));
        _auction.withdraw();
    }

    function test_revertsMoney() public {
        vm.startPrank(address(1));
        vm.expectRevert(bytes4(keccak256("NotEnoughMoney()")));
        _auction.withdraw();
    }

    function test_refundsToZero() public {
        vm.deal(address(1), 1 ether);
        vm.warp(1683992528);
        vm.prank(address(1));
        _auction.bid{value: 1e16}();
        _auction.withdraw();
        assertEq(_auction.refunds(address(this)), 0);
    }

    function test_refundsMoney() public {
        vm.deal(address(1), 1 ether);
        vm.warp(1683992528);
        vm.prank(address(1));
        _auction.bid{value: 1e16}();
        _auction.bid{value: 1e17}();
        vm.prank(address(1));
        _auction.withdraw();
        assertEq(address(1).balance, 1e18);
    }

    receive() external payable {}
    
    fallback() external payable {}
}

contract TestEndAuction is Test {
    Auction public _auction;

    function setUp() public {
        _auction = new Auction(address(1), 1683992518, 1686670991);
        vm.warp(1683992528);
        vm.prank(address(this));
        _auction.bid{value: 1e10}();
    }

    function test_revertTimestamp() public {
        vm.warp(1686670980);
        vm.expectRevert(bytes4(keccak256("AuctionNotEnded()")));
        _auction.endAuction();
    }

    function test_updatesBool() public {
        vm.warp(1686670999);
        _auction.endAuction();
        assertEq(_auction.isEnded(), true);
    }

    function test_sendsWinnerMoney() public {
        vm.warp(1686670999);
        _auction.endAuction();
        assertEq(address(1).balance, 1e10);
    }

    receive() external payable {}
    
    fallback() external payable {}
}