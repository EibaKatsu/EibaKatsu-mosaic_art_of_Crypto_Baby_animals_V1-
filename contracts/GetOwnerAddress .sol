// SPDX-License-Identifier: MIT
// Copyright (c) 2022 Eiba

/*
  CBAのコントラクトから、指定するTokenIdを所有するオーナーを取得する
**/

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract GetOwnerAddress {
    // Contract of Crypto Baby Animals
    ERC721 cbaContract = ERC721(0x495f947276749Ce646f68AC8c248420045cb7b5e);

    function getCbaOwner(uint256 _tokenId) public view returns (address){
        // CBAコントラクトからオーナーアドレスを取得
        address cbaOwner = cbaContract.ownerOf(_tokenId);

        return cbaOwner;
        
    }

    function name () public view returns (string memory){
        return cbaContract.name();
    }
}
