// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IERC721EnumerableUpgradeable} from
  '@openzeppelin-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol';
import {IODSafeManager} from '@interfaces/proxies/IODSafeManager.sol';
import {NFTRenderer} from '@contracts/proxies/NFTRenderer.sol';
import {IAuthorizable} from '@interfaces/utils/IAuthorizable.sol';
import {IModifiable} from '@interfaces/utils/IModifiable.sol';

interface IVault721 is IERC721EnumerableUpgradeable, IAuthorizable, IModifiable {
  // --- Events ---

  /**
   * @notice Emitted when a new user proxy is built
   * @param _user address of the owner of the proxy
   * @param _proxy the address of the proxy
   */
  event CreateProxy(address indexed _user, address indexed _proxy);

  // --- Errors ---

  /// @notice Throws if an address other than the safe manager tries to call a onlySafeManager function
  error NotSafeManager();
  /// @notice throws if a proxy tries to create another proxy
  error NotWallet();
  /// @notice throws if an address attempts to build a second proxy
  error ProxyAlreadyExist();
  /// @notice throws if a vault is attempted to be transferred before the block delay is over
  error BlockDelayNotOver();
  /// @notice throws if a vault is attempted to be transferred before the time delay is over
  error TimeDelayNotOver();
  /// @notice throws if zero address is passed as a param
  error ZeroAddress();

  // --- Struct ---

  struct HashState {
    /// the last vault hash state
    bytes32 lastHash;
    /// the block number of the last vault state change
    uint256 lastBlockNumber;
    /// the timestamp of the last vault state change
    uint256 lastBlockTimestamp;
  }

  /**
   * @dev initializes DAO timelockController contract
   */
  function initialize(address _timelockController) external;

  /**
   * @dev initializes SafeManager contract
   */
  function initializeManager() external;

  /**
   * @dev initializes NFTRenderer contract
   */
  function initializeRenderer() external;

  // --- Registry ---

  /**
   * @notice The timelockController is the governance contract with permissions to update params
   * @return address of the timelock controller
   */
  function timelockController() external returns (address _timelockController);

  /**
   * @notice The safe manager calls mint and other functions on this contract and is used to get safe data for the vault hash
   * @return safeManager address handles permissions and safe state
   */
  function safeManager() external returns (IODSafeManager _safeManager);

  /**
   * @notice The nftRenderer creates the tokenURI and is used in the vaultHashState
   * @return address of NFTrenderer
   */
  function nftRenderer() external returns (NFTRenderer _nftRenderer);

  // --- Params ---

  /**
   * @notice The block delay is the enforced number of blocks between the last change of a vault and when vault ownership can be transfered
   * @return blockDelay
   */
  function blockDelay() external returns (uint256);

  /**
   * @notice The time delay is the enforced amount of time between the last change of a vault and when vault ownership can be transfered
   * @return blockDelay
   */
  function timeDelay() external returns (uint256);

  // --- Data ---

  /**
   * @notice The contract metadata is the prefix used when calculating the contractUri
   * @return contractMetadata
   */
  function contractMetaData() external returns (string memory);

  /**
   * @dev get proxy by user address
   */
  function getProxy(address _user) external view returns (address);

  /**
   * @dev get hash state by vault id
   */
  function getHashState(uint256 _vaultId) external view returns (HashState memory _hashState);

  // --- Methods ---

  /**
   * @dev allows msg.sender without an ODProxy to deploy a new ODProxy
   */
  function build() external returns (address payable);

  /**
   * @dev allows user without an ODProxy to deploy a new ODProxy
   */
  function build(address _user) external returns (address payable);

  /**
   * @dev allows user to deploy proxies for multiple users
   * @param _users array of user addresses
   * @return _proxies array of proxy addresses
   */
  function build(address[] memory _users) external returns (address payable[] memory _proxies);

  /**
   * @dev mint can only be called by the SafeManager
   * enforces that only ODProxies call `openSafe` function by checking _proxyRegistry
   */
  function mint(address proxy, uint256 safeId) external;

  /**
   * @dev allows ODSafeManager to update the hash state
   */
  function updateVaultHashState(uint256 _vaultId) external;

  /**
   * @dev contract level meta data
   */
  function contractURI() external returns (string memory);
}
