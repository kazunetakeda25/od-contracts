// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

abstract contract AnvilContracts {
  address public ChainlinkRelayerFactory_Address = 0x25C0a2F0A077F537Bd11897F04946794c2f6f1Ef;
  address public DenominatedOracleFactory_Address = 0x01cf58e264d7578D4C67022c58A24CbC4C4a304E;
  address public DelayedOracleFactory_Address = 0xd038A2EE73b64F30d65802Ad188F27921656f28F;
  address public MintableVoteERC20_Address = 0xeC1BB74f5799811c0c1Bff94Ef76Fb40abccbE4a;
  address public MintableERC20_WSTETH_Address = 0xF6a8aD553b265405526030c2102fda2bDcdDC177;
  address public MintableERC20_CBETH_Address = 0x09120eAED8e4cD86D85a616680151DAA653880F2;
  address public MintableERC20_RETH_Address = 0x3E661784267F128e5f706De17Fac1Fc1c9d56f30;
  address public DenominatedOracleChild_10_Address = 0x4a2D095b33100C9A5742CA04B832a9b3e4577377;
  address public DenominatedOracleChild_12_Address = 0x5cc0968e6d80FD57480aA97e1E4a297c29e3bea4;
  address public DenominatedOracleChild_14_Address = 0x1480755b3dfe5516347110106E48ffBE3ca1E6EB;
  address public DelayedOracleChild_15_Address = 0xCd2B0e7332dCd819a79B12e0250B66f839729b2f;
  address public DelayedOracleChild_16_Address = 0xfFf70BB7A172BF7fa456C1ff5ACEDA2E39067823;
  address public DelayedOracleChild_17_Address = 0xc137905256363123fE2253972B9F492613eDE803;
  address public DelayedOracleChild_18_Address = 0x5F78E88FC06e94001AcE69277365c318B8be7523;
  address public SystemCoin_Address = 0x74ef2B06A1D2035C33244A4a263FF00B84504865;
  address public ProtocolToken_Address = 0xF5b81Fe0B6F378f9E6A3fb6A6cD1921FCeA11799;
  address public TimelockController_Address = 0x73C68f1f41e4890D06Ba3e71b9E9DfA555f1fb46;
  address public ODGovernor_Address = 0xD2D5e508C82EFc205cAFA4Ad969a4395Babce026;
  address public SAFEEngine_Address = 0x7bdd3b028C4796eF0EAf07d11394d0d9d8c24139;
  address public OracleRelayer_Address = 0xB468647B04bF657C9ee2de65252037d781eABafD;
  address public SurplusAuctionHouse_Address = 0x47c05BCCA7d57c87083EB4e586007530eE4539e9;
  address public DebtAuctionHouse_Address = 0x408F924BAEC71cC3968614Cb2c58E155A35e6890;
  address public AccountingEngine_Address = 0x773330693cb7d5D233348E25809770A32483A940;
  address public LiquidationEngine_Address = 0x52173b6ac069619c206b9A0e75609fC92860AB2A;
  address public CollateralAuctionHouseFactory_Address = 0x40A633EeF249F21D95C8803b7144f19AAfeEF7ae;
  address public CoinJoin_Address = 0x532802f2F9E0e3EE9d5Ba70C35E1F43C0498772D;
  address public CollateralJoinFactory_Address = 0xdB012DD3E3345e2f8D23c0F3cbCb2D94f430Be8C;
  address public TaxCollector_Address = 0xd977422c9eE9B646f64A4C4389a6C98ad356d8C4;
  address public StabilityFeeTreasury_Address = 0x1eB5C49630E08e95Ba7f139BcF4B9BA171C9a8C7;
  address public GlobalSettlement_Address = 0xF45B1CdbA9AACE2e9bbE80bf376CE816bb7E73FB;
  address public PostSettlementSurplusAuctionHouse_Address = 0x22b1c5C2C9251622f7eFb76E356104E5aF0e996A;
  address public SettlementSurplusAuctioneer_Address = 0x5A569Ad19272Afa97103fD4DbadF33B2FcbaA175;
  address public PIDController_Address = 0x3de00f44ce68FC56DB0e0E33aD4015C6e78eCB39;
  address public PIDRateSetter_Address = 0x89372b32b8AF3F1272e2efb3088616318D2834cA;
  address public AccountingJob_Address = 0x21915b79E1d334499272521a3508061354D13FF0;
  address public LiquidationJob_Address = 0x44863F234b137A395e5c98359d16057A9A1fAc55;
  address public OracleJob_Address = 0x0c03eCB91Cb50835e560a7D52190EB1a5ffba797;
  address public CollateralJoinChild_0x4152420000000000000000000000000000000000000000000000000000000000_Address =
    0x21564150f548D74fd7D4901F475295dAcD8a42B5;
  address public
    CollateralAuctionHouseChild_0x4152420000000000000000000000000000000000000000000000000000000000_Address =
      0x3e3c1e5477f5F3261D7c25088566e548405B724B;
  address public CollateralJoinChild_0x5753544554480000000000000000000000000000000000000000000000000000_Address =
    0x3B36Cd0Ecc5FF7b21cb3295710e3a78E4fc6bCA3;
  address public
    CollateralAuctionHouseChild_0x5753544554480000000000000000000000000000000000000000000000000000_Address =
      0x6f0AF5BBf2BFDDDF288620Fa6240f2697ebCb127;
  address public CollateralJoinChild_0x4342455448000000000000000000000000000000000000000000000000000000_Address =
    0x5321FB0164c50635F4d5201446A84c3766f7f537;
  address public
    CollateralAuctionHouseChild_0x4342455448000000000000000000000000000000000000000000000000000000_Address =
      0x6d9E2f51B58705C7FCF62623CfD0972414C2F561;
  address public CollateralJoinChild_0x5245544800000000000000000000000000000000000000000000000000000000_Address =
    0x2642c998B7Bb9D666A09f3448A66c575bC50035C;
  address public
    CollateralAuctionHouseChild_0x5245544800000000000000000000000000000000000000000000000000000000_Address =
      0xf73F97bbe80fDEddd2bcb0A8C39381885213D924;
  address public Vault721_Address = 0x12456Fa31e57F91B70629c1196337074c966492a;
  address public ODSafeManager_Address = 0xD5bFeBDce5c91413E41cc7B24C8402c59A344f7c;
  address public NFTRenderer_Address = 0x77AD263Cd578045105FBFC88A477CAd808d39Cf6;
  address public BasicActions_Address = 0x38628490c3043E5D0bbB26d5a0a62fC77342e9d5;
  address public DebtBidActions_Address = 0x05bB67cB592C1753425192bF8f34b95ca8649f09;
  address public SurplusBidActions_Address = 0xa85EffB2658CFd81e0B1AaD4f2364CdBCd89F3a1;
  address public CollateralBidActions_Address = 0x8aAC5570d54306Bb395bf2385ad327b7b706016b;
  address public PostSettlementSurplusBidActions_Address = 0x64f5219563e28EeBAAd91Ca8D31fa3b36621FD4f;
  address public GlobalSettlementActions_Address = 0x1757a98c1333B9dc8D408b194B2279b5AFDF70Cc;
  address public RewardedActions_Address = 0x6484EB0792c646A4827638Fc1B6F20461418eB00;
}
