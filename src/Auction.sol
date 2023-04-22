// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

error AuctionNotStarted();
error AuctionEnded();
error NoMoney();
error AuctionNotEnded();
error CanNotBeZero();

contract Auction {
    struct Auction {
        uint256 _id;
        uint256 _startingTime;
        uint256 _endingTime;
        uint256 _highestBid;
        address _winner;
        uint256 _biddingAmount;
        address _auctionCreator;
    }

    event AuctionCreated(
        uint256 id,
        uint256 started,
        uint256 ended,
        uint256 amount,
        address auctionCreator
    );
    event AuctionClosed(uint256 id, uint256 higestBid, address winner);

    mapping(uint256 => Auction) private _auctions;
    uint256 private _auctionId;

    modifier onlyCreator(uint256 _id) {
        if (_auctions[_id]._auctionCreator == msg.sender) {
            _;
        }
    }

    modifier onlyWinner(uint256 _id) {
        if (_auctions[_id]._winner == msg.sender) {
            _;
        }
    }

    constructor() {
        _auctionId = 0;
    }

    function createAuction(
        uint256 startingTime,
        uint256 endingTime,
        uint256 biddingAmount
    ) external {
        if (biddingAmount == 0) {
            revert CanNotBeZero();
        }
        _auctions[_auctionId] = Auction(
            _auctionId,
            startingTime,
            endingTime,
            0,
            address(0),
            1e17,
            msg.sender
        );
        emit AuctionCreated(_auctionId, startingTime, endingTime, 1e17, msg.sender);
        _auctionId++;
    }

    function endAuction(uint256 _id) external payable onlyWinner(_id) {
        Auction memory auction = _auctions[_auctionId];
        if (block.timestamp < auction._endingTime) {
            revert AuctionNotEnded();
        }
        (bool success, ) = address(this).call{value: auction._highestBid}("");
        require(success);
        emit AuctionClosed(_id, auction._highestBid, auction._winner);
    }

    function bid(uint256 _id) external {
        Auction storage auction = _auctions[_id];
        if (block.timestamp < auction._startingTime) {
            revert AuctionNotStarted();
        }
        if (block.timestamp > auction._endingTime) {
            revert AuctionEnded();
        }
        auction._highestBid += 1e17;
        auction._winner = msg.sender;
    }

    function claimMoney(uint256 _id) external onlyCreator(_id) {
        Auction memory auction = _auctions[_id];
        if (auction._highestBid == 0) {
            revert NoMoney();
        }
        if (block.timestamp < auction._endingTime) {
            revert AuctionNotEnded();
        }
        (bool success, ) = msg.sender.call{value: auction._highestBid}("");
        require(success);
    }

    function auctionsInfo(uint256 _id) external view returns (Auction memory) {
        return _auctions[_id];
    }
}
