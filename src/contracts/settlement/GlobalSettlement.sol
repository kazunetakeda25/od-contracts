// SPDX-License-Identifier: GPL-3.0
/// GlobalSettlement.sol

// Copyright (C) 2018 Rain <rainbreak@riseup.net>
// Copyright (C) 2018 Lev Livnev <lev@liv.nev.org.uk>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.8.19;

import {ISAFEEngine as SAFEEngineLike} from '@interfaces/ISAFEEngine.sol';
import {ILiquidationEngine as LiquidationEngineLike} from '@interfaces/ILiquidationEngine.sol';
import {IStabilityFeeTreasury as StabilityFeeTreasuryLike} from '@interfaces/IStabilityFeeTreasury.sol';
import {IAccountingEngine as AccountingEngineLike} from '@interfaces/IAccountingEngine.sol';
import {IDisableable as CoinSavingsAccountLike} from '@interfaces/utils/IDisableable.sol';
import {ICollateralAuctionHouse as CollateralAuctionHouseLike} from '@interfaces/ICollateralAuctionHouse.sol';
import {IOracle as OracleLike} from '@interfaces/IOracle.sol';
import {IOracleRelayer as OracleRelayerLike} from '@interfaces/IOracleRelayer.sol';

import {Authorizable} from '@contracts/utils/Authorizable.sol';
import {Disableable} from '@contract-utils/Disableable.sol';

import {Math, RAY} from '@libraries/Math.sol';

/*
    This is the Global Settlement module. It is an
    involved, stateful process that takes place over nine steps.
    First we freeze the system and lock the prices for each collateral type.
    1. `shutdownSystem()`:
        - freezes user entrypoints
        - starts cooldown period
    2. `freezeCollateralType(collateralType)`:
       - set the final price for each collateralType, reading off the price feed
    We must process some system state before it is possible to calculate
    the final coin / collateral price. In particular, we need to determine:
      a. `collateralShortfall` (considers under-collateralised SAFEs)
      b. `outstandingCoinSupply` (after including system surplus / deficit)
    We determine (a) by processing all under-collateralised SAFEs with
    `processSAFE`
    3. `processSAFE(collateralType, safe)`:
       - cancels SAFE debt
       - any excess collateral remains
       - backing collateral taken
    We determine (b) by processing ongoing coin generating processes,
    i.e. auctions. We need to ensure that auctions will not generate any
    further coin income. In the two-way auction model this occurs when
    all auctions are in the reverse (`decreaseSoldAmount`) phase. There are two ways
    of ensuring this:
    4.  i) `shutdownCooldown`: set the cooldown period to be at least as long as the
           longest auction duration, which needs to be determined by the
           shutdown administrator.
           This takes a fairly predictable time to occur but with altered
           auction dynamics due to the now varying price of the system coin.
       ii) `fastTrackAuction`: cancel all ongoing auctions and seize the collateral.
           This allows for faster processing at the expense of more
           processing calls. This option allows coin holders to retrieve
           their collateral faster.
           `fastTrackAuction(collateralType, auctionId)`:
            - cancel individual collateral auctions in the `increaseBidSize` (forward) phase
            - retrieves collateral and returns coins to bidder
            - `decreaseSoldAmount` (reverse) phase auctions can continue normally
    Option (i), `shutdownCooldown`, is sufficient for processing the system
    settlement but option (ii), `fastTrackAuction`, will speed it up. Both options
    are available in this implementation, with `fastTrackAuction` being enabled on a
    per-auction basis.
    When a SAFE has been processed and has no debt remaining, the
    remaining collateral can be removed.
    5. `freeCollateral(collateralType)`:
        - remove collateral from the caller's SAFE
        - owner can call as needed
    After the processing period has elapsed, we enable calculation of
    the final price for each collateral type.
    6. `setOutstandingCoinSupply()`:
       - only callable after processing time period elapsed
       - assumption that all under-collateralised SAFEs are processed
       - fixes the total outstanding supply of coin
       - may also require extra SAFE processing to cover system surplus
    7. `calculateCashPrice(collateralType)`:
        - calculate `collateralCashPrice`
        - adjusts `collateralCashPrice` in the case of deficit / surplus
    At this point we have computed the final price for each collateral
    type and coin holders can now turn their coin into collateral. Each
    unit coin can claim a fixed basket of collateral.
    Coin holders must first `prepareCoinsForRedeeming` into a `coinBag`. Once prepared,
    coins cannot be transferred out of the bag. More coin can be added to a bag later.
    8. `prepareCoinsForRedeeming(coinAmount)`:
        - put some coins into a bag in order to 'redeemCollateral'. The bigger the bag, the more collateral the user can claim.
    9. `redeemCollateral(collateralType, collateralAmount)`:
        - exchange some coin from your bag for tokens from a specific collateral type
        - the amount of collateral available to redeem is limited by how big your bag is
*/

contract GlobalSettlement is Authorizable, Disableable {
  using Math for uint256;

  // --- Data ---
  SAFEEngineLike public safeEngine;
  LiquidationEngineLike public liquidationEngine;
  AccountingEngineLike public accountingEngine;
  OracleRelayerLike public oracleRelayer;
  CoinSavingsAccountLike public coinSavingsAccount;
  StabilityFeeTreasuryLike public stabilityFeeTreasury;

  // The timestamp when settlement was triggered
  uint256 public shutdownTime;
  // The amount of time post settlement during which no processing takes place
  uint256 public shutdownCooldown;
  // The outstanding supply of system coins computed during the setOutstandingCoinSupply() phase
  uint256 public outstandingCoinSupply; // [rad]

  // The amount of collateral that a system coin can redeem
  mapping(bytes32 => uint256) public finalCoinPerCollateralPrice; // [ray]
  // Total amount of bad debt in SAFEs with different collateral types
  mapping(bytes32 => uint256) public collateralShortfall; // [wad]
  // Total debt backed by every collateral type
  mapping(bytes32 => uint256) public collateralTotalDebt; // [wad]
  // Mapping of collateral prices in terms of system coins after taking into account system surplus/deficit and finalCoinPerCollateralPrices
  mapping(bytes32 => uint256) public collateralCashPrice; // [ray]

  // Bags of coins ready to be used for collateral redemption
  mapping(address => uint256) public coinBag; // [wad]
  // Amount of coins already used for collateral redemption by every address and for different collateral types
  mapping(bytes32 => mapping(address => uint256)) public coinsUsedToRedeem; // [wad]

  // --- Events ---
  event ModifyParameters(bytes32 parameter, uint256 data);
  event ModifyParameters(bytes32 parameter, address data);
  event ShutdownSystem();
  event FreezeCollateralType(bytes32 indexed collateralType, uint256 finalCoinPerCollateralPrice);
  event FastTrackAuction(bytes32 indexed collateralType, uint256 auctionId, uint256 collateralTotalDebt);
  event ProcessSAFE(bytes32 indexed collateralType, address safe, uint256 collateralShortfall);
  event FreeCollateral(bytes32 indexed collateralType, address sender, int256 collateralAmount);
  event SetOutstandingCoinSupply(uint256 outstandingCoinSupply);
  event CalculateCashPrice(bytes32 indexed collateralType, uint256 collateralCashPrice);
  event PrepareCoinsForRedeeming(address indexed sender, uint256 coinBag);
  event RedeemCollateral(
    bytes32 indexed collateralType, address indexed sender, uint256 coinsAmount, uint256 collateralAmount
  );

  // --- Init ---
  constructor() Authorizable(msg.sender) {}

  // --- Administration ---
  /**
   * @notice Modify an address parameter
   * @param parameter The name of the parameter to modify
   * @param data The new address for the parameter
   */
  function modifyParameters(bytes32 parameter, address data) external isAuthorized whenEnabled {
    if (parameter == 'safeEngine') safeEngine = SAFEEngineLike(data);
    else if (parameter == 'liquidationEngine') liquidationEngine = LiquidationEngineLike(data);
    else if (parameter == 'accountingEngine') accountingEngine = AccountingEngineLike(data);
    else if (parameter == 'oracleRelayer') oracleRelayer = OracleRelayerLike(data);
    else if (parameter == 'coinSavingsAccount') coinSavingsAccount = CoinSavingsAccountLike(data);
    else if (parameter == 'stabilityFeeTreasury') stabilityFeeTreasury = StabilityFeeTreasuryLike(data);
    else revert('GlobalSettlement/modify-unrecognized-parameter');
    emit ModifyParameters(parameter, data);
  }

  /**
   * @notice Modify an uint256 parameter
   * @param parameter The name of the parameter to modify
   * @param data The new value for the parameter
   */
  function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized whenEnabled {
    if (parameter == 'shutdownCooldown') shutdownCooldown = data;
    else revert('GlobalSettlement/modify-unrecognized-parameter');
    emit ModifyParameters(parameter, data);
  }

  function disableContract() external pure {
    revert NonDisableable();
  }

  // --- Settlement ---
  /**
   * @notice Freeze the system and start the cooldown period
   */
  function shutdownSystem() external isAuthorized whenEnabled {
    shutdownTime = block.timestamp;
    _disableContract();

    safeEngine.disableContract();
    liquidationEngine.disableContract();
    // treasury must be disabled before the accounting engine so that all surplus is gathered in one place
    if (address(stabilityFeeTreasury) != address(0)) {
      stabilityFeeTreasury.disableContract();
    }
    accountingEngine.disableContract();
    oracleRelayer.disableContract();
    if (address(coinSavingsAccount) != address(0)) {
      coinSavingsAccount.disableContract();
    }
    emit ShutdownSystem();
  }

  /**
   * @notice Calculate a collateral type's final price according to the latest system coin redemption price
   * @param collateralType The collateral type to calculate the price for
   */
  function freezeCollateralType(bytes32 collateralType) external whenDisabled {
    require(finalCoinPerCollateralPrice[collateralType] == 0, 'GlobalSettlement/final-collateral-price-already-defined');
    collateralTotalDebt[collateralType] = safeEngine.cData(collateralType).debtAmount;
    (OracleLike orcl,,) = oracleRelayer.collateralTypes(collateralType);
    // redemptionPrice is a ray, orcl returns a wad
    finalCoinPerCollateralPrice[collateralType] = oracleRelayer.redemptionPrice().wdiv(uint256(orcl.read()));
    emit FreezeCollateralType(collateralType, finalCoinPerCollateralPrice[collateralType]);
  }

  /**
   * @notice Fast track an ongoing collateral auction
   * @param collateralType The collateral type associated with the auction contract
   * @param auctionId The ID of the auction to be fast tracked
   */
  function fastTrackAuction(bytes32 collateralType, uint256 auctionId) external {
    require(finalCoinPerCollateralPrice[collateralType] != 0, 'GlobalSettlement/final-collateral-price-not-defined');

    (address auctionHouse_,,) = liquidationEngine.cParams(collateralType);
    CollateralAuctionHouseLike collateralAuctionHouse = CollateralAuctionHouseLike(auctionHouse_);
    uint256 _accumulatedRate = safeEngine.cData(collateralType).accumulatedRate;

    uint256 bidAmount = collateralAuctionHouse.bidAmount(auctionId);
    uint256 raisedAmount = collateralAuctionHouse.raisedAmount(auctionId);
    uint256 collateralToSell = collateralAuctionHouse.remainingAmountToSell(auctionId);
    address forgoneCollateralReceiver = collateralAuctionHouse.forgoneCollateralReceiver(auctionId);
    uint256 amountToRaise = collateralAuctionHouse.amountToRaise(auctionId);

    safeEngine.createUnbackedDebt(address(accountingEngine), address(accountingEngine), amountToRaise - raisedAmount);
    safeEngine.createUnbackedDebt(address(accountingEngine), address(this), bidAmount);
    safeEngine.approveSAFEModification(address(collateralAuctionHouse));
    collateralAuctionHouse.terminateAuctionPrematurely(auctionId);

    uint256 _debt = (amountToRaise - raisedAmount) / _accumulatedRate;
    collateralTotalDebt[collateralType] = collateralTotalDebt[collateralType] + _debt;
    require(int256(collateralToSell) >= 0 && int256(_debt) >= 0, 'GlobalSettlement/overflow');
    safeEngine.confiscateSAFECollateralAndDebt(
      collateralType,
      forgoneCollateralReceiver,
      address(this),
      address(accountingEngine),
      int256(collateralToSell),
      int256(_debt)
    );
    emit FastTrackAuction(collateralType, auctionId, collateralTotalDebt[collateralType]);
  }

  /**
   * @notice Cancel a SAFE's debt and leave any extra collateral in it
   * @param collateralType The collateral type associated with the SAFE
   * @param safe The SAFE to be processed
   */
  function processSAFE(bytes32 collateralType, address safe) external {
    require(finalCoinPerCollateralPrice[collateralType] != 0, 'GlobalSettlement/final-collateral-price-not-defined');
    uint256 _accumulatedRate = safeEngine.cData(collateralType).accumulatedRate;
    SAFEEngineLike.SAFE memory _safeData = safeEngine.safes(collateralType, safe);

    uint256 amountOwed =
      _safeData.generatedDebt.rmul(_accumulatedRate).rmul(finalCoinPerCollateralPrice[collateralType]);
    uint256 minCollateral = Math.min(_safeData.lockedCollateral, amountOwed);
    collateralShortfall[collateralType] = collateralShortfall[collateralType] + (amountOwed - minCollateral);

    require(minCollateral <= 2 ** 255 && _safeData.generatedDebt <= 2 ** 255, 'GlobalSettlement/overflow');
    safeEngine.confiscateSAFECollateralAndDebt(
      collateralType,
      safe,
      address(this),
      address(accountingEngine),
      -int256(minCollateral),
      -int256(_safeData.generatedDebt)
    );

    emit ProcessSAFE(collateralType, safe, collateralShortfall[collateralType]);
  }

  /**
   * @notice Remove collateral from the caller's SAFE
   * @param collateralType The collateral type to free
   */
  function freeCollateral(bytes32 collateralType) external whenDisabled {
    SAFEEngineLike.SAFE memory _safeData = safeEngine.safes(collateralType, msg.sender);
    require(_safeData.generatedDebt == 0, 'GlobalSettlement/safe-debt-not-zero');
    require(_safeData.lockedCollateral <= 2 ** 255, 'GlobalSettlement/overflow');
    safeEngine.confiscateSAFECollateralAndDebt(
      collateralType, msg.sender, msg.sender, address(accountingEngine), -int256(_safeData.lockedCollateral), 0
    );
    emit FreeCollateral(collateralType, msg.sender, -int256(_safeData.lockedCollateral));
  }

  /**
   * @notice Set the final outstanding supply of system coins
   * @dev There must be no remaining surplus in the accounting engine
   */
  function setOutstandingCoinSupply() external whenDisabled {
    require(outstandingCoinSupply == 0, 'GlobalSettlement/outstanding-coin-supply-not-zero');
    require(safeEngine.coinBalance(address(accountingEngine)) == 0, 'GlobalSettlement/surplus-not-zero');
    require(block.timestamp >= shutdownTime + shutdownCooldown, 'GlobalSettlement/shutdown-cooldown-not-finished');
    outstandingCoinSupply = safeEngine.globalDebt();
    emit SetOutstandingCoinSupply(outstandingCoinSupply);
  }

  /**
   * @notice Calculate a collateral's price taking into consideration system surplus/deficit and the finalCoinPerCollateralPrice
   * @param collateralType The collateral whose cash price will be calculated
   */
  function calculateCashPrice(bytes32 collateralType) external {
    require(outstandingCoinSupply != 0, 'GlobalSettlement/outstanding-coin-supply-zero');
    require(collateralCashPrice[collateralType] == 0, 'GlobalSettlement/collateral-cash-price-already-defined');

    uint256 _accumulatedRate = safeEngine.cData(collateralType).accumulatedRate;
    uint256 redemptionAdjustedDebt =
      collateralTotalDebt[collateralType].rmul(_accumulatedRate).rmul(finalCoinPerCollateralPrice[collateralType]);
    collateralCashPrice[collateralType] =
      (redemptionAdjustedDebt - collateralShortfall[collateralType]) * RAY / (outstandingCoinSupply / RAY);

    emit CalculateCashPrice(collateralType, collateralCashPrice[collateralType]);
  }

  /**
   * @notice Add coins into a 'bag' so that you can use them to redeem collateral
   * @param coinAmount The amount of internal system coins to add into the bag
   */
  function prepareCoinsForRedeeming(uint256 coinAmount) external {
    require(outstandingCoinSupply != 0, 'GlobalSettlement/outstanding-coin-supply-zero');
    safeEngine.transferInternalCoins(msg.sender, address(accountingEngine), coinAmount * RAY);
    coinBag[msg.sender] = coinBag[msg.sender] + coinAmount;
    emit PrepareCoinsForRedeeming(msg.sender, coinBag[msg.sender]);
  }

  /**
   * @notice Redeem a specific collateral type using an amount of internal system coins from your bag
   * @param collateralType The collateral type to redeem
   * @param coinsAmount The amount of internal coins to use from your bag
   */
  function redeemCollateral(bytes32 collateralType, uint256 coinsAmount) external {
    require(collateralCashPrice[collateralType] != 0, 'GlobalSettlement/collateral-cash-price-not-defined');
    uint256 collateralAmount = coinsAmount.rmul(collateralCashPrice[collateralType]);
    safeEngine.transferCollateral(collateralType, address(this), msg.sender, collateralAmount);
    coinsUsedToRedeem[collateralType][msg.sender] = coinsUsedToRedeem[collateralType][msg.sender] + coinsAmount;
    require(
      coinsUsedToRedeem[collateralType][msg.sender] <= coinBag[msg.sender], 'GlobalSettlement/insufficient-bag-balance'
    );
    emit RedeemCollateral(collateralType, msg.sender, coinsAmount, collateralAmount);
  }
}
