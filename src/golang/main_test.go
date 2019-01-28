package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"github.com/stretchr/testify/assert"
	"encoding/json"
	"bytes"
)

type ts_json_resp struct {
	Message string
	Timestamp int
}

func TestTimestampRoute(t *testing.T) {
	//Create test instance of router
	router := setupRouter()

	//Make request
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/timestamp", nil)
	router.ServeHTTP(w, req)
	
	//Make assertions
	assert.Equal(t, 200, w.Code)
	assert.Contains(t, w.Body.String(),"Dont let your dreams be dreams. Time:")

	//Example JSON response parsing for our last assertion
	buf := new(bytes.Buffer)
	buf.ReadFrom(w.Body)
	var test_struct ts_json_resp
	json.Unmarshal(buf.Bytes(), &test_struct)
	x := 11111111 //TypeOf needs this

	//Make sure our timestamp is actually an int like we expect
	assert.IsType(t, x, test_struct.Timestamp)
}
