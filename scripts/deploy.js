async function main() {
  // Initialize parameters for contract constructor
  entryFee = 1000;
  ownerCut = 500;
  // ===== RandomNumberGenerator Deployment ====== //
  const RandomNumberGenerator = await ethers.getContractFactory(
    "RandomNumberGenerator"
  );
  console.log("Deploying RNG Contract...");
  const rngContract = await RandomNumberGenerator.deploy();
  await rngContract.deployed();
  console.log("rngContract deployed to: ", rngContract.address);

  // ===== Lottery Deployment ====== //
  const Lottery = await ethers.getContractFactory("Lottery");
  console.log("Deploying Lottery Contract...");
  const lottery = await Lottery.deploy(entryFee, ownerCut, rngContract.address);
  await lottery.deployed();
  console.log("lottery Contract deployed to: ", lottery.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
