// SPDX-License-Identifier: MIT
// Copyright (c) 2022 Eiba

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./lib/RecoverSigner.sol";
import "./lib/AddressStrings.sol";

contract CryptoBabyAnimalsSecandaryCreation is ERC1155, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint16;
    using Strings for uint256;
    using AddressStrings for address;

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

    Counters.Counter private _tokenCounter;

    struct Nft {
        string name;
        string uri;
        uint16 tokenMax;
        uint256 minimumPrice;
        Counters.Counter amount;
        address payable creator;
    }

    bool public paused = false;
    address signer = 0x52A76a606AC925f7113B4CC8605Fe6bCad431EbB;

    mapping(uint256 => Nft) public nfts;

    constructor() ERC1155("") {
        _tokenCounter.reset();
    }

    function createNft(
        string memory _name,
        string memory _uri,
        uint16 _tokenMax,
        uint16 _mintForCreator,
        uint256 _minimumPrice,
        address payable _creator,
        string memory _hashMsg,
        bytes memory signature
    ) public noReentrancy {
        // コントラクトが停止中でないこと
        require(!paused, "the contract is paused");

        require(bytes(_name).length > 0, "_name is unset");
        require(bytes(_uri).length > 0, "_uri is unset");
        require(_tokenMax > 0, "_tokenMax is 0");
        require(_creator != address(0), "_creator is zero address");

        if (msg.sender != owner()) {
            // 署名が正しいこと
            require(
                _verifySigner(_makeMassage(_hashMsg, msg.sender), signature),
                "signature is incorrect"
            );
        }

        _tokenCounter.increment();
        Counters.Counter memory _amount;
        nfts[_tokenCounter.current()] = Nft(
            _name,
            _uri,
            _tokenMax,
            _minimumPrice,
            _amount,
            _creator
        );

        // ceatorにmint
        if (_mintForCreator > 0) {
            _mint(_creator, _tokenCounter.current(), _mintForCreator, "");
        }

        // 使用数カウンターをup
        for (uint16 i = 0; i < _mintForCreator; i++) {
            nfts[_tokenCounter.current()].amount.increment();
        }
    }

    // mint
    function mint(uint256 _tokenId) public payable {
        // tokenIdが存在するかのチェック(mappingに存在しない場合は初期値0になる)
        require(nfts[_tokenId].tokenMax != 0, '_tokenId is not exists');

        // 複数所有はNG
        require(
            balanceOf(msg.sender, _tokenId) == 0,
            "can mint only one token"
        );

        // tokenMaxを超えたらNG
        require(
            nfts[_tokenId].amount.current() + 1 <= nfts[_tokenId].tokenMax,
            "this tokenId had reached max count"
        );

        // 最低価格設定がある場合は最低価格以上
        if (nfts[_tokenId].minimumPrice > 0) {
            require(
                msg.value >= nfts[_tokenId].minimumPrice,
                "Insufficient payment"
            );
        }

        // mint
        _mint(msg.sender, _tokenId, 1, "");

        // amountを追加
        nfts[_tokenId].amount.increment();

        // valueがあればcreatorへ送金
        if (msg.value > 0) {
            nfts[_tokenId].creator.transfer(msg.value);
        }
    }

    // 署名検証用のメッセージ
    function _makeMassage(string memory _hashMsg, address _sender)
        internal
        view
        virtual
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(_hashMsg, "|", "0x", _sender.toAsciiString())
            );
    }

    function testMakeMessage(string memory _hash, address _sender)
        public
        view
        returns (string memory)
    {
        return _makeMassage(_hash, _sender);
    }

    // 署名の検証
    // 複合したアドレスがsignerと一致するかチェック
    function _verifySigner(string memory message, bytes memory signature)
        internal
        view
        returns (bool)
    {
        return RecoverSigner.recoverSignerByMsg(message, signature) == signer;
    }

    function updateNft(
        uint256 _tokenId,
        string memory _name,
        string memory _uri,
        uint16 _tokenMax,
        address payable _creator,
        string memory _hashMsg,
        bytes memory signature
    ) public {
        // tokenIdが存在するかのチェック(mappingに存在しない場合は初期値0になる)
        require(nfts[_tokenId].tokenMax != 0, "_tokenId is not exists");

        if (msg.sender != owner()) {
            // 署名が正しいこと
            require(
                _verifySigner(_makeMassage(_hashMsg, msg.sender), signature),
                "signature is incorrect"
            );
        }

        if (bytes(_name).length != 0) {
            nfts[_tokenId].name = _name;
        }

        if (bytes(_uri).length != 0) {
            nfts[_tokenId].uri = _uri;
        }

        if (_tokenMax != 0) {
            // 現在の発行数以下はNG
            require(
                nfts[_tokenId].amount.current() <= _tokenMax,
                "cannot set under to amount"
            );
            nfts[_tokenId].tokenMax = _tokenMax;
        }

        if (_creator != address(0)) {
            nfts[_tokenId].creator = _creator;
        }
    }

    // minimumPriceはゼロ設定可能なため、updateNFTとは別にする
    function updateMinimumPrice(
        uint256 _tokenId,
        uint256 _minimumPrice,
        string memory _hashMsg,
        bytes memory signature
    ) public onlyOwner {
        if (msg.sender != owner()) {
            // 署名が正しいこと
            require(
                _verifySigner(_makeMassage(_hashMsg, msg.sender), signature),
                "signature is incorrect"
            );
        }
        nfts[_tokenId].minimumPrice = _minimumPrice;
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return nfts[_id].uri;
    }

    function name(uint256 _id) public view returns (string memory) {
        return nfts[_id].name;
    }

    function tokenMax(uint256 _id) public view returns (uint16) {
        return nfts[_id].tokenMax;
    }

    function minimumPrice(uint256 _id) public view returns (uint256) {
        return nfts[_id].minimumPrice;
    }

    function creator(uint256 _id) public view returns (address) {
        return nfts[_id].creator;
    }

    function amount(uint256 _id) public view returns (uint256) {
        return nfts[_id].amount.current();
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    // withdraw関数
    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
}
