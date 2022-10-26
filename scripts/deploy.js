async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());
    // const Token = await ethers.getContractFactory("CryptoBabyAnimalsMosaic");
    const Token = await ethers.getContractFactory("CharaDaoEventNft");
    const token = await Token.deploy(["0x52A76a606AC925f7113B4CC8605Fe6bCad431EbB","0x480d565527086DC3dc2262648194E1e9cCAB70EF"]);
    console.log("Token address:", token.address);
   }
   main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });