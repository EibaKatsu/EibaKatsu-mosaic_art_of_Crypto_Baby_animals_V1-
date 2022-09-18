// SPDX-License-Identifier: MIT
// Copyright (c) 2022 Eiba

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./lib/RecoverSigner.sol";
import "./lib/AddressStrings.sol";

contract CryptoBabyAnimalsMosaic is ERC721URIStorage, Ownable {
    using Strings for uint256;
    using AddressStrings for address;

    uint256 public maxAmount = 3;
    bool public paused = false;
    address toolUser = 0x52A76a606AC925f7113B4CC8605Fe6bCad431EbB;

    /**
     * リエントランシ対策
     * 関数実行中なら再度実行させない.
     */
    modifier noReentrancy() {
        require(!locked, "reentrancy error");
        locked = true;
        _;
        locked = false;
    }
    bool locked = false;

    constructor() ERC721("Crypto Baby Animals Mosaic", "CBAM") {}

    //  CBAモザイクのミント
    function mintCBAMosaic(
        uint256 _tokenId,
        string memory _baseUri,
        address _cbaOwner,
        bytes memory signature
    ) public payable noReentrancy {
        // コントラクトが停止中でないこと
        require(!paused, "the contract is paused");

        // 署名が正しいこと
        require(
            _verifySigner(
                _makeMassage(_tokenId, _baseUri, _cbaOwner, msg.sender),
                signature
            ),
            "signature is incorrect"
        );

        // 指定されたtokenIdをミントしていないこと
        require(!_exists(_tokenId * 10), "the tokenId is minted");

        // 数量分ループ
        for (uint256 i = 0; i <= maxAmount; i++) {
            // CBAの tokenId * 10を起点に数量分+1した値をtokenIdにする
            uint256 newTokenId = _tokenId * 10 + i;

            // mint - 一つ目はCBAsオーナーへ
            if (i == 0) {
                _mint(_cbaOwner, newTokenId);
                // mint - 二つ目は申込者へ
            } else if (i == 1) {
                _mint(msg.sender, newTokenId);
                // mint - 三つ目はコントラクトアドレスへ
            } else {
                _mint(address(this), newTokenId);
            }

            // tokenURI
            _setTokenURI(
                newTokenId,
                string(
                    abi.encodePacked(_baseUri, newTokenId.toString(), ".json")
                )
            );
        }
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function setToolUser(address _toolUser) public onlyOwner {
        toolUser = _toolUser;
    }

    // 署名検証用のメッセージ
    function _makeMassage(
        uint256 _tokenId,
        string memory _baseUri,
        address _cbaOwner,
        address _sender
    ) internal view virtual returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _tokenId.toString(),
                    "|",
                    _baseUri,
                    "|",
                    "0x",
                    _cbaOwner.toAsciiString(),
                    "|",
                    "0x",
                    _sender.toAsciiString()
                )
            );
    }

    function testMakeMessage(
        uint256 _tokenId,
        string memory _baseUri,
        address _cbaOwner,
        address _sender
    ) public view returns (string memory) {
        return _makeMassage(_tokenId, _baseUri, _cbaOwner, _sender);
    }

    // 署名の検証
    // 複合したアドレスがtoolUserと一致するかチェック
    function _verifySigner(string memory message, bytes memory signature)
        internal
        view
        returns (bool)
    {
        return RecoverSigner.recoverSignerByMsg(message, signature) == toolUser;
    }

    // withdraw関数
    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function testBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
