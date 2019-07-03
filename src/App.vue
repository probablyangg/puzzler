<template>
  <b-container class="mb-5">
    <b-row class="header-row">
      <b-col>
        <h1>Puzzler</h1>
        <img src="./assets/spiro/spiro3.png" class = "unknown-viper">
      </b-col>
    </b-row>

    <b-row>
      <b-col class="action-container">
        <h4>
          {{ questions[level].question }}
        </h4>
        <b-form>
          <b-col class="middle-container">
        <img v-if="isLoading" src="https://media.giphy.com/media/11cXHq5SBfWbug/giphy.gif"></b-col>
        <b-form-group v-if="!isLoading"
                    >
            <b-form-input id="matron"
                          v-model="matron"
                          required
                          placeholder="Your answer">
            </b-form-input>
          </b-form-group>
          <b-button 
          v-if="!isLoading"
          v-on:click="createSpiro" type="button">Submit</b-button>
          
          <p>Gas costs apply.</p>
        </b-form>
      </b-col>
    </b-row>

    <hr>
    <h2 class="mb-5">Stats</h2>
    <p><u>Account address</u>: {{ account }} </p>
    <p><u>Contract address</u>: {{ contractAddr }} </p>

    <b-row>
      <b-col>
        <p><b>Level: </b>{{ level }}</p>
      </b-col>
      <b-col>
        <p><b>Spiro: </b> {{ spiro }} <b>PZLR</b> </p>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        <p><b>SpiroID on sale: </b> <span v-for ="i in spirosOnSale"> {{ i }}, </span> </p>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        {{ k = 0 }}
        <p><b>Spiros generated so far: </b> <ul> <li v-for ="i in allSpiros"> {{ k ++ }} {{ i }} </li> </ul> </p>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        <p><b>Spiros owned by the contract: </b> <span v-for ="i in contractSpiros"> {{ i }}, </span></p>
      </b-col>
    </b-row>
    <hr>
  <b-row>
    <b-col class="action-container">
    <b-form>
        <b-col class="middle-container">
        <img v-if="isLoading" src="https://media.giphy.com/media/11cXHq5SBfWbug/giphy.gif"></b-col>
        <b-form-group v-if="!isLoading">
          <p>To freeze/level up:</p>
            <b-form-input id="spiroIdToBuy"
                          v-model="spiroIdToBuy"
                          required
                          placeholder="Spiro ID">
            </b-form-input>
          </b-form-group>
          <b-button 
          v-if="!isLoading"
          v-on:click="buyNew" type="button">Submit</b-button>
          
          <p>Cost for each Spiro (S) = (S.level * 0.005) ether </p>
        </b-form>
    </b-col>
    <b-col class="action-container">
    <b-form>
        <b-col class="middle-container">
        <img v-if="isLoading" src="https://media.giphy.com/media/11cXHq5SBfWbug/giphy.gif"></b-col>
        <b-form-group v-if="!isLoading">
          <p>Sell:</p>
            <b-form-input id="sellSpiroId"
                          v-model="sellSpiroId"
                          required
                          placeholder="Spiro ID">
            </b-form-input>
          </b-form-group>
          
      
          <b-button 
          v-if="!isLoading"
          v-on:click="sellSpiro" type="button">Submit</b-button>
          
          <p>Selling price for each Spiro (S) = (S.level * 0.005) ether </p>
        </b-form>
    </b-col>
    </b-row>
    <hr>
  </b-container>
</template>

<script>
import allQuestions from './components/questions.json';
import getWeb3 from '../contracts/web3';
import contractAbi from '../contracts/abi';
//puzzlerContract
const contractAddress = '0xb572e8d58b214455e6aff3aee9e0e8f55a102354';
export default {
  name: 'App',
  data() {
    return {
      web3: null,
      account: null,
      contractInstance: null,
      contractAddr: contractAddress,
      level: 1,
      spiro: "-",
      spirosOnSale: [],
      allSpiros: [],
      contractSpiros: [],
      isLoading: false,
      questions: allQuestions
      
    };
  },
  mounted() {
    getWeb3().then((res) => {
      this.web3 = res;
      this.contractInstance = new this.web3.eth.Contract(contractAbi, contractAddress);
      this.web3.eth.getAccounts().then((accounts) => {
        // [this.account] = accounts;
        this.account = accounts[0];
        this.getSpiro();
        // this.getSpiros();
        this.getContractSpiros();
      }).catch((err) => {
        console.log(err, 'err!!');
      });
    });
  },

  methods: {
    
    createSpiro () {
      if (matron.value == this.questions[this.level].answer) {
      this.isLoading = true;
      this.contractInstance.methods.createSpiro(this.level).send({
        from: this.account
      }).then((receipt) => {
        this.addSpiroFromReceipt(receipt);
        this.level ++;
        this.isLoading = false;
      }).catch((err) => {
        console.log(err, 'err');
        this.isLoading = false;
      })
      } else {
        console.log("matron value");
        console.log(matron.value);
        console.log ("answer is");
        console.log (this.questions[this.level].answer);
        alert ("This isn't the right answer");
      }
      this.getContractSpiros();
    }, 

    buyNew () {
      let lvl;
      this.contractInstance.methods.spiros(this.spiroIdToBuy).call({
          from: this.account
        }).then((s) => {
          lvl = s.level;
        });
        let amt = lvl * 0.005;
      this.contractInstance.methods.buyNewSpiro(this.spiroIdToBuy).send({
        from: this.account,
        value: web3.toWei(amt, 'ether')
      }).then((receipt) => {
        this.addSpiroFromReceipt(receipt);
        this.spiro = this.spiroIdToBuy;
        this.isLoading = false;
      }).catch((err) => {
        console.log (err);
        this.isLoading = false;
      });
      this.getContractSpiros();
    },

    getSpiro() {
      this.isLoading = true;
      this.contractInstance.methods.ownerToSpiro(this.account).call({
        from:this.account
      }).then((receipt) => {
        this.spiro = receipt;
        this.contractInstance.methods.spiros(this.spiro).call({
          from: this.account
        }).then((s) => {
          this.level = s.level;
        });
        this.isLoading = false;
        console.log ("user spiro set to: ", this.spiro);
      }).catch((err) => {
        console.log(err, 'err');
        this.isLoading = false;
      });
    },

    getContractSpiros () {
      this.contractInstance.methods.getSpiros().call({
        from: this.account
      }).then((allSpiros) => {
        this.contractSpiros = allSpiros;
        console.log ("user spiro set to: ", this.contractSpiros);
      }).catch((err) => {
        console.log (err, 'err');
      });
    },

    sellSpiro () {
      this.contractInstance.methods.sellSpiro(this.sellSpiroId).send({
        from: this.account
      }).then((receipt) => {
        console.log ("ok");
        this.contractInstance.methods.spiroToSalePrice(this.sellSpiroId).call ({
          from: this.account
        }).then ((price) => {
          console.log ("now pushing");
          spirosOnSale.push(sellSpiroId, price);
        })
        this.spiro = "-"
        getSpiro();
      });
    } ,
    addSpiroFromReceipt(receipt) {
      console.log("---");
      console.log(receipt);
      console.log(typeof(receipt));
      this.allSpiros.push({
        level: receipt.events.newSpiro.returnValues.level,
        creator: receipt.events.newSpiro.returnValues.creator
      });
      console.log(this.allSpiros);
    }
  },
};
</script>

<style lang="css">
@import url('https://fonts.googleapis.com/css?family=Poppins:400,500');

* {
  font-family: 'Poppins', sans-serif;
}
button {
  width: 100%;
}
h1, h2, h3, h4, p {
  color: white;
}
hr { display: block; height: 1px;
    border: 0; border-top: 1px solid #ccc;
    margin: 1em 0; padding: 0; }
 body {
  background-color: rgb(24,24,24);
}
.header-row {
  text-align: center;
  margin: 30px 0;
}
.action-container h4 {
  text-align: center;
  margin-bottom: 30px;
}
.action-container p {
  text-align: center;
  margin-top: 10px;
}
.middle-container {
  display: flex;
  justify-content: center;
  align-items: center;
}
.middle-container img {
  height: 100px;
}
.unknown-viper {
  height: 180px;
  width: 180px;
  margin: 9px 0;
}
</style>
