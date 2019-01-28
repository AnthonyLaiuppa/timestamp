package main

import (
  "fmt"
  "log"
  "net/http"
  "os"
  "flag"
  "bytes"
  "encoding/json"
)


type ts_json_resp struct {
  Message string
  Timestamp int
}

var site  = flag.String("url", "url", "Provide the timestamp endpoint url")

func init() { 
  flag.StringVar(site, "u", "None", "Provide the timestamp endpoint url")
}


func main(){
  flag.Parse()

  if *site == "None"{
    myUsage()
  }

  var url string = *site
  testEndpoint(url)
}


func myUsage() {

  fmt.Printf("Usage: %s [OPTIONS] arguments ....\n", os.Args[0])
  flag.PrintDefaults()
  os.Exit(1)

}


func testEndpoint(site string) {
  //Make request
  resp, err := http.Get(site)

  if err != nil {
     log.Fatal("Unable to make request: ", err)
  }

  //Get statuscode
  status := resp.StatusCode
  fmt.Println("Endpoint is up with code:", status)

  //Read in JSON from response object
  buf := new(bytes.Buffer)
  buf.ReadFrom(resp.Body)
  var test_struct ts_json_resp
  json.Unmarshal(buf.Bytes(), &test_struct)
  
  //Validate message and display timestamp
  msg := "Dont let your dreams be dreams. Time:"
  if test_struct.Message == msg {
    fmt.Println("Message is correct")
    fmt.Println("message:",test_struct.Message)
  }
  fmt.Println("timestamp:",test_struct.Timestamp)
}

