package main

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

var client *mongo.Client

func main() {
	var err error
	client, err = mongo.Connect(options.Client().ApplyURI("mongodb://localhost:27017"))
	if err != nil {
		log.Fatalf("Error connecting to MongoDB: %v", err)
	}

	r := gin.Default()
	r.POST("/find", find)
	r.Run("localhost:8080")
}

type FindRequest struct {
	Database   string         `json:"database" binding:"required"`
	Collection string         `json:"collection" binding:"required"`
	Query      map[string]any `json:"query"`
}

func find(c *gin.Context) {
	var req FindRequest
	if err := c.Bind(&req); err != nil {
		c.Error(err)
		return
	}

	coll := client.Database(req.Database).Collection(req.Collection)
	cursor, err := coll.Find(c.Request.Context(), req.Query)
	if err != nil {
		c.Error(err)
		return
	}

	var res []bson.D
	err = cursor.All(c.Request.Context(), &res)
	if err != nil {
		c.Error(err)
		return
	}

	c.JSON(http.StatusOK, res)
}
