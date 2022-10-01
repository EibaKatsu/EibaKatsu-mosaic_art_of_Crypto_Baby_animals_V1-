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

    string baseURI;
    string public baseExtension = ".json";
    uint256 public maxAmount = 3;
    bool public paused = false;
    address toolUser = 0x2dbb039f7ABD8Bf3dC26Fcf7418f4fA4cABb5C22;
    address public approved = 0x2dbb039f7ABD8Bf3dC26Fcf7418f4fA4cABb5C22;

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

    constructor(string memory _initBaseURI)
        ERC721("Crypto Baby Animals Mosaic", "CBAM")
    {
        setBaseURI(_initBaseURI);
    }

    //  CBAモザイクのミント
    function mintCBAMosaic(uint256 _tokenId, bytes memory signature)
        external
        payable
        noReentrancy
    {
        // コントラクトが停止中でないこと
        require(!paused, "the contract is paused");

        // 署名が正しいこと
        require(
            _verifySigner(_makeMassage(_tokenId, msg.sender), signature),
            "signature is incorrect"
        );

        // tokenIdが999以下であること
        require(_tokenId <= 999, "CBAs are only 999");

        // 指定されたtokenIdをミントしていないこと
        require(!_exists(_tokenId * 10), "the tokenId is minted");

        // 数量分ループ
        for (uint8 i = 0; i < maxAmount; i++) {
            // CBAの tokenId * 10を起点に数量分+1した値をtokenIdにする
            uint256 newTokenId = _tokenId * 10 + i;

            // mint - 最後以外のトークンはsenderへ
            if (i < maxAmount - 1) {
                _mint(msg.sender, newTokenId);
                // mint - 最後はコントラクトアドレスへ
            } else {
                _mint(address(this), newTokenId);
            }

            // 運営にApproval
            _approve(approved, newTokenId);
        }
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function setToolUser(address _toolUser) public onlyOwner {
        toolUser = _toolUser;
    }

    function setApproved(address _approved) public onlyOwner {
        approved = _approved;
    }

    function isExists(uint256 _tokenId) public view returns (bool) {
        return _exists(_tokenId);
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    // 署名検証用のメッセージ
    function _makeMassage(uint256 _tokenId, address _sender)
        internal
        view
        virtual
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    _tokenId.toString(),
                    "|",
                    "0x",
                    _sender.toAsciiString()
                )
            );
    }

    function testMakeMessage(uint256 _tokenId, address _sender)
        public
        view
        returns (string memory)
    {
        return _makeMassage(_tokenId, _sender);
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

    function testBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
