package main

import "net/http"

func main() {
  port := os.Geteng("PORT")

  http.ListenAndServe(fmt.Sprint(":", port), func (w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Hello world!"))
  })
}
