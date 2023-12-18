// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

abstract contract AnvilContracts {
  address public ChainlinkRelayerFactory_Address = 0xa722bdA6968F50778B973Ae2701e90200C564B49;
  address public UniV3RelayerFactory_Address = 0xc7cDb7A2E5dDa1B7A0E792Fe1ef08ED20A6F56D4;
  address public CamelotRelayerFactory_Address = 0x967AB65ef14c58bD4DcfFeaAA1ADb40a022140E5;
  address public DenominatedOracleFactory_Address = 0xe1708FA6bb2844D5384613ef0846F9Bc1e8eC55E;
  address public DelayedOracleFactory_Address = 0x0aec7c174554AF8aEc3680BB58431F6618311510;
  address public MintableVoteERC20_Address = 0x871ACbEabBaf8Bed65c22ba7132beCFaBf8c27B5;
  address public MintableERC20_7_Address = 0x6A59CC73e334b018C9922793d96Df84B538E6fD5;
  address public MintableERC20_8_Address = 0xC1e0A9DB9eA830c52603798481045688c8AE99C2;
  address public MintableERC20_9_Address = 0x683d9CDD3239E0e01E8dC6315fA50AD92aB71D2d;
  address public MintableERC20_10_Address = 0x1c9fD50dF7a4f066884b58A05D91e4b55005876A;
  address public DenominatedOracleChild_13_Address = 0xC31510e8533F402F5428980E9503fbd838488606;
  address public DenominatedOracleChild_15_Address = 0x9555031810845e4d65FCa99ec404F229c263a11D;
  address public DenominatedOracleChild_17_Address = 0x66549Df510615BaaDE0165Bda5f0FA777244BCEb;
  address public DenominatedOracleChild_19_Address = 0x6728D3f64d03E77eB990C3215800e29AF5e6AD79;
  address public DelayedOracleChild_20_Address = 0xEC0291F346db42B49A3cC8739295c4273Da28fa9;
  address public DelayedOracleChild_21_Address = 0x568D927cE1EB2343c8CCDeE561129Aa03968Efde;
  address public DelayedOracleChild_22_Address = 0xc8Ca95f44F21b88E4E93e40D0430A24e96A95C78;
  address public DelayedOracleChild_23_Address = 0x9F8620f0264B6feaC5b4062C0e591A888475906F;
  address public DelayedOracleChild_24_Address = 0xF71A24556506C8aA9379634783Dfa413E4D20712;
  address public SystemCoin_Address = 0x79E8AB29Ff79805025c9462a2f2F12e9A496f81d;
  address public ProtocolToken_Address = 0x0Dd99d9f56A14E9D53b2DdC62D9f0bAbe806647A;
  address public TimelockController_Address = 0xd9fEc8238711935D6c8d79Bef2B9546ef23FC046;
  address public ODGovernor_Address = 0xd3FFD73C53F139cEBB80b6A524bE280955b3f4db;
  address public SAFEEngine_Address = 0x987e855776C03A4682639eEb14e65b3089EE6310;
  address public OracleRelayer_Address = 0xb932C8342106776E73E39D695F3FFC3A9624eCE0;
  address public SurplusAuctionHouse_Address = 0xE8F7d98bE6722d42F29b50500B0E318EF2be4fc8;
  address public DebtAuctionHouse_Address = 0xe38b6847E611e942E6c80eD89aE867F522402e80;
  address public AccountingEngine_Address = 0x2c8ED11fd7A058096F2e5828799c68BE88744E2F;
  address public LiquidationEngine_Address = 0x7580708993de7CA120E957A62f26A5dDD4b3D8aC;
  address public CollateralAuctionHouseFactory_Address = 0x75c68e69775fA3E9DD38eA32E554f6BF259C1135;
  address public CoinJoin_Address = 0x572316aC11CB4bc5daf6BDae68f43EA3CCE3aE0e;
  address public CollateralJoinFactory_Address = 0x975Ab64F4901Af5f0C96636deA0b9de3419D0c2F;
  address public TaxCollector_Address = 0x4593ed9CbE6003e687e5e77368534bb04b162503;
  address public StabilityFeeTreasury_Address = 0xCd7c00Ac6dc51e8dCc773971Ac9221cC582F3b1b;
  address public GlobalSettlement_Address = 0x1E3b98102e19D3a164d239BdD190913C2F02E756;
  address public PostSettlementSurplusAuctionHouse_Address = 0x3fdc08D815cc4ED3B7F69Ee246716f2C8bCD6b07;
  address public SettlementSurplusAuctioneer_Address = 0x286B8DecD5ED79c962b2d8F4346CD97FF0E2C352;
  address public PIDController_Address = 0x158d291D8b47F056751cfF47d1eEcd19FDF9B6f8;
  address public PIDRateSetter_Address = 0x2F54D1563963fC04770E85AF819c89Dc807f6a06;
  address public AccountingJob_Address = 0x8ac5eE52F70AE01dB914bE459D8B3d50126fd6aE;
  address public LiquidationJob_Address = 0x325c8Df4CFb5B068675AFF8f62aA668D1dEc3C4B;
  address public OracleJob_Address = 0x4eaB29997D332A666c3C366217Ab177cF9A7C436;
  address public CollateralJoinChild_0x4152420000000000000000000000000000000000000000000000000000000000_Address =
    0x358a6cf86FeE6701C2175536e2605A96d5651978;
  address public
    CollateralAuctionHouseChild_0x4152420000000000000000000000000000000000000000000000000000000000_Address =
      0x8c62914017D16ce28778F8A087D7Bdee346f0828;
  address public CollateralJoinChild_0x5753544554480000000000000000000000000000000000000000000000000000_Address =
    0x45AA00E6Ad1cc04C51245Bb93D79075f4DA4d74D;
  address public
    CollateralAuctionHouseChild_0x5753544554480000000000000000000000000000000000000000000000000000_Address =
      0xED968533CfBbB45900D721f8DBdBC76CaB687550;
  address public CollateralJoinChild_0x4342455448000000000000000000000000000000000000000000000000000000_Address =
    0x22659133758b30dd402CBfA1Ba8f12d28A1eCe44;
  address public
    CollateralAuctionHouseChild_0x4342455448000000000000000000000000000000000000000000000000000000_Address =
      0x4514a566B1F41B9ad81b63FFad4C74f1bED5A629;
  address public CollateralJoinChild_0x5245544800000000000000000000000000000000000000000000000000000000_Address =
    0x63E4e734F429576A927eF3b19ffbBBe6be8c1B95;
  address public
    CollateralAuctionHouseChild_0x5245544800000000000000000000000000000000000000000000000000000000_Address =
      0xf70D321290b3E50549093DfF8306528e3595f56B;
  address public CollateralJoinChild_0x4d41474943000000000000000000000000000000000000000000000000000000_Address =
    0x5Af22CE9208F4fc2c2F0a96553FF13c0708132EE;
  address public
    CollateralAuctionHouseChild_0x4d41474943000000000000000000000000000000000000000000000000000000_Address =
      0xF85C925b41D92AE8E73BB14790CaB63Dee3C7219;
  address public Vault721_Address = 0xf5C3953Ae4639806fcbCC3196f71dd81B0da4348;
  address public ODSafeManager_Address = 0xdb54fa574a3e8c6aC784e1a5cdB575A737622CFf;
  address public NFTRenderer_Address = 0xDDa0648FA8c9cD593416EC37089C2a2E6060B45c;
  address public BasicActions_Address = 0xccA9728291bC98ff4F97EF57Be3466227b0eb06C;
  address public DebtBidActions_Address = 0xc6B407503dE64956Ad3cF5Ab112cA4f56AA13517;
  address public SurplusBidActions_Address = 0x3a622DB2db50f463dF562Dc5F341545A64C580fc;
  address public CollateralBidActions_Address = 0x6A47346e722937B60Df7a1149168c0E76DD6520f;
  address public PostSettlementSurplusBidActions_Address = 0x7A28cf37763279F774916b85b5ef8b64AB421f79;
  address public GlobalSettlementActions_Address = 0x2BB8B93F585B43b06F3d523bf30C203d3B6d4BD4;
  address public RewardedActions_Address = 0xB7ca895F81F20e05A5eb11B05Cbaab3DAe5e23cd;
}
