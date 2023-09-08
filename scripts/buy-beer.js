const hre = require("hardhat");

// Returns the Ether balance of a given address.
async function getBalance(address) {
  const balanceBigInt = await hre.ethers.provider.getBalance(address);
  return hre.ethers.utils.formatEther(balanceBigInt);
}

// Logs the Ether balances for a list of addresses.
async function printBalances(addresses) {
  let idx = 0;
  for (const address of addresses) {
    console.log(`Address ${idx} balance: `, await getBalance(address));
    idx ++;
  }
}

// Logs the memos stored on-chain from beer purchases.
async function printMemos(memos) {
  for (const memo of memos) {
    const timestamp = memo.timestamp;
    const tipper = memo.name;
    const tipperAddress = memo.from;
    const message = memo.message;
    console.log(`At ${timestamp}, ${tipper} (${tipperAddress}) said: "${message}"`);
  }
}

async function main() {
  // Get the example accounts we'll be working with.
  const [owner, tipper, tipper2, tipper3] = await hre.ethers.getSigners();

  // We get the contract to deploy.
  const BuyMeABeer = await hre.ethers.getContractFactory("BuyMeABeer");
  const buyMeABeer = await BuyMeABeer.deploy();

  // Deploy the contract.
  await buyMeABeer.deployed();
  console.log("BuyMeABeer deployed to:", buyMeABeer.address);

  // Check balances before the beer purchase.
  const addresses = [owner.address, tipper.address, buyMeABeer.address];
  console.log("== start ==");
  await printBalances(addresses);

  // Buy the owner a few beers.
  const tip = {value: hre.ethers.utils.parseEther("1")};
  await buyMeABeer.connect(tipper).buyBeer("Carolina", "You're the best!", tip);
  await buyMeABeer.connect(tipper2).buyBeer("Vitto", "Amazing teacher", tip);
  await buyMeABeer.connect(tipper3).buyBeer("Kay", "I love my Proof of Knowledge", tip);

  // Check balances after the coffee purchase.
  console.log("== bought coffee ==");
  await printBalances(addresses);

  // Withdraw.
  await buyMeABeer.connect(owner).withdrawTips();

  // Check balances after withdrawal.
  console.log("== withdrawTips ==");
  await printBalances(addresses);

  // Check out the memos.
  console.log("== memos ==");
  const memos = await buyMeABeer.getMemos();
  printMemos(memos);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });