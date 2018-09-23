## Blockchain hackathon project - Lean Meat

### Background
Build a simple ethereum blockchain application to be able to track status of a product in its lifecycle from production to end consumer.

Project get inspired from [Truffle Webpack Demo](https://github.com/ConsenSys/truffle-webpack-demo)

There are one asset (Product) and 3 participants (Producer, Shipper and Consumer) in this project.

* When a Producer pack the product and ready for delivery, it will tag product with metadata such as id, category, description and when the product is packed by who. 
* When a Shipper ready for send delivery to consumer, it will add an entry to product saying when the product is delivered by who.
* When a consumer buy a product, the timestamp will also be updated on the product.
* All participants at any time can get detail information about given product, to make them confident that the product keep good quality standard all the way to end consumers.

**NOTE** We can add more action points for participants and more participants, but we make it simpler but yet good enough to demostrate problem we can solve.


### Coding Style

This repo uses JS Standard.

### Running

For test smart contract, we can use copy .sol file and test directly in remix IDE, connect to local testnet provider.

The Web3 RPC location will be picked up from the `truffle.js` file.

0. Clone this repo
0. `npm install`
0. Make sure `testrpc` is running on its default port. Then:
  - `npm run start` - Starts the development server
  - `npm run build` - Generates a build
  - `truffle test` - Run the rest suite
