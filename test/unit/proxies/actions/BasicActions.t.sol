// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import 'forge-std/Test.sol';
import {ActionBaseTest, ODProxy} from './ActionBaseTest.sol';
import {BasicActions} from '@contracts/proxies/actions/BasicActions.sol';
import {ODSafeManagerMock} from './GlobalSettlementActions.t.sol';
import {CoinJoinMock} from './CollateralBidActions.t.sol';

contract BasicActionsTest is ActionBaseTest {
  BasicActions basicActions = new BasicActions();
  ODSafeManagerMock safeManager = new ODSafeManagerMock();
  CoinJoinMock coinJoin = new CoinJoinMock();

  function setUp() public {
    proxy = new ODProxy(alice);
  }

  function test_openSAFE() public {
    safeManager.reset();
    vm.startPrank(alice);

    proxy.execute(
      address(basicActions),
      abi.encodeWithSignature('openSAFE(address,bytes32,address)', address(safeManager), bytes32(0), address(0))
    );

    assertTrue(safeManager.wasOpenSAFECalled());
  }

  function test_generateDebt() public {
    /*safeManager.reset();
    coinJoin.reset();

    vm.startPrank(alice);

    proxy.execute(
      address(basicActions),
      abi.encodeWithSignature(
        'generateDebt(address,address,uint256,uint256)',
        address(safeManager),
        address(coinJoin),
        1,
        10
      )
    );

    assertTrue(coinJoin.wasExitCalled());*/
  }

  function test_allowSAFE() public {
    safeManager.reset();
    vm.startPrank(alice);

    proxy.execute(
      address(basicActions),
      abi.encodeWithSignature('allowSAFE(address,uint256,address,bool)', address(safeManager), 1, address(0x01), true)
    );

    assertTrue(safeManager.wasAllowSAFECalled());
  }

  function test_quitSystem() public {
    safeManager.reset();
    vm.startPrank(alice);

    proxy.execute(
      address(basicActions),
      abi.encodeWithSignature('quitSystem(address,uint256,address)', address(safeManager), 1, address(0x01))
    );

    assertTrue(safeManager.wasQuitSystemCalled());
  }

  function test_enterSystem() public {
    safeManager.reset();
    vm.startPrank(alice);

    proxy.execute(
      address(basicActions),
      abi.encodeWithSignature('enterSystem(address,address,uint256)', address(safeManager), address(0x01), 1)
    );

    assertTrue(safeManager.wasEnterSystemCalled());
  }

  function test_moveSafe() public {
    safeManager.reset();
    vm.startPrank(alice);

    proxy.execute(
      address(basicActions), abi.encodeWithSignature('moveSAFE(address,uint256,uint256)', address(safeManager), 1, 1)
    );

    assertTrue(safeManager.wasMoveSAFECalled());
  }

  function test_addSAFE() public {
    safeManager.reset();
    vm.startPrank(alice);

    proxy.execute(address(basicActions), abi.encodeWithSignature('addSAFE(address,uint256)', address(safeManager), 1));

    assertTrue(safeManager.wasAddSAFECalled());
  }

  function test_removeSAFE() public {
    safeManager.reset();
    vm.startPrank(alice);

    proxy.execute(
      address(basicActions), abi.encodeWithSignature('removeSAFE(address,uint256)', address(safeManager), 1)
    );

    assertTrue(safeManager.wasRemoveSAFECalled());
  }

  function test_protectSAFE() public {
    safeManager.reset();
    vm.startPrank(alice);

    proxy.execute(
      address(basicActions),
      abi.encodeWithSignature('protectSAFE(address,uint256,address)', address(safeManager), 1, address(0x1))
    );

    assertTrue(safeManager.wasProtectSAFECalled());
  }
}
