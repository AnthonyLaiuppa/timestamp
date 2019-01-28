import React, { Component } from 'react';

import './App.css';

class App extends Component {

  constructor(props){
  		super(props);
  		this.state = {
        isLoaded: false,
  			message: '',
        timestamp: '',
  		}
  }

  componentDidMount(){
    this.fetchData();

  }

  async fetchData(){

  //await fetch('http://localhost:8080/timestamp',{
    await fetch('http://api.ezctf.com/timestamp',{
      method: "GET",
      mode : "cors",
      headers : { 
        'Content-Type': 'application/json',
        'Accept': 'application/json'
       },
    })
      .then((Response) => Response.json())
      .then((findresponse)=>{
        this.setState({
          isLoaded: true,
          message: findresponse.message,
          timestamp: findresponse.timestamp,
        })
      })
      .catch(error => console.log('Parsing failed', error)) 

  }

  render() {

  	var { isLoaded, message, timestamp } = this.state;

  	if (!isLoaded){
  		return <div>Loading... </div>;
  	}
  	else{
    	return (
      		<div className="App">
            Loaded
            <br></br>
            {message} {timestamp}
      		</div>
    	);
  	}
  }
}

export default App;
