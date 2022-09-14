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
    uint256 public maxAmount = 3;
    bool public paused = false;
    address toolUser = 0x52A76a606AC925f7113B4CC8605Fe6bCad431EbB;
    bytes32 passphrase = "jfaijei343t4Fr4es";

    /**
     * リエントランシ対策
     * 関数実行中なら再度実行させない.
     */
    modifier noReentrancy () {
        require(!locked, "reentrancy error");
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

        // 数量が1以上maxAmount以下であること
        require(amount > 0 && amount <= maxAmount, "amount is incorrect");

        // 指定されたtokenIdをミントしていないこと
        require(!_exists(_tokenId * 10), "the tokenId is exists");

        // 指定された数量分ループ
        for (uint256 i = 0; i <= amount; i++) {

            // CBAの tokenId * 10を起点に数量分+1した値をtokenIdにする
            uint256 newTokenId = _tokenId * 10 + i;
            
            // mint
            _mint(msg.sender, newTokenId);

            // tokenURI
            _setTokenURI(newTokenId, string(abi.encodePacked(_baseURI(),newTokenId,baseExtension)));
        }

        // パスフレーズを更新
        updatePassphrase(msg.sender);
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

    function getPassphrase() public view returns(bytes32){
        // toolUserにしか教えない
        require(msg.sender == toolUser, "only toolUser can get passphrase");
        return passphrase;
    }

    function updatePassphrase(address addr) internal {
        // ブロックナンバー、タイムスタンプ、アドレスからパスフレーズを生成
        passphrase = keccak256(abi.encodePacked(block.number , block.timestamp, addr));
    }

    function setToolUser(address _toolUser) public onlyOwner{
        toolUser = _toolUser;
    }
}
