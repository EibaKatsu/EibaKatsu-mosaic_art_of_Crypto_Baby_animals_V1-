const { expect } = require("chai");
const { ethers } = require("hardhat");

// 1. fixturesを使うための関数import
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("CryptoBabyAnimalsSecondaryCreation test", function () {

  // 2. セットアップ処理の内容を記載。デプロイやウォレット取得を行う
  async function deployNftFixture() {
    const contractFactory = await ethers.getContractFactory("CryptoBabyAnimalsSecandaryCreation");

    const [owner, signer, user1, user2, creator] = await ethers.getSigners();

    const contract = await contractFactory.deploy();
    await contract.deployed();

    // 3. itから呼ばれた際に、返却する変数たちを定義
    return { contractFactory, contract, owner, signer, user1, user2, creator };
  }

  it("正常系", async function () {
    // 4. loadFixtureを通して、セットアップ処理をたたき、各種変数を取得
    const { contractFactory, contract, owner, signer, user1, user2, creator } = await loadFixture(deployNftFixture);

    // // pauseの設定
    await contract.pause(false);

    // toolUserの設定
    await contract.setSigner(signer.address);

    // メッセージハッシュの作成
    hashMsg = makeMassage(user1.address);
    hashbytes = makeMassageBytes(hashMsg);

    // signerユーザで署名
    let signature = await signer.signMessage(hashbytes);

    // NFTを登録
    await contract.createNft(
      "name",  //_name,
      "ipfs://1234567890/1.json",   // _uri,
      10,  //  _tokenMax,
      5,  // _mintForCreator,
      0, // _minimumPrice,
      creator.address,  // _creator,
      hashMsg, // _hash,
      signature // signature
    );

    // createNftでセットした値の確認
    expect(await contract.name(1)).equal("name");
    expect(await contract.uri(1)).equal("ipfs://1234567890/1.json");
    expect(await contract.tokenMax(1)).equal(10);
    expect(await contract.minimumPrice(1)).equal(0);
    expect(await contract.creator(1)).equal(creator.address);

    // creatorにミントされていること
    expect(await contract.balanceOf(creator.address, 1)).equal(5);
    expect(await contract.amount(1)).equal(5);
    
    // ミント
    await contract.connect(user1).mint(1);

    // user1にミントされていること
    expect(await contract.balanceOf(user1.address, 1)).equal(1);
    expect(await contract.amount(1)).equal(6);

  }
  );

  it("正常系 - updateNft", async function () {
    // 4. loadFixtureを通して、セットアップ処理をたたき、各種変数を取得
    const { contractFactory, contract, owner, signer, user1, user2, creator } = await loadFixture(deployNftFixture);

    // // pauseの設定
    await contract.pause(false);

    // toolUserの設定
    await contract.setSigner(signer.address);

    // メッセージハッシュの作成
    hashMsg = makeMassage(user1.address);
    hashbytes = makeMassageBytes(hashMsg);

    // signerユーザで署名
    let signature = await signer.signMessage(hashbytes);

    // NFTを登録
    await contract.createNft(
      "name",  //_name,
      "ipfs://1234567890/1.json",   // _uri,
      10,  //  _tokenMax,
      5,  // _mintForCreator,
      0, // _minimumPrice,
      creator.address,  // _creator,
      hashMsg, // _hash,
      signature // signature
    );

    // createNftでセットした値の確認
    expect(await contract.name(1)).equal("name");
    expect(await contract.uri(1)).equal("ipfs://1234567890/1.json");
    expect(await contract.tokenMax(1)).equal(10);
    expect(await contract.minimumPrice(1)).equal(0);
    expect(await contract.creator(1)).equal(creator.address);

    // creatorにミントされていること
    expect(await contract.balanceOf(creator.address, 1)).equal(5);
    expect(await contract.amount(1)).equal(5);
    
    // NFTを登録
    await contract.updateNft(
      1,
      "name2",  //_name,
      "ipfs://2345678901/1.json",   // _uri,
      100,  //  _tokenMax,
      user2.address,  // _creator,
      hashMsg, // _hash,
      signature // signature
    );

    // createNftでセットした値の確認
    expect(await contract.name(1)).equal("name2");
    expect(await contract.uri(1)).equal("ipfs://2345678901/1.json");
    expect(await contract.tokenMax(1)).equal(100);
    expect(await contract.creator(1)).equal(user2.address);

    // 最低価格を変更
    await contract.updateMinimumPrice(
      1,
      ethers.utils.parseEther("1"),
      hashMsg, // _hash,
      signature // signature
    );
    expect(await contract.minimumPrice(1)).equal(ethers.utils.parseEther("1"));

  }
  );

  it("異常系 - createNft", async function () {
    // 4. loadFixtureを通して、セットアップ処理をたたき、各種変数を取得
    const { contractFactory, contract, owner, signer, user1, user2, creator } = await loadFixture(deployNftFixture);

    // // pauseの設定
    await contract.pause(false);

    // toolUserの設定
    await contract.setSigner(signer.address);

    // メッセージハッシュの作成
    hashMsg = makeMassage(user1.address);
    hashbytes = makeMassageBytes(hashMsg);

    // signerユーザで署名
    let signature = await signer.signMessage(hashbytes);

    // hashMsgに別ユーザでセット(異なるhashMsg)
    hashMsg2 = makeMassage(user2.address);

    // console.log("hashMsg:", hashMsg);
    // console.log("hashMsg2:", hashMsg2);

    // console.log("testMakeMassage1:", await contract.testMakeMessage(hashMsg, user1.address));
    // console.log("testMakeMassage2:", await contract.testMakeMessage(hashMsg2, user1.address));

    // NFTを登録
    await expect(contract.connect(user1).createNft(
      "name",  //_name,
      "ipfs://1234567890/1.json",   // _uri,
      10,  //  _tokenMax,
      5,  // _mintForCreator,
      0, // _minimumPrice,
      creator.address,  // _creator,
      hashMsg2, // _hash,
      signature // signature
    )).to.be.revertedWith("signature is incorrect");

    // await expect( contract.connect(signer).mintCBAMosaic(1000, signature, { value: ethers.utils.parseEther("1") }))
    // .to.be.revertedWith('CBAs are only 999');

    // NFTを登録
    await expect(contract.connect(user1).createNft(
      "name",  //_name,
      "",   // _uri,
      10,  //  _tokenMax,
      5,  // _mintForCreator,
      0, // _minimumPrice,
      creator.address,  // _creator,
      hashMsg, // _hash,
      signature // signature
    )).to.be.revertedWith("_uri is unset");

    // NFTを登録
    await expect(contract.connect(user1).createNft(
      "name",  //_name,
      "ipfs://1234567890/1.json",   // _uri,
      0,  //  _tokenMax,
      5,  // _mintForCreator,
      0, // _minimumPrice,
      creator.address,  // _creator,
      hashMsg, // _hash,
      signature // signature
    )).to.be.revertedWith("_tokenMax is 0");

  }
  );


  it("異常系 - mint", async function () {
    // 4. loadFixtureを通して、セットアップ処理をたたき、各種変数を取得
    const { contractFactory, contract, owner, signer, user1, user2, creator } = await loadFixture(deployNftFixture);

    // // pauseの設定
    await contract.pause(false);

    // toolUserの設定
    await contract.setSigner(signer.address);
  
    // メッセージハッシュの作成
    hashMsg = makeMassage(user1.address);
    hashbytes = makeMassageBytes(hashMsg);

    // signerユーザで署名
    let signature = await signer.signMessage(hashbytes);

    // NFTを登録
    await contract.createNft(
      "name",  //_name,
      "ipfs://1234567890/1.json",   // _uri,
      10,  //  _tokenMax,
      9,  // _mintForCreator,
      ethers.utils.parseEther("1"), // _minimumPrice,
      creator.address,  // _creator,
      hashMsg, // _hash,
      signature // signature
    );

    // createNftでセットした値の確認
    expect(await contract.name(1)).equal("name");
    expect(await contract.uri(1)).equal("ipfs://1234567890/1.json");
    expect(await contract.tokenMax(1)).equal(10);
    expect(await contract.minimumPrice(1)).equal(ethers.utils.parseEther("1"));
    expect(await contract.creator(1)).equal(creator.address);

    // creatorにミントされていること
    expect(await contract.balanceOf(creator.address, 1)).equal(9);
    expect(await contract.amount(1)).equal(9);
    
    // 最低価格チェック
    await expect(contract.connect(user2).mint(1, {value: ethers.utils.parseEther("0.9") })).to.be.revertedWith('Insufficient payment');

    // ミント
    await contract.connect(user1).mint(1, {value: ethers.utils.parseEther("1") });

    // ミント2回目
    await expect(contract.connect(user1).mint(1, {value: ethers.utils.parseEther("1") })).to.be.revertedWith("can mint only one token");

    // ミント 存在しないtokenId
    await expect(contract.connect(user1).mint(2, {value: ethers.utils.parseEther("1") })).to.be.revertedWith('_tokenId is not exists');

    // 最大数以上のミント 現在の発行数はmax
    expect(await contract.amount(1)).equal(10);
    // ミント2回目
    await expect(contract.connect(user2).mint(1)).to.be.revertedWith("this tokenId had reached max count");

  }
  );

})

function makeMassage(
  _sender) {
  let msg = String(new Date().getTime()) + "|" +
    String(_sender).toLowerCase();

  return msg;
}

function makeMassageBytes(
  _msg) {
  return ethers.utils.arrayify(
    ethers.utils.id(_msg));
}