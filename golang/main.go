package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"

	"gopkg.in/yaml.v2"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Activity struct {
	ID             uint       `json:"id"`
	Date           *time.Time `gorm:"type:date" json:"date,omitempty"`
	CompanyID      uint       `json:"companyId"`
	ActivityType   string     `json:"activityType"`
	NumberOfShares uint       `json:"numberOfShares"`
	TotalPrice     float32    `sql:"type:decimal(10,2)" json:"totalPrice"`
	CreatedAt      time.Time  `json:"createdAt"`
	UpdatedAt      time.Time  `json:"updatedAt"`
	Charges        *float32   `sql:"type:decimal(10,2)" json:"charges,omitempty"`
	UserID         uint       `json:"userId"`
	Notes          string     `json:"notes"`
}

func connectDB() (*gorm.DB, error) {
	yamlFile, err := ioutil.ReadFile("../config/database.yml")
	if err != nil {
		return nil, err
	}

	var database struct {
		Development struct {
			Hostname string `yaml:"hostname"`
			Username string `yaml:"username"`
			Dbname   string `yaml:"database"`
			Password string `yaml:"password"`
		} `yaml:"development"`
	}

	err = yaml.Unmarshal(yamlFile, &database)
	if err != nil {
		return nil, err
	}

	connectionString := fmt.Sprintf(
		"postgres://%s:5432/%s?user=%s&password=%s&sslmode=disable",
		database.Development.Hostname,
		database.Development.Dbname,
		database.Development.Username,
		database.Development.Password)

	db, err := gorm.Open(postgres.New(postgres.Config{DSN: connectionString}), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	return db, nil
}

func activities(w http.ResponseWriter, r *http.Request) {
	db, err := connectDB()
	if err != nil {
		fmt.Fprint(w, err)
		return
	}

	var activities []Activity
	db.Find(&activities)
	jsonData, err := json.Marshal(activities)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonData)
}

func main() {

	http.HandleFunc("/activities", activities)
	http.ListenAndServe(":8080", nil)
}
