// SPDX-License-Identifier: MIT
// Copyright (c) 2022 Eiba

/*
  別のERC721コントラクトから、指定するTokenIdを所有するオーナーを取得する

**/

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract GetOwnerAddress {
    // Contract of Crypto Ninja Partners
    ERC721 cnpContract = ERC721(0x845a007D9f283614f403A24E3eB3455f720559ca);

    function getOwner(uint256 _tokenId) public view returns (address){
        // CNPコントラクトからオーナーアドレスを取得
        address owner = cnpContract.ownerOf(_tokenId);

        return owner;
    }

    function name () public view returns (string memory){
        return cnpContract.name();
    }
}
