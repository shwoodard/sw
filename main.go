package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"os"
	"path"

	"gopkg.in/yaml.v2"
)

var (
	staticAppPath = flag.String("static", "", "The path to the static site content. For Dev only.")
	meals         = []*meal{}
)

const publicMealsYAMLURL = "https://raw.githubusercontent.com/shwoodard/sw/gh-pages/data/meals.yaml"

type AppEnv int

const (
	Dev AppEnv = iota
	Prod
)

var appEnv AppEnv

type meal struct {
	Kind        string   `yaml:"kind" json:"kind"`
	Day         string   `yaml:"day" json:"day"`
	Date        string   `yaml:"date" json:"date"`
	Time        string   `yaml:"time" json:"time"`
	Title       string   `yaml:"title" json:"title"`
	Ingredients string   `yaml:"ingredients" json:"ingredients"`
	Hunger      string   `yaml:"hunger" json:"hunger"`
	Situation   string   `yaml:"situation" json:"situation"`
	Images      []string `yaml:"images" json:"images"`
	Comments    string   `yaml:"comments" json:"comments"`
}

type mealsHandler struct{}

func (*mealsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	jsonData, err := json.Marshal(meals)
	if err != nil {
		log.Printf("Failed to marshal json for food.yaml: %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonData)
}

func main() {
	flag.Parse()

	switch env := os.Getenv("APPENV"); env {
	case "PROD":
		appEnv = Prod
	default:
		appEnv = Dev
	}

	var mealsData []byte
	if *staticAppPath == "" {
		if appEnv == Dev {
			log.Print("Attempting to fetch public meals data in Dev, discouraged.")
		}

		resp, err := http.Get(publicMealsYAMLURL)
		if err != nil {
			log.Fatalf("Failed to fetch prod food data: %v", err)
		}

		mealsData, err = ioutil.ReadAll(resp.Body)
		if err != nil {
			log.Fatalf("Failed to read prod food data: %v", err)
		}
	} else {
		var err error

		if appEnv == Prod {
			log.Fatal("Local data path provided but it is unavialable in prod.")
		}

		mealsData, err = ioutil.ReadFile(path.Join(*staticAppPath, "data", "meals.yaml"))
		if err != nil {
			log.Fatalf("Failed to read prod food data: %v", err)
		}
	}

	if err := yaml.Unmarshal(mealsData, &meals); err != nil {
		log.Fatalf("Failed to parse meal data YAML: %v", err)
	}

	port := os.Getenv("PORT")
	if port == "" {
		log.Fatal("Env var PORT is required, exiting")
	}

	http.Handle("/meals", &mealsHandler{})
	http.ListenAndServe(net.JoinHostPort("", port), nil)
}
