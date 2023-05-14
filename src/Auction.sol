//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

error WrongTime();
error AuctionNotStarted();
error AuctionEnded();
error BidMore();
error WinnerCanNotWithdraw();
error NotEnoughMoney();
error AuctionNotEnded();

contract Auction {
    address private _auctionOwner;
    uint256 private _auctionStart;
    uint256 private _auctionEnd;
    address private _highestBidder;
    uint256 private _highestBid;
    bool private _isEnded;
    mapping(address => uint256) private _pendingRefunds;

    constructor(address _owner, uint256 _start, uint256 _end) {
        _auctionOwner = _owner;
        _auctionStart = _start;
        _auctionEnd = _end;
    }

    function bid() external payable {
        if (block.timestamp < _auctionStart) {
            revert AuctionNotStarted();
        }
        if (block.timestamp > _auctionEnd) {
            revert AuctionEnded();
        }
        if (msg.value <= _highestBid) {
            revert BidMore();
        }
        _pendingRefunds[msg.sender] += _highestBid;
        _highestBidder = msg.sender;
        _highestBid = msg.value;
    }

    function withdraw() external {
        if (msg.sender == _highestBidder) {
            revert WinnerCanNotWithdraw();
        }
        uint256 _amount = _pendingRefunds[msg.sender];
        if (_amount == 0) {
            revert NotEnoughMoney();
        }
        _pendingRefunds[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success);
    }

    function endAuction() external {
        if (block.timestamp < _auctionEnd) {
            revert AuctionNotEnded();
        }
        if (_isEnded == false) {
            revert AuctionNotEnded();
        }
        _isEnded = true;
        (bool success, ) = _highestBidder.call{value: _highestBid}("");
        require(success);
    }

    function auctionOwner() external view returns (address) {
        return _auctionOwner;
    }

    function auctionStart() external view returns (uint256) {
        return _auctionStart;
    }

    function auctionEnd() external view returns (uint256) {
        return _auctionEnd;
    }

    function highestBidder() external view returns (address) {
        return _highestBidder;
    }

    function highestBid() external view returns (uint256) {
        return _highestBid;
    }

    function isEnded() external view returns (bool) {
        return _isEnded;
    }

    function refunds(address _address) external view returns (uint256) {
        return _pendingRefunds[_address];
    }
}
