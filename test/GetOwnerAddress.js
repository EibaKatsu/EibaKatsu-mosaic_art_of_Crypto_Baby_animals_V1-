const { expect } = require("chai");
const { ethers } = require("hardhat");

// 1. fixturesを使うための関数import
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("テスト", function () {

  // 2. セットアップ処理の内容を記載。デプロイやウォレット取得を行う
  async function deployNftFixture() {
    const contractFactory = await ethers.getContractFactory("GetOwnerAddress");

    const [owner, addr1, addr2] = await ethers.getSigners();

    const contract = await contractFactory.deploy();
    await contract.deployed();

    // 3. itから呼ばれた際に、返却する変数たちを定義
    return { contractFactory, contract, owner, addr1, addr2 };
  }

  it("名前の取得", async function () {
    const eibaAddress = 0x35e5664686475Fe0Fb05300a1708B3C7243F916e;

    // 4. loadFixtureを通して、セットアップ処理をたたき、各種変数を取得
    const { concontractFactory, contract, addr1 } = await loadFixture(deployNftFixture);

    const name = await contract.name();
    expect(name).equal("Mitama-Tomato #17558");

  });

  it("オーナーの取得", async function () {
    const eibaAddress = 0x35e5664686475Fe0Fb05300a1708B3C7243F916e;

    // 4. loadFixtureを通して、セットアップ処理をたたき、各種変数を取得
    const { concontractFactory, contract, addr1 } = await loadFixture(deployNftFixture);

    const addr = await contract.getCbaOwner(ethers.BigNumber.from(17558));
    expect(addr).equal(ethers.utils.getAddress(eibaAddress));
  });

});