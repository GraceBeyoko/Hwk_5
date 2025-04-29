// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/ArtGalleryToken.sol";
import "../src/Gallery.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        ArtGalleryToken token = new ArtGalleryToken();
        console.log("ArtGalleryToken deployed at:", address(token));

        address[3] memory signers = [
            0x0B8efa42a8012C7201163A92b46C6712442466bc, 
            0x5F02f5F5Cd3192849CA4e1cDA9FA422C4b348b50,
            0xa13a5929761620dBF1eb7FA8D8ecFb6D37c3A611
        ];
        GalleryCore dao = new GalleryCore(address(token), signers);
        console.log("GalleryCore deployed at:", address(dao));

        vm.stopBroadcast();
    }
}
