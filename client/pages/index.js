import React, { Component } from "react";
import getWeb3 from "../ethereum/getWeb3";
import cap from "../ethereum/build/CapitalDistribution.json";
import { Button, Form, Input, Message, Label } from "semantic-ui-react";
import Layout from "../components/layout";

class Home extends Component {
  state = {
    web3: null,
    accounts: null,
    account: null,
    capInstance: null,
    tokenAddress: "",
    distributions: "",
    ethAmount: 0,
    errorMessage: "",
    loading: false,
  };

  componentDidMount = async () => {
    try {
      const web3 = await getWeb3();
      const accounts = await web3.eth.getAccounts();
      const networkId = await web3.eth.net.getId();

      const deployedNetwork1 = cap.networks[networkId];
      const capInstance = new web3.eth.Contract(
        cap.abi,
        deployedNetwork1 && deployedNetwork1.address
      );

      this.setState(
        {
          web3,
          accounts,
          capInstance,
        },
        this.loadData
      );
    } catch (error) {
      console.log(error);
    }
  };

  loadData = async () => {
    try {
      const { web3 } = this.state;

      let account = await web3.eth.getCoinbase();
      this.setState({ account });
    } catch (error) {
      console.log(error);
    }
  };

  onSubmit = async (event) => {
    this.setState({ errorMessage: "", loading: true });
    event.preventDefault();
    try {
      const { capInstance, account, sendEth } = this.state;
      let tokAdd;
      if (this.state.ethAmount != 0)
        tokAdd = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";
      else tokAdd = this.state.tokenAddress;

      await capInstance.methods
        .distribute(tokAdd, this.state.distributions)
        .send({
          from: account,
          value: this.state.ethAmount != 0 ? this.state.ethAmount : 0,         
        });
     
    } catch (error) {
      this.setState({ errorMessage: error.message });
    }
    this.setState({ loading: false });
  };

  render() {
    const web3 = this.state.web3;
    if (!web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }

    return (
      <Layout>
        <div>
          <div>
            <h1>Capital Distribution</h1>
            <hr />
            <br />
          </div>
          <div>
           
            <br />

            <Form onSubmit={this.onSubmit} error={!!this.state.errorMessage}>
              <Form.Field>
                
                <Label>Ether Amount</Label>
                <Input
                  focus
                  value={this.state.ethAmount}
                  onChange={(event) =>
                    this.setState({ ethAmount: event.target.value })
                  }
                />
              </Form.Field>
              <Form.Field>
                <Label>Token Address</Label>
                <Input
                  focus
                  value={this.state.tokenAddress}
                  onChange={(event) =>
                    this.setState({ tokenAddress: event.target.value })
                  }
                />
              </Form.Field>
              <Form.Field>
                <Label>Distribution List</Label>
                <Input
                  focus
                  value={this.state.distributions}
                  onChange={(event) =>
                    this.setState({ distributions: event.target.value })
                  }
                />
              </Form.Field>
              <Button primary loading={this.state.loading}>
                Distribute Tokens
              </Button>
              <Message error header="Oops!" content={this.state.errorMessage} />
            </Form>
            <br />

            <hr />
            <p>Your Account: {this.state.account}</p>          
          </div>
        </div>
      </Layout>
    );
  }
}

export default Home;
