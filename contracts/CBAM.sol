// SPDX-License-Identifier: MIT
// Copyright (c) 2022 Eiba

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract CBAM is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseURI;
    string public baseExtension = ".json";
    uint256 public maxAmount = 10;
    bool public paused = false;

    // Contract of Crypto Baby Animals
    ERC721 cbaContract = ERC721(0x495f947276749Ce646f68AC8c248420045cb7b5e);

    /**
     * リエントランシ対策
     * 関数実行中なら再度実行させない.
     */
    modifier noReentrancy () {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    bool locked = false;
    constructor(string memory _initBaseURI)
        ERC721("Crypto Baby Animals Mosaic", "CBAM")
    {
        setBaseURI(_initBaseURI);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function freeMint(uint256 _tokenId, uint256 amount) public noReentrancy{
        // コントラクトが停止中でないこと
        require(!paused, "the contract is paused");

        // 数量が1以上10以下であること
        require(amount > 0 && amount <= maxAmount, "amount is incorrect");

        // 指定されたtokenIdをミントしていないこと
        require(!_exists(_tokenId * 10), "the tokenId is exists");

        // CBAコントラクトからオーナーアドレスを取得
        address cbaOwner = cbaContract.ownerOf(_tokenId);

        // senderとCBAオーナーが一致すること
        require(msg.sender == cbaOwner, "sender isn't match to CBA owner");

        // 指定された数量分ループ
        for (uint256 i = 0; i <= amount; i++) {

            // CBAの tokenId * 10を起点に数量分+1した値をtokenIdにする
            _mint(msg.sender, _tokenId * 10 + i);

            // イメージファイルは共通
            _setTokenURI(
                _tokenId * 10 + i,
                string(abi.encodePacked(_baseURI(),_tokenId * 10,baseExtension))
            );
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(_baseURI(), tokenId, baseExtension));
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
}
