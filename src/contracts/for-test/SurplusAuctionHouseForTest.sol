// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {SurplusAuctionHouse, ISurplusAuctionHouse} from '@contracts/SurplusAuctionHouse.sol';

contract SurplusAuctionHouseForTest is SurplusAuctionHouse {
  constructor(
    address _safeEngine,
    address _protocolToken,
    SurplusAuctionHouseParams memory _sahParams
  ) SurplusAuctionHouse(_safeEngine, _protocolToken, _sahParams) {}

  function addBid(
    uint256 _id,
    uint256 _bidAmount,
    uint256 _amountToSell,
    address _highBidder,
    uint48 _bidExpiry,
    uint48 _auctionDeadline
  ) external {
    bids[_id].bidAmount = _bidAmount;
    bids[_id].amountToSell = _amountToSell;
    bids[_id].highBidder = _highBidder;
    bids[_id].bidExpiry = _bidExpiry;
    bids[_id].auctionDeadline = _auctionDeadline;
  }

  function setBidDuration(uint48 _bidDuration) external {
    _params.bidDuration = _bidDuration;
  }

  function setTotalAuctionLength(uint48 _totalAuctionLength) external {
    _params.totalAuctionLength = _totalAuctionLength;
  }
}
