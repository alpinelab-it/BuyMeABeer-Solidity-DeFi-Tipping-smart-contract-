// scripts/deploy.js

const hre = require("hardhat");

async function main() {
  // We get the contract to deploy.
  const BuyMeABeer = await hre.ethers.getContractFactory("BuyMeABeer");
  const buyMeABeer = await BuyMeABeer.deploy();

  await buyMeABeer.deployed();

  console.log("BuyMeABeer deployed to:", buyMeABeer.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });