package main

import "os"
import "io"
import "time"
import "github.com/gin-gonic/gin"
import "github.com/gin-contrib/cors"

//Timestamp endpoint
func v1_timestamp(c *gin.Context) {
	timestamp := time.Now().Unix() 
	c.JSON(200, gin.H{"message": "Dont let your dreams be dreams. Time:", "timestamp": timestamp,})
}

func setupRouter() *gin.Engine {
	f, _ := os.Create("api.log")
	gin.DefaultWriter = io.MultiWriter(f, os.Stdout)
	gin.SetMode(gin.ReleaseMode)
	r := gin.New()
	r.Use(gin.Logger())
	r.Use(gin.Recovery())
	r.Use(cors.Default()) 
	r.GET("/timestamp", v1_timestamp)
	return r
}

func main() {
	r := setupRouter()
	r.Run(":8080")
}
